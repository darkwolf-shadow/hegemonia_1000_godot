#!/usr/bin/env python3
"""Arricchisce game_config.json con albero tecnologico, recruit_pool e effetti avanzati.
Modello: Medieval II Total War adattato al 1000.
Dark Corporation / Stev"""

import json
import os
import copy

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONFIG_PATH = os.path.join(BASE_DIR, "data", "config", "game_config.json")

with open(CONFIG_PATH, "r", encoding="utf-8") as f:
    config = json.load(f)

buildings = config["buildings"]

# ============================================================
# 1. ALBERO TECNOLOGICO: requires, upgrades, construction_turns
# ============================================================

TREE = {
    # Base
    "centro_cittadino": {"requires": [], "upgrades": None, "turns": 2},
    # Economico - legname
    "capanna_boscaioli": {"requires": ["centro_cittadino"], "upgrades": "segheria", "turns": 2},
    "segheria": {"requires": ["capanna_boscaioli"], "upgrades": None, "turns": 3},
    # Economico - cibo
    "mulino": {"requires": ["centro_cittadino"], "upgrades": None, "turns": 3},
    "magazzino": {"requires": ["centro_cittadino"], "upgrades": None, "turns": 3},
    # Economico - mercato
    "mercato": {"requires": ["centro_cittadino"], "upgrades": None, "turns": 3},
    "mercato_marittimo": {"requires": ["mercato", "molo_i"], "upgrades": None, "turns": 4},
    # Economico - miniere
    "miniera": {"requires": ["centro_cittadino"], "upgrades": None, "turns": 4},
    # Economico - armi
    "fucina": {"requires": ["miniera"], "upgrades": "officina_armi", "turns": 3},
    "officina_armi": {"requires": ["fucina", "miniera"], "upgrades": None, "turns": 5},
    # Infrastruttura
    "strade": {"requires": ["centro_cittadino"], "upgrades": None, "turns": 2},
    # Religione
    "monastero": {"requires": ["centro_cittadino"], "upgrades": None, "turns": 6},
    # Militare - fanteria
    "caserma_i": {"requires": ["centro_cittadino"], "upgrades": "caserma_ii", "turns": 3},
    "caserma_ii": {"requires": ["caserma_i", "fortezza_frontiera"], "upgrades": "caserma_iii", "turns": 5},
    "caserma_iii": {"requires": ["caserma_ii", "officina_armi"], "upgrades": None, "turns": 7},
    # Militare - tiro
    "campo_tiro_i": {"requires": ["centro_cittadino"], "upgrades": "campo_tiro_ii", "turns": 3},
    "campo_tiro_ii": {"requires": ["campo_tiro_i", "fortezza_frontiera"], "upgrades": "campo_tiro_iii", "turns": 5},
    "campo_tiro_iii": {"requires": ["campo_tiro_ii", "officina_armi"], "upgrades": None, "turns": 7},
    # Militare - cavalleria
    "scuderia_i": {"requires": ["centro_cittadino"], "upgrades": "scuderia_ii", "turns": 3},
    "scuderia_ii": {"requires": ["scuderia_i", "fucina"], "upgrades": "scuderia_iii", "turns": 5},
    "scuderia_iii": {"requires": ["scuderia_ii", "officina_armi"], "upgrades": None, "turns": 7},
    # Militare - cortile cavaliere
    "cortile_cavaliere": {"requires": ["scuderia_ii", "monastero"], "upgrades": None, "turns": 6},
    # Militare - assedio
    "officina_assedio_i": {"requires": ["caserma_i"], "upgrades": "officina_assedio_ii", "turns": 4},
    "officina_assedio_ii": {"requires": ["officina_assedio_i", "fucina"], "upgrades": "officina_assedio_iii", "turns": 6},
    "officina_assedio_iii": {"requires": ["officina_assedio_ii", "officina_armi"], "upgrades": None, "turns": 8},
    # Militare - fortificazioni
    "fortezza_frontiera": {"requires": ["centro_cittadino"], "upgrades": None, "turns": 5},
    # Portuale
    "molo_i": {"requires": ["centro_cittadino"], "upgrades": "molo_ii", "turns": 3},
    "molo_ii": {"requires": ["molo_i"], "upgrades": None, "turns": 5},
    "arsenale_i": {"requires": ["molo_ii", "fucina"], "upgrades": "arsenale_ii", "turns": 6},
    "arsenale_ii": {"requires": ["arsenale_i", "officina_armi"], "upgrades": None, "turns": 8},
}

