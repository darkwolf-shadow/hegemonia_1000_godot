#!/usr/bin/env python3
"""Costruisce game_config.json con edifici, unita', navi, stat e requisiti."""

import json
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

SETTLEMENT_TYPES = {
    "civil": {
        "name": "Citta'",
        "description": "Agglomerato urbano civile: produce oro, cibo e prestigio.",
        "base_slots": 8,
        "allowed_buildings": [
            "centro_cittadino", "mercato", "mulino", "monastero", "caserma_i",
            "campo_tiro_i", "scuderia_i", "officina_assedio_i", "capanna_boscaioli",
            "segheria", "fucina", "molo_i", "molo_ii"
        ]
    },
    "military": {
        "name": "Fortezza",
        "description": "Agglomerato militare: addestra truppe avanzate e fortifica la provincia.",
        "base_slots": 10,
        "allowed_buildings": [
            "centro_cittadino", "caserma_i", "caserma_ii", "caserma_iii", "campo_tiro_i",
            "campo_tiro_ii", "campo_tiro_iii", "scuderia_i", "scuderia_ii", "scuderia_iii",
            "cortile_cavaliere", "officina_assedio_i", "officina_assedio_ii",
            "officina_assedio_iii", "fortezza_frontiera", "fucina", "officina_armi",
            "monastero", "mercato"
        ]
    },
    "industrial": {
        "name": "Centro industriale",
        "description": "Estrae risorse e produce armi e materiali.",
        "base_slots": 7,
        "allowed_buildings": [
            "capanna_boscaioli", "segheria", "miniera", "fucina", "officina_armi",
            "mulino", "caserma_i", "centro_cittadino"
        ]
    },
    "port": {
        "name": "Porto",
        "description": "Centro commerciale e navale: costruisce navi e commercia.",
        "base_slots": 7,
        "allowed_buildings": [
            "molo_i", "molo_ii", "arsenale_i", "arsenale_ii", "magazzino", "mercato_marittimo",
            "segheria", "fucina", "centro_cittadino"
        ]
    }
}

