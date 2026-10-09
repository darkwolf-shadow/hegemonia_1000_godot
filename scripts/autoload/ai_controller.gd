extends Node

# AIController per Hegemonia 1000 - Dark Corporation / Stev
# Architettura ibrida: sviluppo economico deterministico + obiettivi per nazione

var _faction_goals: Dictionary = {}
const GOALS_DIR := "res://dati/factions/"

func _ready():
	_load_faction_goals()


func _load_faction_goals():
	var dir := DirAccess.open(GOALS_DIR)
	if dir == null:
		push_warning("Cartella obiettivi non trovata: " + GOALS_DIR)
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while not file_name.is_empty():
		if file_name.ends_with(".json"):
			var path := GOALS_DIR + file_name
			var f := FileAccess.open(path, FileAccess.READ)
			if f != null:
				var json := JSON.new()
				if json.parse(f.get_as_text()) == OK:
					var data: Dictionary = json.data
					var goal_name: String = data.get("name", file_name.get_basename().replace("_", " "))
					_faction_goals[goal_name] = data
		file_name = dir.get_next()
	print("AIController: caricati %d obiettivi fazione" % _faction_goals.size())


func _get_goals(faction_name: String) -> Dictionary:
	# Cerca per nome esatto o per nome normalizzato
	if _faction_goals.has(faction_name):
		return _faction_goals[faction_name]
	# Cerca per nome normalizzato (sostituisci spazi)
	var normalized := faction_name.replace(" ", "_").replace("'", "")
	for key in _faction_goals.keys():
		var key_norm: String = key.replace(" ", "_").replace("'", "")
		if key_norm == normalized:
			return _faction_goals[key]
	return {}


# ============================================================
# Turno IA principale
# ============================================================

func run_ai_turn():
	for faction_name in GameState.state.factions.keys():
		if faction_name == GameState.state.player_faction:
			continue
		if faction_name == "Terra di Nessuno":
			continue
		if faction_name == "Mare Aperto":
			continue
		if faction_name == "Isole Disabitate":
			continue
		var faction = GameState.state.factions[faction_name]
		if faction.get("is_neutral", false):
			continue
		make_decisions(faction_name)


func make_decisions(faction_name: String):
	var faction = GameState.state.factions[faction_name]
	var goals := _get_goals(faction_name)

	# 1. Aggiorna recruit pool in tutti i settlement
	_update_recruit_pools(faction_name)

	# 2. Sviluppo economico: costruisci edifici secondo catena_priorita
	_economic_development(faction_name, goals)

	# 3. Reclutamento basato su obiettivi militari
	_recruit_units(faction_name, goals)

	# 4. Decisione militare (attacco/difesa)
	_military_decision(faction_name, goals)

	# 5. Richiesta IA esterna per decisione strategica di alto livello
	# (diplomazia, narrazione) - asincrona, non blocca il turno
	_request_external_strategy(faction_name, goals)


# ============================================================
# Sviluppo economico deterministico - Dark Corporation / Stev
# ============================================================

func _economic_development(faction_name: String, goals: Dictionary):
	var faction = GameState.state.factions[faction_name]
	var catena: Array = goals.get("catena_priorita", [])
	if catena.is_empty():
		# Catena di default se non ci sono obiettivi
		catena = ["centro_cittadino", "mercato", "mulino", "miniera", "fucina", "caserma_i", "campo_tiro_i", "scuderia_i"]

	var res = faction.get("resources", {})
	var built_this_turn := false

	# Trova il primo edificio della catena che non e' ancora costruito in nessun settlement
	for building_type in catena:
		var building_data = WorldData.get_building(building_type)
		if building_data.is_empty():
			continue

		# Verifica se l'edificio e' gia' presente in qualche settlement
		var already_has := _faction_has_building(faction_name, building_type)
		if already_has:
			continue

		# Trova un settlement adatto
		var settlement = _find_settlement_for_building(faction_name, building_type)
		if settlement.is_empty():
			continue

		# Verifica prerequisiti e risorse
		var s_dict = settlement["settlement"]
		var prov_dict = settlement["province"]
		if not SettlementManager.can_build_settlement_building(faction, s_dict, building_type):
			# Prova upgrade se l'edificio e' un upgrade di uno esistente
			var upgrade_to = building_data.get("upgrades", "")
			if upgrade_to != null and not upgrade_to.is_empty():
				if SettlementManager.can_upgrade_building(faction, s_dict, upgrade_to):
					if SettlementManager.upgrade_building(faction, prov_dict, settlement["settlement_name"], upgrade_to):
						GameState.push_event("%s migliora %s in %s" % [faction_name, building_type, settlement["settlement_name"]])
						built_this_turn = true
						break
			continue

		# Costruisci
		if SettlementManager.build_settlement_building(faction, prov_dict, settlement["settlement_name"], building_type):
			GameState.push_event("%s costruisce %s in %s" % [faction_name, building_type, settlement["settlement_name"]])
			built_this_turn = true
			break

	# Se non ha costruito nulla, prova a fare upgrade di edifici esistenti
	if not built_this_turn:
		_try_upgrade_existing(faction_name)


