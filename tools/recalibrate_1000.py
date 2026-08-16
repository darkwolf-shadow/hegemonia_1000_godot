#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Ricalibrazione storica dei confini e delle economie per Hegemonia 1000.
Applica regole storiche all'anno 1000 a provinces_1000.json e a mappa_anno_1000.geojson.
Modalità dry-run stampa i totali previsti senza scrivere file.
Uso: python tools/recalibrate_1000.py          (dry-run)
     python tools/recalibrate_1000.py --apply (applica)
"""

import json, collections, copy, sys

GEO_PATH = 'data/world/mappa_anno_1000.geojson'
PROV_PATH = 'data/world/provinces_1000.json'
OUT_LOG = 'tools/recalibration_log.txt'

SEA_FEATURECLAS = {'sea','ocean','gulf','bay','strait','sound','channel','lagoon','fjord','river','reef','inlet'}

def is_sea(props):
    fc = (props.get('featurecla') or '').lower()
    if fc in SEA_FEATURECLAS:
        return True
    tipo = (props.get('tipo') or '').lower()
    if tipo == 'mare':
        return True
    if props.get('admin') is None and props.get('name') is None:
        return True
    name = (props.get('name') or '').upper()
    for suffix in (' SEA',' STRAIT',' GULF',' BAY',' OCEAN',' CHANNEL'):
        if suffix in name:
            return True
    if name.startswith('STRAIT OF ') or name.startswith('GULF OF '):
        return True
    return False

def in_box(lat, lon, lat_min, lat_max, lon_min, lon_max):
    if lat is None or lon is None:
        return False
    return lat_min <= lat <= lat_max and lon_min <= lon <= lon_max

def new_owner(name, admin, lat, lon, current, props):
    # Rinomina Fatimide
    if current == 'Califfato Fatimide':
        current = 'Impero Fatimide'

    # Mari/laghi -> Terra di Nessuno
    if is_sea(props):
        return 'Terra di Nessuno'

    # Heian: solo arcipelago giapponese (lon > 129.5E, 28N < lat < 50N)
    if admin == 'Impero del Giappone' or current == 'Regno Heian':
        if admin == 'Impero del Giappone' and lat and lon and 28 < lat < 50 and lon > 129.5:
            return 'Regno Heian'
        return 'Terra di Nessuno'

    # Liao: Manciuria, Mongolia, Mongolia Interna, Pechino/Tianjin
    # Verifica anche province già assegnate a Liao (es. Corea nel dataset Giappone)
    if current == 'Impero Khitan Liao':
        if admin == 'Impero del Giappone':
            return 'Terra di Nessuno'
        if admin == 'Impero Russo' and lon and lon > 120:
            return 'Terra di Nessuno'
        if name in ('Beijing','Tianjin') or in_box(lat, lon, 40, 54, 87, 135):
            return 'Impero Khitan Liao'
        return 'Terra di Nessuno'

    # Impero Qing -> Liao / Song / neutrale
    if admin == 'Impero Qing':
        # Liao: Manciuria, Mongolia, Mongolia Interna, Pechino/Tianjin
        # Manteniamo Hebei/Shanxi a Song (province grandi, il nord era misto)
        if name in ('Beijing','Tianjin') or in_box(lat, lon, 40, 54, 87, 135):
            return 'Impero Khitan Liao'
        # Zone non cinesi -> neutrale
        if name in ('Xinjiang','Xizang','Qinghai','Gansu','Ningxia','Yunnan'):
            return 'Terra di Nessuno'
        # Hainan a Song
        if name == 'Hainan' and in_box(lat, lon, 18, 20, 108, 111):
            return 'Dinastia Song'
        # Cina propria
        if in_box(lat, lon, 18, 42, 102, 123):
            return 'Dinastia Song'
        return 'Terra di Nessuno'

    # Hong Kong e simili sbagliatamente assegnate a Song
    if current == 'Dinastia Song' and admin == 'Regno Unito':
        return 'Terra di Nessuno'

    # Vietnam settentrionale (Đại Việt indipendente dall'anno 980) non era Song
    if current == 'Dinastia Song' and name not in ('Hainan','Guangxi','Guangdong','Macau') and in_box(lat, lon, 15, 24, 102, 109.3):
        return 'Terra di Nessuno'

    # Vichinghi: Scandinavia e Nord Atlantico, non Russia
    if admin in ('Regno di Danimarca','Regno di Norvegia','Regno di Svezia'):
        if in_box(lat, lon, 50, 85, -50, 35):
            return 'Vichinghi'
        return 'Terra di Nessuno'
    if current == 'Vichinghi':
        if admin == 'Impero Russo':
            return 'Terra di Nessuno'
        if admin is None and lat and lon and ((lat > 50 and lon < -20) or (lat > 60 and lon < 0)):
            return 'Vichinghi'
        if in_box(lat, lon, 54, 71, -10, 32):
            return 'Vichinghi'
        return 'Terra di Nessuno'

    # Impero del Ghana: Sahel occidentale
    if current == 'Impero del Ghana':
        if in_box(lat, lon, 10, 20, -18, 5):
            return 'Impero del Ghana'
        return 'Terra di Nessuno'

    # Chola: espansione in India del Sud / Sri Lanka / Maldive
    if admin == 'Impero Britannico' or current == 'Impero Chola':
        if in_box(lat, lon, 4, 20, 68, 86):
            return 'Impero Chola'
        if current == 'Impero Chola':
            return 'Terra di Nessuno'

    return current


def recalibrate(dry_run=True):
    geo = json.load(open(GEO_PATH, encoding='utf-8'))
    prov = json.load(open(PROV_PATH, encoding='utf-8'))

    old_counts = collections.Counter(d.get('owner','?') for d in prov.values())
    old_pop = collections.defaultdict(int)
    old_denaro = collections.defaultdict(int)
    old_oro = collections.defaultdict(int)
    for d in prov.values():
        own = d.get('owner','?')
        old_pop[own] += d.get('population',0)
        old_denaro[own] += d.get('resources',{}).get('denaro',0)
        old_oro[own] += d.get('resources',{}).get('oro',0)

    # Calcola target owner per ogni provincia
    name_to_target = {}
    for f in geo['features']:
        props = f['properties']
        name = props.get('name') or props.get('name_it') or props.get('name_en')
        admin = props.get('admin')
        lat = props.get('latitude')
        lon = props.get('longitude')
        current = props.get('STATO_1000','Terra di Nessuno')
        target = new_owner(name, admin, lat, lon, current, props)
        name_to_target[name] = target

    # Simula conversione denaro -> oro
    new_prov = copy.deepcopy(prov)
    for name, d in new_prov.items():
        target = name_to_target.get(name, d.get('owner','?'))
        d['owner'] = target
        r = d.get('resources', {})
        if 'denaro' in r:
            den = r.pop('denaro')
            val = max(1, round(den / 10000))
            r['oro'] = r.get('oro', 0) + val

    new_counts = collections.Counter(d.get('owner','?') for d in new_prov.values())
    new_pop = collections.defaultdict(int)
    new_oro = collections.defaultdict(int)
    for d in new_prov.values():
        own = d.get('owner','?')
        new_pop[own] += d.get('population',0)
        new_oro[own] += d.get('resources',{}).get('oro',0)

    changes = []
    for name, d in new_prov.items():
        old = prov[name].get('owner','?')
        new = d['owner']
        if old != new:
            changes.append((name, old, new))

    print('=== RIEPILOGO RICALIBRAZIONE (dry_run=%s) ===' % dry_run)
    print('Province con owner cambiato:', len(changes))
    print('\n%-30s | %6s | %7s | %10s | %6s | %7s | %10s' % ('Fazione','Pr. vec','Pop vec','Denaro vec','Pr. nu','Pop nu','Oro nu'))
    owners = set(old_counts) | set(new_counts)
    for o in sorted(owners, key=lambda x: new_counts.get(x,0), reverse=True):
        print('%30s | %6d | %7d | %10d | %6d | %7d | %10d' % (
            o[:30], old_counts.get(o,0), old_pop.get(o,0), old_denaro.get(o,0),
            new_counts.get(o,0), new_pop.get(o,0), new_oro.get(o,0)))

    if not dry_run:
        for f in geo['features']:
            props = f['properties']
            name = props.get('name') or props.get('name_it') or props.get('name_en')
            if name in name_to_target:
                props['STATO_1000'] = name_to_target[name]
        with open(GEO_PATH, 'w', encoding='utf-8') as f:
            # Il GeoJSON originale è una riga unica; manteniamo quel formato.
            json.dump(geo, f, ensure_ascii=False, separators=(',', ':'))
        with open(PROV_PATH, 'w', encoding='utf-8') as f:
            # provinces_1000.json è formattato con indentazione per leggibilità.
            json.dump(new_prov, f, ensure_ascii=False, indent=2)
        with open(OUT_LOG, 'w', encoding='utf-8') as f:
            f.write('Province cambiate: %d\n' % len(changes))
            for n, old, new in sorted(changes):
                f.write(f"{n} | {old} -> {new}\n")
        print('\nFile aggiornati:', GEO_PATH, PROV_PATH, OUT_LOG)


if __name__ == '__main__':
    dry = '--apply' not in sys.argv
    recalibrate(dry_run=dry)
