extends Node

const ICONS_PATH := "res://data/config/icons_1000.json"

var _data: Dictionary = {}
var _cache: Dictionary = {}

var _faction_regions := {
	"Impero Bizantino": "oriental",
	"Califfato di Cordova": "oriental",
	"Impero Fatimide": "oriental",
	"Califfato Abbaside": "oriental",
	"Sultanato Ghaznavide": "oriental",
	"Dinastia Song": "asian",
	"Impero Khitan Liao": "asian",
	"Regno Heian": "asian",
	"Regno Khmer": "asian",
	"Regno di Srivijaya": "asian",
	"Impero Chola": "indian",
	"Impero del Ghana": "african",
	"Toltechi": "american",
	"Regni Maya": "american",
	"Terra di Nessuno": "european"
}


func _ready():
	_load_data()


func _load_data():
	if not FileAccess.file_exists(ICONS_PATH):
		push_warning("Icon manifest non trovato: " + ICONS_PATH)
		return
	var file = FileAccess.open(ICONS_PATH, FileAccess.READ)
	var json = JSON.new()
	var err = json.parse(file.get_as_text())
	if err == OK:
		_data = json.data
	else:
		push_warning("Errore parsing icon manifest: " + json.get_error_message())


func get_building_icon(building_id: String, region: String = "european") -> Texture2D:
	return _get_icon("buildings", building_id, region)


func get_unit_icon(unit_id: String, region: String = "european") -> Texture2D:
	return _get_icon("units", unit_id, region)


func get_battle_sprite(unit_id: String, region: String = "european") -> Texture2D:
	return _get_icon("battle", unit_id, region)


func get_settlement_icon(settlement_type: String, region: String = "european") -> Texture2D:
	return _get_icon("settlements", settlement_type, region)


func _get_icon(category: String, id: String, region: String) -> Texture2D:
	var key := category + "_" + region + "_" + id
	if _cache.has(key):
		return _cache[key]

	var path := _resolve_path(category, id, region)
	var tex: Texture2D
	if ResourceLoader.exists(path):
		tex = load(path) as Texture2D

	if tex == null:
		tex = _fallback(category)

	_cache[key] = tex
	return tex


func _resolve_path(category: String, id: String, region: String) -> String:
	var regions = _data.get("regions", {})
	var region_data = regions.get(region, {})
	var cat = region_data.get(category, {})
	if cat.has(id):
		return cat[id]

	# Fallback alla regione di default
	var default = _data.get("default_region", "european")
	if region != default:
		region_data = regions.get(default, {})
		cat = region_data.get(category, {})
		if cat.has(id):
			return cat[id]
	return ""


func _fallback(category: String) -> Texture2D:
	match category:
		"buildings", "settlements":
			return _load_or_null(_data.get("fallback_building", "res://assets/ui_textures/generic/generic_building.png"))
		"battle":
			return _load_or_null(_data.get("fallback_battle", "res://assets/ui_textures/generic/generic_unit_card.png"))
		_:
			return _load_or_null(_data.get("fallback_unit", "res://assets/ui_textures/generic/generic_unit_card.png"))


func _load_or_null(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null


func region_for_faction(faction_name: String) -> String:
	return _faction_regions.get(faction_name, "european")
