#!/usr/bin/env python3
"""Aggiorna game_config.json con le unità e navi dell'anno 1000."""

import json
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

new_units = {
    "fanteria": {"name": "Fanti", "strength": 0.2, "cost": 1000, "pop": 1000, "maintenance": 1, "food": 1},
    "arcieri": {"name": "Arcieri", "strength": 0.22, "cost": 900, "pop": 800, "maintenance": 1, "food": 1},
    "cavalleria": {"name": "Cavalieri", "strength": 0.4, "cost": 1800, "pop": 500, "maintenance": 3, "food": 2},
    "cavalleria_pesante": {"name": "Cavalleria Pesante", "strength": 0.5, "cost": 2400, "pop": 350, "maintenance": 3, "food": 2, "ferro": 3, "armi": 2},
    "artiglieria": {"name": "Catapulta", "strength": 0.3, "cost": 2500, "pop": 150, "maintenance": 2, "food": 0, "pietra": 2, "legname": 2},
    "cataphractoi": {"name": "Cataphractoi", "strength": 0.6, "cost": 3000, "pop": 300, "maintenance": 4, "food": 3, "ferro": 4, "armi": 3},
    "varangian_guard": {"name": "Guardia Varanga", "strength": 0.5, "cost": 2500, "pop": 300, "maintenance": 3, "food": 2, "legname": 2, "ferro": 3, "armi": 2},
    "toxotai": {"name": "Toxotai", "strength": 0.25, "cost": 1000, "pop": 800, "maintenance": 1, "food": 1},
    "milites": {"name": "Milites", "strength": 0.3, "cost": 1200, "pop": 900, "maintenance": 2, "food": 1, "legname": 1, "ferro": 1},
    "ministeriales": {"name": "Ministeriales", "strength": 0.45, "cost": 2200, "pop": 400, "maintenance": 3, "food": 2, "ferro": 2, "armi": 2},
    "loricati": {"name": "Loricati", "strength": 0.55, "cost": 2800, "pop": 300, "maintenance": 4, "food": 2, "ferro": 4, "armi": 3},
    "berserker": {"name": "Berserker", "strength": 0.45, "cost": 1800, "pop": 500, "maintenance": 2, "food": 2, "legname": 2},
    "huskarl": {"name": "Huskarl", "strength": 0.4, "cost": 1600, "pop": 400, "maintenance": 2, "food": 2, "legname": 2, "ferro": 1, "armi": 1},
    "bondi": {"name": "Bondi", "strength": 0.15, "cost": 700, "pop": 1000, "maintenance": 1, "food": 1, "legname": 1},
    "jinete": {"name": "Jinete", "strength": 0.35, "cost": 1500, "pop": 400, "maintenance": 2, "food": 2},
    "black_guard": {"name": "Guardia Nera", "strength": 0.4, "cost": 1800, "pop": 500, "maintenance": 2, "food": 2, "legname": 1, "ferro": 1, "armi": 1},
    "sudanese_spearmen": {"name": "Lancieri Sudanese", "strength": 0.3, "cost": 1200, "pop": 900, "maintenance": 2, "food": 1},
    "armenian_archers": {"name": "Arcieri Armeni", "strength": 0.3, "cost": 1200, "pop": 700, "maintenance": 2, "food": 1},
    "mamluk_cavalry": {"name": "Cavalleria Mamluk", "strength": 0.5, "cost": 2600, "pop": 350, "maintenance": 3, "food": 2, "ferro": 3, "armi": 2},
    "magyar_cavalry": {"name": "Cavalleria Magiara", "strength": 0.35, "cost": 1600, "pop": 400, "maintenance": 2, "food": 2},
    "szekler_infantry": {"name": "Fanteria Szekler", "strength": 0.25, "cost": 1000, "pop": 800, "maintenance": 1, "food": 1},
    "druzhina": {"name": "Druzhina", "strength": 0.5, "cost": 2400, "pop": 350, "maintenance": 3, "food": 2, "ferro": 2, "armi": 2},
    "voi": {"name": "Voi (Milizia)", "strength": 0.15, "cost": 700, "pop": 1000, "maintenance": 1, "food": 1},
    "varangian_mercenaries": {"name": "Mercenari Varanghi", "strength": 0.45, "cost": 2200, "pop": 350, "maintenance": 3, "food": 2, "legname": 1, "ferro": 2, "armi": 2},
    "druzyna": {"name": "Drużyna", "strength": 0.45, "cost": 2200, "pop": 400, "maintenance": 3, "food": 2, "ferro": 2, "armi": 2},
    "polish_spearmen": {"name": "Lancieri Polacchi", "strength": 0.25, "cost": 900, "pop": 900, "maintenance": 1, "food": 1},
    "ghilman": {"name": "Ghilman", "strength": 0.5, "cost": 2600, "pop": 350, "maintenance": 3, "food": 2, "ferro": 3, "armi": 2},
    "daylami_infantry": {"name": "Fanteria Daylami", "strength": 0.35, "cost": 1400, "pop": 700, "maintenance": 2, "food": 1},
    "ghulam_cavalry": {"name": "Cavalleria Ghulam", "strength": 0.5, "cost": 2600, "pop": 350, "maintenance": 3, "food": 2, "ferro": 3, "armi": 2},
    "war_elephants": {"name": "Elefanti da Guerra", "strength": 0.7, "cost": 5000, "pop": 100, "maintenance": 5, "food": 4, "ferro": 1, "armi": 1},
    "afghan_infantry": {"name": "Fanteria Afghana", "strength": 0.25, "cost": 900, "pop": 900, "maintenance": 1, "food": 1},
    "turkish_horse_archers": {"name": "Arcieri a Cavallo Turchi", "strength": 0.35, "cost": 1600, "pop": 400, "maintenance": 2, "food": 2},
    "crossbowmen": {"name": "Balestrieri", "strength": 0.3, "cost": 1100, "pop": 700, "maintenance": 2, "food": 1},
    "shenbi_nu": {"name": "Shenbi Nu", "strength": 0.35, "cost": 1300, "pop": 700, "maintenance": 2, "food": 1},
    "fire_lance": {"name": "Lancia di Fuoco", "strength": 0.4, "cost": 1800, "pop": 300, "maintenance": 2, "food": 1, "ferro": 1, "armi": 1},
    "khitan_horse_archers": {"name": "Arcieri a Cavallo Khitan", "strength": 0.35, "cost": 1600, "pop": 400, "maintenance": 2, "food": 2},
    "liao_lancers": {"name": "Lancieri Liao", "strength": 0.45, "cost": 2200, "pop": 400, "maintenance": 3, "food": 2, "ferro": 2, "armi": 2},
    "tamil_infantry": {"name": "Fanteria Tamil", "strength": 0.22, "cost": 950, "pop": 900, "maintenance": 1, "food": 1},
    "elephant_corps": {"name": "Corpo degli Elefanti", "strength": 0.6, "cost": 4500, "pop": 120, "maintenance": 4, "food": 3, "ferro": 1, "armi": 1},
    "khmer_spearmen": {"name": "Lancieri Khmer", "strength": 0.25, "cost": 950, "pop": 900, "maintenance": 1, "food": 1},
    "khmer_elephants": {"name": "Elefanti Khmer", "strength": 0.65, "cost": 4800, "pop": 100, "maintenance": 5, "food": 4},
    "samurai": {"name": "Samurai", "strength": 0.5, "cost": 2500, "pop": 300, "maintenance": 3, "food": 2, "ferro": 3, "armi": 2},
    "yamato_infantry": {"name": "Fanteria Yamato", "strength": 0.2, "cost": 900, "pop": 900, "maintenance": 1, "food": 1},
    "malay_archers": {"name": "Arcieri Malese", "strength": 0.25, "cost": 950, "pop": 800, "maintenance": 1, "food": 1},
    "soninke_cavalry": {"name": "Cavalleria Soninke", "strength": 0.35, "cost": 1500, "pop": 400, "maintenance": 2, "food": 2},
    "sudani_spearmen": {"name": "Lancieri Sudani", "strength": 0.25, "cost": 900, "pop": 900, "maintenance": 1, "food": 1},
    "jaguar_warrior": {"name": "Guerriero Giaguaro", "strength": 0.45, "cost": 1800, "pop": 400, "maintenance": 2, "food": 2, "legname": 1, "ferro": 1, "armi": 1},
    "eagle_warrior": {"name": "Guerriero Aquila", "strength": 0.35, "cost": 1500, "pop": 450, "maintenance": 2, "food": 2},
    "coyote_warrior": {"name": "Guerriero Coyote", "strength": 0.3, "cost": 1200, "pop": 500, "maintenance": 2, "food": 1},
    "otomi_aux": {"name": "Ausiliari Otomi", "strength": 0.2, "cost": 800, "pop": 900, "maintenance": 1, "food": 1},
    "maya_spearmen": {"name": "Lancieri Maya", "strength": 0.2, "cost": 850, "pop": 900, "maintenance": 1, "food": 1},
    "holcan": {"name": "Holcan", "strength": 0.4, "cost": 1600, "pop": 400, "maintenance": 2, "food": 2},
    "atlatl": {"name": "Atlatl", "strength": 0.25, "cost": 900, "pop": 700, "maintenance": 1, "food": 1},
}

