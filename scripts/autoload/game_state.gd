# Dark Corporation / Stev
# Stato di gioco Hegemonia 1000 con nebbia di guerra a raggio
extends Node

const START_YEAR := 1000
const START_MONTH := 1

var state := {}
var _fog_center := Vector2.ZERO
var _fog_radius := 8.0


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
		state.provinces[p]["fog"] = "nebbia"
	_calculate_fog_center()
	_apply_fog()


func _calculate_fog_center():
	# Non piu' usato: la nebbia ora parte da ogni singola provincia
	pass


func _apply_fog():
	var player = state.player_faction
	if player.is_empty():
		for p in state.provinces.keys():
			state.provinces[p]["fog"] = "nebbia"
		return

	# Raccogli le coordinate di ogni provincia del giocatore
	var player_coords: Array = []
	for p in state.provinces.keys():
		if state.provinces[p].get("owner") == player:
			var data = WorldData.get_province(p)
			var lat: float = float(data.get("latitude", 0.0))
			var lon: float = float(data.get("longitude", 0.0))
			if lat != 0.0 or lon != 0.0:
				player_coords.append(Vector2(lon, lat))

	# Raggio di visibilita' da ogni provincia (5 gradi ~ 550 km)
	var vis_radius: float = 5.0
	var half_radius: float = vis_radius * 0.6

	for p in state.provinces.keys():
		# Le province del giocatore sono SEMPRE visibili
		if state.provinces[p].get("owner") == player:
			state.provinces[p]["fog"] = "visibile"
			continue
		var data = WorldData.get_province(p)
		var lat: float = float(data.get("latitude", 0.0))
		var lon: float = float(data.get("longitude", 0.0))
		if lat == 0.0 and lon == 0.0:
			state.provinces[p]["fog"] = "nebbia"
			continue
		var prov_coord := Vector2(lon, lat)
		var min_dist: float = INF
		for pc in player_coords:
			var d: float = prov_coord.distance_to(pc)
			if d < min_dist:
				min_dist = d
		if min_dist <= half_radius:
			state.provinces[p]["fog"] = "visibile"
		elif min_dist <= vis_radius:
			state.provinces[p]["fog"] = "mezza"
		else:
			state.provinces[p]["fog"] = "nebbia"


func get_fog(province_name: String) -> String:
	if not state.provinces.has(province_name):
		return "nebbia"
	return state.provinces[province_name].get("fog", "nebbia")


func advance_turn(months: int = 1):
	state.month += months
	while state.month > 12:
		state.month -= 12
		state.year += 1
	state.turn += 1
	_execute_player_orders()
	EconomyEngine.apply_production()
	AIController.run_ai_turn()
	_calculate_fog_center()
	_apply_fog()
	push_event("Turno %d: %d-%d" % [state.turn, state.year, state.month])


func _execute_player_orders():
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
