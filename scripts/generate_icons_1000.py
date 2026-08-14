import json
import os
import re

BASE_DIR = os.path.join("assets", "icons", "1000")


def save(key, folder, svg):
    os.makedirs(os.path.join(BASE_DIR, folder), exist_ok=True)
    path = os.path.join(BASE_DIR, folder, f"{key}.svg")
    with open(path, "w", encoding="utf-8") as f:
        f.write(svg)


def svg(contents: str) -> str:
    return f'<svg viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">{contents}</svg>'


def building(body="#8c7b66", roof="#6d5e4d", extras="") -> str:
    base = (
        f'<rect x="12" y="24" width="40" height="34" fill="{body}" stroke="#2a231c" stroke-width="1.5"/>'
        f'<path d="M10 24 L32 12 L54 24 Z" fill="{roof}" stroke="#2a231c" stroke-width="1.5"/>'
    )
    return svg(base + extras)


BUILDINGS = {
    "centro_cittadino": building("#a89f91", "#7a6f63",
        '<rect x="24" y="14" width="16" height="22" fill="#7a6f63" stroke="#2a231c" stroke-width="1"/>'
        '<rect x="28" y="18" width="8" height="6" fill="#e8dcc0"/>'
        '<line x1="32" y1="14" x2="32" y2="8" stroke="#2a231c" stroke-width="2"/>'
        '<circle cx="32" cy="7" r="2" fill="#8b0000"/>'),

    "mercato": building("#b8a88a", "#8f7f63",
        '<rect x="14" y="42" width="14" height="10" fill="#6b4a2a" stroke="#2a231c" stroke-width="1"/>'
        '<rect x="36" y="42" width="14" height="10" fill="#6b4a2a" stroke="#2a231c" stroke-width="1"/>'
        '<path d="M12 42 L20 34 L28 42" fill="#c5a059" stroke="#2a231c" stroke-width="1"/>'
        '<path d="M34 42 L43 34 L52 42" fill="#c5a059" stroke="#2a231c" stroke-width="1"/>'
        '<circle cx="32" cy="50" r="3" fill="#c5a059"/>'),

    "mercato_marittimo": building("#7a8a9a", "#5a6a7a",
        '<path d="M10 58 L16 48 L24 48 L30 58" fill="#4a7a9a" stroke="#1a2a3a" stroke-width="1"/>'
        '<path d="M34 54 L40 50 L48 50 L54 54" fill="#6b4a2a" stroke="#2a231c" stroke-width="1"/>'
        '<circle cx="32" cy="50" r="3" fill="#c5a059"/>'),

    "mulino": building("#b8a88a", "#8f7f63",
        '<rect x="24" y="20" width="16" height="12" fill="#7a6f63"/>'
        '<line x1="32" y1="14" x2="32" y2="40" stroke="#3a2a1a" stroke-width="2"/>'
        '<line x1="22" y1="27" x2="42" y2="27" stroke="#3a2a1a" stroke-width="2"/>'
        '<circle cx="32" cy="27" r="10" fill="none" stroke="#3a2a1a" stroke-width="2"/>'),

    "fucina": building("#5a5a5a", "#3a3a3a",
        '<rect x="20" y="46" width="24" height="8" fill="#4a4a4a" stroke="#1a1a1a"/>'
        '<rect x="28" y="40" width="8" height="10" fill="#8b0000"/>'
        '<path d="M18 38 L24 32 L30 32 L24 38 Z" fill="#4a4a4a"/>'
        '<path d="M14 20 Q18 12 22 20" fill="none" stroke="#555" stroke-width="2"/>'),

    "monastero": building("#d4c4a8", "#7a6f63",
        '<rect x="28" y="30" width="8" height="20" fill="#3a2a1a"/>'
        '<line x1="32" y1="20" x2="32" y2="28" stroke="#8b0000" stroke-width="3"/>'
        '<line x1="28" y1="24" x2="36" y2="24" stroke="#8b0000" stroke-width="2"/>'
        '<circle cx="20" cy="46" r="3" fill="#2a2a3a"/>'
        '<circle cx="44" cy="46" r="3" fill="#2a2a3a"/>'),

    "capanna_boscaioli": building("#6b4a2a", "#5a3a1a",
        '<path d="M14 58 L22 36 L42 36 L50 58" fill="#5a3a1a" stroke="#2a1a0a" stroke-width="1"/>'
        '<circle cx="18" cy="52" r="3" fill="#3a2a1a"/>'
        '<circle cx="22" cy="52" r="3" fill="#3a2a1a"/>'
        '<circle cx="26" cy="52" r="3" fill="#3a2a1a"/>'),

    "segheria": building("#8b7355", "#6b4a2a",
        '<rect x="18" y="38" width="28" height="12" fill="#5a4a3a" stroke="#2a1a0a"/>'
        '<path d="M20 38 L20 20 L26 20 L26 38" fill="#4a3a2a"/>'
        '<circle cx="23" cy="24" r="5" fill="#8b7355" stroke="#2a1a0a"/>'
        '<line x1="18" y1="20" x2="28" y2="30" stroke="#a89f91" stroke-width="2"/>'),

    "miniera": building("#5a4a3a", "#3a2a1a",
        '<path d="M10 58 L20 34 L44 34 L54 58" fill="#4a3a2a" stroke="#1a0a0a"/>'
        '<path d="M22 58 L32 42 L42 58" fill="#1a0a0a"/>'
        '<circle cx="32" cy="48" r="3" fill="#c5a059"/>'),

    "officina_armi": building("#6a6a6a", "#4a4a4a",
        '<line x1="16" y1="34" x2="48" y2="34" stroke="#8b8b8b" stroke-width="3"/>'
        '<path d="M46 34 L52 26 L54 28 L48 36 Z" fill="#c5a059"/>'
        '<rect x="22" y="40" width="20" height="8" fill="#4a4a4a"/>'),

    "caserma_i": building("#8c7b66", "#6d5e4d",
        '<rect x="18" y="34" width="28" height="18" fill="#7a6f63"/>'
        '<rect x="22" y="40" width="5" height="8" fill="#2a2a2a"/>'
        '<rect x="37" y="40" width="5" height="8" fill="#2a2a2a"/>'
        '<rect x="28" y="28" width="8" height="10" fill="#8b0000"/>'),

    "caserma_ii": building("#8c7b66", "#6d5e4d",
        '<rect x="14" y="34" width="36" height="18" fill="#7a6f63"/>'
        '<rect x="18" y="40" width="6" height="8" fill="#2a2a2a"/>'
        '<rect x="40" y="40" width="6" height="8" fill="#2a2a2a"/>'
        '<rect x="26" y="26" width="12" height="14" fill="#8b0000"/>'
        '<circle cx="32" cy="20" r="2" fill="#c5a059"/>'),

    "caserma_iii": building("#7a6f63", "#5a4a3a",
        '<rect x="10" y="32" width="44" height="22" fill="#6d5e4d"/>'
        '<rect x="20" y="20" width="24" height="16" fill="#8b0000"/>'
        '<rect x="28" y="40" width="8" height="14" fill="#3a2a1a"/>'
        '<rect x="16" y="38" width="6" height="8" fill="#2a2a2a"/>'
        '<rect x="42" y="38" width="6" height="8" fill="#2a2a2a"/>'
        '<path d="M12 32 L32 18 L52 32" fill="#4a4a4a"/>'),

    "campo_tiro_i": building("#8b9a4a", "#6a7a3a",
        '<circle cx="32" cy="40" r="12" fill="#e8dcc0" stroke="#5a4a3a" stroke-width="2"/>'
        '<circle cx="32" cy="40" r="6" fill="#8b0000"/>'
        '<circle cx="32" cy="40" r="2" fill="#000"/>'),

    "campo_tiro_ii": building("#8b9a4a", "#6a7a3a",
        '<rect x="14" y="28" width="36" height="8" fill="#6b4a2a"/>'
        '<path d="M12 36 L18 28 L46 28 L52 36 Z" fill="#8b9a4a"/>'
        '<circle cx="32" cy="46" r="8" fill="#e8dcc0" stroke="#5a4a3a" stroke-width="2"/>'
        '<circle cx="32" cy="46" r="3" fill="#8b0000"/>'),

    "campo_tiro_iii": building("#8b9a4a", "#6a7a3a",
        '<rect x="10" y="26" width="44" height="10" fill="#6b4a2a"/>'
        '<path d="M8 38 L16 26 L48 26 L56 38 Z" fill="#8b9a4a"/>'
        '<circle cx="24" cy="48" r="7" fill="#e8dcc0" stroke="#5a4a3a" stroke-width="1.5"/>'
        '<circle cx="40" cy="48" r="7" fill="#e8dcc0" stroke="#5a4a3a" stroke-width="1.5"/>'
        '<circle cx="24" cy="48" r="2.5" fill="#8b0000"/>'
        '<circle cx="40" cy="48" r="2.5" fill="#8b0000"/>'),

    "scuderia_i": building("#a89f91", "#7a6f63",
        '<rect x="18" y="36" width="28" height="16" fill="#8b7355" stroke="#3a2a1a"/>'
        '<circle cx="28" cy="42" r="5" fill="#c5a059"/>'
        '<circle cx="26" cy="40" r="1.2" fill="#000"/>'
        '<path d="M28 47 L26 58 L30 58 Z" fill="#6b4a2a"/>'),

    "scuderia_ii": building("#a89f91", "#7a6f63",
        '<rect x="14" y="36" width="36" height="18" fill="#8b7355" stroke="#3a2a1a"/>'
        '<circle cx="26" cy="42" r="5" fill="#c5a059"/>'
        '<circle cx="38" cy="42" r="5" fill="#c5a059"/>'
        '<path d="M26 47 L24 58 L28 58 Z" fill="#6b4a2a"/>'
        '<path d="M38 47 L36 58 L40 58 Z" fill="#6b4a2a"/>'),

    "scuderia_iii": building("#a89f91", "#7a6f63",
        '<rect x="10" y="34" width="44" height="20" fill="#8b7355" stroke="#3a2a1a"/>'
        '<circle cx="22" cy="40" r="4" fill="#c5a059"/>'
        '<circle cx="34" cy="40" r="4" fill="#c5a059"/>'
        '<circle cx="46" cy="40" r="4" fill="#c5a059"/>'
        '<rect x="26" y="50" width="12" height="8" fill="#6b4a2a"/>'),

    "cortile_cavaliere": building("#8c7b66", "#6d5e4d",
        '<rect x="14" y="36" width="36" height="18" fill="#7a6f63"/>'
        '<rect x="20" y="28" width="24" height="14" fill="#5a4a3a"/>'
        '<circle cx="32" cy="48" r="4" fill="#c5a059"/>'
        '<line x1="32" y1="44" x2="32" y2="36" stroke="#8b0000" stroke-width="2"/>'),

    "officina_assedio_i": building("#6a6a6a", "#4a4a4a",
        '<circle cx="20" cy="50" r="6" fill="#3a3a3a"/>'
        '<line x1="20" y1="50" x2="44" y2="38" stroke="#5a3a1a" stroke-width="3"/>'
        '<path d="M42 34 L48 40 L44 44 Z" fill="#8b7355"/>'),

    "officina_assedio_ii": building("#6a6a6a", "#4a4a4a",
        '<rect x="24" y="40" width="20" height="6" fill="#3a3a3a"/>'
        '<path d="M24 43 L10 30 L10 34 Z" fill="#5a3a1a"/>'
        '<path d="M44 43 L56 34 L56 38 Z" fill="#5a3a1a"/>'),

    "officina_assedio_iii": building("#6a6a6a", "#4a4a4a",
        '<rect x="16" y="44" width="12" height="12" fill="#4a4a4a"/>'
        '<line x1="22" y1="44" x2="22" y2="24" stroke="#3a2a1a" stroke-width="3"/>'
        '<line x1="10" y1="30" x2="34" y2="30" stroke="#5a3a1a" stroke-width="3"/>'
        '<path d="M34 30 L48 22 L48 38 Z" fill="#6b4a2a"/>'),

    "fortezza_frontiera": building("#8a8a7a", "#5a5a4a",
        '<rect x="16" y="28" width="32" height="26" fill="#7a7a6a" stroke="#2a2a1a"/>'
        '<rect x="22" y="18" width="12" height="18" fill="#6a6a5a" stroke="#2a2a1a"/>'
        '<rect x="28" y="42" width="8" height="12" fill="#3a2a1a"/>'
        '<rect x="18" y="34" width="4" height="6" fill="#2a2a2a"/>'
        '<rect x="42" y="34" width="4" height="6" fill="#2a2a2a"/>'),

    "molo_i": building("#6a5a4a", "#4a3a2a",
        '<rect x="20" y="40" width="24" height="6" fill="#5a4a3a"/>'
        '<path d="M20 52 L26 46 L34 46 L40 52" fill="#4a7a9a" stroke="#1a2a3a"/>'
        '<line x1="24" y1="46" x2="24" y2="40" stroke="#3a2a1a" stroke-width="2"/>'
        '<line x1="36" y1="46" x2="36" y2="40" stroke="#3a2a1a" stroke-width="2"/>'),

    "molo_ii": building("#6a5a4a", "#4a3a2a",
        '<rect x="14" y="40" width="36" height="6" fill="#5a4a3a"/>'
        '<path d="M16 54 L24 46 L36 46 L44 54" fill="#4a7a9a" stroke="#1a2a3a"/>'
        '<line x1="22" y1="46" x2="22" y2="40" stroke="#3a2a1a" stroke-width="2"/>'
        '<line x1="38" y1="46" x2="38" y2="40" stroke="#3a2a1a" stroke-width="2"/>'),

    "arsenale_i": building("#5a6a7a", "#3a4a5a",
        '<rect x="10" y="28" width="44" height="14" fill="#4a5a6a"/>'
        '<path d="M10 28 L32 16 L54 28" fill="#3a4a5a"/>'
        '<path d="M14 56 L20 46 L44 46 L50 56" fill="#4a7a9a" stroke="#1a2a3a"/>'
        '<line x1="20" y1="46" x2="20" y2="42" stroke="#3a2a1a" stroke-width="2"/>'
        '<line x1="44" y1="46" x2="44" y2="42" stroke="#3a2a1a" stroke-width="2"/>'),

    "arsenale_ii": building("#5a6a7a", "#3a4a5a",
        '<rect x="8" y="26" width="48" height="16" fill="#4a5a6a"/>'
        '<path d="M8 26 L32 12 L56 26" fill="#3a4a5a"/>'
        '<rect x="28" y="34" width="8" height="10" fill="#2a2a2a"/>'
        '<path d="M12 58 L22 46 L42 46 L52 58" fill="#4a7a9a" stroke="#1a2a3a"/>'),

    "magazzino": building("#b8a88a", "#8f7f63",
        '<rect x="14" y="30" width="36" height="24" fill="#8b7355" stroke="#3a2a1a"/>'
        '<rect x="26" y="40" width="12" height="14" fill="#5a4a3a"/>'
        '<path d="M12 30 L20 22 L44 22 L52 30" fill="#6d5e4d"/>'
        '<rect x="18" y="34" width="6" height="6" fill="#2a2a2a"/>'
        '<rect x="40" y="34" width="6" height="6" fill="#2a2a2a"/>'),
    "strade": building("#9a8a6a", "#7a6f63",
        '<line x1="12" y1="20" x2="52" y2="44" stroke="#5a4a3a" stroke-width="6" stroke-linecap="round"/>'
        '<line x1="12" y1="20" x2="52" y2="44" stroke="#8b7355" stroke-width="2" stroke-linecap="round" stroke-dasharray="4,4"/>'
        '<circle cx="20" cy="26" r="2" fill="#c5a059"/>'
        '<circle cx="36" cy="34" r="2" fill="#c5a059"/>'
        '<circle cx="48" cy="42" r="2" fill="#c5a059"/>'),
}


