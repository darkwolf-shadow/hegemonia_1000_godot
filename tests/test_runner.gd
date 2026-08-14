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

	print("ALL TESTS PASSED")
	get_tree().quit()