for bname, bdata in buildings.items():
    tree = TREE.get(bname, {"requires": [], "upgrades": None, "turns": 3})
    bdata["requires"] = tree["requires"]
    bdata["upgrades"] = tree["upgrades"]
    bdata["construction_turns"] = tree["turns"]

# ============================================================
# 2. RECRUIT_POOL per edifici militari
#    Formato: {unit_name: {initial, rate, max, experience}}
# ============================================================

RECRUIT_POOLS = {
    "caserma_i": {
        "fanteria": {"initial": 1, "rate": 0.3, "max": 3, "experience": 0},
        "lancieri": {"initial": 1, "rate": 0.3, "max": 3, "experience": 0},
        "milizia": {"initial": 1, "rate": 0.4, "max": 4, "experience": 0},
    },
    "caserma_ii": {
        "fanteria_pesante": {"initial": 1, "rate": 0.25, "max": 3, "experience": 1},
        "milites": {"initial": 1, "rate": 0.25, "max": 3, "experience": 1},
        "huskarl": {"initial": 1, "rate": 0.2, "max": 2, "experience": 1},
        "berserker": {"initial": 1, "rate": 0.2, "max": 2, "experience": 1},
        "sudanese_spearmen": {"initial": 1, "rate": 0.25, "max": 3, "experience": 1},
        "daylami_infantry": {"initial": 1, "rate": 0.25, "max": 3, "experience": 1},
    },
    "caserma_iii": {
        "varangian_guard": {"initial": 1, "rate": 0.15, "max": 2, "experience": 2},
        "black_guard": {"initial": 1, "rate": 0.15, "max": 2, "experience": 2},
    },
    "campo_tiro_i": {
        "arcieri": {"initial": 1, "rate": 0.3, "max": 3, "experience": 0},
        "atlatl": {"initial": 1, "rate": 0.3, "max": 3, "experience": 0},
        "malay_archers": {"initial": 1, "rate": 0.3, "max": 3, "experience": 0},
    },
    "campo_tiro_ii": {
        "arcieri_evoluti": {"initial": 1, "rate": 0.25, "max": 3, "experience": 1},
        "toxotai": {"initial": 1, "rate": 0.25, "max": 3, "experience": 1},
        "armenian_archers": {"initial": 1, "rate": 0.25, "max": 3, "experience": 1},
        "crossbowmen": {"initial": 1, "rate": 0.2, "max": 2, "experience": 1},
        "eagle_warrior": {"initial": 1, "rate": 0.2, "max": 2, "experience": 1},
    },
    "campo_tiro_iii": {
        "balestrieri": {"initial": 1, "rate": 0.2, "max": 2, "experience": 2},
        "shenbi_nu": {"initial": 1, "rate": 0.2, "max": 2, "experience": 2},
    },
    "scuderia_i": {
        "cavalleria": {"initial": 1, "rate": 0.2, "max": 2, "experience": 0},
        "jinete": {"initial": 1, "rate": 0.2, "max": 2, "experience": 0},
        "magyar_cavalry": {"initial": 1, "rate": 0.2, "max": 2, "experience": 0},
        "soninke_cavalry": {"initial": 1, "rate": 0.2, "max": 2, "experience": 0},
        "turkish_horse_archers": {"initial": 1, "rate": 0.2, "max": 2, "experience": 0},
        "khitan_horse_archers": {"initial": 1, "rate": 0.2, "max": 2, "experience": 0},
    },
    "scuderia_ii": {
        "cavalleria_pesante": {"initial": 1, "rate": 0.15, "max": 2, "experience": 1},
        "ministeriales": {"initial": 1, "rate": 0.15, "max": 2, "experience": 1},
        "druzyna": {"initial": 1, "rate": 0.15, "max": 2, "experience": 1},
        "liao_lancers": {"initial": 1, "rate": 0.15, "max": 2, "experience": 1},
        "samurai": {"initial": 1, "rate": 0.15, "max": 2, "experience": 1},
    },
    "scuderia_iii": {
        "cataphractoi": {"initial": 1, "rate": 0.1, "max": 1, "experience": 2},
    },
    "cortile_cavaliere": {
        "mamluk_cavalry": {"initial": 1, "rate": 0.15, "max": 2, "experience": 2},
        "druzhina": {"initial": 1, "rate": 0.15, "max": 2, "experience": 2},
        "ghilman": {"initial": 1, "rate": 0.15, "max": 2, "experience": 2},
        "ghulam_cavalry": {"initial": 1, "rate": 0.15, "max": 2, "experience": 2},
        "loricati": {"initial": 1, "rate": 0.15, "max": 2, "experience": 2},
    },
    "officina_assedio_i": {
        "artiglieria": {"initial": 0, "rate": 0.1, "max": 1, "experience": 0},
    },
    "officina_assedio_ii": {
        "artiglieria": {"initial": 1, "rate": 0.15, "max": 2, "experience": 1},
        "war_elephants": {"initial": 0, "rate": 0.1, "max": 1, "experience": 1},
        "elephant_corps": {"initial": 0, "rate": 0.1, "max": 1, "experience": 1},
        "khmer_elephants": {"initial": 0, "rate": 0.1, "max": 1, "experience": 1},
    },
    "officina_assedio_iii": {
        "fire_lance": {"initial": 1, "rate": 0.15, "max": 2, "experience": 2},
    },
    "arsenale_i": {
        "drakkar": {"initial": 1, "rate": 0.2, "max": 2, "experience": 0},
        "dromone": {"initial": 1, "rate": 0.2, "max": 2, "experience": 0},
        "nave_guerra_indiana": {"initial": 1, "rate": 0.2, "max": 2, "experience": 0},
        "canoa": {"initial": 1, "rate": 0.3, "max": 3, "experience": 0},
    },
    "arsenale_ii": {
        "tower_ship": {"initial": 1, "rate": 0.15, "max": 2, "experience": 1},
        "nave_guerra": {"initial": 1, "rate": 0.15, "max": 2, "experience": 1},
    },
    "molo_i": {
        "canoa": {"initial": 1, "rate": 0.3, "max": 3, "experience": 0},
    },
    "molo_ii": {
        "galea": {"initial": 1, "rate": 0.2, "max": 2, "experience": 0},
        "giunca": {"initial": 1, "rate": 0.2, "max": 2, "experience": 0},
    },
    # Edifici che sbloccano unita' speciali
    "monastero": {
        "jaguar_warrior": {"initial": 0, "rate": 0.1, "max": 1, "experience": 2},
        "holcan": {"initial": 0, "rate": 0.1, "max": 1, "experience": 2},
    },
    "mercato": {
        "varangian_mercenaries": {"initial": 1, "rate": 0.15, "max": 2, "experience": 1},
    },
    "centro_cittadino": {
        "bondi": {"initial": 1, "rate": 0.3, "max": 3, "experience": 0},
        "voi": {"initial": 1, "rate": 0.3, "max": 3, "experience": 0},
        "otomi_aux": {"initial": 1, "rate": 0.3, "max": 3, "experience": 0},
    },
}

