extends Node


func get_settlements(province: Dictionary) -> Dictionary:
	return province.get("settlements", {})


func has_settlement(province: Dictionary, settlement_name: String) -> bool:
	return province.get("settlements", {}).has(settlement_name)


func get_settlement(province: Dictionary, settlement_name: String) -> Dictionary:
	return province.get("settlements", {}).get(settlement_name, {})


func ensure_settlement(province: Dictionary, settlement_name: String, type_name: String = "civil"):
	if not province.has("settlements") or province["settlements"] == null:
		province["settlements"] = {}
	if not province["settlements"].has(settlement_name):
		var pop = int(province.get("population", 0) / 10)
		if pop <= 0:
			pop = 1000
		province["settlements"][settlement_name] = {
			"name": settlement_name,
			"type": type_name,
			"population": pop,
			"buildings": ["centro_cittadino"],
			"building_levels": {"centro_cittadino": 1}
		}


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

	# Prerequisiti: edifici richiesti dall'albero tecnologico
	for req in building.get("requires", []):
		if req not in current:
			return false

	# Slot disponibili nel settlement
	var stype_data = WorldData.get_settlement_type(stype)
	var max_slots = stype_data.get("max_slots", 10)
	if current.size() >= max_slots:
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

	if not settlement.has("buildings"):
		settlement["buildings"] = []
	if not settlement.has("building_levels"):
		settlement["building_levels"] = {}
	settlement["buildings"].append(building_type)
	settlement["building_levels"][building_type] = 1
	return true


func get_building_level(settlement: Dictionary, building_type: String) -> int:
	return settlement.get("building_levels", {}).get(building_type, 1)


func can_upgrade_settlement_building(faction: Dictionary, settlement: Dictionary, building_type: String) -> bool:
	var building = WorldData.get_building(building_type)
	if building.is_empty():
		return false
	if building_type not in settlement.get("buildings", []):
		return false
	var level = get_building_level(settlement, building_type)
	if level >= 4:
		return false
	var next_cost = _upgrade_cost(building, level + 1)
	var res = faction.get("resources", {})
	for r in next_cost.keys():
		if res.get(r, 0) < next_cost[r]:
			return false
	return true


func upgrade_settlement_building(faction: Dictionary, province: Dictionary, settlement_name: String, building_type: String) -> bool:
	var settlement = get_settlement(province, settlement_name)
	if settlement.is_empty():
		return false
	if not can_upgrade_settlement_building(faction, settlement, building_type):
		return false
	var building = WorldData.get_building(building_type)
	var level = get_building_level(settlement, building_type)
	var next_cost = _upgrade_cost(building, level + 1)
	var res = faction.get("resources", {})
	for r in next_cost.keys():
		res[r] = res.get(r, 0) - next_cost[r]
	settlement["building_levels"][building_type] = level + 1
	return true


func _upgrade_cost(building: Dictionary, target_level: int) -> Dictionary:
	var base = building.get("cost", {})
	var out := {}
	for r in base.keys():
		out[r] = base[r] * target_level
	return out


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
				var level = s.get("building_levels", {}).get(b, 1)
				for eff in data.get("effects", {}).keys():
					if eff in WorldData.config.get("resources", []):
						prod[eff] = prod.get(eff, 0) + data["effects"][eff] * level
	return prod


# ============================================================
# Sistema upgrade edifici - Dark Corporation / Stev
# ============================================================

func can_upgrade_building(faction: Dictionary, settlement: Dictionary, building_type: String) -> bool:
	var building = WorldData.get_building(building_type)
	if building.is_empty():
		return false
	var upgrade_to = building.get("upgrades", "")
	if upgrade_to == null or upgrade_to.is_empty():
		return false
	if building_type not in settlement.get("buildings", []):
		return false
	# Verifica che l'upgrade sia costruibile (prerequisiti e risorse)
	return can_build_settlement_building(faction, settlement, upgrade_to)


func upgrade_building(faction: Dictionary, province: Dictionary, settlement_name: String, building_type: String) -> bool:
	var settlement = get_settlement(province, settlement_name)
	if settlement.is_empty():
		return false
	if not can_upgrade_building(faction, settlement, building_type):
		return false
	var building = WorldData.get_building(building_type)
	var upgrade_to = building.get("upgrades", "")
	# Paga il costo del nuovo edificio
	var new_data = WorldData.get_building(upgrade_to)
	var res = faction.get("resources", {})
	for r in new_data.get("cost", {}).keys():
		res[r] = res.get(r, 0) - new_data["cost"][r]
	# Rimuovi il vecchio, aggiungi il nuovo
	var buildings = settlement.get("buildings", [])
	var idx = buildings.find(building_type)
	if idx >= 0:
		buildings[idx] = upgrade_to
	var levels = settlement.get("building_levels", {})
	levels.erase(building_type)
	levels[upgrade_to] = 1
	return true


