import json
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from xlsx_writer import Workbook, Sheet


CONFIG = r"C:\Users\Administrator\repos\hegemonia_1000_godot\data\config\game_config.json"
OUT = r"C:\Users\Administrator\repos\hegemonia_1000_godot\docs\Unita_stats.xlsx"


def load_config():
    with open(CONFIG, encoding="utf-8") as f:
        return json.load(f)


def fmt_res(data, res_keys):
    parts = []
    for k in res_keys:
        v = data.get(k)
        if v is not None:
            parts.append(f"{k}={v}")
    return ", ".join(parts)


def build_units_sheet(data):
    sheet = Sheet("Unità")
    res_keys = ["legname", "pietra", "ferro", "argento", "armi", "cibo", "prestigio"]
    headers = [
        ("ID", "str"),
        ("Nome", "str"),
        ("Attacco", "num"),
        ("Difesa", "num"),
        ("Armatura", "num"),
        ("Velocità", "num"),
        ("Morale", "num"),
        ("Esperienza", "num"),
        ("Costo oro", "num"),
        ("Popolazione", "num"),
        ("Manutenzione", "num"),
        ("Cibo", "num"),
        ("Altre risorse", "str"),
        ("Edifici richiesti", "str"),
        ("Fazioni", "str"),
    ]
    header_row = [h[0] for h in headers]
    sheet.add_row(header_row)

    units = data.get("units", {})
    for unit_id in sorted(units.keys()):
        u = units[unit_id]
        sheet.add_row([
            unit_id,
            u.get("name", ""),
            u.get("attack", 0.0),
            u.get("defense", 0.0),
            u.get("armor", 0.0),
            u.get("speed", 0.0),
            u.get("base_morale", 0),
            u.get("experience", 0),
            u.get("cost", 0),
            u.get("pop", 0),
            u.get("maintenance", 0),
            u.get("food", 0),
            fmt_res(u, res_keys),
            ", ".join(u.get("requires_buildings", [])),
            ", ".join(u.get("factions", [])) if u.get("factions") else "Tutte",
        ])
    return sheet


def build_ships_sheet(data):
    sheet = Sheet("Navi")
    headers = [
        "ID", "Nome", "Costo oro", "Pop", "Manutenzione", "Cibo",
        "Attacco", "Difesa", "Velocità", "Capacità", "Edifici richiesti", "Fazioni"
    ]
    sheet.add_row(headers)
    ships = data.get("ships", {})
    for ship_id in sorted(ships.keys()):
        s = ships[ship_id]
        sheet.add_row([
            ship_id,
            s.get("name", ""),
            s.get("cost", 0),
            s.get("pop", 0),
            s.get("maintenance", 0),
            s.get("food", 0),
            s.get("attack", 0.0),
            s.get("defense", 0.0),
            s.get("speed", 0.0),
            s.get("capacity", 0),
            ", ".join(s.get("requires_buildings", [])),
            ", ".join(s.get("factions", [])) if s.get("factions") else "Tutte",
        ])
    return sheet


def build_tactics_sheet():
    sheet = Sheet("Tattiche")
    sheet.add_row([
        "Tattica", "Descrizione", "Ruolo ideale", "Bonus", "Malus", "Trigger IA"
    ])
    rows = [
        [
            "standard",
            "Avanzata ordinaria, nessun bonus/malus. Le unità marciano verso il nemico e attaccano al contatto.",
            "Qualsiasi",
            "Nessuno",
            "Nessuno",
            "Composizione bilanciata o poche unità specializzate"
        ],
        [
            "charge",
            "Carica frontale. Cavalleria ed elefanti guadagnano velocità e impatto, ma subiscono più danni se fermati.",
            "Cavalleria, Elefanti",
            "Attacco +25%, Velocità +30% per cavalleria/elefanti, morale attaccante +10 iniziale",
            "Difesa -15%, stamina consumata più velocemente",
            "Cavalleria >= 35% e morale attaccante >= difensore"
        ],
        [
            "skirmish",
            "Guerriglia a distanza. Arcieri attaccano mentre si ritirano, cavalleria affronta i fianchi.",
            "Arcieri, cavalleria leggera",
            "Arceri: raggio d'azione +20%, danno da distanza +15%; nemici in carica subiscono danni da fuoco",
            "Fanteria in mischia -10% difesa se isolata",
            "Arcieri >= 40%"
        ],
        [
            "shield_wall",
            "Muro di scudi difensivo. Ottimo per fanteria pesante che attende il nemico.",
            "Fanteria pesante",
            "Difesa +30%, morale più stabile -10% perdite",
            "Velocità -40%, incapace di inseguire nemici in ritirata",
            "Difensore superato numericamente o fanteria >= 60%"
        ],
        [
            "elephant_charge",
            "Carica di elefanti. Alta pressione psicologica e danni al centro, rischio di panico se danneggiati.",
            "Elefanti",
            "Attacco +40%, danno area contro fanteria leggera, morale nemico -15",
            "Se gli elefanti perdono >30% salute possono impazzire e danneggiare alleati",
            "Elefanti >= 25%"
        ],
        [
            "hold",
            "Tieni posizione. Le unità non avanzano, aumentano difesa e aspettano il contatto.",
            "Difesa, artiglieria",
            "Difesa +20%, bonus terreno se difensore in collina/foresta",
            "Non si muove, nessun bonus offensivo",
            "Difensore con artiglieria o in terreno favorevole"
        ]
    ]
    for r in rows:
        sheet.add_row(r)
    return sheet


def main():
    config = load_config()
    wb = Workbook()
    wb.add_sheet(build_units_sheet(config))
    wb.add_sheet(build_ships_sheet(config))
    wb.add_sheet(build_tactics_sheet())
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    wb.save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    main()
