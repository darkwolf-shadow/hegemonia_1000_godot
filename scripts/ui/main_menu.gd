extends Control

@onready var faction_option := $VBoxContainer/FactionOption
@onready var start_button := $VBoxContainer/StartButton
@onready var load_button := $VBoxContainer/LoadButton
@onready var catalog_button := $VBoxContainer/CatalogButton
@onready var exit_button := $VBoxContainer/ExitButton
@onready var vbox := $VBoxContainer


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
	var test_button := Button.new()
	test_button.text = "Battaglia di prova"
	test_button.pressed.connect(_on_test_battle)
	vbox.add_child(test_button)
	vbox.move_child(test_button, exit_button.get_index())


func _on_test_battle():
	var faction := "Impero Bizantino"
	GameState.new_game(faction)
	GameState.set_pending_battle({
		"attacker": faction,
		"defender": "Califfato Fatimide",
		"province": "Nicea",
		"attacker_units": {"fanteria": 2, "arcieri": 1, "cavalleria": 1},
		"defender_units": {"fanteria": 2, "arcieri": 1, "cavalleria": 1}
	})
	get_tree().change_scene_to_file("res://scenes/battle_view.tscn")


func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()


func _on_exit():
	get_tree().quit()