BUILDINGS = {
    # Civili
    "centro_cittadino": {
        "name": "Centro cittadino",
        "settlement_types": ["civil", "military", "industrial", "port"],
        "cost": {"oro": 600, "legname": 25, "pietra": 15},
        "construction_turns": 2,
        "effects": {"cibo": 10, "oro": 15, "prestigio": 2},
    },
    "mercato": {
        "name": "Mercato",
        "settlement_types": ["civil", "military", "port"],
        "cost": {"oro": 800, "legname": 20},
        "construction_turns": 2,
        "effects": {"oro": 30, "prestigio": 1},
    },
    "mercato_marittimo": {
        "name": "Mercato marittimo",
        "settlement_types": ["port"],
        "cost": {"oro": 1000, "legname": 25},
        "construction_turns": 2,
        "effects": {"oro": 40, "prestigio": 1},
    },
    "mulino": {
        "name": "Mulino",
        "settlement_types": ["civil", "industrial"],
        "cost": {"oro": 700, "legname": 30},
        "construction_turns": 2,
        "effects": {"cibo": 15},
    },
    "monastero": {
        "name": "Monastero",
        "settlement_types": ["civil", "military"],
        "cost": {"oro": 1500, "legname": 30, "pietra": 20},
        "construction_turns": 3,
        "effects": {"prestigio": 5, "cibo": 5},
    },
    # Industriali
    "capanna_boscaioli": {
        "name": "Capanna dei boscaioli",
        "settlement_types": ["civil", "industrial"],
        "cost": {"oro": 300, "legname": 10},
        "construction_turns": 1,
        "effects": {"legname": 10},
    },
    "segheria": {
        "name": "Segheria",
        "settlement_types": ["industrial", "civil", "port"],
        "cost": {"oro": 600, "legname": 15},
        "construction_turns": 2,
        "effects": {"legname": 20},
    },
    "miniera": {
        "name": "Miniera",
        "settlement_types": ["industrial"],
        "cost": {"oro": 800, "legname": 20, "pietra": 10},
        "construction_turns": 2,
        "effects": {"pietra": 15, "ferro": 8, "argento": 3},
    },
    "fucina": {
        "name": "Fucina",
        "settlement_types": ["industrial", "military", "port"],
        "cost": {"oro": 900, "legname": 15, "pietra": 10},
        "construction_turns": 2,
        "effects": {"armi": 3, "ferro": -2},
    },
    "officina_armi": {
        "name": "Officina d'armi",
        "settlement_types": ["industrial", "military"],
        "cost": {"oro": 1200, "legname": 20, "ferro": 15},
        "construction_turns": 3,
        "effects": {"armi": 5, "ferro": -3},
    },
    # Militari terrestri
    "caserma_i": {
        "name": "Caserma I",
        "settlement_types": ["civil", "military", "industrial"],
        "cost": {"oro": 1000, "legname": 20, "pietra": 10},
        "construction_turns": 2,
        "effects": {},
        "unlocks_units": ["fanteria", "milizia", "lancieri"],
    },
    "caserma_ii": {
        "name": "Caserma II",
        "settlement_types": ["military"],
        "cost": {"oro": 2500, "legname": 40, "pietra": 25, "armi": 10},
        "construction_turns": 3,
        "effects": {},
        "unlocks_units": ["fanteria_pesante", "milites", "huskarl", "sudanese_spearmen", "daylami_infantry", "afghan_infantry"],
    },
    "caserma_iii": {
        "name": "Caserma III",
        "settlement_types": ["military"],
        "cost": {"oro": 4500, "legname": 60, "pietra": 40, "armi": 20, "ferro": 15},
        "construction_turns": 4,
        "effects": {},
        "unlocks_units": ["varangian_guard", "black_guard", "berserker", "holcan", "samurai"],
    },
    "campo_tiro_i": {
        "name": "Campo di tiro I",
        "settlement_types": ["civil", "military"],
        "cost": {"oro": 900, "legname": 20},
        "construction_turns": 2,
        "effects": {},
        "unlocks_units": ["arcieri", "atlatl", "malay_archers", "szekler_infantry"],
    },
    "campo_tiro_ii": {
        "name": "Campo di tiro II",
        "settlement_types": ["military"],
        "cost": {"oro": 2200, "legname": 35, "armi": 10},
        "construction_turns": 3,
        "effects": {},
        "unlocks_units": ["arcieri_evoluti", "toxotai", "armenian_archers", "eagle_warrior", "crossbowmen"],
    },
    "campo_tiro_iii": {
        "name": "Campo di tiro III",
        "settlement_types": ["military"],
        "cost": {"oro": 4000, "legname": 50, "armi": 20, "ferro": 10},
        "construction_turns": 4,
        "effects": {},
        "unlocks_units": ["shenbi_nu", "balestrieri"],
    },
    "scuderia_i": {
        "name": "Scuderia I",
        "settlement_types": ["civil", "military"],
        "cost": {"oro": 1200, "legname": 30, "pietra": 10},
        "construction_turns": 2,
        "effects": {},
        "unlocks_units": ["cavalleria", "jinete", "magyar_cavalry", "turkish_horse_archers", "khitan_horse_archers", "soninke_cavalry"],
    },
    "scuderia_ii": {
        "name": "Scuderia II",
        "settlement_types": ["military"],
        "cost": {"oro": 2800, "legname": 45, "pietra": 25, "ferro": 10},
        "construction_turns": 3,
        "effects": {},
        "unlocks_units": ["cavalleria_pesante", "ministeriales", "druzyna", "liao_lancers", "druzhina"],
    },
    "scuderia_iii": {
        "name": "Scuderia III",
        "settlement_types": ["military"],
        "cost": {"oro": 5000, "legname": 60, "pietra": 40, "ferro": 25, "armi": 15},
        "construction_turns": 4,
        "effects": {},
        "unlocks_units": ["cataphractoi", "loricati", "mamluk_cavalry", "ghilman", "ghulam_cavalry"],
    },
    "cortile_cavaliere": {
        "name": "Cortile del cavaliere",
        "settlement_types": ["military"],
        "cost": {"oro": 3500, "legname": 40, "pietra": 30, "ferro": 15, "armi": 10},
        "construction_turns": 3,
        "effects": {"prestigio": 3},
        "unlocks_units": ["cavalleria_pesante", "cataphractoi", "loricati", "mamluk_cavalry", "druzhina"],
    },
    "officina_assedio_i": {
        "name": "Officina d'assedio I",
        "settlement_types": ["military", "civil"],
        "cost": {"oro": 1200, "legname": 25, "pietra": 15},
        "construction_turns": 2,
        "effects": {},
        "unlocks_units": ["artiglieria", "balista"],
    },
    "officina_assedio_ii": {
        "name": "Officina d'assedio II",
        "settlement_types": ["military"],
        "cost": {"oro": 2800, "legname": 40, "pietra": 35, "ferro": 10},
        "construction_turns": 3,
        "effects": {},
        "unlocks_units": ["artiglieria_avanzata", "catapulta", "war_elephants", "elephant_corps", "khmer_elephants"],
    },
    "officina_assedio_iii": {
        "name": "Officina d'assedio III",
        "settlement_types": ["military"],
        "cost": {"oro": 5000, "legname": 50, "pietra": 50, "ferro": 20, "armi": 15},
        "construction_turns": 4,
        "effects": {},
        "unlocks_units": ["trabucco", "fire_lance"],
    },
    "fortezza_frontiera": {
        "name": "Fortezza di frontiera",
        "settlement_types": ["military"],
        "cost": {"oro": 2500, "pietra": 30, "legname": 20},
        "construction_turns": 3,
        "effects": {"defense": 8},
    },
    # Portuali
    "molo_i": {
        "name": "Molo I",
        "settlement_types": ["port"],
        "cost": {"oro": 800, "legname": 30},
        "construction_turns": 2,
        "effects": {"oro": 10},
        "unlocks_units": ["canoa"],
    },
    "molo_ii": {
        "name": "Molo II",
        "settlement_types": ["port"],
        "cost": {"oro": 1800, "legname": 50, "pietra": 20},
        "construction_turns": 3,
        "effects": {"oro": 25},
        "unlocks_units": ["galea", "giunca"],
    },
    "arsenale_i": {
        "name": "Arsenale I",
        "settlement_types": ["port", "military"],
        "cost": {"oro": 2500, "legname": 60, "pietra": 30},
        "construction_turns": 3,
        "effects": {},
        "unlocks_units": ["drakkar", "dromone", "nave_guerra_indiana"],
    },
    "arsenale_ii": {
        "name": "Arsenale II",
        "settlement_types": ["port", "military"],
        "cost": {"oro": 5000, "legname": 80, "pietra": 50, "ferro": 25, "armi": 15},
        "construction_turns": 4,
        "effects": {},
        "unlocks_units": ["nave_guerra", "tower_ship"],
    },
    "magazzino": {
        "name": "Magazzino portuale",
        "settlement_types": ["port", "civil", "industrial"],
        "cost": {"oro": 1000, "legname": 30},
        "construction_turns": 2,
        "effects": {"cibo": 10, "oro": 10},
    },
}

