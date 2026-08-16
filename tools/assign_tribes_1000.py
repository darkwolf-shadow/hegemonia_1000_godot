#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Assegna le province 'Terra di Nessuno' della mappa a fazioni tribali o
regionali plausibili per l'anno 1000.
Crea le nuove fazioni in factions_1000.json e sincronizza mappa e province.

Uso:
    python tools/assign_tribes_1000.py        # dry run
    python tools/assign_tribes_1000.py --apply
"""

import json, csv, sys, copy, colorsys
from pathlib import Path
from collections import Counter, defaultdict

GEO_PATH = Path('data/world/mappa_anno_1000.geojson')
PROV_PATH = Path('data/world/provinces_1000.json')
FACTIONS_PATH = Path('data/world/factions_1000.json')
COUNTRY_CODES_PATH = Path('tools/country_codes.csv')

SEA_FEATURECLAS = {'sea', 'ocean', 'gulf', 'bay', 'strait', 'sound', 'channel',
                   'lagoon', 'fjord', 'river', 'reef', 'inlet'}


def is_sea(props):
    fc = (props.get('featurecla') or '').lower()
    if fc in SEA_FEATURECLAS:
        return True
    tipo = (props.get('tipo') or '').lower()
    if tipo == 'mare':
        return True
    return False


def load_country_info():
    info = {}
    if not COUNTRY_CODES_PATH.exists():
        return info
    with open(COUNTRY_CODES_PATH, newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            iso = row.get('ISO3166-1-Alpha-3')
            if not iso:
                continue
            display = (row.get('CLDR display name') or '').strip()
            official = (row.get('official_name_en') or '').strip()
            name = display or official or iso
            info[iso] = {
                'name': name,
                'continent': (row.get('Continent') or '').strip() or None,
                'subregion': (row.get('Sub-region Name') or '').strip() or None,
            }
    return info


# ---------- Mapping storico principale ----------
# Per ogni ISO usato nelle province, restituisce una stringa oppure una
# funzione (lat, lon, name) -> nome fazione.


def _gbr(lat, lon, name):
    if lat > 58.5 and lon < 0:
        return "Regno di Scozia"
    if lat > 55.5 and lon < -1.8:
        return "Regno di Scozia"
    if lon < -2.5 and lat < 53.5 and lat > 51.0:
        return "Principato di Galles"
    if lon < -1.0 and lat < 50.5:
        return "Vichinghi"
    if lon < -5.5 and lat < 55 and lat > 50:
        return "Regno d'Inghilterra"
    return "Regno d'Inghilterra"


def _fra(lat, lon, name):
    if lat < 46.5 and lon > 1.0:
        return "Contea di Tolosa"
    return "Regno di Francia"


def _esp(lat, lon, name):
    if lat > 41.5:
        return "Regni Cristiani di Spagna"
    return "Califfato di Cordova"


def _prt(lat, lon, name):
    if lat > 41.3:
        return "Contea Portoghese"
    return "Califfato di Cordova"


def _nld(lat, lon, name):
    if lat > 52.5 or lon < 4.8:
        return "Contea d'Olanda"
    return "Contea delle Fiandre"


def _rus(lat, lon, name):
    if lat > 55 and lon < 45:
        return "Principato di Novgorod"
    if lon > 80:
        return "Tribù Siberiane"
    if lon > 60:
        return "Tribù Siberiane"
    return "Principato di Novgorod"


def _kaz(lat, lon, name):
    if lon < 60:
        return "Tribù Cumane"
    if lon > 72:
        return "Khanato Qarakhanide"
    return "Tribù Cumane"


def _chn(lat, lon, name):
    if name == 'Yunnan':
        return "Regno di Dali"
    if name in ('Xizang', 'Qinghai'):
        return "Tribù Tibetane"
    if name in ('Gansu', 'Ningxia'):
        return "Regno di Xia Occidentale"
    if name == 'Xinjiang':
        return "Regno di Qocho"
    if name == 'Paracel Islands':
        return "Isole Disabitate"
    return "Tribù Tibetane"


def _ind(lat, lon, name):
    if name in ('Ladakh', 'Jammu and Kashmir', 'Himachal Pradesh', 'Jammu e Kashmir'):
        return "Regno di Ladakh"
    if name in ('Sikkim', 'Assam', 'Arunachal Pradesh', 'Nagaland', 'Manipur',
                'Mizoram', 'Tripura', 'Meghalaya'):
        return "Regno di Kamarupa"
    if name == 'Andaman and Nicobar':
        return "Tribù Andamane"
    # nord/centro -> Gurjara-Pratihara / Kannauj; est -> Impero Pala
    if lon > 84 and lat < 26:
        return "Impero Pala"
    if lon < 77 and lat > 23:
        return "Regno di Kannauj"
    return "Impero Pala"


def _pak(lat, lon, name):
    if lon > 71 and lat > 33:
        return "Regno di Kashmir"
    if lon < 70:
        return "Regno di Sindh"
    return "Sultanato Ghaznavide"


def _irn(lat, lon, name):
    if lon > 57:
        return "Sultanato Ghaznavide"
    if lat > 35 and lon < 50:
        return "Tribù Curde"
    return "Emirato Ziyaride"


def _tur(lat, lon, name):
    if lon > 41 and lat > 38:
        return "Principati Armeni"
    if lon > 38.5 and lat < 38:
        return "Tribù Curde"
    return "Tribù Turche"


def _dza(lat, lon, name):
    if lat > 35:
        return "Tribù Berberi del Maghreb"
    if lat < 30:
        return "Tribù Tuareg"
    return "Emirato Ziride"


def _sdn(lat, lon, name):
    if lat > 16:
        return "Regno di Makuria"
    return "Regno di Alodia"


def _uga(lat, lon, name):
    if lat > 2.5:
        return "Regno di Bunyoro-Kitara"
    return "Tribù Baganda"


def _nga(lat, lon, name):
    if lat >= 10:
        return "Stati Hausa"
    if lon < 7 and lat > 6:
        return "Regno di Ife"
    if lon > 8 and lat < 8:
        return "Regno di Nri"
    return "Regno di Benin"


def _col(lat, lon, name):
    if lat > 9:
        return "Regno Tairona"
    if lon < -75:
        return "Confederazione Muisca"
    return "Tribù Quimbaya"


def _per(lat, lon, name):
    if lon < -76 and lat > -8:
        return "Impero Chimu"
    if lat < -10 and lon < -70:
        return "Regno di Cusco"
    if lon < -72:
        return "Cultura Wari"
    return "Tribù Arawak"


def _bra(lat, lon, name):
    if lat > -2:
        return "Tribù Arawak"
    if lon > -45:
        return "Tribù Tupi"
    if lat < -20:
        return "Tribù Guarani"
    return "Tribù Tupi"


def _arg(lat, lon, name):
    if lat > -24:
        return "Tribù Diaguita"
    if lat < -40:
        return "Tribù Tehuelche"
    return "Tribù Mapuche"


def _chl(lat, lon, name):
    if lat > -22:
        return "Tribù Aymara"
    if lat < -38:
        return "Tribù Tehuelche"
    return "Tribù Mapuche"


def _usa(lat, lon, name):
    if lat > 60:
        return "Tribù Inuit"
    if lon < -115 and lat > 35:
        return "Tribù Ancestrali Pueblo"
    if lon < -120:
        return "Tribù Pacifico Nord-ovest"
    if lon < -100 and lat > 32 and lat < 50:
        return "Tribù delle Pianure"
    if lon > -85 and lat > 30:
        return "Tribù Natchez"
    if lon > -95 and lat > 37:
        return "Tribù Algonchine"
    return "Tribù Irochesi"


def _can(lat, lon, name):
    if lat > 65:
        return "Tribù Inuit"
    if lon < -115:
        return "Tribù Pacifico Nord-ovest"
    if lon < -95 and lat > 50:
        return "Tribù Algonchine"
    return "Prime Nazioni del Canada"


def _mex(lat, lon, name):
    if lat > 22:
        return "Regni Maya"
    if lon < -99:
        return "Impero Tolteco"
    if lon < -96 and lat < 18:
        return "Tribù Mixtechi"
    if lon > -96 and lat < 18:
        return "Tribù Zapotec"
    return "Impero Tolteco"


def _phl(lat, lon, name):
    if lat > 15:
        return "Regno di Tondo"
    if lat < 7:
        return "Regno di Maguindanao"
    return "Regno di Cebu"


def _vnm(lat, lon, name):
    if lat > 17.5:
        return "Dai Viet"
    return "Regno di Champa"


def _idn(lat, lon, name):
    if lat < -6 and lon > 120:
        return "Regno di Sulawesi"
    if lon < 105:
        return "Regno di Srivijaya"
    if lon > 115:
        return "Regno di Srivijaya"
    return "Regno di Java"


def _tza(lat, lon, name):
    if lon > 39:
        return "Regno di Kilwa"
    return "Tribù Bantu Orientali"


def _ago(lat, lon, name):
    if lat > -8:
        return "Regno del Kongo"
    if lat > -16:
        return "Regno di Ndongo"
    return "Tribù Ovimbundu"


def _aus(lat, lon, name):
    if lat > -25 and lon > 130:
        return "Aborigeni Australiani"
    if lat < -30:
        return "Aborigeni Australiani"
    return "Aborigeni Australiani"


def _nz(lat, lon, name):
    return "Terra Incognita"


def _car(lat, lon, name):
    if lat > 17 or (lat > 15 and lon < -72):
        return "Tribù Taino"
    return "Tribù Caraibiche"


def _central_america(lat, lon, name):
    if lat > 15.5 and lon < -88:
        return "Tribù Maya"
    if lon < -96 and lat > 18:
        return "Tribù Maya"
    if lat > 15 and lon > -96:
        return "Tribù Nahua"
    if lat < 12 and lon > -86:
        return "Tribù Bribri"
    return "Tribù Ngäbe"


ISO_SPECIAL = {
    # Isole britanniche e nordiche
    'GBR': _gbr,
    'IRL': "Regni Irlandesi",
    'IMN': "Vichinghi",
    'NOR': "Regno di Norvegia",
    'GRL': "Tribù Inuit",
    'FIN': "Tribù Finniche",
    'LVA': lambda lat, lon, name: "Tribù Curoni" if lon < 24 else ("Tribù Selonici" if lat < 56.5 else "Tribù Letgalli"),
    'EST': "Tribù Baltiche",
    'LTU': "Tribù Baltiche",
    'BLR': "Principato di Polotsk",
    'UKR': lambda lat, lon, name: "Principato di Galizia-Volinia" if lon < 30 else "Tribù Cumane",
    'RUS': _rus,
    'KAZ': _kaz,
    'UZB': "Khanato Qarakhanide",
    'KGZ': "Khanato Qarakhanide",
    'TKM': "Tribù Oghuz",
    'TJK': "Khanato Qarakhanide",
    'MNG': "Tribù Mongole",

    # Asia orientale e sud-orientale
    'CHN': _chn,
    'KOR': "Regno di Goryeo",
    'PRK': "Regno di Goryeo",
    'JPN': lambda lat, lon, name: "Tribù Ainu" if lat > 40 else "Regno Heian",
    'TWN': "Tribù Aborigene di Taiwan",
    'HKG': "Regno di Nanhan",
    'VNM': _vnm,
    'LAO': "Tribù Tai",
    'THA': "Regno di Lavo",
    'MMR': "Regno di Pagan",
    'KHM': "Regno Khmer",
    'IDN': _idn,
    'MYS': "Regno di Srivijaya",
    'PHL': _phl,
    'PNG': "Tribù Papuane",
    'TLS': "Regno di Wehali",
    'BRN': "Regno di Srivijaya",
    'SGP': "Regno di Srivijaya",

    # Sud Asia
    'IND': _ind,
    'PAK': _pak,
    'BGD': "Impero Pala",
    'NPL': "Regno di Nepal",
    'BTN': "Regno di Bhutan",
    'LKA': "Impero Chola",
    'MDV': "Regno di Maldive",

    # Asia occidentale
    'TUR': _tur,
    'SYR': "Tribù Arabe del Levante",
    'JOR': "Tribù Arabe del Levante",
    'LBN': "Tribù Arabe del Levante",
    'ISR': "Tribù Arabe del Levante",
    'SAU': "Shariffato della Mecca",
    'YEM': "Regno di Yemen",
    'OMN': "Imamato di Oman",
    'ARE': "Tribù Arabe del Golfo",
    'QAT': "Tribù Arabe del Golfo",
    'BHR': "Tribù Arabe del Golfo",
    'KWT': "Tribù Arabe del Golfo",
    'GEO': "Regno di Georgia",
    'ARM': "Regno di Armenia",
    'AZE': "Regno di Shirvan",
    'IRQ': "Califfato Abbaside",
    'IRN': _irn,

    # Nord Africa
    'DZA': _dza,
    'TUN': "Emirato Ziride",
    'MAR': "Tribù Berberi del Maghreb",
    'LBY': "Emirato Ziride",
    'EGY': "Impero Fatimide",
    'SDN': _sdn,
    'SSD': "Regno di Alodia",
    'MRT': "Tribù Sanhaja",
    'SAH': "Tribù Sanhaja",

    # Africa occidentale
    'GIN': "Tribù Mandinka",
    'SEN': "Tribù Wolof",
    'GMB': "Tribù Wolof",
    'BFA': "Tribù Mossi",
    'CIV': "Tribù Akan",
    'GHA': "Tribù Akan",
    'TGO': "Regno di Benin",
    'BEN': "Regno di Dahomey",
    'NGA': _nga,
    'NER': "Regno di Kanem-Bornu",
    'MLI': "Regno di Sosso",
    'LBR': "Tribù Kru",
    'SLE': "Tribù Mende",
    'GNB': "Tribù Mandinka",
    'CPV': "Isole Disabitate",

    # Africa centrale/meridionale/orientale
    'CMR': "Tribù Bamileke",
    'CAF': "Tribù Bantu Centrali",
    'TCD': "Regno di Kanem-Bornu",
    'COD': "Regno del Kongo",
    'COG': "Regno del Kongo",
    'GAB': "Tribù Bantu Centrali",
    'AGO': _ago,
    'ETH': "Regno d'Etiopia",
    'ERI': "Regno d'Etiopia",
    'SOM': "Tribù Somale",
    'DJI': "Tribù Afar",
    'KEN': "Tribù Swahili",
    'TZA': _tza,
    'UGA': _uga,
    'RWA': "Regno di Rwanda",
    'BDI': "Regno di Burundi",
    'MWI': "Regno di Maravi",
    'MOZ': "Regno di Kilwa",
    'MDG': "Tribù Malgascio",
    'ZMB': "Regno di Mapungubwe",
    'ZWE': "Regno di Mapungubwe",
    'BWA': "Tribù Khoisan",
    'NAM': "Tribù Khoisan",
    'ZAF': "Tribù Khoisan",
    'SWZ': "Tribù Nguni",
    'LSO': "Tribù Sotho",
    'COM': "Regno di Kilwa",
    'SYC': "Isole Disabitate",
    'MUS': "Isole Disabitate",
    'STP': "Isole Disabitate",
    'GNQ': "Tribù Bantu Centrali",

    # Europa occidentale
    'FRA': _fra,
    'NLD': _nld,
    'BEL': "Contea delle Fiandre",
    'LUX': "Sacro Romano Impero",
    'CHE': "Sacro Romano Impero",
    'AUT': "Sacro Romano Impero",
    'ESP': _esp,
    'PRT': _prt,
    'AND': "Regno di Aragona",
    'MCO': "Sacro Romano Impero",
    'SMR': "Papato di Roma",
    'VAT': "Papato di Roma",
    'ALD': "Contea di Normandia",

    # Europa meridionale e balcani
    'ITA': lambda lat, lon, name: "Papato di Roma" if name in ('Roma','Vatican','Latina') else ("Impero Bizantino" if lat < 41.5 else ("Tribù Sarda" if name in ('Baronia','Campidano') else "Sacro Romano Impero")),
    'MLT': "Tribù Maltese",
    'HRV': "Regno di Croazia",
    'BIH': "Regno di Croazia",
    'SRB': "Regno di Serbia",
    'MNE': "Regno di Duklja",
    'MKD': "Regno di Bulgaria",
    'SVN': "Regno di Croazia",
    'ALB': "Regno di Duklja",
    'BGR': "Regno di Bulgaria",
    'GRC': "Impero Bizantino",
    'CYP': "Impero Bizantino",
    'CZE': "Sacro Romano Impero",
    'SVK': "Sacro Romano Impero",
    'HUN': "Regno d'Ungheria",
    'POL': "Regno di Polonia",
    'ROU': "Regno d'Ungheria",
    'MDA': "Principato di Kiev",
    'DNK': "Regno di Danimarca",
    'SWE': "Regno di Svezia",
    'ISL': "Regno di Norvegia",

    # Americhe
    'USA': _usa,
    'CAN': _can,
    'MEX': _mex,
    'GTM': "Tribù Maya",
    'BLZ': "Tribù Maya",
    'HND': "Tribù Maya",
    'SLV': "Tribù Maya",
    'NIC': "Tribù Maya",
    'CRI': "Tribù Bribri",
    'PAN': "Tribù Ngäbe",
    'COL': _col,
    'ECU': lambda lat, lon, name: "Regno di Quito" if lat > -2 else "Cultura Bahia",
    'PER': _per,
    'BOL': lambda lat, lon, name: "Cultura Tiwanaku" if lat > -20 else "Tribù Aymara",
    'BRA': _bra,
    'VEN': lambda lat, lon, name: "Tribù Caraibiche" if lon > -65 else "Tribù Arawak",
    'GUY': "Tribù Arawak",
    'SUR': "Tribù Arawak",
    'GUF': "Tribù Arawak",
    'URY': "Tribù Charrua",
    'PRY': "Tribù Guarani",
    'ARG': _arg,
    'CHL': _chl,
    'CUB': "Tribù Taino",
    'HTI': "Tribù Taino",
    'DOM': "Tribù Taino",
    'JAM': "Tribù Taino",
    'PRI': "Tribù Taino",
    'BHS': "Tribù Lucayane",
    'BRB': "Tribù Caraibiche",
    'LCA': "Tribù Caraibiche",
    'VCT': "Tribù Caraibiche",
    'GRD': "Tribù Caraibiche",
    'ATG': "Tribù Caraibiche",
    'DMA': "Tribù Caraibiche",
    'KNA': "Tribù Caraibiche",
    'MSR': "Tribù Caraibiche",
    'AIA': "Tribù Caraibiche",
    'VGB': "Tribù Caraibiche",
    'TCA': "Tribù Caraibiche",
    'VIR': "Tribù Caraibiche",
    'MAF': "Tribù Caraibiche",
    'SXM': "Tribù Caraibiche",
    'BLM': "Tribù Caraibiche",
    'TTO': "Tribù Caraibiche",
    'BMU': "Isole Disabitate",

    # Oceania
    'AUS': _aus,
    'NZL': _nz,
    'FJI': "Tribù Melanesiane",
    'VUT': "Tribù Melanesiane",
    'SLB': "Tribù Melanesiane",
    'COK': "Polinesiani",
    'WSM': "Polinesiani",
    'TON': "Polinesiani",
    'KIR': "Polinesiani",
    'MHL': "Micronesiani",
    'NRU': "Polinesiani",
    'TUV': "Polinesiani",
    'NIU': "Polinesiani",
    'PLW': "Micronesiani",
    'FSM': "Micronesiani",
    'GUM': "Tribù Chamorro",
    'MNP': "Tribù Chamorro",
    'ASM': "Polinesiani",
    'PYF': "Polinesiani",
    'NCL': "Tribù Melanesiane",
    'WLF': "Polinesiani",
    'NFK': "Isole Disabitate",
    'PCN': "Isole Disabitate",
    'FLK': "Isole Disabitate",
    'SGS': "Isole Disabitate",
    'HMD': "Isole Disabitate",
    'IOT': "Isole Disabitate",
    'SHN': "Isole Disabitate",
    'ATF': "Terra Incognita",
    'ATA': "Terra Incognita",

    # Codici non standard
    'KAS': "Regno di Kashmir",
    'KAB': "Sultanato Ghaznavide",
    'SOL': "Tribù Melanesiane",
    'PSX': "Tribù Arabe del Levante",
    'USG': "Isole Disabitate",
    'UMI': "Isole Disabitate",
    'SDS': _sdn,
    'CUW': "Tribù Caraibiche",
    'ABW': "Tribù Caraibiche",
    'BES': "Tribù Caraibiche",
    'SPM': "Isole Disabitate",
    'JEY': "Contea di Normandia",
    'GGY': "Contea di Normandia",
    'CSI': "Isole Disabitate",
    'PGA': "Isole Disabitate",
    'CLP': "Isole Disabitate",
    'ATC': "Isole Disabitate",
    'IOA': "Isole Disabitate",
}


def choose_faction(name, admin, iso, lat, lon, props, info):
    try:
        lat = float(lat) if lat not in (None, '') else 0.0
    except (ValueError, TypeError):
        lat = 0.0
    try:
        lon = float(lon) if lon not in (None, '') else 0.0
    except (ValueError, TypeError):
        lon = 0.0
    if is_sea(props):
        return "Mare Aperto"

    # Province italiane senza ISO
    if admin == "Regno d'Italia" and not iso:
        if name in ('Roma', 'Vatican', 'Latina'):
            return "Papato di Roma"
        if name in ('Baronia', 'Campidano'):
            return "Tribù Sarda"
        if lat < 41.5:
            return "Impero Bizantino"
        return "Sacro Romano Impero"

    # Province cinesi lasciate neutre da recalibrate_1000.py
    if name == 'Guantanamo Bay USNB':
        return "Tribù Taino"
    if admin == 'Regno Unito' and not iso:
        if name == 'Cardiff':
            return "Principato di Galles"
        if name in ('Bristol', 'Londra'):
            return "Regno d'Inghilterra"
        return _gbr(lat, lon, name)
    if admin == 'Impero Russo' and not iso:
        return "Regno di Shirvan"
    if admin == 'Impero Qing':
        return _chn(lat, lon, name)

    # Canale di Normandia / isole del Canale
    if admin == 'Regno Unito' and iso == 'ALD':
        return "Contea di Normandia"

    # ISO speciale
    special = ISO_SPECIAL.get(iso)
    if special:
        if callable(special):
            return special(lat, lon, name)
        return special

    # Fallback per ISO non elencato: genera un nome basato sul paese.
    cinfo = info.get(iso)
    if cinfo:
        continent = cinfo.get('continent') or ''
        cname = cinfo.get('name', iso)
        # pulizia nome
        cname = cname.replace('the ', '').replace('The ', '').strip()
        if continent == 'AF':
            return f"Tribù di {cname}"
        if continent == 'AS':
            return f"Tribù di {cname}"
        if continent == 'EU':
            return f"Contea di {cname}"
        if continent in ('NA', 'SA'):
            return f"Tribù di {cname}"
        if continent == 'OC':
            return f"Tribù di {cname}"
        if continent == 'AN':
            return "Terra Incognita"
        return f"Tribù di {cname}"

    # Ultimo fallback
    return "Tribù Locale"


# ---------- Generazione fazioni ----------


def _hash_color(name):
    h = hash(name) % 360
    s = 0.55 + (hash(name) % 20) / 100.0
    v = 0.75 + (hash(name) % 15) / 100.0
    r, g, b = colorsys.hsv_to_rgb(h / 360.0, s, v)
    return '#{:02x}{:02x}{:02x}'.format(int(r * 255), int(g * 255), int(b * 255))


FACTION_TEMPLATE = {
    "name": "",
    "leader": "Capo",
    "attitude": "balanced",
    "color": "",
    "capital": "",
    "resources": {
        "oro": 1200,
        "legname": 40,
        "pietra": 30,
        "ferro": 15,
        "argento": 10,
        "armi": 10,
        "cibo": 6000,
        "prestigio": 15
    },
    "units": {
        "fanteria": 12,
        "arcieri": 5,
        "cavalleria": 0,
        "artiglieria": 0
    },
    "ships": {},
    "buildings": ["mulino", "fucina", "mercato"],
    "production": {
        "oro": 40,
        "cibo": 80,
        "armi": 0,
        "prestigio": 0
    },
    "modifiers": {
        "oro": 1.0,
        "cibo": 1.0,
        "armi": 1.0,
        "prestigio": 1.0
    },
    "description": "Fazione locale dell'anno 1000."
}


def generate_faction(name, continent=None):
    f = copy.deepcopy(FACTION_TEMPLATE)
    f["name"] = name
    f["color"] = _hash_color(name)
    if name in ('Mare Aperto', 'Isole Disabitate', 'Terra Incognita', 'Terra di Nessuno'):
        f["is_neutral"] = True
        f["units"] = {}
        f["resources"] = {"oro": 0, "cibo": 0}
        f["production"] = {"oro": 0, "cibo": 0}
    else:
        # Varianti leggere per continente
        if continent == 'EU':
            f["units"]["cavalleria"] = 3
        elif continent == 'AF':
            f["units"]["fanteria"] = 15
            f["units"]["arcieri"] = 3
        elif continent == 'AS':
            f["units"]["cavalleria"] = 4
        elif continent == 'NA' or continent == 'SA':
            f["units"]["fanteria"] = 10
            f["units"]["arcieri"] = 6
        elif continent == 'OC':
            f["units"]["fanteria"] = 8
            f["ships"]["canoa"] = 2
    return f


# ---------- Applicazione ----------


def apply(dry_run=True):
    geo = json.load(open(GEO_PATH, 'r', encoding='utf-8'))
    prov = json.load(open(PROV_PATH, 'r', encoding='utf-8'))
    factions = json.load(open(FACTIONS_PATH, 'r', encoding='utf-8'))
    info = load_country_info()

    new_owners = {}
    new_faction_names = set()
    for feature in geo['features']:
        props = feature['properties']
        name = props.get('name') or props.get('name_it') or props.get('name_en') or ''
        admin = props.get('admin')
        iso = props.get('adm0_a3')
        lat = props.get('latitude')
        lon = props.get('longitude')
        current = props.get('STATO_1000', 'Terra di Nessuno')

        if current != 'Terra di Nessuno':
            continue

        target = choose_faction(name, admin, iso, lat, lon, props, info)
        pname = name
        new_owners[pname] = target
        new_faction_names.add(target)

    # Propaga ai provinces_1000.json
    missing = 0
    for pname, target in new_owners.items():
        if pname in prov:
            prov[pname]['owner'] = target
        else:
            missing += 1

    # Aggiorna STATO_1000 nel GeoJSON
    for feature in geo['features']:
        props = feature['properties']
        pname = props.get('name') or props.get('name_it') or props.get('name_en') or ''
        if pname in new_owners:
            props['STATO_1000'] = new_owners[pname]

    # Aggiungi fazioni mancanti
    for fname in new_faction_names:
        if fname in factions:
            continue
        iso_for_name = None
        # prova a indovinare continente dal primo paese che produce questa fazione
        for pname, target in new_owners.items():
            if target != fname:
                continue
            iso = None
            for f in geo['features']:
                if (f['properties'].get('name') or f['properties'].get('name_it') or f['properties'].get('name_en') or '') == pname:
                    iso = f['properties'].get('adm0_a3')
                    break
            if iso and iso in info:
                factions[fname] = generate_faction(fname, info[iso]['continent'])
                break
        else:
            factions[fname] = generate_faction(fname)

    # Controlli
    counts = Counter(prov[p].get('owner', '?') for p in prov)
    remaining = counts.get('Terra di Nessuno', 0)
    land_remaining = 0
    for feature in geo['features']:
        p = feature['properties']
        if p.get('STATO_1000') == 'Terra di Nessuno' and not is_sea(p):
            land_remaining += 1

    print(f'Province riassegnate: {len(new_owners)}')
    print(f'Terra di Nessuno rimanenti (totale): {remaining}')
    print(f'Terra di Nessuno rimanenti su terraferma: {land_remaining}')
    print(f'Nuove fazioni create: {len(new_faction_names)}')
    if missing:
        print(f'ATTENZIONE: {missing} province del GeoJSON non trovate in provinces_1000.json')

    if not dry_run:
        with open(GEO_PATH, 'w', encoding='utf-8') as f:
            json.dump(geo, f, ensure_ascii=False, separators=(',', ':'))
        with open(PROV_PATH, 'w', encoding='utf-8') as f:
            json.dump(prov, f, ensure_ascii=False, indent=2)
        with open(FACTIONS_PATH, 'w', encoding='utf-8') as f:
            json.dump(factions, f, ensure_ascii=False, indent=2)
        print('File scritti.')
    else:
        print('Dry-run: nessun file modificato.')
        # Stampa le fazioni con piu province
        top = counts.most_common(40)
        print('\nTop 40 fazioni per numero di province:')
        for name, n in top:
            print(f'  {name}: {n}')


if __name__ == '__main__':
    dry = '--apply' not in sys.argv
    apply(dry_run=dry)
