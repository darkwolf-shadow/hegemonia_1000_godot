class_name FormationSystem
extends RefCounted

# Sistema formazioni militari per Hegemonia 1000
# Dark Corporation / Stev

enum FormationType {
	LINE,        # linea larga, fronte esteso
	SQUARE,      # quadrato compatto, difesa
	WEDGE,       # cuneo triangolare, rompe linee
	WING,        # a V, avvolge i fianchi
	SPREAD,      # sparsa, arcieri distanziati
	COLUMN       # colonna, movimento veloce
}

# Definizioni formazioni: slot relativi al centro del gruppo
# Ogni slot e' un Vector2 offset in pixel
# Dark Corporation / Stev

const FORMATION_SLOTS := {
	FormationType.LINE: [
		Vector2(-60, 0), Vector2(-30, 0), Vector2(0, 0), Vector2(30, 0), Vector2(60, 0),
		Vector2(-45, 20), Vector2(-15, 20), Vector2(15, 20), Vector2(45, 20),
		Vector2(-60, -20), Vector2(-30, -20), Vector2(0, -20), Vector2(30, -20), Vector2(60, -20),
	],
	FormationType.SQUARE: [
		Vector2(-30, -30), Vector2(0, -30), Vector2(30, -30),
		Vector2(-30, 0), Vector2(0, 0), Vector2(30, 0),
		Vector2(-30, 30), Vector2(0, 30), Vector2(30, 30),
		Vector2(-60, -30), Vector2(60, -30), Vector2(-60, 30), Vector2(60, 30),
	],
	FormationType.WEDGE: [
		Vector2(0, -40),
		Vector2(-25, -20), Vector2(25, -20),
		Vector2(-50, 0), Vector2(0, 0), Vector2(50, 0),
		Vector2(-75, 20), Vector2(-25, 20), Vector2(25, 20), Vector2(75, 20),
		Vector2(-100, 40), Vector2(-50, 40), Vector2(0, 40), Vector2(50, 40), Vector2(100, 40),
	],
	FormationType.WING: [
		Vector2(-80, -40), Vector2(-60, -20), Vector2(-40, 0),
		Vector2(80, -40), Vector2(60, -20), Vector2(40, 0),
		Vector2(-100, 20), Vector2(100, 20),
		Vector2(-20, 30), Vector2(20, 30),
		Vector2(0, 50),
	],
	FormationType.SPREAD: [
		Vector2(-80, -40), Vector2(-40, -30), Vector2(0, -40), Vector2(40, -30), Vector2(80, -40),
		Vector2(-70, 0), Vector2(-30, 10), Vector2(30, 10), Vector2(70, 0),
		Vector2(-80, 40), Vector2(-40, 30), Vector2(0, 40), Vector2(40, 30), Vector2(80, 40),
	],
	FormationType.COLUMN: [
		Vector2(0, -60), Vector2(0, -30), Vector2(0, 0), Vector2(0, 30), Vector2(0, 60),
		Vector2(-20, -45), Vector2(20, -45), Vector2(-20, -15), Vector2(20, -15),
		Vector2(-20, 15), Vector2(20, 15), Vector2(-20, 45), Vector2(20, 45),
	]
}

# Bonus/malus per formazione
# attack_mod, defense_mod, speed_mod, morale_mod, range_mod
const FORMATION_MODIFIERS := {
	FormationType.LINE: {
		"attack": 1.1, "defense": 0.9, "speed": 1.0, "morale": 1.0, "range": 1.0,
		"flank_vulnerable": true, "description": "Largo fronte, buono contro fanteria"
	},
	FormationType.SQUARE: {
		"attack": 0.8, "defense": 1.4, "speed": 0.6, "morale": 1.2, "range": 0.9,
		"flank_vulnerable": false, "description": "Compatto, anti-cavalleria"
	},
	FormationType.WEDGE: {
		"attack": 1.3, "defense": 0.7, "speed": 1.1, "morale": 1.1, "range": 0.8,
		"flank_vulnerable": true, "description": "Cuneo, rompe linee nemiche"
	},
	FormationType.WING: {
		"attack": 1.15, "defense": 0.8, "speed": 1.1, "morale": 0.9, "range": 1.0,
		"flank_vulnerable": false, "description": "A V, avvolge i fianchi"
	},
	FormationType.SPREAD: {
		"attack": 0.9, "defense": 0.7, "speed": 1.0, "morale": 0.8, "range": 1.2,
		"flank_vulnerable": true, "description": "Sparsa, arcieri distanziati"
	},
	FormationType.COLUMN: {
		"attack": 0.9, "defense": 1.0, "speed": 1.3, "morale": 1.0, "range": 0.7,
		"flank_vulnerable": true, "description": "Colonna, movimento veloce"
	}
}

# Formazioni consigliate per ruolo
const ROLE_FORMATIONS := {
	"infantry": [FormationType.LINE, FormationType.SQUARE, FormationType.COLUMN],
	"cavalry": [FormationType.WEDGE, FormationType.WING, FormationType.COLUMN],
	"ranged": [FormationType.SPREAD, FormationType.LINE],
	"artillery": [FormationType.LINE, FormationType.SPREAD],
	"elephant": [FormationType.WEDGE, FormationType.LINE]
}

const FORMATION_NAMES := {
	FormationType.LINE: "Linea",
	FormationType.SQUARE: "Quadrato",
	FormationType.WEDGE: "Cuneo",
	FormationType.WING: "Ala",
	FormationType.SPREAD: "Sparsa",
	FormationType.COLUMN: "Colonna"
}


static func get_slots(formation: int) -> Array:
	return FORMATION_SLOTS.get(formation, FORMATION_SLOTS[FormationType.LINE])


static func get_modifiers(formation: int) -> Dictionary:
	return FORMATION_MODIFIERS.get(formation, FORMATION_MODIFIERS[FormationType.LINE])


static func get_name(formation: int) -> String:
	return FORMATION_NAMES.get(formation, "Linea")


static func get_formation_radius(formation: int) -> float:
	# Raggio approssimativo dell'area occupata
	match formation:
		FormationType.LINE: return 80.0
		FormationType.SQUARE: return 60.0
		FormationType.WEDGE: return 100.0
		FormationType.WING: return 110.0
		FormationType.SPREAD: return 90.0
		FormationType.COLUMN: return 30.0
		_: return 70.0


static func get_formation_width(formation: int) -> float:
	match formation:
		FormationType.LINE: return 140.0
		FormationType.SQUARE: return 80.0
		FormationType.WEDGE: return 200.0
		FormationType.WING: return 220.0
		FormationType.SPREAD: return 180.0
		FormationType.COLUMN: return 50.0
		_: return 120.0


static func groups_overlap(pos_a: Vector2, formation_a: int, pos_b: Vector2, formation_b: int) -> bool:
	var ra := get_formation_radius(formation_a)
	var rb := get_formation_radius(formation_b)
	var dist := pos_a.distance_to(pos_b)
	return dist < (ra + rb) * 0.7


static func get_allowed_formations(role: String) -> Array:
	return ROLE_FORMATIONS.get(role, [FormationType.LINE])
