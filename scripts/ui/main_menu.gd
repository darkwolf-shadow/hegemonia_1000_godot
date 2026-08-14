extends Control

@onready var faction_option := $VBoxContainer/FactionOption
@onready var start_button := $VBoxContainer/StartButton
@onready var load_button := $VBoxContainer/LoadButton
@onready var exit_button := $VBoxContainer/ExitButton


func _ready():
	start_button.pressed.connect(_on_start)
	load_button.pressed.connect(_on_load)
	exit_button.pressed.connect(_on_exit)


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


func _on_exit():
	get_tree().quit()
