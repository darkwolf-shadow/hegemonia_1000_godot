extends Node

const START_YEAR := 1000
const START_MONTH := 1

var state := {}


func _ready():
	reset_state()


func reset_state():
	state = {
		"turn": 1,
		"year": START_YEAR,
		"month": START_MONTH,
		"player_faction": "",
		"factions": {},
		"provinces": {},
		"armies": {},
		"fleets": {},
		"events": [],
		"pending_battle": null,
	}


func new_game(faction_name: String):
	reset_state()
	state.player_faction = faction_name
	state.factions = WorldData.factions.duplicate(true)
	state.provinces = WorldData.provinces.duplicate(true)
	for faction_name_key in state.factions.keys():
		var data = state.factions[faction_name_key]
		if data.has("resources"):
			data["resources"] = data["resources"].duplicate(true)
		if data.has("units"):
			data["units"] = data["units"].duplicate(true)
		if data.has("ships"):
			data["ships"] = data["ships"].duplicate(true)
		if data.has("buildings"):
			data["buildings"] = data["buildings"].duplicate()
	_init_fog_of_war()
	push_event("Inizio partita: anno %d, mese %d" % [state.year, state.month])


func _init_fog_of_war():
	for p in state.provinces.keys():
		var prov = state.provinces[p]
		prov["explored"] = false
		prov["visible"] = false
	_reveal_around_player()


func _reveal_around_player():
	var player = state.player_faction
	if player.is_empty():
		return
	for p in state.provinces.keys():
		if state.provinces[p].get("owner") == player:
			_set_visible(p, true)
			for n in WorldData.get_province(p).get("neighbors", []):
				_set_visible(n, true)


func _set_visible(province_name: String, visible: bool):
	if not state.provinces.has(province_name):
		return
	var prov = state.provinces[province_name]
	if visible:
		prov["visible"] = true
		prov["explored"] = true
	else:
		prov["visible"] = false


func advance_turn(months: int = 1):
	state.month += months
	while state.month > 12:
		state.month -= 12
		state.year += 1
	state.turn += 1
	_execute_player_orders()
	EconomyEngine.apply_production()
	AIController.run_ai_turn()
	_reveal_around_player()
	push_event("Turno %d: %d-%d" % [state.turn, state.year, state.month])


func _execute_player_orders():
	# Stub: gli ordini del giocatore vengono gestiti dall'interfaccia.
	pass


func push_event(text: String):
	state.events.append({"turn": state.turn, "text": text})


func get_player_faction() -> Dictionary:
	return state.factions.get(state.player_faction, {})


func get_player_provinces() -> Array:
	var list := []
	for p in state.provinces.keys():
		if state.provinces[p].get("owner") == state.player_faction:
			list.append(p)
	return list


func set_pending_battle(battle: Dictionary):
	state.pending_battle = battle


func clear_pending_battle():
	state.pending_battle = null