for bname, pool in RECRUIT_POOLS.items():
    if bname in buildings:
        buildings[bname]["recruit_pool"] = pool

# ============================================================
# 3. EFFETTI ARRICCHITI
#    Nuovi campi: happiness_bonus, population_growth_bonus,
#    weapon_bonus, armour_bonus, free_upkeep, recruitment_slots,
#    law_bonus, defense_bonus, trade_bonus
# ============================================================

EXTRA_EFFECTS = {
    "centro_cittadino": {"happiness_bonus": 5, "population_growth_bonus": 1, "recruitment_slots": 1},
    "mercato": {"trade_bonus": 10, "happiness_bonus": 2},
    "mercato_marittimo": {"trade_bonus": 20, "happiness_bonus": 3},
    "mulino": {"population_growth_bonus": 2},
    "monastero": {"happiness_bonus": 10, "law_bonus": 5},
    "magazzino": {"population_growth_bonus": 1, "happiness_bonus": 2},
    "strade": {"trade_bonus": 5, "happiness_bonus": 1},
    "fortezza_frontiera": {"defense_bonus": 15, "happiness_bonus": 5, "free_upkeep": 2},
    "caserma_i": {"recruitment_slots": 1, "free_upkeep": 1},
    "caserma_ii": {"recruitment_slots": 2, "free_upkeep": 2, "weapon_bonus": 1},
    "caserma_iii": {"recruitment_slots": 3, "free_upkeep": 3, "weapon_bonus": 2, "armour_bonus": 1},
    "campo_tiro_i": {"recruitment_slots": 1},
    "campo_tiro_ii": {"recruitment_slots": 2, "weapon_bonus": 1},
    "campo_tiro_iii": {"recruitment_slots": 3, "weapon_bonus": 2},
    "scuderia_i": {"recruitment_slots": 1},
    "scuderia_ii": {"recruitment_slots": 2, "weapon_bonus": 1},
    "scuderia_iii": {"recruitment_slots": 3, "weapon_bonus": 2, "armour_bonus": 1},
    "cortile_cavaliere": {"recruitment_slots": 2, "happiness_bonus": 3, "armour_bonus": 2},
    "officina_assedio_i": {"recruitment_slots": 1},
    "officina_assedio_ii": {"recruitment_slots": 2, "weapon_bonus": 1},
    "officina_assedio_iii": {"recruitment_slots": 3, "weapon_bonus": 2},
    "fucina": {"weapon_bonus": 1},
    "officina_armi": {"weapon_bonus": 2, "armour_bonus": 1},
    "molo_i": {"trade_bonus": 5},
    "molo_ii": {"trade_bonus": 10, "recruitment_slots": 1},
    "arsenale_i": {"recruitment_slots": 2, "free_upkeep": 1},
    "arsenale_ii": {"recruitment_slots": 3, "free_upkeep": 2},
    "miniera": {"happiness_bonus": -2},
    "segheria": {"happiness_bonus": -1},
    "capanna_boscaioli": {},
}

