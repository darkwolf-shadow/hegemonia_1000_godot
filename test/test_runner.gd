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
	print("Strategic map scene load ok")

	print("Other scene load test")
	GameState.state["last_province"] = "Kalimantan Timur"
	var scenes = [
		"res://scenes/main_menu.tscn",
		"res://scenes/province_scene.tscn",
		"res://scenes/settlement_scene.tscn",
		"res://scenes/province_popup.tscn",
		"res://scenes/battle_view.tscn",
		"res://scenes/catalog_scene.tscn",
	]
	for path in scenes:
		var packed = load(path)
		var inst = packed.instantiate()
		add_child(inst)
		await get_tree().process_frame
		if inst.has_method("show_province"):
			inst.show_province("Kalimantan Timur")
		remove_child(inst)
		inst.queue_free()
		print(path, " ok")

	print("ALL TESTS PASSED")
	get_tree().quit()
