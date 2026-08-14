extends Node

func apply_production():
	for faction_name in GameState.state.factions.keys():
		var faction = GameState.state.factions[faction_name]
		if faction.get("is_neutral", false):
			continue
		produce_resources(faction)
		pay_maintenance(faction)
		consume_food(faction)


func produce_resources(faction: Dictionary):
	var name = faction.get("name", "")
	var modifiers = faction.get("modifiers", {})
	var res = faction.get("resources", {})
	var prod = SettlementManager.production_for_faction(name)
	for r in prod.keys():
		var amount = prod[r]
		res[r] = res.get(r, 0) + int(amount * modifiers.get(r, 1.0))


func pay_maintenance(faction: Dictionary):
	var res = faction.get("resources", {})
	var costs = WorldData.config.get("maintenance", {})
	for unit_type in faction.get("units", {}).keys():
		var count = faction["units"][unit_type]
		res["oro"] = res.get("oro", 0) - count * costs.get(unit_type, 0)
	for ship_type in faction.get("ships", {}).keys():
		var count = faction["ships"][ship_type]
		res["oro"] = res.get("oro", 0) - count * costs.get(ship_type, 0)


func consume_food(faction: Dictionary):
	var res = faction.get("resources", {})
	var units = faction.get("units", {})
	var ships = faction.get("ships", {})
	var total_food = 0
	for unit_type in units.keys():
		var count = units[unit_type]
		var food_cost = WorldData.get_unit(unit_type).get("food", 0)
		total_food += count * food_cost
	for ship_type in ships.keys():
		var count = ships[ship_type]
		var food_cost = WorldData.get_ship(ship_type).get("food", 0)
		total_food += count * food_cost
	res["cibo"] = res.get("cibo", 0) - total_food
	if res["cibo"] < 0:
		push_warning("%s non ha abbastanza cibo" % faction.get("name", ""))
		res["cibo"] = 0


func can_recruit(faction: Dictionary, unit_type: String, amount: int) -> bool:
	var data = WorldData.get_unit(unit_type)
	var res = faction.get("resources", {})
	var cost = data.get("cost", 0) * amount
	if res.get("oro", 0) < cost:
		return false
	for r in ["legname", "pietra", "ferro", "armi"]:
		if data.get(r, 0) * amount > res.get(r, 0):
			return false
	return true


func can_build(faction: Dictionary, building_type: String) -> bool:
	var data = WorldData.get_building(building_type)
	var res = faction.get("resources", {})
	var cost = data.get("cost", {})
	for r in cost.keys():
		if res.get(r, 0) < cost[r]:
			return false
	return true
