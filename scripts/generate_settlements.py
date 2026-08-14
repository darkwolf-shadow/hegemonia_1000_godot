#!/usr/bin/env python3
"""Aggiunge agglomerati urbani (settlements) a ogni provincia."""

import json
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

CAPITALS = {
    "Impero Bizantino": ("Costantinopoli", "Costantinopoli"),
    "Sacro Romano Impero": ("Roma", "Roma"),
    "Vichinghi": ("Hedeby", "Hedeby"),
    "Regno di Francia": ("Parigi", "Parigi"),
    "Califfato di Cordova": ("Cordova", "Cordova"),
    "Impero Fatimide": ("Il Cairo", "Il Cairo"),
    "Regno d'Ungheria": ("Esztergom", "Esztergom"),
    "Principato di Kiev": ("Kiev", "Kiev"),
    "Regno di Polonia": ("Gniezno", "Gniezno"),
    "Califfato Abbaside": ("Baghdad", "Baghdad"),
    "Sultanato Ghaznavide": ("Ghazna", "Ghazna"),
    "Dinastia Song": ("Kaifeng", "Kaifeng"),
    "Impero Khitan Liao": ("Shangjing", "Shangjing"),
    "Impero Chola": ("Tanjore", "Tanjore"),
    "Regno Khmer": ("Angkor", "Angkor"),
    "Regno Heian": ("Kyoto", "Kyoto"),
    "Regno di Srivijaya": ("Palembang", "Palembang"),
    "Impero del Ghana": ("Koumbi Saleh", "Koumbi Saleh"),
    "Toltechi": ("Tollan", "Tollan"),
    "Regni Maya": ("Chichen Itza", "Chichen Itza"),
    "Terra di Nessuno": ("", "")
}

# Province che storicamente erano portuali o costiere importanti intorno al 1000
COASTAL_PROVINCES = {
    "Costantinopoli", "Nicea", "Smirne", "Antiochia", "Candia", "Siracusa", "Salerno",
    "Roma", "Ravenna", "Venezia", "Marsiglia", "Bordeaux", "Lisbona", "Siviglia",
    "Cordova", "Palermo", "Alessandria", "Il Cairo", "Tripoli", "Hedeby", "Roskilde",
    "Oslo", "Viken", "Gotland", "Tanjore", "Madurai", "Malabar", "Sri Lanka",
    "Palembang", "Kedah", "Sumatra", "Jambi", "Guangzhou", "Hangzhou", "Kyoto",
    "Osaka", "Kamakura", "Koumbi Saleh"
}


def choose_settlement_type(prov_name, terrain, owner, population):
    if owner == "Terra di Nessuno":
        return None
    # Capitale: citta'
    for faction, (cap_prov, _) in CAPITALS.items():
        if cap_prov == prov_name:
            return "civil"
    if prov_name in COASTAL_PROVINCES:
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
        return ["centro_cittadino", "caserma_i", "fortezza_frontiera"]
    if stype == "industrial":
        return ["centro_cittadino", "capanna_boscaioli", "segheria", "miniera", "fucina"]
    if stype == "port":
        return ["centro_cittadino", "molo_i", "segheria", "mercato_marittimo"]
    return []


def main():
    prov_path = os.path.join(BASE_DIR, "data", "world", "provinces_1000.json")
    with open(prov_path, "r", encoding="utf-8") as f:
        provinces = json.load(f)

    faction_capitals = {prov: fact for fact, (prov, _) in CAPITALS.items()}

    for name, data in provinces.items():
        if data.get("owner") == "Terra di Nessuno":
            continue
        terrain = data.get("terrain", "plains")
        pop = data.get("population", 0)
        owner = data.get("owner", "")
        stype = choose_settlement_type(name, terrain, owner, pop)
        if stype is None:
            continue
        is_capital = name in faction_capitals
        settlement_name = CAPITALS.get(owner, ("", ""))[1] if is_capital else f"Abitato di {name}"
        buildings = default_buildings(stype, is_capital)

        # Per i porti costieri importanti aggiungiamo arsenale
        if stype == "port" and is_capital:
            buildings.append("arsenale_i")

        # Per la capitale di fazioni con tradizione navale, arsenale
        if is_capital and owner in ["Vichinghi", "Impero Bizantino", "Impero Chola", "Regno di Srivijaya"]:
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
                "roads": []
            }
        }
        # Gli edifici della capitale producono anche per la fazione, quindi aggiorniamo
        # la produzione base della fazione se necessario piu' avanti.

    with open(prov_path, "w", encoding="utf-8") as f:
        json.dump(provinces, f, ensure_ascii=False, indent=2)

    print("Settlements aggiunti a", len(provinces), "province")


if __name__ == "__main__":
    main()
