extends Control

@onready var tab_container: TabContainer = $TabContainer
@onready var back_button: Button = $BackButton
@onready var region_select: OptionButton = $RegionSelect

var _icon_size := Vector2(64, 64)
var _regions := ["", "european", "oriental", "asian", "indian", "african", "american"]
var _region_labels := ["Automatica", "Europea", "Orientale", "Asiatica", "Indiana", "Africana", "Americana"]

func _ready():
	back_button.pressed.connect(_on_back)
	for label in _region_labels:
		region_select.add_item(label)
	region_select.item_selected.connect(_on_region_changed)
	_build_tabs()


func _on_region_changed(_index: int):
	_build_tabs()


func _current_region() -> String:
	var idx := region_select.selected
	if idx < 0 or idx >= _regions.size():
		idx = 0
	return _regions[idx]


func _build_tabs():
	_clear_tabs()
	var region := _current_region()
	_add_list_tab("Edifici", WorldData.buildings.keys(), "building", region)
	_add_list_tab("Unità", WorldData.units.keys(), "unit", region)
	_add_list_tab("Navi", WorldData.ships.keys(), "ship", region)
	_add_list_tab("Risorse", WorldData.config.get("resources", []), "resource", region)
	_add_list_tab("Aglomerati", WorldData.settlement_types.keys(), "settlement", region)


func _clear_tabs():
	while tab_container.get_tab_count() > 0:
		var child = tab_container.get_tab_control(0)
		tab_container.remove_child(child)
		child.queue_free()


func _add_list_tab(title: String, ids: Array, category: String, region: String):
	var scroll := ScrollContainer.new()
	scroll.name = title
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var grid := GridContainer.new()
	grid.columns = 6
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)

	for id in ids:
		var icon := TextureRect.new()
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = _icon_size
		icon.size = _icon_size
		icon.texture = _get_icon(category, id, region)

		var label := Label.new()
		label.text = _get_name(category, id)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.custom_minimum_size = Vector2(96, 0)

		var box := VBoxContainer.new()
		box.custom_minimum_size = Vector2(112, 112)
		box.alignment = BoxContainer.ALIGNMENT_CENTER
		box.add_child(icon)
		box.add_child(label)
		grid.add_child(box)

	scroll.add_child(grid)
	tab_container.add_child(scroll)


func _get_name(category: String, id: String) -> String:
	match category:
		"building":
			return WorldData.get_building(id).get("name", id)
		"unit":
			return WorldData.get_unit(id).get("name", id)
		"ship":
			return WorldData.get_ship(id).get("name", id)
		"settlement":
			return WorldData.get_settlement_type(id).get("name", id)
		_:
			return id.capitalize()


func _get_icon(category: String, id: String, region: String) -> Texture2D:
	match category:
		"building":
			return IconManager.get_building_icon(id, region)
		"unit":
			return IconManager.get_unit_icon(id, region)
		"ship":
			return IconManager.get_ship_icon(id, region)
		"resource":
			return IconManager.get_resource_icon(id, region)
		"settlement":
			return IconManager.get_settlement_icon(id, region)
		_:
			return null


func _on_back():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
