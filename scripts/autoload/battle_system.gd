extends Node

signal battle_started(battle)
signal round_ended(report)
signal battle_ended(result)

var current_battle: Dictionary = {}


func start_battle(attacker: String, defender: String, province: String, attacker_units: Dictionary, defender_units: Dictionary):
	current_battle = {
		"attacker": attacker,
		"defender": defender,
		"province": province,
		"attacker_units": attacker_units.duplicate(true),
		"defender_units": defender_units.duplicate(true),
		"attacker_morale": 100,
		"defender_morale": 100,
		"attacker_ammo": 100,
		"defender_ammo": 100,
		"round": 0,
		"terrain": GameState.state.provinces.get(province, {}).get("terrain", "plains"),
	}
	battle_started.emit(current_battle)


func play_round(tactic_att: String = "standard", tactic_def: String = "standard"):
	if current_battle.is_empty():
		return
	current_battle.round += 1
	var a_strength = calculate_strength(current_battle.attacker_units, tactic_att)
	var d_strength = calculate_strength(current_battle.defender_units, tactic_def)

	# Modificatori del terreno
	var terrain = WorldData.terrain_modifiers.get(current_battle.terrain, {})
	a_strength *= terrain.get("attack", 1.0)
	d_strength *= terrain.get("defense", 1.0)

	# Fattore casuale
	var roll_a = randf_range(0.85, 1.15)
	var roll_d = randf_range(0.85, 1.15)
	a_strength *= roll_a
	d_strength *= roll_d

	var result = "stalemate"
	if a_strength > d_strength * 1.1:
		result = "attacker"
		apply_losses(current_battle.defender_units, 0.12)
		current_battle.defender_morale -= 15
	elif d_strength > a_strength * 1.1:
		result = "defender"
		apply_losses(current_battle.attacker_units, 0.12)
		current_battle.attacker_morale -= 15

	current_battle.attacker_ammo = max(0, current_battle.attacker_ammo - 5)
	current_battle.defender_ammo = max(0, current_battle.defender_ammo - 5)

	var report = {
		"round": current_battle.round,
		"result": result,
		"attacker_strength": a_strength,
		"defender_strength": d_strength,
	}
	round_ended.emit(report)

	if current_battle.attacker_morale <= 0 or current_battle.defender_morale <= 0 or current_battle.round >= 5:
		end_battle()
	return report


func calculate_strength(units: Dictionary, tactic: String) -> float:
	var strength = 0.0
	var tactic_mods = WorldData.tactics.get(tactic, {})
	for unit_type in units.keys():
		var count = units[unit_type]
		var base = WorldData.get_unit(unit_type).get("strength", 1.0)
		var bonus = tactic_mods.get(unit_type, 1.0)
		strength += count * base * bonus
	return max(1.0, strength)


func apply_losses(units: Dictionary, pct: float):
	for unit_type in units.keys():
		units[unit_type] = max(0, int(units[unit_type] * (1.0 - pct)))


func end_battle():
	if current_battle.is_empty():
		return
	var winner = "attacker"
	if current_battle.attacker_morale < current_battle.defender_morale:
		winner = "defender"

	var result = {
		"winner": winner,
		"province": current_battle.province,
		"attacker": current_battle.attacker,
		"defender": current_battle.defender,
	}

	if winner == "attacker" and GameState.state.provinces.has(current_battle.province):
		GameState.state.provinces[current_battle.province]["owner"] = current_battle.attacker

	battle_ended.emit(result)
	GameState.push_event("Battaglia finita: vince %s a %s" % [winner, current_battle.province])
	current_battle = {}