for bname, extra in EXTRA_EFFECTS.items():
    if bname in buildings:
        for k, v in extra.items():
            buildings[bname]["effects"][k] = v

# ============================================================
# 4. Aggiungi sezione technology_tree (riassunto visivo)
# ============================================================

config["technology_tree"] = {
    "description": "Albero tecnologico edifici. requires = prerequisiti, upgrades = evoluzione.",
    "categories": {
        "core": ["centro_cittadino"],
        "economic_food": ["mulino", "magazzino"],
        "economic_wood": ["capanna_boscaioli", "segheria"],
        "economic_mine": ["miniera"],
        "economic_weapons": ["fucina", "officina_armi"],
        "economic_trade": ["mercato", "mercato_marittimo", "strade"],
        "religious": ["monastero"],
        "military_infantry": ["caserma_i", "caserma_ii", "caserma_iii"],
        "military_ranged": ["campo_tiro_i", "campo_tiro_ii", "campo_tiro_iii"],
        "military_cavalry": ["scuderia_i", "scuderia_ii", "scuderia_iii", "cortile_cavaliere"],
        "military_siege": ["officina_assedio_i", "officina_assedio_ii", "officina_assedio_iii"],
        "military_fort": ["fortezza_frontiera"],
        "naval": ["molo_i", "molo_ii", "arsenale_i", "arsenale_ii"],
    }
}

# ============================================================
# 5. Aggiungi population ai settlement_types
# ============================================================

for stname, stdata in config.get("settlement_types", {}).items():
    if "base_population" not in stdata:
        stdata["base_population"] = 2000 if stname == "civil" else 1000
    if "max_slots" not in stdata:
        stdata["max_slots"] = stdata.get("base_slots", 8) + 4

# ============================================================
# Salva
# ============================================================

with open(CONFIG_PATH, "w", encoding="utf-8") as f:
    json.dump(config, f, ensure_ascii=False, indent=2)

print(f"Configurazione aggiornata: {len(buildings)} edifici")
print(f"Edifici con recruit_pool: {len(RECRUIT_POOLS)}")
print(f"Edifici con requires: {sum(1 for b in buildings.values() if b.get('requires'))}")
print(f"Edifici con upgrades: {sum(1 for b in buildings.values() if b.get('upgrades'))}")
print(f"Technology tree aggiunto con {len(config['technology_tree']['categories'])} categorie")