# ============================================================
# Sistema recruit_pool - Dark Corporation / Stev
# ============================================================

func get_recruit_pool(settlement: Dictionary, building_type: String) -> Dictionary:
	var building = WorldData.get_building(building_type)
	return building.get("recruit_pool", {})


func get_available_recruits(faction: Dictionary, settlement: Dictionary) -> Dictionary:
	# Restituisce {unit_type: {available, max, rate, experience}}
	var out := {}
	var current = settlement.get("buildings", [])
	for b in current:
		var pool = get_recruit_pool(settlement, b)
		for unit_type in pool.keys():
			var p = pool[unit_type]
			# Verifica che la fazione possa reclutare l'unita'
			var unit = WorldData.get_unit(unit_type)
			var allowed_factions = unit.get("factions", [])
			if allowed_factions.size() > 0 and faction.get("name", "") not in allowed_factions:
				continue
			# Verifica risorse
			if not EconomyEngine.can_recruit(faction, unit_type, 1):
				continue
			var stored = settlement.get("recruit_pool_state", {}).get(unit_type, {})
			var available = stored.get("available", p.get("initial", 0))
			out[unit_type] = {
				"available": available,
				"max": p.get("max", 1),
				"rate": p.get("rate", 0.2),
				"experience": p.get("experience", 0)
			}
	return out


func refresh_recruit_pool(settlement: Dictionary, delta_turns: float):
	# Aggiorna i pool di reclutamento in base al rate
	var current = settlement.get("buildings", [])
	if not settlement.has("recruit_pool_state"):
		settlement["recruit_pool_state"] = {}
	var state = settlement["recruit_pool_state"]
	for b in current:
		var pool = get_recruit_pool(settlement, b)
		for unit_type in pool.keys():
			var p = pool[unit_type]
			if not state.has(unit_type):
				state[unit_type] = {"available": p.get("initial", 0)}
			var s = state[unit_type]
			var max_val = p.get("max", 1)
			var rate = p.get("rate", 0.2)
			s["available"] = minf(max_val, s.get("available", 0) + rate * delta_turns)


func recruit_from_pool(faction: Dictionary, settlement: Dictionary, unit_type: String, amount: int) -> bool:
	var state = settlement.get("recruit_pool_state", {})
	if not state.has(unit_type):
		return false
	var s = state[unit_type]
	if s.get("available", 0) < amount:
		return false
	if not EconomyEngine.can_recruit(faction, unit_type, amount):
		return false
	# Paga il costo
	var unit = WorldData.get_unit(unit_type)
	var res = faction.get("resources", {})
	res["oro"] = res.get("oro", 0) - unit.get("cost", 0) * amount
	for r in ["legname", "pietra", "ferro", "armi"]:
		if unit.get(r, 0) > 0:
			res[r] = res.get(r, 0) - unit[r] * amount
	# Riduci popolazione
	var pop_cost = unit.get("pop", 0) * amount
	settlement["population"] = max(0, settlement.get("population", 0) - pop_cost)
	# Aggiungi unita' alla fazione
	var units = faction.get("units", {})
	units[unit_type] = units.get(unit_type, 0) + amount
	# Riduci available
	s["available"] = s.get("available", 0) - amount
	return true


# ============================================================
# Effetti aggregati settlement - Dark Corporation / Stev
# ============================================================

func get_settlement_effects(settlement: Dictionary) -> Dictionary:
	var out := {
		"happiness_bonus": 0.0,
		"population_growth_bonus": 0.0,
		"trade_bonus": 0.0,
		"defense_bonus": 0.0,
		"law_bonus": 0.0,
		"weapon_bonus": 0.0,
		"armour_bonus": 0.0,
		"free_upkeep": 0,
		"recruitment_slots": 0
	}
	for b in settlement.get("buildings", []):
		var data = WorldData.get_building(b)
		var level = settlement.get("building_levels", {}).get(b, 1)
		var effects = data.get("effects", {})
		for eff in effects.keys():
			if out.has(eff):
				out[eff] += effects[eff] * level
	return out
