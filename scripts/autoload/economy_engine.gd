extends Node

# Motore economico basato su popolazione - Dark Corporation / Stev
# Modello: popolazione come motore principale (tasse + agricoltura)
# Edifici moltiplicano la produzione, non la generano da soli

# Parametri del modello (calibrati su Hegemonia 800aC/1700)
const TASSA_PRO_CAPITE := 0.03    # oro per abitante (1700: pop/20 = 0.05)
const FORZA_LAVORO_PCT := 0.70    # 70% popolazione lavora (come 1700)
const COEFF_EPOCA := 0.02         # efficienza agricola anno 1000 (800aC=0.15, ma scala diversa)
const CONSUMO_POP_PCT := 0.01     # consumo cibo popolazione: 1% della pop (scala migliaia)

func apply_production():
	for faction_name in GameState.state.factions.keys():
		var faction = GameState.state.factions[faction_name]
		if faction.get("is_neutral", false):
			continue
		produce_resources(faction)
		pay_maintenance(faction)
		consume_food(faction)
		apply_population_growth(faction)


# Nuovo modello produzione basato su popolazione
# ORO = tasse(pop) + edifici(suolo) + base_fazione
# CIBO = agricoltura(forza_lavoro * suolo * coeff) + edifici(suolo) + base_fazione
# Dark Corporation / Stev
func produce_resources(faction: Dictionary):
	var name = faction.get("name", "")
	var modifiers = faction.get("modifiers", {})
	var res = faction.get("resources", {})
	var base = faction.get("production", {})

	var pop_total := 0
	var suolo_total := 0
	var prov_count := 0
	var edif_oro := 0
	var edif_cibo := 0
	var edif_armi := 0
	var edif_prestigio := 0
	var trade_bonus := 0.0

	for prov_name in GameState.state.provinces.keys():
		var prov = GameState.state.provinces[prov_name]
		if prov.get("owner") != name:
			continue
		prov_count += 1
		pop_total += int(prov.get("population", 0))
		suolo_total += _suolo_agricolo(prov)
		for s_name in prov.get("settlements", {}).keys():
			var s = prov["settlements"][s_name]
			# Cap per settlement: ogni insediamento produce al massimo
			# 50 oro e 40 cibo dagli edifici, anche se ha 10 edifici
			# Questo evita che fazioni con tanti edifici producano troppo
			var sett_oro := 0
			var sett_cibo := 0
			for b in s.get("buildings", []):
				var data = WorldData.get_building(b)
				var level = s.get("building_levels", {}).get(b, 1)
				var eff = data.get("effects", {})
				sett_oro += int(eff.get("oro", 0)) * level
				sett_cibo += int(eff.get("cibo", 0)) * level
				edif_armi += int(eff.get("armi", 0)) * level
				edif_prestigio += int(eff.get("prestigio", 0)) * level
				trade_bonus += eff.get("trade_bonus", 0.0)
			edif_oro += min(sett_oro, 50)
			edif_cibo += min(sett_cibo, 40)

	var suolo_medio := suolo_total / float(max(prov_count, 1))
	var forza_lavoro := int(pop_total * FORZA_LAVORO_PCT)

	# ORO: tasse + edifici (con cap per settlement) + base_fazione
	# Il cap per settlement (50 oro) e' gia applicato nel ciclo sopra
	# Dark Corporation / Stev
	var oro_tasse := int(pop_total * TASSA_PRO_CAPITE)
	var oro_edif_base := edif_oro  # gia' capped per settlement
	var oro_edif_bonus := int(edif_oro * suolo_medio / 5.0)  # bonus da suolo fertile
	var oro_edif_total := oro_edif_base + oro_edif_bonus
	var oro_base := int(base.get("oro", 0))
	var oro_prod := oro_tasse + oro_edif_total + oro_base
	# Applica trade bonus (media per provincia)
	if prov_count > 0:
		trade_bonus = trade_bonus / prov_count
	if trade_bonus > 0:
		oro_prod = int(oro_prod * (1.0 + trade_bonus / 100.0))
	var mod_oro: float = float(modifiers.get("oro", 1.0))
	res["oro"] = res.get("oro", 0) + int(oro_prod * mod_oro)

	# CIBO: agricoltura (suolo) + edifici (base + bonus suolo, senza cap) + base
	# Nessun cap sul cibo: gli edifici garantiscono sopravvivenza minima
	# anche in terre povere (Vichinghi con suolo 0.8)
	var cibo_agri := int(forza_lavoro * suolo_medio * COEFF_EPOCA)
	var cibo_edif_base := edif_cibo  # base fissa, garantisce sopravvivenza
	var cibo_edif_bonus := int(edif_cibo * suolo_medio / 5.0)  # bonus da suolo
	var cibo_edif_total := cibo_edif_base + cibo_edif_bonus
	var cibo_base := int(base.get("cibo", 0))
	var cibo_prod := cibo_agri + cibo_edif_total + cibo_base
	var mod_cibo: float = float(modifiers.get("cibo", 1.0))
	res["cibo"] = res.get("cibo", 0) + int(cibo_prod * mod_cibo)

	# Altre risorse: armi, prestigio, legname, ferro, pietra
	if edif_armi > 0:
		res["armi"] = res.get("armi", 0) + int(edif_armi * modifiers.get("armi", 1.0))
	if edif_prestigio > 0:
		res["prestigio"] = res.get("prestigio", 0) + int(edif_prestigio * modifiers.get("prestigio", 1.0))

	# Risorse province (legname, ferro, pietra) - rimangono fisse per provincia
	for prov_name in GameState.state.provinces.keys():
		var prov = GameState.state.provinces[prov_name]
		if prov.get("owner") != name:
			continue
		for r in prov.get("resources", {}).keys():
			if r in ["oro", "cibo"]:
				continue  # gia' calcolate con il nuovo modello
			var amount = prov["resources"][r]
			var mod = modifiers.get(r, 1.0)
			res[r] = res.get(r, 0) + int(amount * mod)