# Mapping keyword -> (category, weight_category_for_defense)
def classify_unit(name: str):
    n = name.lower()
    if any(x in n for x in ["drakkar", "galea", "dromone", "giunca", "nave", "ship", "canoa", "tower"]):
        return "ship"
    if any(x in n for x in ["elephant", "elefanti", "corpo"]):
        return "elephant"
    if "artiglieria" in n or "fire_lance" in n or "trabucco" in n or "catapulta" in n or "balista" in n:
        return "artillery"
    if any(x in n for x in ["cavalleria", "cavalry", "lancer", "druzhina", "ghulam", "mamluk", "cataphractoi", "ministeriales", "loricati", "ghilman", "jinete", "magyar", "turkish_horse", "khitan_horse", "soninke"]):
        if any(x in n for x in ["pesante", "heavy", "cataphractoi", "mamluk", "ghulam", "druzhina", "ministeriales", "loricati", "ghilman", "druzyna", "liao"]):
            return "heavy_cavalry"
        return "light_cavalry"
    if any(x in n for x in ["arcieri", "archers", "atlatl", "crossbow", "shenbi", "balestrieri", "toxotai"]):
        return "archer"
    if "milizia" in n or "bondi" in n or "voi" in n or "contadina" in n or "otomi_aux" in n:
        return "militia"
    return "infantry"


def category_stats(category: str, attack: float):
    """Restituisce (defense_factor, armor, speed, morale)."""
    if category == "ship":
        # speed per le navi separato piu' avanti
        return (0.5, 0.15, 4.0, 100)
    if category == "elephant":
        return (0.9, 0.35, 1.5, 110)
    if category == "artillery":
        return (0.2, 0.0, 1.0, 90)
    if category == "heavy_cavalry":
        return (0.75, 0.35, 4.0, 105)
    if category == "light_cavalry":
        return (0.6, 0.1, 5.5, 100)
    if category == "archer":
        return (0.3, 0.05, 2.8, 95)
    if category == "militia":
        return (0.35, 0.0, 2.2, 80)
    # infantry
    return (0.55, 0.15, 2.2, 100)