func _faction_has_building(faction_name: String, building_type: String) -> bool:
	for prov_name in GameState.state.provinces.keys():
		var prov = GameState.state.provinces[prov_name]
		if prov.get("owner") != faction_name:
			continue
		for s_name in prov.get("settlements", {}).keys():
			var s = prov["settlements"][s_name]
			if building_type in s.get("buildings", []):
				return true
	return false


func _find_settlement_for_building(faction_name: String, building_type: String) -> Dictionary:
	var building_data = WorldData.get_building(building_type)
	if building_data.is_empty():
		return {}
	var allowed_types: Array = building_data.get("settlement_types", [])

	for prov_name in GameState.state.provinces.keys():
		var prov = GameState.state.provinces[prov_name]
		if prov.get("owner") != faction_name:
			continue
		for s_name in prov.get("settlements", {}).keys():
			var s = prov["settlements"][s_name]
			var stype = s.get("type", "")
			if stype in allowed_types:
				return {"province": prov, "settlement": s, "settlement_name": s_name, "province_name": prov_name}
	return {}


func _try_upgrade_existing(faction_name: String):
	var faction = GameState.state.factions[faction_name]
	for prov_name in GameState.state.provinces.keys():
		var prov = GameState.state.provinces[prov_name]
		if prov.get("owner") != faction_name:
			continue
		for s_name in prov.get("settlements", {}).keys():
			var s = prov["settlements"][s_name]
			for b in s.get("buildings", []):
				if SettlementManager.can_upgrade_building(faction, s, b):
					if SettlementManager.upgrade_building(faction, prov, s_name, b):
						GameState.push_event("%s migliora %s in %s" % [faction_name, b, s_name])
						return


# ============================================================
# Reclutamento basato su obiettivi militari
# ============================================================

