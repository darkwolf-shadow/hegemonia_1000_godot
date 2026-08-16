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
	var path := _resolve_path("battle", unit_id, region)
	if not path.is_empty() and ResourceLoader.exists(path):
		return _get_icon("battle", unit_id, region)
	return get_unit_icon(unit_id, region)


func get_settlement_icon(settlement_type: String, region: String = "european") -> Texture2D:
	return _get_icon("settlements", settlement_type, region)


func get_ship_icon(ship_id: String, region: String = "european") -> Texture2D:
	return _get_icon("ships", ship_id, region)


func get_resource_icon(resource_id: String, region: String = "european") -> Texture2D:
	return _get_icon("resources", resource_id, region)


func _get_icon(category: String, id: String, region: String) -> Texture2D:
	var key := category + "_" + region + "_" + id
	if _cache.has(key):
		return _cache[key]

	var path := _resolve_path(category, id, region)
	var tex: Texture2D
	if not path.is_empty() and FileAccess.file_exists(path) and ResourceLoader.exists(path):
		tex = load(path) as Texture2D

	if tex == null:
		tex = _fallback(category)

	_cache[key] = tex
	return tex


func _resolve_path(category: String, id: String, region: String) -> String:
	var regions: Dictionary = _data.get("regions", {})
	var default: String = _data.get("default_region", "european")

	# Se la regione e' vuota, cerca in tutte le regioni (modalita' automatica)
	if region.is_empty():
		for any_region in regions.keys():
			var region_data = regions.get(any_region, {})
			var cat = region_data.get(category, {})
			if cat.has(id):
				var candidate: String = cat[id]
				if FileAccess.file_exists(candidate):
					return candidate
	else:
		# Regione richiesta
		var region_data = regions.get(region, {})
		var cat = region_data.get(category, {})
		if cat.has(id):
			var candidate: String = cat[id]
			if FileAccess.file_exists(candidate):
				return candidate

		# Fallback alla regione di default
		if region != default:
			region_data = regions.get(default, {})
			cat = region_data.get(category, {})
			if cat.has(id):
				var candidate: String = cat[id]
				if FileAccess.file_exists(candidate):
					return candidate

		# Poi cerca in tutte le altre regioni (le icone sono spesso condivise)
		for other in regions.keys():
			if other == region or other == default:
				continue
			region_data = regions.get(other, {})
			cat = region_data.get(category, {})
			if cat.has(id):
				var candidate: String = cat[id]
				if FileAccess.file_exists(candidate):
					return candidate

	# Se non c'e' un'icona regionale, prova lo stile base SVG dell'anno 1000
	var base := _default_svg_path(category, id)
	if not base.is_empty() and FileAccess.file_exists(base):
		return base

	return ""


func _default_svg_path(category: String, id: String) -> String:
	match category:
		"buildings":
			return "res://assets/icons/1000/buildings/" + id + ".svg"
		"units":
			return "res://assets/icons/1000/units/" + id + ".svg"
		"ships":
			return "res://assets/icons/1000/ships/" + id + ".svg"
		"resources":
			return "res://assets/icons/1000/resources/" + id + ".svg"
		"settlements":
			return "res://assets/icons/1000/settlements/" + id + ".svg"
		"battle":
			# Le icone battle sono sprite pre-renderizzati, non SVG generici
			return ""
		_:
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


var _mask_cache: Dictionary = {}

func get_building_icon_masked(building_id: String, region: String = "european") -> Texture2D:
	return _get_icon_masked("building", building_id, region, get_building_icon)


func get_settlement_icon_masked(settlement_type: String, region: String = "european") -> Texture2D:
	return _get_icon_masked("settlement", settlement_type, region, get_settlement_icon)


func get_unit_icon_masked(unit_id: String, region: String = "european") -> Texture2D:
	return _get_icon_masked("unit", unit_id, region, get_unit_icon)


func _get_icon_masked(prefix: String, id: String, region: String, getter: Callable) -> Texture2D:
	var key := "masked_" + prefix + "_" + region + "_" + id
	if _mask_cache.has(key):
		return _mask_cache[key]
	var tex: Texture2D = getter.call(id, region)
	if tex == null:
		return null
	var masked := _remove_white_background(tex)
	_mask_cache[key] = masked
	return masked


func _remove_white_background(tex: Texture2D) -> Texture2D:
	var img := tex.get_image()
	if img == null:
		return tex
	img = img.duplicate()
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()
	var thr := 0.92
	for y in range(h):
		for x in range(w):
			var c := img.get_pixel(x, y)
			if c.r > thr and c.g > thr and c.b > thr and c.a > 0.5:
				c.a = 0.0
				img.set_pixel(x, y, c)
	return ImageTexture.create_from_image(img)
