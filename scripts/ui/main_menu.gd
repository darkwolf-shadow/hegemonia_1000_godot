extends Control

@onready var faction_option := $VBoxContainer/FactionOption
@onready var start_button := $VBoxContainer/StartButton
@onready var load_button := $VBoxContainer/LoadButton
@onready var catalog_button := $VBoxContainer/CatalogButton
@onready var exit_button := $VBoxContainer/ExitButton
@onready var vbox := $VBoxContainer

var _side_option: OptionButton


func _ready():
	start_button.pressed.connect(_on_start)
	load_button.pressed.connect(_on_load)
	catalog_button.pressed.connect(_on_catalog)
	exit_button.pressed.connect(_on_exit)
	_popola_fazioni()
	_add_test_battle_button()


func _popola_fazioni():
	faction_option.clear()
	for nome in WorldData.factions.keys():
		if nome == "Terra di Nessuno":
			continue
		faction_option.add_item(nome)
	if faction_option.item_count > 0:
		faction_option.select(0)


func _on_start():
	var faction = faction_option.get_item_text(faction_option.selected)
	if faction.is_empty():
		faction = "Impero Bizantino"
	GameState.new_game(faction)
	get_tree().change_scene_to_file("res://scenes/strategic_map.tscn")


func _on_load():
	var slots = SaveManager.get_slots()
	if slots.size() > 0:
		SaveManager.load_game(slots[0])
		get_tree().change_scene_to_file("res://scenes/strategic_map.tscn")


func _on_catalog():
	get_tree().change_scene_to_file("res://scenes/catalog_scene.tscn")


func _add_test_battle_button():
	var label := Label.new()
	label.text = "Prova battaglia:"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label)
	vbox.move_child(label, exit_button.get_index())

	_side_option = OptionButton.new()
	_side_option.add_item("Attaccante (Impero Bizantino)")
	_side_option.add_item("Difensore (Califfato Fatimide)")
	vbox.add_child(_side_option)
	vbox.move_child(_side_option, exit_button.get_index())

	var test_button := Button.new()
	test_button.text = "Inizia battaglia di prova"
	test_button.pressed.connect(_on_test_battle)
	vbox.add_child(test_button)
	vbox.move_child(test_button, exit_button.get_index())


func _on_test_battle():
	var attacker_faction := "Impero Bizantino"
	var defender_faction := "Califfato Fatimide"
	var player_is_attacker := (_side_option.selected == 0)
	var province_name := _random_province()

	var player_faction := attacker_faction if player_is_attacker else defender_faction
	var enemy_faction := defender_faction if player_is_attacker else attacker_faction

	GameState.new_game(player_faction)
	GameState.set_pending_battle({
		"attacker": attacker_faction,
		"defender": defender_faction,
		"province": province_name,
		"attacker_units": {"fanteria": 2, "arcieri": 1, "cavalleria": 1},
		"defender_units": {"fanteria": 2, "arcieri": 1, "cavalleria": 1}
	})
	get_tree().change_scene_to_file("res://scenes/battle_view.tscn")


func _random_province() -> String:
	var keys: Array = WorldData.provinces.keys()
	keys.shuffle()
	for p in keys:
		var data: Dictionary = WorldData.get_province(p)
		var terrain = data.get("terrain", "")
		if not terrain.is_empty():
			return p
	return "Nicea"


func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()


func _on_exit():
	get_tree().quit()
