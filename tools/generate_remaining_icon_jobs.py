import json, os

base_dir = r'C:\Users\Administrator\repos\hegemonia_1000_godot'

building_cells = [
    ["centro_cittadino", "mercato", "monastero", "caserma_i", "caserma_ii", "caserma_iii", "scuderia_i", "scuderia_ii", "scuderia_iii"],
    ["campo_tiro_i", "campo_tiro_ii", "campo_tiro_iii", "officina_assedio_i", "officina_assedio_ii", "officina_assedio_iii", "officina_armi", "fucina", "arsenale_i"],
    ["arsenale_ii", "molo_i", "molo_ii", "mercato_marittimo", "miniera", "segheria", "capanna_boscaioli", "mulino", "magazzino"],
    ["cortile_cavaliere", "fortezza_frontiera", "strade", ""]
]

building_desc = {
    "centro_cittadino": "town center with administrative hall, main gate and banner",
    "mercato": "open-air market with stalls, awnings and goods",
    "monastero": "religious complex with temple/shrine, courtyard and bell tower",
    "caserma_i": "small wooden barracks with training yard",
    "caserma_ii": "medium barracks with watchtower and palisade",
    "caserma_iii": "large fortress barracks with towers and courtyard",
    "scuderia_i": "small stables with horses and hay",
    "scuderia_ii": "medium cavalry stables with hitching posts",
    "scuderia_iii": "grand horse complex with pavilion and training ring",
    "campo_tiro_i": "archery range with straw targets",
    "campo_tiro_ii": "covered archery yard with multiple targets",
    "campo_tiro_iii": "large archery compound with towers and galleries",
    "officina_assedio_i": "siege workshop with wooden trebuchet frame",
    "officina_assedio_ii": "siege yard with catapult and ballista",
    "officina_assedio_iii": "grand siege arsenal with multiple trebuchets",
    "officina_armi": "weaponsmith workshop with anvil, polearms and furnace",
    "fucina": "blacksmith forge with bellows and hammers",
    "arsenale_i": "small dockside ship shed with oars and ropes",
    "arsenale_ii": "large naval dockyard with ship sheds and cranes",
    "molo_i": "simple wooden pier with mooring posts",
    "molo_ii": "stone quay with cargo and a merchant ship",
    "mercato_marittimo": "harbor market with stalls and a ship at dock",
    "miniera": "mine entrance in a hill with cart tracks and ore",
    "segheria": "sawmill with water wheel and cut planks",
    "capanna_boscaioli": "woodcutter hut with thatched roof and log piles",
    "mulino": "water mill with turning wheel and grain sacks",
    "magazzino": "warehouse with roof, amphorae and crate stacks",
    "cortile_cavaliere": "cavalry training courtyard with sand and posts",
    "fortezza_frontiera": "frontier fortress with watchtower and crenellated walls",
    "strade": "paved road with trees and milestone"
}

ship_cells = ["canoa", "drakkar", "dromone", "galea", "giunca", "nave_guerra", "nave_guerra_indiana", "tower_ship"]
ship_desc = {
    "canoa": "small canoe with paddles",
    "drakkar": "long Viking-style warship with shields and sail",
    "dromone": "Byzantine war galley with ram and oars",
    "galea": "Mediterranean galley with lateen sail",
    "giunca": "Asian junk with square sails",
    "nave_guerra": "heavy war cog with forecastle",
    "nave_guerra_indiana": "Indian ocean war dhow",
    "tower_ship": "tower ship with fighting platform"
}

settlement_cells = ["civil", "military", "industrial", "port"]
settlement_desc = {
    "civil": "civilian town cluster with houses and market",
    "military": "military settlement with barracks and watchtower",
    "industrial": "industrial settlement with workshops and smoke",
    "port": "port settlement with jetties and warehouses"
}

unit_generic_order = ["milizia", "fanteria", "arcieri", "cavalleria", "cavalleria_pesante", "artiglieria", "lancieri", "fanteria_pesante", "balestrieri", "arcieri_evoluti", "szekler_infantry"]
unit_generic_desc = {
    "milizia": "peasant levy with simple weapon and clothes",
    "fanteria": "infantry spearman with shield",
    "arcieri": "archer drawing a bow",
    "cavalleria": "light cavalry rider with lance",
    "cavalleria_pesante": "heavy cavalry on armored horse",
    "artiglieria": "siege crew with a stone-thrower",
    "lancieri": "pikeman with long spear",
    "fanteria_pesante": "heavy infantry with axe and mail",
    "balestrieri": "crossbowman aiming a crossbow",
    "arcieri_evoluti": "veteran archers in loose formation",
    "szekler_infantry": "medium infantry with curved blade and shield"
}

