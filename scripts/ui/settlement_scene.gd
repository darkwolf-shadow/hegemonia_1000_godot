# Dark Corporation / Stev
# Scena agglomerato urbano - gestione edifici e truppe
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


func _ready():
	back_button.pressed.connect(_on_back)
	_add_recruitment_button()
	_instantiate_recruitment_view()
	buildings_list.item_selected.connect(_on_building_list_selected)
	settlement_map.connect("building_selected", _on_map_building_selected)
	_configure_fullscreen_map()
	var prov = GameState.state.get("last_province", "")
	var sett = GameState.state.get("last_settlement", "")
	if not prov.is_empty() and not sett.is_empty():
		_open_settlement(prov, sett)
	elif not prov.is_empty():
		# Fallback: se non c'e' un settlement specifico, mostra info provincia
		title_label.text = prov
		var data = WorldData.get_province(prov)
		info_label.text = "Proprietario: %s\nRegione: %s\nTerreno: %s\nPopolazione: %d" % [
			GameState.state.provinces.get(prov, {}).get("owner", "N/D"),
			data.get("region", "N/D"),
			data.get("terrain", "N/D"),
			int(data.get("population", 0))
		]


func _configure_fullscreen_map():
	# Rendi la mappa a schermo intero con una barra laterale scura per i dati
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


func _open_settlement(province_name: String, settlement_name: String):
	current_province = province_name
	current_settlement = settlement_name
	title_label.text = settlement_name

	var region := _get_region(province_name)
	var prov = GameState.state.provinces.get(province_name, {})
	var settlements = prov.get("settlements", {})

	# Se il settlement esiste nei dati, mostra i suoi edifici
	if settlements is Dictionary and settlements.has(settlement_name):
		var s = settlements[settlement_name]
		buildings_list.clear()
		for b in s.get("buildings", []):
			var bdata = WorldData.get_building(b)
			var icon = IconManager.get_building_icon_masked(b, region)
			var idx = buildings_list.add_item(bdata.get("name", b), icon)
			buildings_list.set_item_metadata(idx, b)

		info_label.text = "Tipo: %s\nPopolazione: %d\nEdifici: %d" % [
			_translate_type(s.get("type", "civil")),
			int(s.get("population", 0)),
			s.get("buildings", []).size()
		]

		# Mappa dell'agglomerato con strade ed edifici
		if settlement_map and settlement_map.has_method("build_map"):
			settlement_map.build_map(s, region, province_name, settlement_name)
	else:
		# Fallback: mostra info generiche con icone e mappa
		var data = WorldData.get_province(province_name)
		buildings_list.clear()
		var idx1 = buildings_list.add_item("Centro urbano", IconManager.get_building_icon_masked("centro_cittadino", region))
		buildings_list.set_item_metadata(idx1, "centro_cittadino")
		var idx2 = buildings_list.add_item("Mercato", IconManager.get_building_icon_masked("mercato", region))
		buildings_list.set_item_metadata(idx2, "mercato")
		var idx3 = buildings_list.add_item("Caserma", IconManager.get_building_icon_masked("caserma_i", region))
		buildings_list.set_item_metadata(idx3, "caserma_i")
		info_label.text = "Tipo: Civile\nPopolazione: %d\nEdifici: 3 (predefiniti)" % [
			int(data.get("population", 0))
		]
		var fallback := {
			"type": "civil",
			"population": data.get("population", 0),
			"buildings": ["centro_cittadino", "mercato", "caserma_i"]
		}
		if settlement_map and settlement_map.has_method("build_map"):
			settlement_map.build_map(fallback, region, province_name, settlement_name)


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


func _show_building_info(id: String):
	var bdata = WorldData.get_building(id)
	if bdata.is_empty():
		info_label.text = "Edificio: " + id
		return
	info_label.text = "Edificio: %s\n%s" % [bdata.get("name", id), bdata.get("description", "")]


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
	panel.add_child(recruit_button)


func _instantiate_recruitment_view():
	var view_scene := preload("res://scenes/settlement_view.tscn")
	_recruitment_view = view_scene.instantiate()
	add_child(_recruitment_view)


func _on_recruit():
	if _recruitment_view == null or current_province.is_empty() or current_settlement.is_empty():
		return
	_recruitment_view.open(current_province, current_settlement)


func _on_back():
	get_tree().change_scene_to_file("res://scenes/province_scene.tscn")


func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file("res://scenes/province_scene.tscn")