# Requisiti specifici per unita' speciale / evoluta
UNIT_REQUIRES = {
    "fanteria": ["caserma_i"],
    "arcieri": ["campo_tiro_i"],
    "cavalleria": ["scuderia_i"],
    "cavalleria_pesante": ["scuderia_ii", "fucina"],
    "artiglieria": ["officina_assedio_ii"],
    "cataphractoi": ["scuderia_iii", "fucina", "officina_armi"],
    "varangian_guard": ["caserma_iii", "mercato"],
    "toxotai": ["campo_tiro_ii"],
    "milites": ["caserma_ii"],
    "ministeriales": ["scuderia_ii", "fucina"],
    "loricati": ["cortile_cavaliere", "officina_armi"],
    "berserker": ["caserma_ii", "officina_armi"],
    "huskarl": ["caserma_ii", "fucina"],
    "bondi": ["centro_cittadino"],
    "jinete": ["scuderia_i"],
    "black_guard": ["caserma_iii", "mercato"],
    "sudanese_spearmen": ["caserma_ii"],
    "armenian_archers": ["campo_tiro_ii"],
    "mamluk_cavalry": ["cortile_cavaliere"],
    "magyar_cavalry": ["scuderia_i", "campo_tiro_i"],
    "szekler_infantry": ["caserma_i"],
    "druzhina": ["cortile_cavaliere"],
    "voi": ["centro_cittadino"],
    "varangian_mercenaries": ["caserma_ii", "mercato"],
    "druzyna": ["scuderia_ii", "fucina"],
    "polish_spearmen": ["caserma_i"],
    "ghilman": ["cortile_cavaliere"],
    "daylami_infantry": ["caserma_ii"],
    "ghulam_cavalry": ["cortile_cavaliere"],
    "war_elephants": ["officina_assedio_ii", "mercato"],
    "afghan_infantry": ["caserma_i"],
    "turkish_horse_archers": ["scuderia_i", "campo_tiro_i"],
    "crossbowmen": ["campo_tiro_ii", "officina_armi"],
    "shenbi_nu": ["campo_tiro_iii", "officina_armi"],
    "fire_lance": ["officina_assedio_iii", "officina_armi"],
    "khitan_horse_archers": ["scuderia_i", "campo_tiro_i"],
    "liao_lancers": ["scuderia_ii"],
    "tamil_infantry": ["caserma_i"],
    "elephant_corps": ["officina_assedio_ii", "mercato"],
    "khmer_spearmen": ["caserma_i"],
    "khmer_elephants": ["officina_assedio_ii", "mercato"],
    "samurai": ["scuderia_ii", "monastero"],
    "yamato_infantry": ["caserma_i"],
    "malay_archers": ["campo_tiro_i"],
    "soninke_cavalry": ["scuderia_i"],
    "sudani_spearmen": ["caserma_i"],
    "jaguar_warrior": ["caserma_ii", "monastero"],
    "eagle_warrior": ["campo_tiro_ii", "monastero"],
    "coyote_warrior": ["caserma_i"],
    "otomi_aux": ["centro_cittadino"],
    "maya_spearmen": ["caserma_i"],
    "holcan": ["caserma_ii", "monastero"],
    "atlatl": ["campo_tiro_i"],
    # base milizia
    "milizia": ["centro_cittadino", "capanna_boscaioli"],
    # nuovi nomi evoluti (non presenti ora, ma pronti)
    "lancieri": ["caserma_i"],
    "fanteria_pesante": ["caserma_ii"],
    "arcieri_evoluti": ["campo_tiro_ii"],
    "balestrieri": ["campo_tiro_iii"],
    "balista": ["officina_assedio_i"],
    "catapulta": ["officina_assedio_ii"],
    "trabucco": ["officina_assedio_iii"],
}