RESOURCES = {
    "oro": svg('<circle cx="32" cy="32" r="20" fill="#c5a059" stroke="#8b6914" stroke-width="2"/>'
               '<circle cx="32" cy="32" r="14" fill="none" stroke="#8b6914" stroke-width="2"/>'
               '<text x="32" y="40" text-anchor="middle" font-size="16" fill="#5c4033" font-family="serif">£</text>'),
    "legname": svg('<rect x="8" y="24" width="48" height="8" fill="#6b4a2a" stroke="#3a2a1a" rx="2"/>'
                   '<rect x="8" y="34" width="48" height="8" fill="#5a3a1a" stroke="#3a2a1a" rx="2"/>'
                   '<rect x="8" y="44" width="48" height="8" fill="#6b4a2a" stroke="#3a2a1a" rx="2"/>'),
    "pietra": svg('<path d="M16 48 L20 28 L32 20 L44 28 L48 48 Z" fill="#9a9a8a" stroke="#4a4a3a" stroke-width="2"/>'
                  '<circle cx="28" cy="38" r="4" fill="#7a7a6a"/>'
                  '<circle cx="38" cy="42" r="3" fill="#7a7a6a"/>'),
    "ferro": svg('<path d="M10 20 L20 14 L44 14 L54 20 L54 48 L44 54 L20 54 L10 48 Z" fill="#6a6a6a" stroke="#2a2a2a" stroke-width="2"/>'
                 '<circle cx="32" cy="34" r="8" fill="#4a4a4a" stroke="#c5a059" stroke-width="2"/>'),
    "cibo": svg('<path d="M32 10 L38 24 L52 24 L42 34 L46 50 L32 40 L18 50 L22 34 L12 24 L26 24 Z" fill="#8b9a4a" stroke="#4a5a2a" stroke-width="1.5"/>'),
    "armi": svg('<line x1="14" y1="46" x2="50" y2="18" stroke="#5a5a5a" stroke-width="4" stroke-linecap="round"/>'
                '<line x1="18" y1="18" x2="46" y2="46" stroke="#5a5a5a" stroke-width="4" stroke-linecap="round"/>'
                '<circle cx="32" cy="32" r="6" fill="#8b0000"/>'),
    "prestigio": svg('<path d="M8 44 L12 20 L24 32 L32 12 L40 32 L52 20 L56 44 Z" fill="#c5a059" stroke="#8b6914" stroke-width="2"/>'
                     '<circle cx="16" cy="24" r="3" fill="#8b0000"/>'
                     '<circle cx="32" cy="18" r="3" fill="#8b0000"/>'
                     '<circle cx="48" cy="24" r="3" fill="#8b0000"/>'),
    "pop": svg('<circle cx="20" cy="24" r="6" fill="#c5a059"/>'
               '<circle cx="44" cy="24" r="6" fill="#c5a059"/>'
               '<circle cx="32" cy="18" r="7" fill="#c5a059"/>'
               '<path d="M14 46 L14 36 L26 36 L26 46 M38 46 L38 36 L50 36 L50 46 M24 46 L24 38 L40 38 L40 46" fill="#8b7355"/>'),
}


