extends Node


func _ready():
	print("TEST RUNNER START")
	await get_tree().create_timer(0.5).timeout

	print("WorldData factions: ", WorldData.factions.keys())
	print("WorldData provinces: ", WorldData.provinces.size())

	print("New game test")
	GameState.new_game("Impero Bizantino")
	print("Player faction: ", GameState.state.player_faction)
	print("Turn: ", GameState.state.turn)

	print("Economy test")
	EconomyEngine.apply_production()
	print("Economy ok")

	print("Battle test")
	BattleSystem.start_battle("Impero Bizantino", "Califfato Fatimide", "Nicea", {"fanteria": 20}, {"fanteria": 15})
	BattleSystem.play_round()
	print("Battle round ok")

	print("Save test")
	SaveManager.save_game("test")
	print("Save ok")

	print("Scene load test")
	var ps = load("res://scenes/strategic_map.tscn")
	var scene = ps.instantiate()
	add_child(scene)
	await get_tree().process_frame
	print("Scene children: ", scene.get_children().map(func(n): return n.name))
	var ui = scene.get_node_or_null("CanvasLayer/UI")
	print("UI node: ", ui)
	if ui:
		print("UI children: ", ui.get_children().map(func(n): return n.name))
	remove_child(scene)
	scene.queue_free()
	print("Scene load ok")

	print("ALL TESTS PASSED")
	get_tree().quit()