func _recruit_units(faction_name: String, goals: Dictionary):
	var faction = GameState.state.factions[faction_name]
	var militari: Dictionary = goals.get("obiettivi_militari", {})
	if militari.is_empty():
		return

	var current_units = faction.get("units", {})

	# Mappa ruolo -> unita' reclutabili
	var role_units = {
		"infantry": ["fanteria", "lancieri", "fanteria_pesante", "milites", "huskarl", "berserker", "sudanese_spearmen", "daylami_infantry", "varangian_guard", "black_guard", "polish_spearmen", "szekler_infantry", "tamil_infantry", "khmer_spearmen", "maya_spearmen", "yamato_infantry", "afghan_infantry", "coyote_warrior", "milizia", "bondi", "voi", "otomi_aux"],
		"cavalry": ["cavalleria", "cavalleria_pesante", "jinete", "magyar_cavalry", "soninke_cavalry", "turkish_horse_archers", "khitan_horse_archers", "ministeriales", "druzyna", "liao_lancers", "samurai", "cataphractoi", "mamluk_cavalry", "druzhina", "ghilman", "ghulam_cavalry", "loricati"],
		"ranged": ["arcieri", "arcieri_evoluti", "toxotai", "armenian_archers", "crossbowmen", "eagle_warrior", "balestrieri", "shenbi_nu", "atlatl", "malay_archers"],
		"artillery": ["artiglieria", "fire_lance"],
		"elephant": ["war_elephants", "elephant_corps", "khmer_elephants"]
	}

	# Verifica fanteria
	var fanteria_min: int = militari.get("fanteria_min", 0)
	var current_infantry = _count_role_units(current_units, role_units["infantry"])
	if current_infantry < fanteria_min:
		_try_recruit_role(faction_name, "infantry", role_units["infantry"], fanteria_min - current_infantry)

	# Verifica cavalleria
	var cavalleria_min: int = militari.get("cavalleria_min", 0)
	var current_cavalry = _count_role_units(current_units, role_units["cavalry"])
	if current_cavalry < cavalleria_min:
		_try_recruit_role(faction_name, "cavalry", role_units["cavalry"], cavalleria_min - current_cavalry)

	# Verifica arcieri
	var arcieri_min: int = militari.get("arcieri_min", 0)
	var current_ranged = _count_role_units(current_units, role_units["ranged"])
	if current_ranged < arcieri_min:
		_try_recruit_role(faction_name, "ranged", role_units["ranged"], arcieri_min - current_ranged)

	# Verifica artiglieria
	var artiglieria_min: int = militari.get("artiglieria_min", 0)
	var current_artillery = _count_role_units(current_units, role_units["artillery"])
	if current_artillery < artiglieria_min:
		_try_recruit_role(faction_name, "artillery", role_units["artillery"], artiglieria_min - current_artillery)

	# Verifica elefanti
	var elefanti_min: int = militari.get("elefanti_min", 0)
	var current_elephant = _count_role_units(current_units, role_units["elephant"])
	if current_elephant < elefanti_min:
		_try_recruit_role(faction_name, "elephant", role_units["elephant"], elefanti_min - current_elephant)

	# Verifica navi
	var navi_min: int = militari.get("navi_min", 0)
	var current_ships = _count_ships(faction.get("ships", {}))
	if current_ships < navi_min:
		_try_recruit_ships(faction_name, navi_min - current_ships)

	# Espansione militare: se sopra i minimi e con oro sufficiente, recluta extra
	var res = faction.get("resources", {})
	var oro = res.get("oro", 0)
	var comportamento = goals.get("comportamento", faction.get("attitude", "balanced"))
	var expansion_target := 0
	match comportamento:
		"imperiale", "razziatore":
			expansion_target = 2  # 2 unita' extra per turno
		"emergente":
			expansion_target = 1
		"marinaro", "commerciale":
			expansion_target = 1
		"isolazionista", "regionale", "religioso":
			expansion_target = 0
		_:
			expansion_target = 1
	# Recluta solo se ha abbastanza oro (almeno 3000 di riserva dopo mantenimento)
	if oro > 3000 and expansion_target > 0:
		# Recluta fanteria extra (la piu' economica)
		_try_recruit_role(faction_name, "infantry", role_units["infantry"], expansion_target)
		# Recluta cavalleria extra se aggressiva
		if comportamento in ["imperiale", "razziatore"] and oro > 8000:
			_try_recruit_role(faction_name, "cavalry", role_units["cavalry"], 1)
		# Recluta navi extra se marinaro
		if comportamento == "marinaro" and oro > 5000:
			_try_recruit_ships(faction_name, 1)


func _count_role_units(units: Dictionary, role_list: Array) -> int:
	var total := 0
	for unit_type in units.keys():
		if unit_type in role_list:
			total += units[unit_type]
	return total


func _count_ships(ships: Dictionary) -> int:
	var total := 0
	for ship_type in ships.keys():
		total += ships[ship_type]
	return total


func _try_recruit_role(faction_name: String, role: String, unit_list: Array, needed: int):
	if needed <= 0:
		return
	var faction = GameState.state.factions[faction_name]

	# Trova settlement con recruit_pool disponibile
	for prov_name in GameState.state.provinces.keys():
		if needed <= 0:
			break
		var prov = GameState.state.provinces[prov_name]
		if prov.get("owner") != faction_name:
			continue
		for s_name in prov.get("settlements", {}).keys():
			if needed <= 0:
				break
			var s = prov["settlements"][s_name]
			var recruits = SettlementManager.get_available_recruits(faction, s)
			for unit_type in unit_list:
				if needed <= 0:
					break
				if not recruits.has(unit_type):
					continue
				var avail = int(recruits[unit_type].get("available", 0))
				if avail <= 0:
					continue
				var to_recruit = min(needed, avail)
				if SettlementManager.recruit_from_pool(faction, s, unit_type, to_recruit):
					GameState.push_event("%s recluta %d %s in %s" % [faction_name, to_recruit, unit_type, s_name])
					needed -= to_recruit


func _try_recruit_ships(faction_name: String, needed: int):
	if needed <= 0:
		return
	var faction = GameState.state.factions[faction_name]
	var ship_types = ["drakkar", "galea", "dromone", "giunca", "tower_ship", "nave_guerra", "nave_guerra_indiana", "canoa"]

	for prov_name in GameState.state.provinces.keys():
		if needed <= 0:
			break
		var prov = GameState.state.provinces[prov_name]
		if prov.get("owner") != faction_name:
			continue
		for s_name in prov.get("settlements", {}).keys():
			if needed <= 0:
				break
			var s = prov["settlements"][s_name]
			var recruits = SettlementManager.get_available_recruits(faction, s)
			for ship_type in ship_types:
				if needed <= 0:
					break
				if not recruits.has(ship_type):
					continue
				var avail = int(recruits[ship_type].get("available", 0))
				if avail <= 0:
					continue
				var to_recruit = min(needed, avail)
				if SettlementManager.recruit_from_pool(faction, s, ship_type, to_recruit):
					# Le navi vanno nella sezione ships, non units
					var ships = faction.get("ships", {})
					# recruit_from_pool mette in units, correggi
					var units = faction.get("units", {})
					if units.has(ship_type):
						units.erase(ship_type)
					ships[ship_type] = ships.get(ship_type, 0) + to_recruit
					GameState.push_event("%s recluta %d %s in %s" % [faction_name, to_recruit, ship_type, s_name])
					needed -= to_recruit


