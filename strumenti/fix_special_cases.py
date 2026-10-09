#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Corregge casi particolari e nomi generici rimasti nelle province."""
import json, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent))
from assign_tribes_1000 import choose_faction, load_country_info, generate_faction

GEO_PATH = Path('data/world/mappa_anno_1000.geojson')
PROV_PATH = Path('data/world/provinces_1000.json')
FACTIONS_PATH = Path('data/world/factions_1000.json')

UPDATE_ISOS = {'UMI', 'USG', 'IRN', 'SDS', 'CUW', 'ABW', 'BES', 'SPM', 'JEY', 'GGY', 'IMN'}
UPDATE_ADMINS = {'Regno Unito', 'Impero Russo'}
UPDATE_OWNERS = {
    'Tribù Locale',
    'Tribù di Iran (Islamic Republic of)',
    'Tribù di United States Minor Outlying Islands',
    'Tribù di Curaçao',
    'Tribù di Aruba',
    'Tribù di Saint Pierre and Miquelon',
    'Tribù di Bonaire',
    'Tribù di Sint Eustatius',
    'Tribù di Saba',
}


def needs_update(props):
    iso = props.get('adm0_a3')
    admin = props.get('admin')
    owner = props.get('STATO_1000')
    if iso in UPDATE_ISOS:
        return True
    if admin in UPDATE_ADMINS and not iso:
        return True
    if owner in UPDATE_OWNERS:
        return True
    return False


def fix():
    geo = json.load(open(GEO_PATH, 'r', encoding='utf-8'))
    prov = json.load(open(PROV_PATH, 'r', encoding='utf-8'))
    factions = json.load(open(FACTIONS_PATH, 'r', encoding='utf-8'))
    info = load_country_info()

    changed = 0
    for feature in geo['features']:
        props = feature['properties']
        if not needs_update(props):
            continue
        name = props.get('name') or ''
        admin = props.get('admin')
        iso = props.get('adm0_a3')
        lat = props.get('latitude')
        lon = props.get('longitude')
        target = choose_faction(name, admin, iso, lat, lon, props, info)
        if target != props.get('STATO_1000'):
            props['STATO_1000'] = target
            if name in prov:
                prov[name]['owner'] = target
            if target not in factions:
                factions[target] = generate_faction(target, info.get(iso, {}).get('continent'))
            changed += 1

    with open(GEO_PATH, 'w', encoding='utf-8') as f:
        json.dump(geo, f, ensure_ascii=False, separators=(',', ':'))
    with open(PROV_PATH, 'w', encoding='utf-8') as f:
        json.dump(prov, f, ensure_ascii=False, indent=2)
    with open(FACTIONS_PATH, 'w', encoding='utf-8') as f:
        json.dump(factions, f, ensure_ascii=False, indent=2)

    print(f'Corrette {changed} province speciali.')


if __name__ == '__main__':
    fix()