region_specific_units = {
    "indian": ["war_elephants", "tamil_infantry", "elephant_corps"],
    "african": ["soninke_cavalry", "sudani_spearmen"],
    "american": ["jaguar_warrior", "eagle_warrior", "coyote_warrior", "otomi_aux", "maya_spearmen", "holcan", "atlatl"]
}

unit_specific_desc = {
    "war_elephants": "war elephant with tower and mahout",
    "tamil_infantry": "Tamil spearman with round shield",
    "elephant_corps": "elephant corps with armored howdah",
    "soninke_cavalry": "Soninke light cavalry with javelins",
    "sudani_spearmen": "Sudanese spearmen with large shields",
    "jaguar_warrior": "jaguar warrior in pelt and macuahuitl",
    "eagle_warrior": "eagle warrior with feathered cape and spear",
    "coyote_warrior": "coyote warrior with obsidian-edged club",
    "otomi_aux": "Otomi auxiliary with bow and quilted armor",
    "maya_spearmen": "Maya spearman with long pole and shield",
    "holcan": "Maya shock warrior with heavy club",
    "atlatl": "warrior throwing a dart with an atlatl"
}

region_styles = {
    "indian": "2.5D isometric medieval strategy game icon, Indian subcontinent year 1000, carved stone temples with tiered vimana towers, domed pavilions, red sandstone and lotus motifs, hand-painted limited palette, centered in cell, transparent background, no overlap, no text",
    "african": "2.5D isometric medieval strategy game icon, West African Sahel year 1000, mud-brick adobe architecture, thatched roofs, wooden palisades, terracotta and geometric patterns, hand-painted limited palette, centered in cell, transparent background, no overlap, no text",
    "american": "2.5D isometric medieval strategy game icon, Mesoamerican year 1000, Maya and Toltec style stepped pyramids and stone temples with stucco, jungle setting, bright plumage and feathered motifs, hand-painted limited palette, centered in cell, transparent background, no overlap, no text"
}

def chunk(lst, n):
    for i in range(0, len(lst), n):
        yield lst[i:i+n]

def make_building_jobs(region):
    style = region_styles[region]
    jobs = []
    for idx, group in enumerate(building_cells):
        cells = []
        for b in group:
            if b:
                cells.append({"id": b, "desc": building_desc[b]})
            else:
                cells.append({"id": "", "desc": "blank"})
        rows = 2 if idx == 3 else 3
        cols = 2 if idx == 3 else 3
        jobs.append({
            "id": f"buildings_{idx}",
            "category": "buildings",
            "rows": rows,
            "cols": cols,
            "style": style + ", building",
            "cells": cells
        })
    return jobs

def make_ship_jobs(region):
    style = region_styles[region]
    cells = [{"id": s, "desc": ship_desc[s]} for s in ship_cells]
    while len(cells) < 9:
        cells.append({"id": "", "desc": "blank"})
    return [{
        "id": "ships_0",
        "category": "ships",
        "rows": 3,
        "cols": 3,
        "style": style + ", ship or boat",
        "cells": cells
    }]

def make_settlement_jobs(region):
    style = region_styles[region]
    return [{
        "id": "settlements_0",
        "category": "settlements",
        "rows": 2,
        "cols": 2,
        "style": style + ", settlement",
        "cells": [{"id": s, "desc": settlement_desc[s]} for s in settlement_cells]
    }]

def make_unit_jobs(region):
    style = region_styles[region] + ", single figure or small group, no repeated faces"
    units = unit_generic_order + region_specific_units[region]
    desc_map = {**unit_generic_desc, **unit_specific_desc}
    jobs = []
    for idx, group in enumerate(chunk(units, 9)):
        rows = 3 if len(group) > 4 else 2
        cols = 3 if len(group) > 4 else 2
        cells = []
        for u in group:
            cells.append({"id": u, "desc": desc_map[u]})
        while len(cells) < rows * cols:
            cells.append({"id": "", "desc": "blank"})
        jobs.append({
            "id": f"units_{idx}",
            "category": "units",
            "rows": rows,
            "cols": cols,
            "style": style + ", unit",
            "cells": cells
        })
    return jobs

for region in ["indian", "african", "american"]:
    jobs = make_building_jobs(region) + make_ship_jobs(region) + make_settlement_jobs(region) + make_unit_jobs(region)
    path = os.path.join(base_dir, 'tools', f'{region}_icon_jobs.json')
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(jobs, f, indent=2, ensure_ascii=False)
    print('wrote', path, 'jobs', len(jobs))
