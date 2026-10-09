extends Node
# Indice delle truppe per fazione
# Ogni fazione ha truppe diverse con colori e unita' speciali
# Permette di applicare texture/colori diversi per ogni fazione
# Dark Corporation / Stev

# Colori primari per ogni fazione (dal JSON)
const FACTION_COLORS := {
	"Impero Bizantino": Color(0.54, 0.17, 0.89),
	"Sacro Romano Impero": Color(1.0, 0.84, 0.0),
	"Vichinghi": Color(0.2, 0.3, 0.5),
	"Regno di Francia": Color(0.3, 0.4, 0.8),
	"Califfato di Cordova": Color(0.2, 0.6, 0.3),
	"Impero Fatimide": Color(0.6, 0.5, 0.1),
	"Regno d'Ungheria": Color(0.7, 0.2, 0.2),
	"Principato di Kiev": Color(0.5, 0.3, 0.1),
	"Regno di Polonia": Color(0.8, 0.2, 0.3),
	"Califfato Abbaside": Color(0.3, 0.5, 0.2),
	"Sultanato Ghaznavide": Color(0.6, 0.3, 0.1),
	"Dinastia Song": Color(0.8, 0.7, 0.2),
	"Impero Khitan Liao": Color(0.5, 0.4, 0.3),
	"Impero Chola": Color(0.7, 0.4, 0.1),
	"Regno Khmer": Color(0.6, 0.2, 0.3),
	"Regno Heian": Color(0.8, 0.3, 0.3),
	"Regno di Srivijaya": Color(0.3, 0.6, 0.5),
	"Impero del Ghana": Color(0.6, 0.5, 0.3),
	"Toltechi": Color(0.7, 0.5, 0.2),
	"Regni Maya": Color(0.4, 0.6, 0.2),
	"Regno di Kilwa": Color(0.5, 0.3, 0.4),
	"Regno di Kamarupa": Color(0.6, 0.3, 0.2),
	"Contea di Tolosa": Color(0.8, 0.3, 0.4),
	"Terra di Nessuno": Color(0.4, 0.4, 0.4)
}

# Unità speciali per fazione (oltre a fanteria, arcieri, cavalleria, artiglieria)
const FACTION_SPECIAL_UNITS := {
	"Impero Bizantino": ["cataphractoi", "varangian_guard"],
	"Sacro Romano Impero": ["milites", "loricati"],
	"Vichinghi": ["berserker", "huskarl"],
	"Regno di Francia": ["cavalleria_pesante"],
	"Califfato di Cordova": ["jinete", "black_guard"],
	"Impero Fatimide": ["mamluk", "hashashin"],
	"Regno d'Ungheria": ["huszar", "szekely"],
	"Principato di Kiev": ["druzhina", "boyar"],
	"Regno di Polonia": ["rycerz", "strzelcy"],
	"Califfato Abbaside": ["ghulam", "hashashin"],
	"Sultanato Ghaznavide": ["ghulam", "afghan_tribal"],
	"Dinastia Song": ["crossbowman", "iron_infantry"],
	"Impero Khitan Liao": ["horse_archer", "liao_cavalry"],
	"Impero Chola": ["war_elephant", "chola_archer"],
	"Regno Khmer": ["war_elephant", "khmer_guard"],
	"Regno Heian": ["samurai", "ashigaru"],
	"Regno di Srivijaya": ["naval_infantry", "srivijaya_guard"],
	"Impero del Ghana": ["cavalry_raider", "tribal_warrior"],
	"Toltechi": ["jaguar_warrior", "eagle_warrior"],
	"Regni Maya": ["jaguar_warrior", "atl_atl_thrower"],
	"Regno di Kilwa": ["swahili_spearman", "arab_mercenary"],
	"Regno di Kamarupa": ["war_elephant", "kamarupa_archer"],
	"Contea di Tolosa": ["occitan_knight", "cathar_militia"],
	"Terra di Nessuno": ["peasant", "militia"]
}