new_ships = {
    "drakkar": {"name": "Drakkar", "cost": 6000, "pop": 150, "wood": 5, "strength": 0.5, "food": 1},
    "galea": {"name": "Galea", "cost": 5000, "pop": 150, "wood": 4, "strength": 0.4, "food": 1},
    "dromone": {"name": "Dromone", "cost": 8000, "pop": 200, "wood": 6, "strength": 0.7, "food": 1},
    "giunca": {"name": "Giunca Cinese", "cost": 5500, "pop": 180, "wood": 5, "strength": 0.45, "food": 1},
    "tower_ship": {"name": "Nave Torre", "cost": 9000, "pop": 250, "wood": 7, "strength": 0.65, "food": 1},
    "nave_guerra": {"name": "Nave da Guerra", "cost": 7000, "pop": 200, "wood": 6, "strength": 0.55, "food": 1},
    "nave_guerra_indiana": {"name": "Nave da Guerra Indiana", "cost": 7000, "pop": 200, "wood": 6, "strength": 0.55, "food": 1},
    "canoa": {"name": "Canoa da Guerra", "cost": 1000, "pop": 80, "wood": 2, "strength": 0.2, "food": 0},
}

maintenance = {
    "fanteria": 1, "arcieri": 1, "cavalleria": 3, "cavalleria_pesante": 3, "artiglieria": 2,
    "cataphractoi": 4, "varangian_guard": 3, "toxotai": 1, "milites": 2, "ministeriales": 3,
    "loricati": 4, "berserker": 2, "huskarl": 2, "bondi": 1, "jinete": 2,
    "black_guard": 2, "sudanese_spearmen": 2, "armenian_archers": 2, "mamluk_cavalry": 3,
    "magyar_cavalry": 2, "szekler_infantry": 1, "druzhina": 3, "voi": 1, "varangian_mercenaries": 3,
    "druzyna": 3, "polish_spearmen": 1, "ghilman": 3, "daylami_infantry": 2, "ghulam_cavalry": 3,
    "war_elephants": 5, "afghan_infantry": 1, "turkish_horse_archers": 2, "crossbowmen": 2,
    "shenbi_nu": 2, "fire_lance": 2, "khitan_horse_archers": 2, "liao_lancers": 3,
    "tamil_infantry": 1, "elephant_corps": 4, "khmer_spearmen": 1, "khmer_elephants": 5,
    "samurai": 3, "yamato_infantry": 1, "malay_archers": 1, "soninke_cavalry": 2,
    "sudani_spearmen": 1, "jaguar_warrior": 2, "eagle_warrior": 2, "coyote_warrior": 2,
    "otomi_aux": 1, "maya_spearmen": 1, "holcan": 2, "atlatl": 1,
    "drakkar": 5, "galea": 4, "dromone": 6, "giunca": 5, "tower_ship": 8,
    "nave_guerra": 7, "nave_guerra_indiana": 7, "canoa": 2
}

