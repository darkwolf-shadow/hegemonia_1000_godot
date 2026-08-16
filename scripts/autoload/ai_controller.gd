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


func choose_battle_tactic(battle: Dictionary = {}, side: String = "") -> String:
	if battle.is_empty() or side.is_empty():
		var t = ["standard", "charge", "shield_wall", "skirmish"]
		return t[randi() % t.size()]

	var my_units = battle.attacker_units if side == "attacker" else battle.defender_units
	var enemy_units = battle.defender_units if side == "attacker" else battle.attacker_units
	var my_morale = battle.attacker_morale if side == "attacker" else battle.defender_morale
	var enemy_morale = battle.defender_morale if side == "attacker" else battle.attacker_morale

	var total := 0
	var cavalry := 0
	var ranged := 0
	var infantry := 0
	var elephants := 0
	for unit_type in my_units.keys():
		var count = my_units[unit_type]
		total += count
		if _is_cavalry(unit_type):
			cavalry += count
		elif _is_ranged(unit_type):
			ranged += count
		elif _is_elephant(unit_type):
			elephants += count
		else:
			infantry += count

	if total == 0:
		return "standard"

	var my_count: int = _count_units(my_units)
	var enemy_count: int = _count_units(enemy_units)
	var outnumbered: bool = enemy_count > int(my_count * 1.2)

	# Cavalleria numerosa e morale alto: carica
	if float(cavalry) / total >= 0.35 and my_morale >= enemy_morale * 0.9:
		return "charge"

	# Molti arcieri e nemico non troppo vicino: schermaglia
	if float(ranged) / total >= 0.4 and enemy_morale > 0:
		return "skirmish"

	# Fanteria pesante e superato numericamente o morale basso: muro di scudi
	if (outnumbered and side == "defender") or (float(infantry) / total >= 0.6 and my_morale < enemy_morale):
		return "shield_wall"

	# Elefanti
	if float(elephants) / total >= 0.25:
		return "elephant_charge"

	return "standard"


func _is_cavalry(unit_type: String) -> bool:
	var key := unit_type.to_lower()
	return key.contains("caval") or key.contains("cataphract") or key.contains("mamluk") or key.contains("ghilman") or key.contains("ghulam") or key.contains("lancer") or key.contains("drak") or key.contains("druzhina") or key.contains("jinete") or key.contains("magyar") or key.contains("horse") or key.contains("soninke")


func _is_ranged(unit_type: String) -> bool:
	var key := unit_type.to_lower()
	return key.contains("arcier") or key.contains("archer") or key.contains("crossbow") or key.contains("balestri") or key.contains("toxot") or key.contains("shenbi") or key.contains("atlatl") or key.contains("javelin")


func _is_elephant(unit_type: String) -> bool:
	var key := unit_type.to_lower()
	return key.contains("elephant") or key.contains("war_elephants") or key.contains("elephant_corps") or key.contains("khmer_elephants")


func _count_units(units: Dictionary) -> int:
	var n := 0
	for k in units.keys():
		n += units[k]
	return n