# ============================================================
# Aggiornamento recruit pool
# ============================================================

func _update_recruit_pools(faction_name: String):
	for prov_name in GameState.state.provinces.keys():
		var prov = GameState.state.provinces[prov_name]
		if prov.get("owner") != faction_name:
			continue
		for s_name in prov.get("settlements", {}).keys():
			var s = prov["settlements"][s_name]
			SettlementManager.refresh_recruit_pool(s, 1.0)


# ============================================================
# Decisione militare
# ============================================================

func _military_decision(faction_name: String, goals: Dictionary):
	var faction = GameState.state.factions[faction_name]
	var comportamento = goals.get("comportamento", faction.get("attitude", "balanced"))
	var scaling: Dictionary = goals.get("obiettivi_militari", {}).get("scaling", {})
	var modalita = scaling.get("modalita", "bilanciata")

	match modalita:
		"aggressiva":
			_attack_weakest_neighbor(faction_name)
		"difensiva":
			pass  # Non attacca, si limita a difendere
		"bilanciata":
			if randf() < 0.3:
				_attack_weakest_neighbor(faction_name)
		_:
			if randf() < 0.2:
				_attack_weakest_neighbor(faction_name)


func _attack_weakest_neighbor(faction_name: String):
	var owned = []
	for p in GameState.state.provinces.keys():
		if GameState.state.provinces[p].get("owner") == faction_name:
			owned.append(p)

	for p in owned:
		var neighbors = WorldData.get_province(p).get("neighbors", [])
		for n in neighbors:
			var neighbor_owner = GameState.state.provinces.get(n, {}).get("owner", "")
			if neighbor_owner != faction_name and neighbor_owner != "Terra di Nessuno" and neighbor_owner != "Mare Aperto" and neighbor_owner != "Isole Disabitate":
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


# ============================================================
# Tattiche di battaglia (mantenuto dal codice originale)
# ============================================================

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

	if float(cavalry) / total >= 0.35 and my_morale >= enemy_morale * 0.9:
		return "charge"

	if float(ranged) / total >= 0.4 and enemy_morale > 0:
		return "skirmish"

	if (outnumbered and side == "defender") or (float(infantry) / total >= 0.6 and my_morale < enemy_morale):
		return "shield_wall"

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


# ============================================================
# Integrazione IA esterna via AIBridge - Dark Corporation / Stev
# ============================================================

func _request_external_strategy(faction_name: String, goals: Dictionary):
	if not is_instance_valid(AIBridge):
		return
	var faction = GameState.state.factions[faction_name]
	var res = faction.get("resources", {})
	var units = faction.get("units", {})
	var ships = faction.get("ships", {})
	var context = {
		"obiettivo": goals.get("obiettivi_storici", ["sopravvivenza"]),
		"comportamento": goals.get("comportamento", faction.get("attitude", "bilanciato")),
		"oro": res.get("oro", 0),
		"cibo": res.get("cibo", 0),
		"armi": res.get("armi", 0),
		"fanteria": _count_role_units(units, _role_unit_types("infantry")),
		"cavalleria": _count_role_units(units, _role_unit_types("cavalry")),
		"arcieri": _count_role_units(units, _role_unit_types("ranged")),
		"navi": _count_ships(ships),
		"province": _count_provinces(faction_name),
		"settlements": _count_settlements(faction_name),
		"minacce": _get_nearby_threats(faction_name)
	}
	var prompt = AIBridge.build_faction_prompt(faction_name, context)
	# Connetti i signal una sola volta
	if not AIBridge.ai_response_received.is_connected(_on_ai_response):
		AIBridge.ai_response_received.connect(_on_ai_response)
	if not AIBridge.ai_error.is_connected(_on_ai_error):
		AIBridge.ai_error.connect(_on_ai_error)
	AIBridge.request_ai_decision(faction_name, prompt)