# Suolo agricolo derivato dalla latitudine (modello 1700 adattato)
# Tropicale (0-10): 5, subtropicale (10-25): 4, temperato (25-40): 3,
# temperato freddo (40-55): 2, boreale (55-65): 1, polare (65+): 0
func _suolo_agricolo(prov: Dictionary) -> int:
	if prov.has("suolo_agricolo"):
		return int(prov["suolo_agricolo"])
	var lat = abs(float(prov.get("latitude", 0)))
	if lat < 10: return 5
	if lat < 25: return 4
	if lat < 40: return 3
	if lat < 55: return 2
	if lat < 65: return 1
	return 0


func pay_maintenance(faction: Dictionary):
	var res = faction.get("resources", {})
	var costs = WorldData.config.get("maintenance", {})
	var free_upkeep = _faction_free_upkeep(faction.get("name", ""))
	var upkeep_count = 0
	for unit_type in faction.get("units", {}).keys():
		var count = faction["units"][unit_type]
		var cost = count * costs.get(unit_type, 0)
		# Le prime free_upkeep unita' non pagano manutenzione
		if upkeep_count < free_upkeep:
			var free = min(free_upkeep - upkeep_count, count)
			cost = (count - free) * costs.get(unit_type, 0)
			upkeep_count += free
		res["oro"] = res.get("oro", 0) - cost
	for ship_type in faction.get("ships", {}).keys():
		var count = faction["ships"][ship_type]
		res["oro"] = res.get("oro", 0) - count * costs.get(ship_type, 0)


func consume_food(faction: Dictionary):
	var res = faction.get("resources", {})
	var units = faction.get("units", {})
	var ships = faction.get("ships", {})
	var faction_name = faction.get("name", "")
	var total_food = 0
	# Consumo cibo unita' terrestri
	for unit_type in units.keys():
		var count = units[unit_type]
		var food_cost = WorldData.get_unit(unit_type).get("food", 0)
		total_food += count * food_cost
	# Consumo cibo navi
	for ship_type in ships.keys():
		var count = ships[ship_type]
		var food_cost = WorldData.get_ship(ship_type).get("food", 0)
		total_food += count * food_cost
	# Consumo cibo popolazione civile: 1% della popolazione (scala migliaia)
	var pop_total = 0
	for prov in GameState.state.provinces.values():
		if prov.get("owner") == faction_name:
			pop_total += int(prov.get("population", 0))
	total_food += int(pop_total * CONSUMO_POP_PCT)
	res["cibo"] = res.get("cibo", 0) - total_food
	if res["cibo"] < 0:
		push_warning("%s non ha abbastanza cibo" % faction_name)
		res["cibo"] = 0


