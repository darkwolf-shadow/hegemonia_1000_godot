# Dark Corporation / Stev
# Scena agglomerato - griglia di slot vuoti, catalogo costruzioni e livelli
extends Control

@onready var title_label: Label = $Panel/Title
@onready var buildings_list: ItemList = $Panel/BuildingsList
@onready var info_label: Label = $Panel/Info
@onready var panel: Panel = $Panel
@onready var back_button: Button = $Panel/BackButton
@onready var settlement_map: Control = $Panel/SettlementMap

var current_province: String = ""
var current_settlement: String = ""
var _recruitment_view: Control

var _catalog_popup: PopupPanel
var _catalog_list: ItemList
var _catalog_info: Label
var _catalog_button: Button
var _available_buildings: Array = []
var _selected_slot: int = -1


func _ready():
	back_button.pressed.connect(_on_back)
	UiHelper.style_button(back_button)
	_add_recruitment_button()
	_instantiate_recruitment_view()
	buildings_list.item_selected.connect(_on_building_list_selected)
	settlement_map.building_selected.connect(_on_map_building_selected)
	settlement_map.slot_selected.connect(_on_slot_selected)
	_configure_fullscreen_map()
	_create_catalog_popup()

	var prov = GameState.state.get("last_province", "")
	var sett = GameState.state.get("last_settlement", "")
	if not prov.is_empty() and not sett.is_empty():
		_open_settlement(prov, sett)
	elif not prov.is_empty():
		# Fallback: mostra info generiche della provincia
		_open_settlement(prov, prov)


func _configure_fullscreen_map():
	panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	settlement_map.set_anchors_preset(Control.PRESET_FULL_RECT)
	settlement_map.z_index = 0

	var sidebar := ColorRect.new()
	sidebar.name = "SidebarBG"
	sidebar.set_anchors_preset(Control.PRESET_FULL_RECT)
	sidebar.anchor_right = 0.35
	sidebar.offset_right = 0.0
	sidebar.color = Color(0.08, 0.06, 0.04, 0.92)
	sidebar.z_index = 1
	sidebar.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_child(sidebar)

	for node_path in ["Title", "BuildingsLabel", "BuildingsList", "Info", "BackButton", "RecruitmentButton"]:
		var n: Control = panel.get_node_or_null(NodePath(node_path))
		if n != null:
			n.z_index = 2


func _create_catalog_popup():
	_catalog_popup = PopupPanel.new()
	_catalog_popup.size = Vector2(520, 420)
	_catalog_popup.add_theme_stylebox_override("panel", UiHelper.parchment_stylebox(Color(0.84, 0.75, 0.60, 0.97)))

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 10
	vbox.offset_top = 10
	vbox.offset_right = -10
	vbox.offset_bottom = -10
	_catalog_popup.add_child(vbox)

	var title := Label.new()
	title.text = "Catalogo costruzioni"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(0.95, 0.80, 0.45))
	vbox.add_child(title)

	var hbox := HBoxContainer.new()
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(hbox)

	_catalog_list = ItemList.new()
	_catalog_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_catalog_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_catalog_list.item_selected.connect(_on_catalog_item_selected)
	hbox.add_child(_catalog_list)

	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_child(right)

	_catalog_info = Label.new()
	_catalog_info.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_catalog_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_catalog_info.text = "Seleziona un edificio per i dettagli."
	right.add_child(_catalog_info)

	_catalog_button = Button.new()
	_catalog_button.text = "Costruisci"
	_catalog_button.disabled = true
	_catalog_button.pressed.connect(_on_catalog_build)
	right.add_child(_catalog_button)

	var close_button := Button.new()
	close_button.text = "Chiudi"
	close_button.pressed.connect(func(): _catalog_popup.hide())
	right.add_child(close_button)

	UiHelper.apply_parchment_theme(vbox)
	add_child(_catalog_popup)



func _open_settlement(province_name: String, settlement_name: String):
	current_province = province_name
	current_settlement = settlement_name

	var region := _get_region(province_name)
	var prov = GameState.state.provinces.get(province_name, {})
	SettlementManager.ensure_settlement(prov, settlement_name)
	var settlements = prov.get("settlements", {})
	var s = settlements.get(settlement_name, {})

	title_label.text = settlement_name

	_update_buildings_list(s, region)
	_update_info(s)

	if settlement_map and settlement_map.has_method("build_map"):
		settlement_map.build_map(s, region, province_name, settlement_name)