tactics = {
    "standard": {},
    "charge": {
        "cavalleria": 1.2, "cavalleria_pesante": 1.2, "cataphractoi": 1.2, "loricati": 1.2,
        "mamluk_cavalry": 1.2, "druzhina": 1.2, "ghilman": 1.2, "ghulam_cavalry": 1.2,
        "liao_lancers": 1.2, "magyar_cavalry": 1.1, "turkish_horse_archers": 1.1,
        "khitan_horse_archers": 1.1, "jinete": 1.1, "soninke_cavalry": 1.1,
        "fanteria": 0.9, "arcieri": 0.9, "artiglieria": 0.9, "atlatl": 0.9
    },
    "shield_wall": {
        "fanteria": 1.2, "milites": 1.2, "huskarl": 1.2, "varangian_guard": 1.2,
        "black_guard": 1.2, "sudanese_spearmen": 1.2, "daylami_infantry": 1.2,
        "polish_spearmen": 1.2, "khmer_spearmen": 1.2, "maya_spearmen": 1.2,
        "sudani_spearmen": 1.2, "tamil_infantry": 1.1, "yamato_infantry": 1.1,
        "cavalleria": 0.9, "cavalleria_pesante": 0.9, "cataphractoi": 0.9,
        "magyar_cavalry": 0.9, "turkish_horse_archers": 0.9
    },
    "skirmish": {
        "arcieri": 1.2, "toxotai": 1.2, "armenian_archers": 1.2, "crossbowmen": 1.2,
        "shenbi_nu": 1.2, "malay_archers": 1.2, "atlatl": 1.2,
        "magyar_cavalry": 1.1, "turkish_horse_archers": 1.1, "khitan_horse_archers": 1.1,
        "jinete": 1.1, "cavalleria": 1.0,
        "fanteria": 0.9, "cavalleria_pesante": 0.9
    },
    "elephant_charge": {
        "war_elephants": 1.25, "elephant_corps": 1.25, "khmer_elephants": 1.25,
        "fanteria": 0.95, "cavalleria": 0.95
    }
}

path = os.path.join(BASE_DIR, "data", "config", "game_config.json")
with open(path, "r", encoding="utf-8") as f:
    config = json.load(f)

config["units"] = new_units
config["ships"] = new_ships
config["maintenance"] = maintenance
config["tactics"] = tactics

with open(path, "w", encoding="utf-8") as f:
    json.dump(config, f, ensure_ascii=False, indent=2)

print("game_config.json aggiornato:", len(new_units), "unità,", len(new_ships), "navi")