# Crescita popolazione basata su edifici - Dark Corporation / Stev
func apply_population_growth(faction: Dictionary):
	var growth_bonus = _faction_population_growth(faction.get("name", ""))
	if growth_bonus <= 0:
		return
	for prov_name in GameState.state.provinces.keys():
		var prov = GameState.state.provinces[prov_name]
		if prov.get("owner") != faction.get("name", ""):
			continue
		var pop = prov.get("population", 0)
		if pop <= 0:
			continue
		# Crescita percentuale mensile
		var growth = int(pop * growth_bonus / 1000.0)
		if growth > 0:
			prov["population"] = pop + growth


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


# ============================================================
# Funzioni helper per effetti aggregati - Dark Corporation / Stev
# ============================================================

# Trade bonus: media per provincia, non somma totale
# Dark Corporation / Stev
func _faction_trade_bonus(faction_name: String) -> float:
	var bonus := 0.0
	var prov_count := 0
	for prov_name in GameState.state.provinces.keys():
		var prov = GameState.state.provinces[prov_name]
		if prov.get("owner") != faction_name:
			continue
		prov_count += 1
		var prov_bonus := 0.0
		for s_name in prov.get("settlements", {}).keys():
			var s = prov["settlements"][s_name]
			var eff = SettlementManager.get_settlement_effects(s)
			prov_bonus += eff.get("trade_bonus", 0.0)
		bonus += prov_bonus
	if prov_count > 0:
		return bonus / prov_count
	return 0.0


# Free upkeep: limitato a max 20 unita' gratuite
func _faction_free_upkeep(faction_name: String) -> int:
	var total := 0
	for prov_name in GameState.state.provinces.keys():
		var prov = GameState.state.provinces[prov_name]
		if prov.get("owner") != faction_name:
			continue
		for s_name in prov.get("settlements", {}).keys():
			var s = prov["settlements"][s_name]
			var eff = SettlementManager.get_settlement_effects(s)
			total += int(eff.get("free_upkeep", 0))
	return min(total, 20)


# Population growth: media per provincia
func _faction_population_growth(faction_name: String) -> float:
	var bonus := 0.0
	var prov_count := 0
	for prov_name in GameState.state.provinces.keys():
		var prov = GameState.state.provinces[prov_name]
		if prov.get("owner") != faction_name:
			continue
		prov_count += 1
		for s_name in prov.get("settlements", {}).keys():
			var s = prov["settlements"][s_name]
			var eff = SettlementManager.get_settlement_effects(s)
			bonus += eff.get("population_growth_bonus", 0.0)
	if prov_count > 0:
		return bonus / prov_count
	return 0.0


func _faction_happiness(faction_name: String) -> float:
	var bonus := 0.0
	var prov_count := 0
	for prov_name in GameState.state.provinces.keys():
		var prov = GameState.state.provinces[prov_name]
		if prov.get("owner") != faction_name:
			continue
		prov_count += 1
		for s_name in prov.get("settlements", {}).keys():
			var s = prov["settlements"][s_name]
			var eff = SettlementManager.get_settlement_effects(s)
			bonus += eff.get("happiness_bonus", 0.0)
	if prov_count > 0:
		return bonus / prov_count
	return 0.0


func _faction_defense_bonus(faction_name: String) -> float:
	var bonus := 0.0
	for prov_name in GameState.state.provinces.keys():
		var prov = GameState.state.provinces[prov_name]
		if prov.get("owner") != faction_name:
			continue
		for s_name in prov.get("settlements", {}).keys():
			var s = prov["settlements"][s_name]
			var eff = SettlementManager.get_settlement_effects(s)
			bonus += eff.get("defense_bonus", 0.0)
	return bonus


func _faction_weapon_bonus(faction_name: String) -> float:
	var bonus := 0.0
	for prov_name in GameState.state.provinces.keys():
		var prov = GameState.state.provinces[prov_name]
		if prov.get("owner") != faction_name:
			continue
		for s_name in prov.get("settlements", {}).keys():
			var s = prov["settlements"][s_name]
			var eff = SettlementManager.get_settlement_effects(s)
			bonus += eff.get("weapon_bonus", 0.0)
	return bonus


func _faction_armour_bonus(faction_name: String) -> float:
	var bonus := 0.0
	for prov_name in GameState.state.provinces.keys():
		var prov = GameState.state.provinces[prov_name]
		if prov.get("owner") != faction_name:
			continue
		for s_name in prov.get("settlements", {}).keys():
			var s = prov["settlements"][s_name]
			var eff = SettlementManager.get_settlement_effects(s)
			bonus += eff.get("armour_bonus", 0.0)
	return bonus