func _update_buildings_list(s: Dictionary, region: String):
	buildings_list.clear()
	var levels = s.get("building_levels", {})
	for b in s.get("buildings", []):
		var bdata = WorldData.get_building(b)
		var level = levels.get(b, 1)
		var text = bdata.get("name", b)
		if level > 1:
			text += " (Liv. %d)" % level
		var icon = IconManager.get_building_icon_masked(b, region)
		var idx = buildings_list.add_item(text, icon)
		buildings_list.set_item_metadata(idx, b)


func _update_info(s: Dictionary):
	info_label.text = "Tipo: %s\nPopolazione: %d\nEdifici: %d" % [
		_translate_type(s.get("type", "civil")),
		int(s.get("population", 0)),
		s.get("buildings", []).size()
	]


func _get_region(province_name: String) -> String:
	var owner: String = GameState.state.provinces.get(province_name, {}).get("owner", "")
	if owner.is_empty():
		return "european"
	if IconManager and IconManager.has_method("region_for_faction"):
		return IconManager.region_for_faction(owner)
	return "european"


func _on_building_list_selected(index: int):
	var id: String = str(buildings_list.get_item_metadata(index))
	settlement_map.select_building(id)
	_show_building_info(id)


func _on_map_building_selected(id: String):
	for i in range(buildings_list.item_count):
		if str(buildings_list.get_item_metadata(i)) == id:
			buildings_list.select(i)
			break
	_show_building_info(id)


func _on_slot_selected(slot_index: int, building_id: String):
	_selected_slot = slot_index
	if building_id.is_empty():
		_open_build_catalog(slot_index)
	else:
		_show_building_info(building_id, true)


func _show_building_info(id: String, allow_upgrade: bool = false):
	var bdata = WorldData.get_building(id)
	if bdata.is_empty():
		info_label.text = "Edificio: " + id
		return

	var prov = GameState.state.provinces.get(current_province, {})
	var s = prov.get("settlements", {}).get(current_settlement, {})
	var level = s.get("building_levels", {}).get(id, 1)
	var text = "Edificio: %s\nLivello: %d" % [bdata.get("name", id), level]
	text += "\nEffetti: " + _effects_text(bdata.get("effects", {}))
	if allow_upgrade:
		if level < 4:
			var cost = SettlementManager._upgrade_cost(bdata, level + 1)
			text += "\n\nCosto miglioramento (Liv. %d): %s" % [level + 1, _cost_text(cost)]
			# Aggiungi pulsante di miglioramento temporaneo
			_add_upgrade_button(id)
		else:
			text += "\n\nLivello massimo raggiunto."
	info_label.text = text


func _get_building_level(building_id: String) -> int:
	var province = GameState.state.provinces.get(current_province, {})
	var s = province.get("settlements", {}).get(current_settlement, {})
	return s.get("building_levels", {}).get(building_id, 1)


func _effects_text(effects: Dictionary) -> String:
	var out := ""
	for r in effects.keys():
		if out != "":
			out += ", "
		out += "%s %+d" % [r, effects[r]]
	return out if out != "" else "nessuno"


func _cost_text(cost: Dictionary) -> String:
	var out := ""
	for r in cost.keys():
		if out != "":
			out += ", "
		out += "%s %d" % [r, cost[r]]
	return out


func _add_upgrade_button(building_id: String):
	# Rimuove eventuali pulsanti precedenti
	for child in panel.get_children():
		if child.name == "UpgradeButton":
			child.queue_free()

	var btn := Button.new()
	btn.name = "UpgradeButton"
	btn.text = "Migliora a Liv. " + str(_get_building_level(building_id) + 1)
	btn.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	btn.offset_left = 20
	btn.offset_top = -55
	btn.offset_right = 170
	btn.offset_bottom = -20
	btn.z_index = 3
	UiHelper.style_button(btn)
	btn.pressed.connect(func():
		_on_upgrade_building(building_id)
		btn.queue_free()
	)
	panel.add_child(btn)


