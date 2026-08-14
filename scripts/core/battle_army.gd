class_name BattleArmy

var faction_name: String
var units: Dictionary
var morale: int = 100
var ammo: int = 100

func _init(faction: String, starting_units: Dictionary):
	faction_name = faction
	units = starting_units.duplicate()


func total_strength(tactic_mods: Dictionary = {}, unit_stats: Dictionary = {}) -> float:
	var strength := 0.0
	for unit_type in units.keys():
		var count = units[unit_type]
		var base = unit_stats.get(unit_type, {}).get("strength", 1.0)
		var bonus = tactic_mods.get(unit_type, 1.0)
		strength += count * base * bonus
	return max(1.0, strength)


func apply_losses(pct: float):
	for unit_type in units.keys():
		units[unit_type] = max(0, int(units[unit_type] * (1.0 - pct)))