SETTLEMENTS = {
    "civil": building("#a89f91", "#7a6f63",
        '<rect x="22" y="30" width="20" height="16" fill="#7a6f63"/>'
        '<rect x="26" y="34" width="5" height="8" fill="#2a2a2a"/>'
        '<rect x="34" y="34" width="5" height="8" fill="#2a2a2a"/>'
        '<line x1="32" y1="22" x2="32" y2="16" stroke="#8b0000" stroke-width="2"/>'
        '<circle cx="32" cy="15" r="2" fill="#c5a059"/>'),
    "military": building("#8a8a7a", "#5a5a4a",
        '<rect x="18" y="26" width="28" height="26" fill="#7a7a6a" stroke="#2a2a1a"/>'
        '<rect x="24" y="16" width="16" height="16" fill="#6a6a5a" stroke="#2a2a1a"/>'
        '<rect x="28" y="40" width="8" height="12" fill="#3a2a1a"/>'
        '<rect x="20" y="32" width="6" height="8" fill="#2a2a2a"/>'
        '<rect x="38" y="32" width="6" height="8" fill="#2a2a2a"/>'),
    "industrial": building("#5a4a3a", "#3a2a1a",
        '<rect x="12" y="36" width="40" height="20" fill="#4a3a2a" stroke="#1a0a0a"/>'
        '<rect x="18" y="20" width="6" height="20" fill="#4a3a2a"/>'
        '<rect x="28" y="16" width="6" height="24" fill="#4a3a2a"/>'
        '<rect x="38" y="22" width="6" height="18" fill="#4a3a2a"/>'
        '<path d="M14 20 Q10 10 18 12" fill="none" stroke="#888" stroke-width="2"/>'
        '<path d="M28 14 Q24 6 32 8" fill="none" stroke="#888" stroke-width="2"/>'),
    "port": building("#6a5a4a", "#4a3a2a",
        '<rect x="14" y="40" width="36" height="6" fill="#5a4a3a"/>'
        '<path d="M16 58 L26 44 L38 44 L48 58" fill="#4a7a9a" stroke="#1a2a3a"/>'
        '<rect x="20" y="28" width="24" height="12" fill="#7a6f63"/>'
        '<line x1="24" y1="28" x2="24" y2="20" stroke="#3a2a1a" stroke-width="2"/>'
        '<line x1="40" y1="28" x2="40" y2="20" stroke="#3a2a1a" stroke-width="2"/>'),
}