func _on_upgrade_building(building_id: String):
	var faction = GameState.state.factions.get(GameState.state.player_faction, {})
	var province = GameState.state.provinces.get(current_province, {})
	if SettlementManager.upgrade_settlement_building(faction, province, current_settlement, building_id):
		_refresh_settlement()


func _open_build_catalog(slot_index: int):
	_selected_slot = slot_index
	_catalog_list.clear()
	_available_buildings.clear()

	var faction = GameState.state.factions.get(GameState.state.player_faction, {})
	var province = GameState.state.provinces.get(current_province, {})
	var s = province.get("settlements", {}).get(current_settlement, {})
	for b in WorldData.buildings.keys():
		if SettlementManager.can_build_settlement_building(faction, s, b):
			_available_buildings.append(b)
			var bdata = WorldData.get_building(b)
			var icon = IconManager.get_building_icon_masked(b, _get_region(current_province))
			_catalog_list.add_item(bdata.get("name", b), icon)

	_catalog_info.text = "Seleziona un edificio per i dettagli."
	_catalog_button.disabled = true
	_catalog_button.text = "Costruisci nello slot %d" % slot_index
	_catalog_popup.popup_centered()


func _on_catalog_item_selected(index: int):
	if index < 0 or index >= _available_buildings.size():
		return
	var id: String = _available_buildings[index]
	var bdata = WorldData.get_building(id)
	var text = "Edificio: %s\nCosto: %s\nEffetti: %s" % [
		bdata.get("name", id),
		_cost_text(bdata.get("cost", {})),
		_effects_text(bdata.get("effects", {}))
	]
	var unlocks: Array = bdata.get("unlocks_units", [])
	if unlocks.size() > 0:
		text += "\nSblocca unità: " + ", ".join(unlocks)
	_catalog_info.text = text
	_catalog_button.disabled = false
	_catalog_button.text = "Costruisci %s" % bdata.get("name", id)


func _on_catalog_build():
	var idx = _catalog_list.get_selected_items()
	if idx.size() == 0 or idx[0] < 0 or idx[0] >= _available_buildings.size():
		return
	var id: String = _available_buildings[idx[0]]
	var faction = GameState.state.factions.get(GameState.state.player_faction, {})
	var province = GameState.state.provinces.get(current_province, {})
	if SettlementManager.build_settlement_building(faction, province, current_settlement, id):
		_catalog_popup.hide()
		_refresh_settlement()


func _refresh_settlement():
	var region := _get_region(current_province)
	var province = GameState.state.provinces.get(current_province, {})
	var s = province.get("settlements", {}).get(current_settlement, {})
	_update_buildings_list(s, region)
	_update_info(s)
	if settlement_map and settlement_map.has_method("build_map"):
		settlement_map.build_map(s, region, current_province, current_settlement)


func _translate_type(type_name: String) -> String:
	match type_name.to_lower():
		"capital":
			return "Capitale"
		"military":
			return "Militare"
		"port":
			return "Porto"
		"industrial":
			return "Industriale"
		"civil":
			return "Civile"
		_:
			return type_name


func _add_recruitment_button():
	var recruit_button := Button.new()
	recruit_button.name = "RecruitmentButton"
	recruit_button.text = "Reclutamento"
	recruit_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	recruit_button.offset_left = -170.0
	recruit_button.offset_top = -50.0
	recruit_button.offset_right = -20.0
	recruit_button.offset_bottom = -15.0
	recruit_button.pressed.connect(_on_recruit)
	recruit_button.z_index = 3
	UiHelper.style_button(recruit_button)
	panel.add_child(recruit_button)


func _instantiate_recruitment_view():
	var view_scene := preload("res://scenes/settlement_view.tscn")
	_recruitment_view = view_scene.instantiate()
	add_child(_recruitment_view)


func _on_recruit():
	if _recruitment_view == null or current_province.is_empty() or current_settlement.is_empty():
		return
	var province = GameState.state.provinces.get(current_province, {})
	SettlementManager.ensure_settlement(province, current_settlement)
	_recruitment_view.open(current_province, current_settlement)


func _on_back():
	get_tree().change_scene_to_file("res://scenes/province_scene.tscn")


func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if _catalog_popup != null and _catalog_popup.visible:
			_catalog_popup.hide()
		else:
			_on_back()