func _count_provinces(faction_name: String) -> int:
	var n := 0
	for p in GameState.state.provinces.values():
		if p.get("owner") == faction_name:
			n += 1
	return n


func _count_settlements(faction_name: String) -> int:
	var n := 0
	for p in GameState.state.provinces.values():
		if p.get("owner") != faction_name:
			continue
		n += p.get("settlements", {}).size()
	return n


func _get_nearby_threats(faction_name: String) -> String:
	var threats: Array[String] = []
	for p_name in GameState.state.provinces.keys():
		var p = GameState.state.provinces[p_name]
		if p.get("owner") != faction_name:
			continue
		for n_name in p.get("neighbors", []):
			if not GameState.state.provinces.has(n_name):
				continue
			var n = GameState.state.provinces[n_name]
			var n_owner = n.get("owner", "")
			if n_owner == faction_name or n_owner == "Terra di Nessuno" or n_owner == "Mare Aperto":
				continue
			if n_owner not in threats:
				var n_units = _count_units(GameState.state.factions.get(n_owner, {}).get("units", {}))
				if n_units > 10:
					threats.append(n_owner)
				if threats.size() >= 3:
					break
		if threats.size() >= 3:
			break
	return ", ".join(threats) if not threats.is_empty() else "nessuna"


func _role_unit_types(role: String) -> Array:
	match role:
		"infantry":
			return ["fanteria", "guerrieri", "milizia", "legioni", "huscarl", "samurai", "spearmen", "swordsmen", "pikemen"]
		"cavalry":
			return ["cavalleria", "catafratti", "knights", "cavalieri", "hussar", "dragons", "uomini_a_cavallo"]
		"ranged":
			return ["arcieri", "arcieri_evoluti", "toxotai", "armenian_archers", "crossbowmen", "eagle_warrior", "balestrieri", "shenbi_nu", "atlatl", "malay_archers"]
		"artillery":
			return ["artiglieria", "fire_lance"]
		"elephant":
			return ["war_elephants", "elephant_corps", "khmer_elephants"]
	return []


# Handler risposta IA esterna - applica l'azione strategica ricevuta
func _on_ai_response(faction_name: String, response: String):
	print("AIBridge [%s]: %s" % [faction_name, response.left(120)])
	var line = response.strip_edges().to_lower()
	if line.begins_with("azione:"):
		line = line.substr(7).strip_edges()
	_parse_and_apply_external_action(faction_name, line)


func _on_ai_error(faction_name: String, error: String):
	# Silenzioso: fallback deterministico gia' eseguito nel turno
	pass


func _parse_and_apply_external_action(faction_name: String, action: String):
	var faction = GameState.state.factions[faction_name]
	if action.begins_with("attacca "):
		var target = action.substr(8).strip_edges()
		_try_attack(faction_name, target)
	elif action.begins_with("difendi "):
		# Difesa: nessuna azione offensiva questo turno (gia' gestito)
		pass
	elif action.begins_with("alleanza "):
		var target = action.substr(9).strip_edges()
		_try_diplomacy(faction_name, target, "alleanza")
	elif action.begins_with("commercio "):
		var target = action.substr(10).strip_edges()
		_try_diplomacy(faction_name, target, "commercio")


func _try_attack(faction_name: String, target_province: String):
	if not GameState.state.provinces.has(target_province):
		return
	var target = GameState.state.provinces[target_province]
	var target_owner = target.get("owner", "")
	if target_owner == faction_name or target_owner == "Terra di Nessuno":
		return
	# Verifica confinanti'
	var has_border = false
	for p_name in GameState.state.provinces.keys():
		var p = GameState.state.provinces[p_name]
		if p.get("owner") != faction_name:
			continue
		if target_province in p.get("neighbors", []):
			has_border = true
			break
	if not has_border:
		return
	var faction = GameState.state.factions[faction_name]
	var units = faction.get("units", {})
	var total_units = _count_units(units)
	if total_units < 5:
		return
	print("AIBridge: %s attacca %s (IA esterna)" % [faction_name, target_province])


func _try_diplomacy(faction_name: String, target_faction: String, action_type: String):
	if not GameState.state.factions.has(target_faction):
		return
	if target_faction == faction_name:
		return
	# Registra l'intenzione diplomatica (semplificato)
	if not GameState.state.has("diplomacy"):
		GameState.state["diplomacy"] = {}
	var diplo = GameState.state["diplomacy"]
	var key = "%s->%s" % [faction_name, target_faction]
	diplo[key] = {"type": action_type, "turn": GameState.state.turn}
	print("AIBridge: %s propone %s a %s" % [faction_name, action_type, target_faction])
