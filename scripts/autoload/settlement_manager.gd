extends Node


func get_settlements(province: Dictionary) -> Dictionary:
	return province.get("settlements", {})


func has_settlement(province: Dictionary, settlement_name: String) -> bool:
	return province.get("settlements", {}).has(settlement_name)


func get_settlement(province: Dictionary, settlement_name: String) -> Dictionary:
	return province.get("settlements", {}).get(settlement_name, {})


func list_faction_settlements(faction_name: String) -> Array:
	var out := []
	for prov_name in GameState.state.provinces.keys():
		var prov = GameState.state.provinces[prov_name]
		if prov.get("owner") == faction_name:
			for s_name in prov.get("settlements", {}).keys():
				var s = prov["settlements"][s_name]
				out.append({"province": prov_name, "settlement_name": s_name, "settlement": s})
	return out


func allowed_buildings(settlement_type: String) -> Array:
	var st = WorldData.config.get("settlement_types", {}).get(settlement_type, {})
	return st.get("allowed_buildings", [])


func can_build_settlement_building(faction: Dictionary, settlement: Dictionary, building_type: String) -> bool:
	var building = WorldData.get_building(building_type)
	if building.is_empty():
		return false

	var stype = settlement.get("type", "")
	var allowed = building.get("settlement_types", [])
	if stype not in allowed:
		return false

	var current = settlement.get("buildings", [])
	if building_type in current:
		return false

	# Prerequisiti: edifici richiesti dalla catena (se presenti in config)
	for req in building.get("requires", []):
		if req not in current:
			return false

	# Risorse della fazione
	if not EconomyEngine.can_build(faction, building_type):
		return false

	return true


func build_settlement_building(faction: Dictionary, province: Dictionary, settlement_name: String, building_type: String) -> bool:
	var settlement = get_settlement(province, settlement_name)
	if settlement.is_empty():
		return false
	if not can_build_settlement_building(faction, settlement, building_type):
		return false

	var building = WorldData.get_building(building_type)
	var res = faction.get("resources", {})
	for r in building.get("cost", {}).keys():
		res[r] = res.get(r, 0) - building["cost"][r]

	settlement["buildings"].append(building_type)
	return true


func can_recruit_in_settlement(faction: Dictionary, settlement: Dictionary, unit_type: String, amount: int = 1) -> bool:
	var unit = WorldData.get_unit(unit_type)
	if unit.is_empty():
		return false

	# Fazione consentita?
	var allowed_factions = unit.get("factions", [])
	if allowed_factions.size() > 0 and faction.get("name", "") not in allowed_factions:
		return false

	# Edifici necessari presenti nell'insediamento
	var current = settlement.get("buildings", [])
	for req in unit.get("requires_buildings", []):
		if req not in current:
			return false

	# Risorse
	if not EconomyEngine.can_recruit(faction, unit_type, amount):
		return false

	return true


func recruit_in_settlement(faction: Dictionary, settlement: Dictionary, unit_type: String, amount: int = 1) -> bool:
	if not can_recruit_in_settlement(faction, settlement, unit_type, amount):
		return false

	var unit = WorldData.get_unit(unit_type)
	var res = faction.get("resources", {})
	res["oro"] = res.get("oro", 0) - unit.get("cost", 0) * amount
	for r in ["legname", "pietra", "ferro", "armi"]:
		if unit.get(r, 0) > 0:
			res[r] = res.get(r, 0) - unit[r] * amount

	var pop_cost = unit.get("pop", 0) * amount
	settlement["population"] = max(0, settlement.get("population", 0) - pop_cost)

	var units = faction.get("units", {})
	units[unit_type] = units.get(unit_type, 0) + amount
	return true


func get_recruitable_units(faction: Dictionary, settlement: Dictionary) -> Array:
	var out := []
	for unit_type in WorldData.units.keys():
		if can_recruit_in_settlement(faction, settlement, unit_type, 1):
			out.append(unit_type)
	return out


func get_buildable_buildings(faction: Dictionary, settlement: Dictionary) -> Array:
	var out := []
	for b in WorldData.buildings.keys():
		if can_build_settlement_building(faction, settlement, b):
			out.append(b)
	return out


func production_for_faction(faction_name: String) -> Dictionary:
	var prod := {}
	# Produzione base della fazione
	var faction = GameState.state.factions.get(faction_name, {})
	var base = faction.get("production", {})
	for r in base.keys():
		prod[r] = prod.get(r, 0) + base[r]

	# Risorse delle province e edifici negli insediamenti
	for prov_name in GameState.state.provinces.keys():
		var prov = GameState.state.provinces[prov_name]
		if prov.get("owner") != faction_name:
			continue

		for r in prov.get("resources", {}).keys():
			prod[r] = prod.get(r, 0) + prov["resources"][r]

		for s_name in prov.get("settlements", {}).keys():
			var s = prov["settlements"][s_name]
			for b in s.get("buildings", []):
				var data = WorldData.get_building(b)
				for eff in data.get("effects", {}).keys():
					if eff in WorldData.config.get("resources", []):
						prod[eff] = prod.get(eff, 0) + data["effects"][eff]
	return prod
