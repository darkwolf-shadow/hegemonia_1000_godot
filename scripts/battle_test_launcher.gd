extends Node2D
# Avvia direttamente la scena di battaglia per test visivo
# Dark Corporation / Stev

func _ready():
	# Inizializza il gioco con la fazione del giocatore
	GameState.new_game("Impero Bizantino")
	# Imposta la battaglia di prova con unita' numerose
	GameState.set_pending_battle({
		"attacker": "Impero Bizantino",
		"defender": "Impero Fatimide",
		"province": "Nicea",
		"attacker_units": {
			"fanteria": 3,
			"arcieri": 2,
			"cavalleria": 2,
			"cavalleria_pesante": 1,
			"cataphractoi": 1
		},
		"defender_units": {
			"fanteria": 3,
			"arcieri": 2,
			"cavalleria": 2,
			"milizia": 2,
			"war_elephants": 1
		}
	})
	# Passa direttamente alla scena di battaglia 3D (deferred per evitare conflitti)
	call_deferred("_change_to_battle")


func _change_to_battle():
	get_tree().change_scene_to_file("res://scenes/battle_view_3d.tscn")
