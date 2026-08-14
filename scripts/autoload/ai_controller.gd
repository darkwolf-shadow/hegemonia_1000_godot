extends Node

func run_ai_turn():
	for faction_name in GameState.state.factions.keys():
		if faction_name == GameState.state.player_faction:
			continue
		if faction_name == "Terra di Nessuno":
			continue
		if GameState.state.factions[faction_name].get("is_neutral", false):
			continue
		make_decisions(faction_name)


func make_decisions(faction_name: String):
	var faction = GameState.state.factions[faction_name]
	var gold = faction.get("resources", {}).get("oro", 0)
	var attitude = faction.get("attitude", "balanced")

	# Difesa se oro basso
	if gold < 1000:
		defend(faction)
		return

	if attitude == "aggressive":
		attack_weakest_neighbor(faction_name)
	elif attitude == "balanced":
		if randf() < 0.5:
			attack_weakest_neighbor(faction_name)
		else:
			develop(faction)
	else:
		defend(faction)

	develop(faction)


func attack_weakest_neighbor(faction_name: String):
	var owned = []
	for p in GameState.state.provinces.keys():
		if GameState.state.provinces[p].get("owner") == faction_name:
			owned.append(p)

	for p in owned:
		var neighbors = WorldData.get_province(p).get("neighbors", [])
		for n in neighbors:
			var neighbor_owner = GameState.state.provinces.get(n, {}).get("owner", "")
			if neighbor_owner != faction_name and neighbor_owner != "Terra di Nessuno":
				if _faction_strength(faction_name) > _faction_strength(neighbor_owner) * 0.8:
					GameState.push_event("%s attacca %s di %s" % [faction_name, n, neighbor_owner])
					return


func _faction_strength(name: String) -> float:
	var faction = GameState.state.factions.get(name, {})
	var units = faction.get("units", {})
	var strength = 0.0
	for unit_type in units.keys():
		var count = units[unit_type]
		var unit_data = WorldData.get_unit(unit_type)
		strength += count * unit_data.get("strength", 1.0)
	var ships = faction.get("ships", {})
	for ship_type in ships.keys():
		var count = ships[ship_type]
		var ship_data = WorldData.get_ship(ship_type)
		strength += count * ship_data.get("strength", 0.5)
	return strength


func develop(faction: Dictionary):
	var res = faction.get("resources", {})
	res["oro"] = res.get("oro", 0) + 50


func defend(faction: Dictionary):
	var res = faction.get("resources", {})
	res["oro"] = res.get("oro", 0) + 10


func choose_battle_tactic() -> String:
	var t = ["standard", "charge", "shield_wall", "skirmish"]
	return t[randi() % t.size()]
