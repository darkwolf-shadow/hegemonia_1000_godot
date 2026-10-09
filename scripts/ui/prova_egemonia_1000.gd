extends Control
# Menu di prova di Egemonia 1000 - accesso rapido a tutte le scene
# Dark Corporation / Stev

@onready var _container: VBoxContainer = $VBoxContainer

const SCENES := {
	"Mappa (test bypass)": "res://scenes/test_map.tscn",
	"Mappa (controller)": "res://scenes/strategic_map_3d.tscn",
	"Provincia 3D": "res://scenes/province_scene_3d.tscn",
	"Provincia dati 2D": "res://scenes/province_scene.tscn",
	"Agglomerato urbano": "res://scenes/settlement_scene_3d.tscn",
	"Battaglia": "res://scenes/battle_view_3d.tscn",
	"Reclutamento": "res://scenes/catalog_scene.tscn",
	"Rendering edifici e unita'": "res://scenes/render_view.tscn",
}

func _ready():
	for name in SCENES:
		var btn := Button.new()
		btn.text = name
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		btn.pressed.connect(_on_scene_selected.bind(SCENES[name]))
		btn.add_theme_font_size_override("font_size", 24)
		_container.add_child(btn)
	
	var exit_btn := Button.new()
	exit_btn.text = "Esci"
	exit_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	exit_btn.pressed.connect(_on_exit)
	exit_btn.add_theme_font_size_override("font_size", 24)
	_container.add_child(exit_btn)

func _on_scene_selected(path: String):
	# La modalita' prova non consuma risorse per visualizzare gli edifici
	GameState.state["render_test_mode"] = path == "res://scenes/settlement_scene_3d.tscn"
	get_tree().change_scene_to_file(path)

func _on_exit():
	get_tree().quit()