# Mapping unita' speciali -> tipo base per la scena 3D
# (quale modello usare nella scena di battaglia)
const SPECIAL_UNIT_MAP := {
	"cataphractoi": "cavalleria",
	"varangian_guard": "spadaccini",
	"milites": "cavalleria",
	"loricati": "spadaccini",
	"berserker": "asceri",
	"huskarl": "spadaccini",
	"cavalleria_pesante": "cavalleria",
	"jinete": "cavalleria",
	"black_guard": "spadaccini",
	"mamluk": "cavalleria",
	"hashashin": "spadaccini",
	"huszar": "cavalleria",
	"szekely": "arciere",
	"druzhina": "spadaccini",
	"boyar": "cavalleria",
	"rycerz": "cavalleria",
	"strzelcy": "arciere",
	"ghulam": "cavalleria",
	"afghan_tribal": "asceri",
	"crossbowman": "arciere",
	"iron_infantry": "spadaccini",
	"horse_archer": "cavalleria",
	"liao_cavalry": "cavalleria",
	"war_elephant": "cavalleria",
	"chola_archer": "arciere",
	"khmer_guard": "spadaccini",
	"samurai": "spadaccini",
	"ashigaru": "lancieri",
	"naval_infantry": "spadaccini",
	"srivijaya_guard": "lancieri",
	"cavalry_raider": "cavalleria",
	"tribal_warrior": "asceri",
	"jaguar_warrior": "asceri",
	"eagle_warrior": "spadaccini",
	"atl_atl_thrower": "arciere",
	"swahili_spearman": "lancieri",
	"arab_mercenary": "cavalleria",
	"kamarupa_archer": "arciere",
	"occitan_knight": "cavalleria",
	"cathar_militia": "spadaccini",
	"peasant": "spadaccini",
	"militia": "lancieri"
}

# Restituisce il colore di una fazione
static func get_faction_color(faction_name: String) -> Color:
	if FACTION_COLORS.has(faction_name):
		return FACTION_COLORS[faction_name]
	return Color(0.5, 0.5, 0.5)

# Restituisce le unita' speciali di una fazione
static func get_special_units(faction_name: String) -> Array:
	if FACTION_SPECIAL_UNITS.has(faction_name):
		return FACTION_SPECIAL_UNITS[faction_name]
	return []

# Restituisce il tipo base di un'unita' speciale
static func get_unit_base_type(special_unit: String) -> String:
	if SPECIAL_UNIT_MAP.has(special_unit):
		return SPECIAL_UNIT_MAP[special_unit]
	return "spadaccini"

# Restituisce la composizione dell'esercito per una fazione
# in base alle unita' nel JSON
static func get_army_composition(faction_data: Dictionary) -> Dictionary:
	var comp := {
		"spadaccini": 0,
		"lancieri": 0,
		"asceri": 0,
		"arciere": 0,
		"cavalleria": 0,
		"artiglieria": 0
	}
	if faction_data.has("units"):
		var units: Dictionary = faction_data["units"]
		# Unità base
		if units.has("fanteria"):
			var f: int = units["fanteria"]
			# Dividi la fanteria in spadaccini, lancieri, asceri
			comp["spadaccini"] = int(f * 0.4)
			comp["lancieri"] = int(f * 0.4)
			comp["asceri"] = int(f * 0.2)
		if units.has("arcieri"):
			comp["arciere"] = int(units["arcieri"])
		if units.has("cavalleria"):
			comp["cavalleria"] = int(units["cavalleria"])
		if units.has("artiglieria"):
			comp["artiglieria"] = int(units["artiglieria"])
		# Unità speciali: aggiungile ai tipi base
		for unit_name in units.keys():
			if unit_name in ["fanteria", "arcieri", "cavalleria", "artiglieria"]:
				continue
			var base_type: String = get_unit_base_type(unit_name)
			if comp.has(base_type):
				comp[base_type] += int(units[unit_name])
	# Limita i totali per la scena 3D (max 20 per tipo)
	for key in comp.keys():
		comp[key] = min(comp[key], 20)
	return comp
