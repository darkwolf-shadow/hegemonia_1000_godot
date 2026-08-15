extends Control

@onready var tab_container: TabContainer = $TabContainer
@onready var back_button: Button = $BackButton

var _icon_size := Vector2(64, 64)

func _ready():
	back_button.pressed.connect(_on_back)
	_build_tabs()


func _build_tabs():
	_clear_tabs()
	_add_list_tab("Edifici", WorldData.buildings.keys(), "building")
	_add_list_tab("Unità", WorldData.units.keys(), "unit")
	_add_list_tab("Navi", WorldData.ships.keys(), "ship")
	_add_list_tab("Risorse", WorldData.config.get("resources", []), "resource")
	_add_list_tab("Aglomerati", WorldData.settlement_types.keys(), "settlement")


func _clear_tabs():
	while tab_container.get_tab_count() > 0:
		var child = tab_container.get_tab_control(0)
		tab_container.remove_child(child)
		child.queue_free()


func _add_list_tab(title: String, ids: Array, category: String):
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
		icon.texture = _get_icon(category, id)

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


func _get_icon(category: String, id: String) -> Texture2D:
	match category:
		"building":
			return IconManager.get_building_icon(id)
		"unit":
			return IconManager.get_unit_icon(id)
		"ship":
			return IconManager.get_ship_icon(id)
		"resource":
			return IconManager.get_resource_icon(id)
		"settlement":
			return IconManager.get_settlement_icon(id)
		_:
			return null


func _on_back():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