# Fazioni che possono reclutare certe unita' speciali (vuoto = tutti)
FACTION_LOCKED = {
    "cataphractoi": ["Impero Bizantino"],
    "varangian_guard": ["Impero Bizantino"],
    "toxotai": ["Impero Bizantino"],
    "dromone": ["Impero Bizantino"],
    "milites": ["Sacro Romano Impero", "Regno di Francia", "Califfato di Cordova"],
    "ministeriales": ["Sacro Romano Impero"],
    "loricati": ["Sacro Romano Impero"],
    "berserker": ["Vichinghi"],
    "huskarl": ["Vichinghi"],
    "bondi": ["Vichinghi"],
    "drakkar": ["Vichinghi", "Principato di Kiev"],
    "jinete": ["Califfato di Cordova"],
    "black_guard": ["Califfato di Cordova"],
    "sudanese_spearmen": ["Impero Fatimide"],
    "armenian_archers": ["Impero Fatimide", "Califfato Abbaside"],
    "mamluk_cavalry": ["Impero Fatimide"],
    "magyar_cavalry": ["Regno d'Ungheria"],
    "druzhina": ["Principato di Kiev"],
    "voi": ["Principato di Kiev"],
    "varangian_mercenaries": ["Principato di Kiev", "Impero Bizantino"],
    "druzyna": ["Regno di Polonia"],
    "polish_spearmen": ["Regno di Polonia"],
    "ghilman": ["Califfato Abbaside"],
    "daylami_infantry": ["Califfato Abbaside"],
    "ghulam_cavalry": ["Sultanato Ghaznavide"],
    "war_elephants": ["Sultanato Ghaznavide", "Impero Chola", "Regno Khmer"],
    "afghan_infantry": ["Sultanato Ghaznavide"],
    "turkish_horse_archers": ["Sultanato Ghaznavide", "Impero Khitan Liao"],
    "crossbowmen": ["Regno di Francia", "Sacro Romano Impero", "Dinastia Song"],
    "shenbi_nu": ["Dinastia Song"],
    "fire_lance": ["Dinastia Song"],
    "tower_ship": ["Dinastia Song"],
    "khitan_horse_archers": ["Impero Khitan Liao"],
    "liao_lancers": ["Impero Khitan Liao"],
    "elephant_corps": ["Impero Chola"],
    "tamil_infantry": ["Impero Chola"],
    "nave_guerra_indiana": ["Impero Chola", "Regno di Srivijaya"],
    "khmer_spearmen": ["Regno Khmer"],
    "khmer_elephants": ["Regno Khmer"],
    "samurai": ["Regno Heian"],
    "yamato_infantry": ["Regno Heian"],
    "malay_archers": ["Regno di Srivijaya"],
    "soninke_cavalry": ["Impero del Ghana"],
    "sudani_spearmen": ["Impero del Ghana"],
    "jaguar_warrior": ["Toltechi"],
    "eagle_warrior": ["Toltechi"],
    "coyote_warrior": ["Toltechi"],
    "otomi_aux": ["Toltechi"],
    "maya_spearmen": ["Regni Maya"],
    "holcan": ["Regni Maya"],
    "atlatl": ["Toltechi", "Regni Maya"],
    "giunca": ["Dinastia Song", "Impero Chola", "Regno di Srivijaya"],
}

SHIP_REQUIRES = {
    "drakkar": ["arsenale_i"],
    "galea": ["molo_ii"],
    "dromone": ["arsenale_i", "fucina"],
    "giunca": ["molo_ii", "segheria"],
    "tower_ship": ["arsenale_ii", "segheria"],
    "nave_guerra": ["arsenale_ii", "fucina"],
    "nave_guerra_indiana": ["arsenale_i"],
    "canoa": ["molo_i"],
}


def add_unit_stats(units: dict):
    """Aggiunge attack/defense/armor/speed/morale/experience e requisiti."""
    for key, data in units.items():
        attack = data.get("strength", 0.2)
        data["attack"] = attack
        cat = classify_unit(key)
        def_factor, armor, speed, morale = category_stats(cat, attack)
        data["defense"] = round(attack * def_factor, 2)
        data["armor"] = armor
        data["speed"] = round(speed, 1)
        data["base_morale"] = morale
        data["experience"] = 0
        data["requires_buildings"] = UNIT_REQUIRES.get(key, [])
        data["allowed_settlement_types"] = []  # se vuoto, ogni insediamento con edificio puo' reclutare (limitato dal tipo edificio)
        if key in FACTION_LOCKED:
            data["factions"] = FACTION_LOCKED[key]


