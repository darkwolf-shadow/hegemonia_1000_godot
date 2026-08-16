#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Corregge le province di terraferma erroneamente assegnate a 'Mare Aperto'."""
import json, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent))
from assign_tribes_1000 import choose_faction, load_country_info, generate_faction

GEO_PATH = Path('data/world/mappa_anno_1000.geojson')
PROV_PATH = Path('data/world/provinces_1000.json')
FACTIONS_PATH = Path('data/world/factions_1000.json')


def fix():
    geo = json.load(open(GEO_PATH, 'r', encoding='utf-8'))
    prov = json.load(open(PROV_PATH, 'r', encoding='utf-8'))
    factions = json.load(open(FACTIONS_PATH, 'r', encoding='utf-8'))
    info = load_country_info()

    fixed = 0
    for feature in geo['features']:
        props = feature['properties']
        if props.get('STATO_1000') != 'Mare Aperto':
            continue
        if props.get('featurecla') != 'Admin-1 states provinces':
            continue

        name = props.get('name') or ''
        admin = props.get('admin')
        iso = props.get('adm0_a3')
        lat = props.get('latitude')
        lon = props.get('longitude')

        # casi specifici derivati dall'analisi
        if name == 'Guantanamo Bay USNB':
            target = 'Tribù Taino'
        elif name == 'Paracel Islands':
            target = 'Isole Disabitate'
        else:
            target = choose_faction(name, admin, iso, lat, lon, props, info)

        if target == 'Mare Aperto':
            # Se rimane acqua, lascia invariato
            continue

        props['STATO_1000'] = target
        if name in prov:
            prov[name]['owner'] = target
        if target not in factions:
            factions[target] = generate_faction(target, info.get(iso, {}).get('continent'))
        fixed += 1

    with open(GEO_PATH, 'w', encoding='utf-8') as f:
        json.dump(geo, f, ensure_ascii=False, separators=(',', ':'))
    with open(PROV_PATH, 'w', encoding='utf-8') as f:
        json.dump(prov, f, ensure_ascii=False, indent=2)
    with open(FACTIONS_PATH, 'w', encoding='utf-8') as f:
        json.dump(factions, f, ensure_ascii=False, indent=2)

    print(f'Corrette {fixed} province da Mare Aperto a fazioni terrestri.')


if __name__ == '__main__':
    fix()
