extends Node

signal battle_started(battle)
signal round_ended(report)
signal battle_ended(result)

var current_battle: Dictionary = {}


func start_battle(attacker: String, defender: String, province: String, attacker_units: Dictionary, defender_units: Dictionary):
	var att_faction = GameState.state.factions.get(attacker, {})
	var def_faction = GameState.state.factions.get(defender, {})
	current_battle = {
		"attacker": attacker,
		"defender": defender,
		"province": province,
		"attacker_units": attacker_units.duplicate(true),
		"defender_units": defender_units.duplicate(true),
		"attacker_morale": att_faction.get("base_morale", 100),
		"defender_morale": def_faction.get("base_morale", 100),
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

	var a_strength = calculate_side_strength(current_battle.attacker, current_battle.attacker_units, tactic_att, current_battle.attacker_morale)
	var d_strength = calculate_side_strength(current_battle.defender, current_battle.defender_units, tactic_def, current_battle.defender_morale)

	var terrain = WorldData.terrain_modifiers.get(current_battle.terrain, {})
	a_strength *= terrain.get("attack", 1.0)
	d_strength *= terrain.get("defense", 1.0)

	var roll_a = randf_range(0.85, 1.15)
	var roll_d = randf_range(0.85, 1.15)
	a_strength *= roll_a
	d_strength *= roll_d

	var result = "stalemate"
	var ratio = 1.0
	if a_strength > d_strength:
		ratio = a_strength / max(1.0, d_strength)
		result = "attacker"
	elif d_strength > a_strength:
		ratio = d_strength / max(1.0, a_strength)
		result = "defender"

	var raw_loss_pct = clamp(0.08 * (ratio - 0.5), 0.0, 0.35)

	if result == "attacker":
		apply_losses(current_battle.defender_units, raw_loss_pct)
		current_battle.defender_morale -= clamp(10 + (ratio - 1.0) * 15, 5, 35)
		current_battle.attacker_morale += 2
	elif result == "defender":
		apply_losses(current_battle.attacker_units, raw_loss_pct)
		current_battle.attacker_morale -= clamp(10 + (ratio - 1.0) * 15, 5, 35)
		current_battle.defender_morale += 2

	current_battle.attacker_morale = clamp(current_battle.attacker_morale, 0, 120)
	current_battle.defender_morale = clamp(current_battle.defender_morale, 0, 120)
	current_battle.attacker_ammo = max(0, current_battle.attacker_ammo - 5)
	current_battle.defender_ammo = max(0, current_battle.defender_ammo - 5)

	var report = {
		"round": current_battle.round,
		"result": result,
		"attacker_strength": a_strength,
		"defender_strength": d_strength,
		"attacker_morale": current_battle.attacker_morale,
		"defender_morale": current_battle.defender_morale,
	}
	round_ended.emit(report)

	if current_battle.attacker_morale <= 0 or current_battle.defender_morale <= 0 or current_battle.round >= 8:
		end_battle()
	return report


func calculate_side_strength(faction_name: String, units: Dictionary, tactic: String, morale: float) -> float:
	var strength = 0.0
	var tactic_mods = WorldData.tactics.get(tactic, {})
	var faction = GameState.state.factions.get(faction_name, {})
	var unit_exp = faction.get("unit_experience", {})
	for unit_type in units.keys():
		var count = units[unit_type]
		if count <= 0:
			continue
		var data = WorldData.get_unit(unit_type)
		var base = data.get("attack", data.get("strength", 1.0))
		var exp = unit_exp.get(unit_type, data.get("experience", 0))
		var exp_bonus = 1.0 + exp * 0.01
		var morale_factor = clamp(morale / 100.0, 0.2, 1.3)
		var tactic_bonus = tactic_mods.get(unit_type, 1.0)
		var speed_bonus = 1.0 + data.get("speed", 2.0) * 0.02
		strength += count * base * exp_bonus * morale_factor * tactic_bonus * speed_bonus
	return max(1.0, strength)


func apply_losses(units: Dictionary, raw_pct: float):
	for unit_type in units.keys():
		var count = units[unit_type]
		if count <= 0:
			continue
		var data = WorldData.get_unit(unit_type)
		var protection = data.get("defense", 0.0) + data.get("armor", 0.0)
		var pct = raw_pct / max(1.0, 1.0 + protection * 0.5)
		units[unit_type] = max(0, int(count * (1.0 - pct)))


func end_battle():
	if current_battle.is_empty():
		return
	var winner = "attacker"
	if current_battle.attacker_morale < current_battle.defender_morale:
		winner = "defender"
	elif current_battle.attacker_morale == current_battle.defender_morale:
		if randf() < 0.5:
			winner = "defender"

	_gain_experience(winner)

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


func _gain_experience(winner: String):
	var side_name = current_battle.attacker if winner == "attacker" else current_battle.defender
	var units_dict = current_battle.attacker_units if winner == "attacker" else current_battle.defender_units
	var faction = GameState.state.factions.get(side_name, {})
	var unit_exp = faction.get("unit_experience", {})
	for unit_type in units_dict.keys():
		if units_dict[unit_type] > 0:
			unit_exp[unit_type] = unit_exp.get(unit_type, 0) + 1
	faction["unit_experience"] = unit_exp