def add_ship_stats(ships: dict):
    for key, data in ships.items():
        attack = data.get("strength", 0.2)
        data["attack"] = attack
        # Le navi hanno difesa/armatura/speed diverse per tipo
        if "drakkar" in key or "canoa" in key:
            data["defense"] = round(attack * 0.4, 2); data["armor"] = 0.05; data["speed"] = 7.0
        elif "galea" in key or "dromone" in key or "giunca" in key:
            data["defense"] = round(attack * 0.55, 2); data["armor"] = 0.15; data["speed"] = 5.0
        else:
            data["defense"] = round(attack * 0.65, 2); data["armor"] = 0.25; data["speed"] = 4.0
        data["base_morale"] = 100
        data["experience"] = 0
        data["requires_buildings"] = SHIP_REQUIRES.get(key, [])


def add_unlocks_from_units(buildings: dict, units: dict, ships: dict):
    """Calcola unlocks_units per ogni edificio in base ai requisiti unita'."""
    for b in buildings:
        buildings[b]["unlocks_units"] = []
    for u_name, u_data in {**units, **ships}.items():
        for b in u_data.get("requires_buildings", []):
            if b in buildings:
                if u_name not in buildings[b].get("unlocks_units", []):
                    buildings[b].setdefault("unlocks_units", []).append(u_name)


def update_maintenance(config: dict):
    """Assicura che ogni unita'/nave abbia un costo di manutenzione."""
    maintenance = config.setdefault("maintenance", {})
    for u in config.get("units", {}):
        if u not in maintenance:
            maintenance[u] = config["units"][u].get("maintenance", 1)
    for s in config.get("ships", {}):
        if s not in maintenance:
            maintenance[s] = config["ships"][s].get("maintenance", 4)


def main():
    path = os.path.join(BASE_DIR, "data", "config", "game_config.json")
    with open(path, "r", encoding="utf-8") as f:
        config = json.load(f)

    config["settlement_types"] = SETTLEMENT_TYPES
    config["buildings"] = BUILDINGS
    add_unit_stats(config["units"])
    add_ship_stats(config["ships"])
    add_unlocks_from_units(BUILDINGS, config["units"], config["ships"])
    update_maintenance(config)

    # Aggiungi qualche unita' base evoluta se non esistono (sono gia' coperte dalle speciali,
    # ma inseriamo i nomi "base" per l'albero di reclutamento)
    units = config["units"]
    if "milizia" not in units:
        units["milizia"] = {
            "name": "Milizia contadina",
            "attack": 0.12, "defense": 0.04, "armor": 0.0, "speed": 2.0,
            "base_morale": 75, "experience": 0, "cost": 400, "pop": 1200,
            "maintenance": 0, "food": 1,
            "requires_buildings": ["centro_cittadino", "capanna_boscaioli"]
        }
    if "lancieri" not in units:
        units["lancieri"] = units["fanteria"].copy() if "fanteria" in units else {}
        units["lancieri"]["name"] = "Lancieri"
        units["lancieri"]["requires_buildings"] = ["caserma_i"]
    if "fanteria_pesante" not in units:
        units["fanteria_pesante"] = {
            "name": "Fanteria pesante",
            "attack": 0.35, "defense": 0.25, "armor": 0.25, "speed": 1.8,
            "base_morale": 105, "experience": 0, "cost": 1600, "pop": 800,
            "maintenance": 2, "food": 1, "ferro": 2, "armi": 2,
            "requires_buildings": ["caserma_ii"]
        }
    if "arcieri_evoluti" not in units:
        units["arcieri_evoluti"] = {
            "name": "Arcieri evoluti",
            "attack": 0.32, "defense": 0.1, "armor": 0.1, "speed": 2.5,
            "base_morale": 100, "experience": 0, "cost": 1200, "pop": 700,
            "maintenance": 2, "food": 1,
            "requires_buildings": ["campo_tiro_ii"]
        }
    if "balestrieri" not in units:
        units["balestrieri"] = {
            "name": "Balestrieri",
            "attack": 0.38, "defense": 0.12, "armor": 0.1, "speed": 2.2,
            "base_morale": 100, "experience": 0, "cost": 1300, "pop": 700,
            "maintenance": 2, "food": 1, "armi": 1,
            "requires_buildings": ["campo_tiro_iii", "officina_armi"]
        }

    with open(path, "w", encoding="utf-8") as f:
        json.dump(config, f, ensure_ascii=False, indent=2)

    print("Config aggiornato:")
    print(" - settlement_types:", len(SETTLEMENT_TYPES))
    print(" - buildings:", len(BUILDINGS))
    print(" - units:", len(config["units"]))
    print(" - ships:", len(config["ships"]))


if __name__ == "__main__":
    main()
