#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Rimuove le fazioni senza province, tranne quelle di servizio."""
import json
from pathlib import Path

FACTIONS_PATH = Path('data/world/factions_1000.json')
PROV_PATH = Path('data/world/provinces_1000.json')
KEEP = {'Terra di Nessuno'}


def prune():
    factions = json.load(open(FACTIONS_PATH, 'r', encoding='utf-8'))
    prov = json.load(open(PROV_PATH, 'r', encoding='utf-8'))
    owners = {prov[p].get('owner', '') for p in prov}
    to_remove = [k for k in factions if k not in owners and k not in KEEP]
    for k in to_remove:
        del factions[k]
    with open(FACTIONS_PATH, 'w', encoding='utf-8') as f:
        json.dump(factions, f, ensure_ascii=False, indent=2)
    print(f'Rimosse {len(to_remove)} fazioni vuotte. Rimaste {len(factions)}.')


if __name__ == '__main__':
    prune()