def unit_icon(key: str) -> str:
    k = key.lower()
    # Scegli arma/montatura
    if "elef" in k:
        mount = '<ellipse cx="32" cy="44" rx="18" ry="10" fill="#8b7355" stroke="#3a2a1a" stroke-width="1.5"/>'
        rider = '<circle cx="32" cy="30" r="6" fill="#c5a059"/><rect x="28" y="34" width="8" height="12" fill="#4a5d3a"/>'
        return svg(mount + rider)
    if "caval" in k or "cataphract" in k or "ghilman" in k or "mamelucco" in k or "carolingio" in k or "lancer" in k:
        mount = '<ellipse cx="32" cy="42" rx="14" ry="8" fill="#8b7355" stroke="#3a2a1a" stroke-width="1.5"/>'
        rider = '<circle cx="32" cy="28" r="5" fill="#c5a059"/><rect x="28" y="32" width="8" height="12" fill="#4a5d3a"/>'
        weapon = ''
        if "lancia" in k or "lancer" in k or "cataphract" in k:
            weapon = '<line x1="42" y1="26" x2="54" y2="16" stroke="#8b7355" stroke-width="2" stroke-linecap="round"/>'
        elif "spada" in k:
            weapon = '<line x1="40" y1="30" x2="50" y2="22" stroke="#8b8b8b" stroke-width="3" stroke-linecap="round"/>'
        elif "arco" in k or "cav_arc" in k:
            weapon = '<path d="M38 28 Q46 28 46 20" fill="none" stroke="#6b4a2a" stroke-width="2"/>'
        return svg(mount + rider + weapon)
    if "nave" in k or "dromone" in k or "drakkar" in k or "giunca" in k or "gal" in k or "vascel" in k or "fregat" in k or "cog" in k or "nef" in k or "snekkja" in k:
        return svg('<path d="M8 44 L16 36 L48 36 L56 44 L48 56 L16 56 Z" fill="#6a5a4a" stroke="#3a2a1a" stroke-width="2"/>'
                   '<line x1="32" y1="36" x2="32" y2="16" stroke="#3a2a1a" stroke-width="2"/>'
                   '<path d="M32 16 L44 28 L32 28 Z" fill="#c5a059"/>')

    # Fanteria
    body = '<circle cx="32" cy="22" r="6" fill="#c5a059"/>'
    torso = '<rect x="26" y="28" width="12" height="18" fill="#4a5d3a" stroke="#2a3d22" stroke-width="1"/>'
    legs = '<rect x="27" y="44" width="4" height="12" fill="#3a2a1a"/><rect x="33" y="44" width="4" height="12" fill="#3a2a1a"/>'
    shield = ''
    weapon = ''
    if "lancia" in k or "picca" in k or "lancier" in k or "picchier" in k:
        weapon = '<line x1="38" y1="24" x2="54" y2="10" stroke="#8b7355" stroke-width="2.5" stroke-linecap="round"/>'
        shield = '<ellipse cx="24" cy="34" rx="4" ry="7" fill="#8b7355" stroke="#3a2a1a"/>'
    elif "spada" in k or "spadacc" in k:
        weapon = '<line x1="40" y1="30" x2="52" y2="18" stroke="#8b8b8b" stroke-width="3" stroke-linecap="round"/>'
    elif "ascia" in k or "boscaiol" in k or "dane" in k or "bondi" in k or "huscarl" in k:
        weapon = '<line x1="40" y1="26" x2="52" y2="14" stroke="#5a3a1a" stroke-width="4" stroke-linecap="round"/>'
    elif "mazza" in k or "mace" in k:
        weapon = '<line x1="40" y1="30" x2="50" y2="18" stroke="#5a5a5a" stroke-width="3" stroke-linecap="round"/>'
        weapon += '<circle cx="50" cy="18" r="3" fill="#4a4a4a"/>'
    elif "arco" in k or "tiro" in k or "sagittari" in k or "longbow" in k:
        weapon = '<path d="M38 26 Q48 26 48 16" fill="none" stroke="#6b4a2a" stroke-width="2"/>'
        weapon += '<line x1="42" y1="18" x2="50" y2="18" stroke="#8b0000" stroke-width="1"/>'
    elif "balestra" in k:
        weapon = '<path d="M38 26 L48 26 L48 16 L38 16 Z" fill="none" stroke="#6b4a2a" stroke-width="2"/>'
        weapon += '<line x1="42" y1="21" x2="50" y2="21" stroke="#8b0000" stroke-width="1"/>'
    else:
        weapon = '<line x1="38" y1="30" x2="48" y2="22" stroke="#8b8b8b" stroke-width="2.5" stroke-linecap="round"/>'
    if "milizia" in k or "contad" in k:
        torso = '<rect x="26" y="28" width="12" height="18" fill="#8b6b3a" stroke="#4a3a1a"/>'
    if "varang" in k or "berserk" in k or "guard" in k or "pretorian" in k or "huscarl" in k or "dane" in k:
        shield = '<rect x="18" y="28" width="6" height="14" fill="#8b0000" stroke="#3a2a1a"/>'
        weapon = weapon.replace('stroke-width="4"', 'stroke-width="5"')
    if "assedio" in k or "balista" in k or "trebuchet" in k or "catapult" in k:
        weapon = '<circle cx="48" cy="32" r="6" fill="#4a4a4a" stroke="#2a2a2a"/>'
        shield = ''
    return svg(body + torso + legs + shield + weapon)


def main():
    with open("data/config/game_config.json", "r", encoding="utf-8") as f:
        cfg = json.load(f)

    for key, svg in BUILDINGS.items():
        save(key, "buildings", svg)

    # Unità dalla config
    for key in cfg["units"].keys():
        save(key, "units", unit_icon(key))

    # Navi
    for key in cfg["ships"].keys():
        save(key, "ships", unit_icon(key))

    # Risorse dalla config
    for key in cfg.get("resources", []):
        save(key, "resources", RESOURCES.get(key, RESOURCES["oro"]))

    # Settlement types
    for key in cfg.get("settlement_types", {}).keys():
        save(key, "settlements", SETTLEMENTS.get(key, SETTLEMENTS["civil"]))

    print("Icone generate in", BASE_DIR)


if __name__ == "__main__":
    main()
