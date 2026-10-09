#!/usr/bin/env python3
"""Aggiunge agglomerati urbani (settlements) a ogni provincia.
Versione corretta: usa la provincia piu' popolosa di ogni fazione come capitale.
Dark Corporation / Stev"""

import json
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

FAZIONI_ESCLUSE = {"Terra di Nessuno", "Mare Aperto", "Isole Disabitate"}

# Province portuali/costiere importanti intorno al 1000 (nomi moderni nel JSON)
PORT_PROVINCES = {
    "Istanbul", "Izmir", "Antalya", "Bursa", "Salerno", "Siracusa",
    "Roma", "Ravenna", "Venezia", "Marsiglia", "Bordeaux", "Lisbona",
    "Siviglia", "Palermo", "Alessandria", "Schleswig-Holstein", "Roskilde",
    "Oslo", "Uppsala", "Gavleborg", "Gampaha", "Bali",
    "Guangxi", "Guangdong", "Wakayama", "Osaka", "Nara",
    "Kalimantan Timur", "Papua Barat"
}

# Fazioni con tradizione navale (arsenale nella capitale)
FAZIONI_NAVALI = {"Vichinghi", "Impero Bizantino", "Impero Chola", "Regno di Srivijaya"}


def choose_settlement_type(prov_name, terrain, owner, population):
    if owner in FAZIONI_ESCLUSE:
        return None
    if prov_name in PORT_PROVINCES:
        return "port"
    if terrain in ["forest", "hills"] and population < 50000:
        return "industrial"
    if terrain == "desert" and population < 60000:
        return "industrial"
    if terrain == "hills" and population >= 60000:
        return "military"
    return "civil"


def default_buildings(stype, is_capital=False):
    if stype == "civil":
        base = ["centro_cittadino", "mercato", "mulino", "caserma_i", "campo_tiro_i", "scuderia_i"]
        if is_capital:
            base += ["fucina", "monastero"]
        return base
    if stype == "military":
        base = ["centro_cittadino", "caserma_i", "fortezza_frontiera"]
        if is_capital:
            base += ["scuderia_i", "campo_tiro_i"]
        return base
    if stype == "industrial":
        return ["centro_cittadino", "capanna_boscaioli", "segheria", "miniera", "fucina"]
    if stype == "port":
        base = ["centro_cittadino", "molo_i", "segheria", "mercato_marittimo"]
        if is_capital:
            base += ["arsenale_i"]
        return base
    return []


def main():
    prov_path = os.path.join(BASE_DIR, "data", "world", "provinces_1000.json")
    with open(prov_path, "r", encoding="utf-8") as f:
        provinces = json.load(f)

    # Trova la provincia piu' popolosa per ogni fazione (sara' la capitale)
    capitals = {}
    faction_provs = {}
    for name, data in provinces.items():
        owner = data.get("owner", "")
        if owner in FAZIONI_ESCLUSE:
            continue
        if owner not in faction_provs:
            faction_provs[owner] = []
        faction_provs[owner].append((name, data))

    for owner, provs in faction_provs.items():
        provs.sort(key=lambda x: x[1].get("population", 0), reverse=True)
        if provs:
            capitals[provs[0][0]] = owner

    print(f"Capitali trovate: {len(capitals)}")
    for cap, fac in sorted(capitals.items()):
        print(f"  {fac}: {cap} (pop={provinces[cap].get('population')})")

    # Genera settlements
    count = 0
    for name, data in provinces.items():
        owner = data.get("owner", "")
        if owner in FAZIONI_ESCLUSE:
            continue
        terrain = data.get("terrain", "plains")
        pop = data.get("population", 0)
        stype = choose_settlement_type(name, terrain, owner, pop)
        if stype is None:
            continue

        is_capital = name in capitals
        if is_capital:
            settlement_name = f"Capitale {name}"
        else:
            settlement_name = f"Abitato di {name}"

        buildings = default_buildings(stype, is_capital)

        # Arsenale per fazioni navali nella capitale
        if is_capital and owner in FAZIONI_NAVALI:
            if "arsenale_i" not in buildings:
                buildings.append("arsenale_i")

        data["settlements"] = {
            settlement_name: {
                "name": settlement_name,
                "type": stype,
                "x": 0.5,
                "y": 0.5,
                "population": max(1000, int(pop * 0.15)) if pop else 2000,
                "buildings": buildings,
                "building_levels": {b: 1 for b in buildings},
                "roads": []
            }
        }
        count += 1

    with open(prov_path, "w", encoding="utf-8") as f:
        json.dump(provinces, f, ensure_ascii=False, indent=2)

    print(f"\nSettlements aggiunti a {count} province su {len(provinces)} totali")


if __name__ == "__main__":
    main()
