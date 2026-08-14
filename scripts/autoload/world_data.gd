extends Node

var config: Dictionary = {}
var factions: Dictionary = {}
var provinces: Dictionary = {}
var units: Dictionary = {}
var ships: Dictionary = {}
var buildings: Dictionary = {}
var settlement_types: Dictionary = {}
var terrain_modifiers: Dictionary = {}
var tactics: Dictionary = {}

const CONFIG_PATH := "res://data/config/game_config.json"
const FACTIONS_PATH := "res://data/world/factions_1000.json"
const PROVINCES_PATH := "res://data/world/provinces_1000.json"
const MAP_PATH := "res://data/world/map_1000.geojson"


func _ready():
	load_all()


func load_all():
	config = load_json(CONFIG_PATH)
	factions = load_json(FACTIONS_PATH)
	provinces = load_json(PROVINCES_PATH)
	units = config.get("units", {})
	ships = config.get("ships", {})
	buildings = config.get("buildings", {})
	settlement_types = config.get("settlement_types", {})
	terrain_modifiers = config.get("terrain_modifiers", {})
	tactics = config.get("tactics", {})
	_load_map()


func load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_warning("File non trovato: " + path)
		return {}
	var file = FileAccess.open(path, FileAccess.READ)
	var text = file.get_as_text()
	var json = JSON.new()
	var err = json.parse(text)
	if err != OK:
		push_warning("Errore JSON in %s: %s" % [path, json.get_error_message()])
		return {}
	return json.data


func _load_map():
	if not FileAccess.file_exists(MAP_PATH):
		push_warning("Mappa GeoJSON non trovata: " + MAP_PATH)
		return
	var file = FileAccess.open(MAP_PATH, FileAccess.READ)
	var text = file.get_as_text()
	var json = JSON.new()
	var err = json.parse(text)
	if err != OK:
		push_warning("Errore nella mappa GeoJSON: " + json.get_error_message())
		return
	var geo = json.data
	if geo.has("features"):
		for feature in geo["features"]:
			var props = feature.get("properties", {})
			var name = props.get("name", "")
			if name.is_empty() and props.has("nome"):
				name = props["nome"]
			if not name.is_empty() and provinces.has(name):
				provinces[name]["geometry"] = feature.get("geometry", {})
				provinces[name]["properties"] = props


func get_faction(name: String) -> Dictionary:
	return factions.get(name, {})


func get_province(name: String) -> Dictionary:
	return provinces.get(name, {})


func get_unit(type_name: String) -> Dictionary:
	return units.get(type_name, {})


func get_ship(type_name: String) -> Dictionary:
	return ships.get(type_name, {})


func get_building(type_name: String) -> Dictionary:
	return buildings.get(type_name, {})


func get_settlement_type(type_name: String) -> Dictionary:
	return settlement_types.get(type_name, {})
