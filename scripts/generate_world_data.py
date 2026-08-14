#!/usr/bin/env python3
"""Genera i dati di Hegemonia 1000 (fazioni, province, mappa GeoJSON)."""

import json
import os
import math

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

FACTIONS = {
    "Impero Bizantino": {
        "name": "Impero Bizantino",
        "leader": "Basilio II",
        "attitude": "balanced",
        "color": "#8A2BE2",
        "capital": "Costantinopoli",
        "playable": True,
        "resources": {"oro": 18000, "legname": 80, "pietra": 70, "ferro": 50, "argento": 40, "armi": 60, "cibo": 25000, "prestigio": 100},
        "units": {"fanteria": 30, "arcieri": 20, "cavalleria": 25, "artiglieria": 5, "cataphractoi": 10, "varangian_guard": 5},
        "ships": {"dromone": 12, "galea": 6},
        "buildings": ["monastero", "castello", "fucina", "fortezza_frontiera"],
        "production": {"oro": 700, "cibo": 600, "armi": 4, "prestigio": 5},
        "modifiers": {"oro": 1.0, "cibo": 1.0, "armi": 1.0, "prestigio": 1.0},
        "description": "Impero Romano d'Oriente all'apice sotto Basilio II, padrone dei mari e dell'Anatolia."
    },
    "Sacro Romano Impero": {
        "name": "Sacro Romano Impero",
        "leader": "Ottone III",
        "attitude": "defensive",
        "color": "#FFD700",
        "capital": "Roma",
        "playable": True,
        "resources": {"oro": 14000, "legname": 100, "pietra": 80, "ferro": 60, "argento": 30, "armi": 50, "cibo": 22000, "prestigio": 85},
        "units": {"fanteria": 35, "arcieri": 15, "cavalleria": 20, "artiglieria": 3, "milites": 12, "loricati": 8},
        "ships": {"galea": 4},
        "buildings": ["monastero", "castello", "mulino", "mercato"],
        "production": {"oro": 550, "cibo": 500, "armi": 2, "prestigio": 3},
        "modifiers": {"oro": 1.0, "cibo": 1.0, "armi": 1.0, "prestigio": 1.0},
        "description": "Sacro Romano Impero di Ottone III, tra Germania e Italia."
    },
    "Vichinghi": {
        "name": "Vichinghi",
        "leader": "Leif Erikson",
        "attitude": "aggressive",
        "color": "#B22222",
        "capital": "Hedeby",
        "playable": True,
        "resources": {"oro": 9000, "legname": 120, "pietra": 30, "ferro": 60, "argento": 35, "armi": 40, "cibo": 12000, "prestigio": 60},
        "units": {"fanteria": 25, "arcieri": 20, "cavalleria": 8, "artiglieria": 1, "berserker": 8, "huskarl": 10},
        "ships": {"drakkar": 18, "galea": 3},
        "buildings": ["mulino", "fucina", "mercato"],
        "production": {"oro": 350, "cibo": 250, "armi": 2, "prestigio": 1},
        "modifiers": {"oro": 1.0, "cibo": 1.0, "armi": 1.0, "prestigio": 1.0},
        "description": "Popoli scandinavi, maestri delle incursioni navali."
    },
    "Regno di Francia": {
        "name": "Regno di Francia",
        "leader": "Ugo Capeto",
        "attitude": "balanced",
        "color": "#0055AA",
        "capital": "Parigi",
        "resources": {"oro": 11000, "legname": 90, "pietra": 60, "ferro": 40, "argento": 20, "armi": 35, "cibo": 18000, "prestigio": 70},
        "units": {"fanteria": 30, "arcieri": 12, "cavalleria": 15, "artiglieria": 1, "cavalleria_pesante": 8},
        "ships": {"galea": 3},
        "buildings": ["castello", "mulino", "mercato"],
        "production": {"oro": 450, "cibo": 400, "armi": 1, "prestigio": 2},
        "modifiers": {"oro": 1.0, "cibo": 1.0, "armi": 1.0, "prestigio": 1.0},
        "description": "Regno dei Franchi occidentali, fertile ma diviso."
    },
    "Califfato di Cordova": {
        "name": "Califfato di Cordova",
        "leader": "Hisham II",
        "attitude": "aggressive",
        "color": "#2E8B57",
        "capital": "Cordova",
        "resources": {"oro": 12000, "legname": 70, "pietra": 50, "ferro": 30, "argento": 25, "armi": 40, "cibo": 16000, "prestigio": 75},
        "units": {"fanteria": 32, "arcieri": 18, "cavalleria": 18, "artiglieria": 3, "jinete": 10, "black_guard": 5},
        "ships": {"galea": 6, "nave_guerra": 3},
        "buildings": ["mercato", "fucina", "monastero"],
        "production": {"oro": 500, "cibo": 350, "armi": 2, "prestigio": 2},
        "modifiers": {"oro": 1.0, "cibo": 1.0, "armi": 1.0, "prestigio": 1.0},
        "description": "Emirato/Califfato omayyade in Iberia, ricco e culturale."
    },
    "Impero Fatimide": {
        "name": "Impero Fatimide",
        "leader": "Al-Hakim",
        "attitude": "aggressive",
        "color": "#228B22",
        "capital": "Il Cairo",
        "resources": {"oro": 15000, "legname": 60, "pietra": 50, "ferro": 40, "argento": 35, "armi": 45, "cibo": 25000, "prestigio": 80},
        "units": {"fanteria": 40, "arcieri": 22, "cavalleria": 20, "artiglieria": 4, "mamluk_cavalry": 8, "sudanese_spearmen": 12},
        "ships": {"dromone": 6, "galea": 8},
        "buildings": ["mercato", "castello", "fucina"],
        "production": {"oro": 600, "cibo": 450, "armi": 2, "prestigio": 2},
        "modifiers": {"oro": 1.0, "cibo": 1.0, "armi": 1.0, "prestigio": 1.0},
        "description": "Califfato ismailita che domina Egitto, Nord Africa e Levante."
    },
    "Regno d'Ungheria": {
        "name": "Regno d'Ungheria",
        "leader": "Stefano I",
        "attitude": "balanced",
        "color": "#556B2F",
        "capital": "Esztergom",
        "resources": {"oro": 7000, "legname": 80, "pietra": 30, "ferro": 25, "argento": 10, "armi": 25, "cibo": 12000, "prestigio": 55},
        "units": {"fanteria": 22, "arcieri": 15, "cavalleria": 12, "artiglieria": 1, "magyar_cavalry": 10, "szekler_infantry": 5},
        "ships": {"galea": 1},
        "buildings": ["castello", "monastero"],
        "production": {"oro": 300, "cibo": 280, "armi": 1, "prestigio": 1},
        "modifiers": {"oro": 1.0, "cibo": 1.0, "armi": 1.0, "prestigio": 1.0},
        "description": "Regno cristiano degli Ungari, tra steppa ed Europa centrale."
    },
    "Principato di Kiev": {
        "name": "Principato di Kiev",
        "leader": "Vladimir I",
        "attitude": "balanced",
        "color": "#4682B4",
        "capital": "Kiev",
        "resources": {"oro": 8000, "legname": 100, "pietra": 40, "ferro": 35, "argento": 20, "armi": 30, "cibo": 15000, "prestigio": 60},
        "units": {"fanteria": 25, "arcieri": 15, "cavalleria": 12, "artiglieria": 1, "druzhina": 10, "voi": 15},
        "ships": {"drakkar": 5, "galea": 2},
        "buildings": ["mulino", "fucina", "mercato"],
        "production": {"oro": 350, "cibo": 320, "armi": 1, "prestigio": 1},
        "modifiers": {"oro": 1.0, "cibo": 1.0, "armi": 1.0, "prestigio": 1.0},
        "description": "Rus' di Kiev, tra Scandinavia e Bisanzio."
    },
    "Regno di Polonia": {
        "name": "Regno di Polonia",
        "leader": "Boleslao I",
        "attitude": "balanced",
        "color": "#DC143C",
        "capital": "Gniezno",
        "resources": {"oro": 6500, "legname": 85, "pietra": 35, "ferro": 25, "argento": 8, "armi": 25, "cibo": 14000, "prestigio": 50},
        "units": {"fanteria": 25, "arcieri": 12, "cavalleria": 8, "artiglieria": 1, "druzyna": 8, "polish_spearmen": 10},
        "ships": {"galea": 1},
        "buildings": ["castello", "mulino"],
        "production": {"oro": 280, "cibo": 300, "armi": 1, "prestigio": 1},
        "modifiers": {"oro": 1.0, "cibo": 1.0, "armi": 1.0, "prestigio": 1.0},
        "description": "Regno slavo occidentale in espansione."
    },
    "Califfato Abbaside": {
        "name": "Califfato Abbaside",
        "leader": "Al-Qadir",
        "attitude": "defensive",
        "color": "#000000",
        "capital": "Baghdad",
        "resources": {"oro": 13000, "legname": 70, "pietra": 60, "ferro": 50, "argento": 30, "armi": 40, "cibo": 20000, "prestigio": 75},
        "units": {"fanteria": 35, "arcieri": 18, "cavalleria": 22, "artiglieria": 4, "ghilman": 10, "daylami_infantry": 8},
        "ships": {"dromone": 4, "galea": 3},
        "buildings": ["monastero", "mercato", "fucina"],
        "production": {"oro": 550, "cibo": 400, "armi": 2, "prestigio": 2},
        "modifiers": {"oro": 1.0, "cibo": 1.0, "armi": 1.0, "prestigio": 1.0},
        "description": "Califfato abbaside, teoricamente capo del mondo islamico, ma ormai decentralizzato."
    },
    "Sultanato Ghaznavide": {
        "name": "Sultanato Ghaznavide",
        "leader": "Mahmud di Ghazna",
        "attitude": "aggressive",
        "color": "#8B4513",
        "capital": "Ghazna",
        "resources": {"oro": 10000, "legname": 60, "pietra": 30, "ferro": 30, "argento": 15, "armi": 35, "cibo": 16000, "prestigio": 65},
        "units": {"fanteria": 30, "arcieri": 15, "cavalleria": 18, "artiglieria": 2, "ghulam_cavalry": 10, "war_elephants": 4},
        "ships": {"galea": 2},
        "buildings": ["fucina", "mercato", "monastero"],
        "production": {"oro": 450, "cibo": 350, "armi": 2, "prestigio": 1},
        "modifiers": {"oro": 1.0, "cibo": 1.0, "armi": 1.0, "prestigio": 1.0},
        "description": "Stato turco-afghano, famoso per i raid in India e gli elefanti da guerra."
    },
    "Dinastia Song": {
        "name": "Dinastia Song",
        "leader": "Zhenzong",
        "attitude": "balanced",
        "color": "#FF4500",
        "capital": "Kaifeng",
        "resources": {"oro": 20000, "legname": 100, "pietra": 80, "ferro": 70, "argento": 55, "armi": 60, "cibo": 35000, "prestigio": 90},
        "units": {"fanteria": 45, "arcieri": 35, "cavalleria": 15, "artiglieria": 6, "crossbowmen": 25, "fire_lance": 5},
        "ships": {"giunca": 10, "tower_ship": 4},
        "buildings": ["mercato", "fucina", "mulino"],
        "production": {"oro": 800, "cibo": 700, "armi": 4, "prestigio": 4},
        "modifiers": {"oro": 1.0, "cibo": 1.0, "armi": 1.0, "prestigio": 1.0},
        "description": "Cina imperiale florida, tecnologicamente avanzata con balestre e polvere da sparo."
    },
    "Impero Khitan Liao": {
        "name": "Impero Khitan Liao",
        "leader": "Shengzong",
        "attitude": "aggressive",
        "color": "#87CEEB",
        "capital": "Shangjing",
        "resources": {"oro": 11000, "legname": 90, "pietra": 40, "ferro": 45, "argento": 20, "armi": 40, "cibo": 18000, "prestigio": 60},
        "units": {"fanteria": 20, "arcieri": 25, "cavalleria": 30, "artiglieria": 2, "khitan_horse_archers": 15, "liao_lancers": 10},
        "ships": {"giunca": 3},
        "buildings": ["fucina", "mulino"],
        "production": {"oro": 400, "cibo": 350, "armi": 2, "prestigio": 1},
        "modifiers": {"oro": 1.0, "cibo": 1.0, "armi": 1.0, "prestigio": 1.0},
        "description": "Impero nomade Khitan nel nord della Cina, temibile cavalleria."
    },
    "Impero Chola": {
        "name": "Impero Chola",
        "leader": "Rajaraja I",
        "attitude": "aggressive",
        "color": "#FF8C00",
        "capital": "Tanjore",
        "resources": {"oro": 12000, "legname": 80, "pietra": 50, "ferro": 35, "argento": 30, "armi": 40, "cibo": 22000, "prestigio": 70},
        "units": {"fanteria": 35, "arcieri": 15, "cavalleria": 8, "artiglieria": 2, "elephant_corps": 6, "tamil_infantry": 12},
        "ships": {"nave_guerra_indiana": 8, "giunca": 4},
        "buildings": ["monastero", "mercato", "fucina"],
        "production": {"oro": 500, "cibo": 450, "armi": 2, "prestigio": 2},
        "modifiers": {"oro": 1.0, "cibo": 1.0, "armi": 1.0, "prestigio": 1.0},
        "description": "Potenza marittima del Sud India con flotta ed elefanti."
    },
    "Regno Khmer": {
        "name": "Regno Khmer",
        "leader": "Suryavarman I",
        "attitude": "balanced",
        "color": "#9932CC",
        "capital": "Angkor",
        "resources": {"oro": 8000, "legname": 90, "pietra": 60, "ferro": 25, "argento": 15, "armi": 30, "cibo": 16000, "prestigio": 55},
        "units": {"fanteria": 25, "arcieri": 12, "cavalleria": 5, "artiglieria": 1, "khmer_spearmen": 10, "war_elephants": 3},
        "ships": {"giunca": 2},
        "buildings": ["monastero", "mulino", "mercato"],
        "production": {"oro": 300, "cibo": 320, "armi": 1, "prestigio": 1},
        "modifiers": {"oro": 1.0, "cibo": 1.0, "armi": 1.0, "prestigio": 1.0},
        "description": "Regno dell'Indocina, costruttore di Angkor."
    },
    "Regno Heian": {
        "name": "Regno Heian",
        "leader": "Emperor Ichijo",
        "attitude": "defensive",
        "color": "#FF69B4",
        "capital": "Kyoto",
        "resources": {"oro": 9000, "legname": 80, "pietra": 40, "ferro": 30, "argento": 20, "armi": 25, "cibo": 14000, "prestigio": 60},
        "units": {"fanteria": 20, "arcieri": 18, "cavalleria": 8, "artiglieria": 1, "samurai": 8, "yamato_infantry": 10},
        "ships": {"giunca": 4},
        "buildings": ["monastero", "mulino"],
        "production": {"oro": 350, "cibo": 300, "armi": 1, "prestigio": 2},
        "modifiers": {"oro": 1.0, "cibo": 1.0, "armi": 1.0, "prestigio": 1.0},
        "description": "Giappone classico, dominato dai clan samurai."
    },
    "Regno di Srivijaya": {
        "name": "Regno di Srivijaya",
        "leader": "Sri Cudamani Warmadewa",
        "attitude": "balanced",
        "color": "#DAA520",
        "capital": "Palembang",
        "resources": {"oro": 9000, "legname": 90, "pietra": 30, "ferro": 20, "argento": 25, "armi": 25, "cibo": 16000, "prestigio": 55},
        "units": {"fanteria": 20, "arcieri": 18, "cavalleria": 2, "artiglieria": 0, "malay_archers": 12},
        "ships": {"giunca": 8, "nave_guerra_indiana": 4},
        "buildings": ["mercato", "mulino"],
        "production": {"oro": 400, "cibo": 350, "armi": 1, "prestigio": 1},
        "modifiers": {"oro": 1.0, "cibo": 1.0, "armi": 1.0, "prestigio": 1.0},
        "description": "Potenza commerciale marittima del Sud-Est asiatico."
    },
    "Impero del Ghana": {
        "name": "Impero del Ghana",
        "leader": "Re Ghana",
        "attitude": "balanced",
        "color": "#CD853F",
        "capital": "Koumbi Saleh",
        "resources": {"oro": 11000, "legname": 50, "pietra": 20, "ferro": 20, "argento": 10, "armi": 20, "cibo": 12000, "prestigio": 50},
        "units": {"fanteria": 25, "arcieri": 15, "cavalleria": 12, "artiglieria": 0, "soninke_cavalry": 8, "sudani_spearmen": 10},
        "ships": {"galea": 2},
        "buildings": ["mercato", "mulino"],
        "production": {"oro": 500, "cibo": 280, "armi": 1, "prestigio": 1},
        "modifiers": {"oro": 1.0, "cibo": 1.0, "armi": 1.0, "prestigio": 1.0},
        "description": "Regno del Sahel, ricco d'oro e sale."
    },
    "Toltechi": {
        "name": "Toltechi",
        "leader": "Ce Acatl Topiltzin",
        "attitude": "aggressive",
        "color": "#20B2AA",
        "capital": "Tollan",
        "resources": {"oro": 6000, "legname": 80, "pietra": 30, "ferro": 10, "argento": 20, "armi": 20, "cibo": 10000, "prestigio": 50},
        "units": {"fanteria": 20, "arcieri": 15, "cavalleria": 0, "artiglieria": 0, "jaguar_warrior": 8, "eagle_warrior": 6, "atlatl": 5},
        "ships": {"canoa": 3},
        "buildings": ["monastero", "mulino"],
        "production": {"oro": 250, "cibo": 220, "armi": 1, "prestigio": 1},
        "modifiers": {"oro": 1.0, "cibo": 1.0, "armi": 1.0, "prestigio": 1.0},
        "description": "Cultura mesoamericana centrata a Tollan/Tula."
    },
    "Regni Maya": {
        "name": "Regni Maya",
        "leader": "Signore di Chichen Itza",
        "attitude": "balanced",
        "color": "#8B0000",
        "capital": "Chichen Itza",
        "resources": {"oro": 5000, "legname": 70, "pietra": 40, "ferro": 5, "argento": 15, "armi": 15, "cibo": 9000, "prestigio": 45},
        "units": {"fanteria": 18, "arcieri": 12, "cavalleria": 0, "artiglieria": 0, "maya_spearmen": 10, "holcan": 5, "atlatl": 5},
        "ships": {"canoa": 2},
        "buildings": ["monastero"],
        "production": {"oro": 220, "cibo": 200, "armi": 1, "prestigio": 1},
        "modifiers": {"oro": 1.0, "cibo": 1.0, "armi": 1.0, "prestigio": 1.0},
        "description": "Città-stato maya del periodo post-classico."
    },
    "Terra di Nessuno": {
        "name": "Terra di Nessuno",
        "is_neutral": True,
        "color": "#AAAAAA"
    }
}

PROVINCES = [
    # Impero Bizantino
    ("Costantinopoli", "Impero Bizantino", 41.0, 28.9, "hills", 500000, {"oro": 120, "cibo": 80, "prestigio": 15}, "Balcani"),
    ("Nicea", "Impero Bizantino", 40.4, 29.0, "plains", 90000, {"cibo": 40}, "Anatolia"),
    ("Adrianopoli", "Impero Bizantino", 41.7, 26.5, "plains", 70000, {"cibo": 30}, "Balcani"),
    ("Sofia", "Impero Bizantino", 42.7, 23.3, "hills", 50000, {}, "Balcani"),
    ("Trebisonda", "Impero Bizantino", 41.0, 39.7, "hills", 60000, {"oro": 60}, "Anatolia"),
    ("Ankara", "Impero Bizantino", 39.9, 32.8, "plains", 70000, {"pietra": 15}, "Anatolia"),
    ("Iconio", "Impero Bizantino", 37.9, 32.5, "plains", 60000, {"cibo": 35}, "Anatolia"),
    ("Smirne", "Impero Bizantino", 38.4, 27.1, "hills", 80000, {"cibo": 40, "oro": 40}, "Anatolia"),
    ("Antiochia", "Impero Bizantino", 36.2, 36.1, "hills", 110000, {"oro": 50}, "Levante"),
    ("Candia", "Impero Bizantino", 35.3, 24.8, "plains", 60000, {"cibo": 30}, "Mediterraneo"),
    ("Nicosia", "Impero Bizantino", 35.2, 33.4, "plains", 50000, {"oro": 30}, "Mediterraneo"),
    ("Salerno", "Impero Bizantino", 40.7, 14.8, "hills", 55000, {"cibo": 25}, "Italia"),
    ("Siracusa", "Impero Bizantino", 37.1, 15.3, "plains", 65000, {"cibo": 30, "oro": 30}, "Mediterraneo"),
    # Sacro Romano Impero
    ("Roma", "Sacro Romano Impero", 41.9, 12.5, "hills", 40000, {"oro": 80, "prestigio": 15}, "Italia"),
    ("Ravenna", "Sacro Romano Impero", 44.4, 12.2, "plains", 50000, {"cibo": 25}, "Italia"),
    ("Milano", "Sacro Romano Impero", 45.5, 9.2, "plains", 65000, {"oro": 40}, "Italia"),
    ("Venezia", "Sacro Romano Impero", 45.4, 12.3, "plains", 55000, {"oro": 50}, "Italia"),
    ("Aquisgrana", "Sacro Romano Impero", 50.8, 6.1, "plains", 45000, {"legname": 20}, "Europa Centrale"),
    ("Magonza", "Sacro Romano Impero", 50.0, 8.3, "plains", 40000, {"oro": 30}, "Europa Centrale"),
    ("Monaco", "Sacro Romano Impero", 48.1, 11.6, "plains", 50000, {"legname": 15}, "Europa Centrale"),
    ("Praga", "Sacro Romano Impero", 50.1, 14.4, "hills", 42000, {"pietra": 15}, "Europa Centrale"),
    ("Sassonia", "Sacro Romano Impero", 51.3, 13.0, "plains", 35000, {"legname": 20}, "Europa Centrale"),
    # Vichinghi
    ("Hedeby", "Vichinghi", 54.5, 9.4, "plains", 25000, {"legname": 25, "oro": 20}, "Scandinavia"),
    ("Roskilde", "Vichinghi", 55.6, 12.1, "plains", 22000, {"legname": 20}, "Scandinavia"),
    ("Oslo", "Vichinghi", 59.9, 10.7, "forest", 18000, {"legname": 25}, "Scandinavia"),
    ("Uppsala", "Vichinghi", 59.9, 17.6, "forest", 16000, {"legname": 20}, "Scandinavia"),
    ("Gotland", "Vichinghi", 57.6, 18.3, "plains", 14000, {"legname": 15}, "Scandinavia"),
    ("Viken", "Vichinghi", 59.0, 10.0, "forest", 15000, {"legname": 15}, "Scandinavia"),
    # Regno di Francia
    ("Parigi", "Regno di Francia", 48.9, 2.3, "plains", 90000, {"oro": 60, "prestigio": 10}, "Europa Occidentale"),
    ("Lione", "Regno di Francia", 45.8, 4.8, "hills", 45000, {"cibo": 30}, "Europa Occidentale"),
    ("Tours", "Regno di Francia", 47.4, 0.7, "plains", 40000, {"cibo": 30}, "Europa Occidentale"),
    ("Bordeaux", "Regno di Francia", 44.8, -0.6, "plains", 42000, {"cibo": 25, "oro": 20}, "Europa Occidentale"),
    ("Tolosa", "Regno di Francia", 43.6, 1.4, "plains", 40000, {"cibo": 25}, "Europa Occidentale"),
    ("Marsiglia", "Regno di Francia", 43.3, 5.4, "plains", 48000, {"oro": 40}, "Europa Occidentale"),
    # Califfato di Cordova
    ("Cordova", "Califfato di Cordova", 37.9, -4.8, "plains", 100000, {"oro": 70, "prestigio": 10}, "Iberia"),
    ("Siviglia", "Califfato di Cordova", 37.4, -6.0, "plains", 75000, {"cibo": 30}, "Iberia"),
    ("Toledo", "Califfato di Cordova", 39.9, -4.0, "hills", 65000, {"pietra": 15}, "Iberia"),
    ("Saragozza", "Califfato di Cordova", 41.6, -0.9, "plains", 55000, {"cibo": 25}, "Iberia"),
    ("Granada", "Califfato di Cordova", 37.2, -3.6, "hills", 60000, {"cibo": 25}, "Iberia"),
    ("Lisbona", "Califfato di Cordova", 38.7, -9.1, "plains", 45000, {"legname": 15}, "Iberia"),
    # Impero Fatimide
    ("Il Cairo", "Impero Fatimide", 30.0, 31.2, "desert", 350000, {"oro": 100, "cibo": 60, "prestigio": 12}, "Africa del Nord"),
    ("Alessandria", "Impero Fatimide", 31.2, 29.9, "desert", 120000, {"cibo": 30}, "Africa del Nord"),
    ("Gerusalemme", "Impero Fatimide", 31.8, 35.2, "hills", 70000, {"prestigio": 15}, "Levante"),
    ("Damasco", "Impero Fatimide", 33.5, 36.3, "plains", 100000, {"cibo": 35}, "Levante"),
    ("Tripoli", "Impero Fatimide", 32.9, 13.2, "desert", 55000, {"cibo": 20}, "Africa del Nord"),
    ("Palermo", "Impero Fatimide", 38.1, 13.4, "plains", 80000, {"cibo": 30, "oro": 30}, "Mediterraneo"),
    # Regno d'Ungheria
    ("Esztergom", "Regno d'Ungheria", 47.8, 18.7, "hills", 45000, {"oro": 25, "prestigio": 8}, "Europa Centrale"),
    ("Buda", "Regno d'Ungheria", 47.5, 19.0, "plains", 40000, {"cibo": 25}, "Europa Centrale"),
    ("Pannonia", "Regno d'Ungheria", 46.0, 18.5, "plains", 35000, {"cibo": 30}, "Europa Centrale"),
    ("Transilvania", "Regno d'Ungheria", 46.8, 24.6, "hills", 32000, {"legname": 20}, "Europa Orientale"),
    # Principato di Kiev
    ("Kiev", "Principato di Kiev", 50.4, 30.5, "plains", 80000, {"oro": 40, "prestigio": 8}, "Europa Orientale"),
    ("Novgorod", "Principato di Kiev", 58.5, 31.3, "forest", 45000, {"legname": 25}, "Europa Orientale"),
    ("Smolensk", "Principato di Kiev", 54.8, 32.0, "forest", 38000, {"legname": 20}, "Europa Orientale"),
    ("Chernigov", "Principato di Kiev", 51.5, 31.3, "plains", 35000, {"cibo": 25}, "Europa Orientale"),
    ("Polotsk", "Principato di Kiev", 55.5, 28.8, "forest", 30000, {"legname": 15}, "Europa Orientale"),
    # Regno di Polonia
    ("Gniezno", "Regno di Polonia", 52.5, 17.6, "plains", 40000, {"oro": 20, "prestigio": 5}, "Europa Orientale"),
    ("Cracovia", "Regno di Polonia", 50.1, 19.9, "plains", 38000, {"cibo": 25}, "Europa Orientale"),
    ("Poznan", "Regno di Polonia", 52.4, 16.9, "plains", 35000, {"cibo": 25}, "Europa Orientale"),
    ("Masovia", "Regno di Polonia", 52.2, 21.0, "plains", 30000, {"legname": 15}, "Europa Orientale"),
    ("Slesia", "Regno di Polonia", 51.1, 17.0, "hills", 32000, {"ferro": 15}, "Europa Orientale"),
    # Califfato Abbaside
    ("Baghdad", "Califfato Abbaside", 33.3, 44.4, "plains", 200000, {"oro": 90, "prestigio": 12}, "Medioriente"),
    ("Mosul", "Califfato Abbaside", 36.3, 43.1, "plains", 90000, {"cibo": 30}, "Medioriente"),
    ("Basra", "Califfato Abbaside", 30.5, 47.8, "desert", 70000, {"cibo": 25}, "Medioriente"),
    ("Isfahan", "Califfato Abbaside", 32.7, 51.7, "hills", 80000, {"oro": 40}, "Persia"),
    ("Rey", "Califfato Abbaside", 35.7, 51.3, "hills", 70000, {"pietra": 15}, "Persia"),
    # Sultanato Ghaznavide
    ("Ghazna", "Sultanato Ghaznavide", 33.5, 68.4, "hills", 60000, {"oro": 40, "prestigio": 8}, "Asia Centrale"),
    ("Kabul", "Sultanato Ghaznavide", 34.5, 69.2, "hills", 55000, {"cibo": 20}, "Asia Centrale"),
    ("Lahore", "Sultanato Ghaznavide", 31.5, 74.3, "plains", 90000, {"oro": 50, "cibo": 40}, "India"),
    ("Peshawar", "Sultanato Ghaznavide", 34.0, 71.5, "hills", 50000, {"cibo": 20}, "Asia Centrale"),
    ("Multan", "Sultanato Ghaznavide", 30.2, 71.5, "desert", 45000, {"oro": 30}, "India"),
    # Dinastia Song
    ("Kaifeng", "Dinastia Song", 34.8, 114.3, "plains", 450000, {"oro": 130, "cibo": 90, "prestigio": 15}, "Cina Orientale"),
    ("Hangzhou", "Dinastia Song", 30.3, 120.2, "hills", 180000, {"cibo": 50}, "Cina Orientale"),
    ("Nanchino", "Dinastia Song", 32.0, 118.8, "plains", 150000, {"cibo": 45}, "Cina Orientale"),
    ("Luoyang", "Dinastia Song", 34.6, 112.4, "plains", 120000, {"pietra": 20, "oro": 40}, "Cina Orientale"),
    ("Chengdu", "Dinastia Song", 30.7, 104.1, "hills", 100000, {"cibo": 40}, "Cina Orientale"),
    ("Guangzhou", "Dinastia Song", 23.1, 113.3, "plains", 110000, {"oro": 60}, "Cina Orientale"),
    # Impero Khitan Liao
    ("Shangjing", "Impero Khitan Liao", 43.9, 119.0, "plains", 70000, {"oro": 40, "prestigio": 8}, "Cina Settentrionale"),
    ("Yanjing", "Impero Khitan Liao", 39.9, 116.4, "plains", 120000, {"cibo": 40}, "Cina Settentrionale"),
    ("Datong", "Impero Khitan Liao", 40.1, 113.3, "hills", 60000, {"ferro": 20}, "Cina Settentrionale"),
    ("Liaodong", "Impero Khitan Liao", 41.0, 122.0, "hills", 50000, {"legname": 20}, "Cina Settentrionale"),
    # Impero Chola
    ("Tanjore", "Impero Chola", 10.8, 79.1, "plains", 120000, {"oro": 50, "prestigio": 10}, "India Meridionale"),
    ("Madurai", "Impero Chola", 9.9, 78.1, "plains", 90000, {"cibo": 35}, "India Meridionale"),
    ("Kanchipuram", "Impero Chola", 12.8, 79.7, "hills", 80000, {"oro": 30}, "India Meridionale"),
    ("Kalinga", "Impero Chola", 20.3, 85.8, "hills", 70000, {"cibo": 30}, "India Orientale"),
    ("Sri Lanka", "Impero Chola", 8.3, 80.4, "hills", 60000, {"cibo": 30, "oro": 30}, "India Meridionale"),
    ("Malabar", "Impero Chola", 11.3, 76.0, "plains", 70000, {"oro": 40}, "India Meridionale"),
    # Regno Khmer
    ("Angkor", "Regno Khmer", 13.4, 103.9, "plains", 100000, {"oro": 30, "prestigio": 8}, "Indocina"),
    ("Phnom Penh", "Regno Khmer", 11.5, 104.9, "plains", 50000, {"cibo": 30}, "Indocina"),
    ("Champasak", "Regno Khmer", 14.9, 105.9, "hills", 40000, {"legname": 20}, "Indocina"),
    ("Lopburi", "Regno Khmer", 14.8, 100.6, "plains", 45000, {"cibo": 25}, "Indocina"),
    # Regno Heian
    ("Kyoto", "Regno Heian", 35.0, 135.8, "hills", 120000, {"oro": 50, "prestigio": 10}, "Giappone"),
    ("Kamakura", "Regno Heian", 35.3, 139.6, "hills", 50000, {"cibo": 25}, "Giappone"),
    ("Osaka", "Regno Heian", 34.7, 135.5, "plains", 80000, {"cibo": 30}, "Giappone"),
    ("Nara", "Regno Heian", 34.7, 135.8, "hills", 60000, {"prestigio": 8}, "Giappone"),
    # Regno di Srivijaya
    ("Palembang", "Regno di Srivijaya", -2.9, 104.7, "forest", 70000, {"oro": 50, "prestigio": 8}, "Sud-Est Asiatico"),
    ("Jambi", "Regno di Srivijaya", -1.6, 103.6, "forest", 40000, {"legname": 25}, "Sud-Est Asiatico"),
    ("Kedah", "Regno di Srivijaya", 6.1, 100.4, "forest", 45000, {"oro": 30}, "Sud-Est Asiatico"),
    ("Sumatra", "Regno di Srivijaya", -3.0, 102.0, "forest", 35000, {"cibo": 30}, "Sud-Est Asiatico"),
    # Impero del Ghana
    ("Koumbi Saleh", "Impero del Ghana", 15.8, -7.95, "desert", 60000, {"oro": 80, "prestigio": 10}, "Sahel"),
    ("Aoudaghost", "Impero del Ghana", 19.4, -5.7, "desert", 35000, {"oro": 30}, "Sahel"),
    ("Walata", "Impero del Ghana", 17.3, -7.0, "desert", 30000, {"oro": 25}, "Sahel"),
    ("Gao", "Impero del Ghana", 16.3, 0.0, "desert", 28000, {"cibo": 20}, "Sahel"),
    # Toltechi
    ("Tollan", "Toltechi", 20.1, -99.7, "plains", 80000, {"oro": 30, "prestigio": 10}, "Mesoamerica"),
    ("Teotihuacan", "Toltechi", 19.7, -98.8, "plains", 60000, {"pietra": 25}, "Mesoamerica"),
    ("Cholula", "Toltechi", 19.0, -98.3, "plains", 50000, {"cibo": 25}, "Mesoamerica"),
    ("Xochicalco", "Toltechi", 18.8, -99.2, "hills", 45000, {"pietra": 20}, "Mesoamerica"),
    # Regni Maya
    ("Chichen Itza", "Regni Maya", 20.7, -88.6, "forest", 70000, {"oro": 20, "prestigio": 8}, "Mesoamerica"),
    ("Tikal", "Regni Maya", 17.2, -89.6, "forest", 50000, {"cibo": 25}, "Mesoamerica"),
    ("Calakmul", "Regni Maya", 18.1, -89.4, "forest", 45000, {"legname": 20}, "Mesoamerica"),
    ("Copan", "Regni Maya", 14.8, -89.1, "hills", 35000, {"pietra": 15}, "Mesoamerica"),
    # Terra di Nessuno (poche aree rappresentative)
    ("Steppe del Caspio", "Terra di Nessuno", 44.0, 52.0, "plains", 10000, {}, "Asia Centrale"),
    ("Deserto Arabico", "Terra di Nessuno", 25.0, 45.0, "desert", 5000, {}, "Arabia"),
    ("Foresta Amazzonica", "Terra di Nessuno", -3.0, -60.0, "forest", 5000, {"legname": 30}, "Sud America"),
    ("Grandi Pianure", "Terra di Nessuno", 45.0, -105.0, "plains", 5000, {}, "America del Nord"),
    ("Sahara Occidentale", "Terra di Nessuno", 25.0, -5.0, "desert", 2000, {}, "Africa"),
    ("Siberia", "Terra di Nessuno", 65.0, 100.0, "forest", 2000, {"legname": 20}, "Siberia"),
    ("Australia", "Terra di Nessuno", -25.0, 135.0, "desert", 3000, {}, "Oceania"),
]


def rect_polygon(lon, lat, w, h):
    return [
        [lon - w, lat - h],
        [lon + w, lat - h],
        [lon + w, lat + h],
        [lon - w, lat + h],
        [lon - w, lat - h]
    ]


def build():
    province_sizes = {
        "Balcani": (2.5, 1.8),
        "Anatolia": (3.0, 2.0),
        "Levante": (2.5, 2.0),
        "Mediterraneo": (2.0, 1.5),
        "Italia": (2.0, 1.8),
        "Europa Centrale": (2.5, 2.0),
        "Europa Occidentale": (2.5, 2.0),
        "Europa Orientale": (3.0, 2.5),
        "Iberia": (2.0, 1.8),
        "Africa del Nord": (3.0, 2.5),
        "Medioriente": (3.0, 2.5),
        "Persia": (3.0, 2.5),
        "Asia Centrale": (3.0, 2.5),
        "India": (3.0, 2.5),
        "India Meridionale": (2.5, 2.0),
        "India Orientale": (3.0, 2.5),
        "Cina Orientale": (3.5, 2.5),
        "Cina Settentrionale": (3.5, 2.5),
        "Indocina": (2.5, 2.0),
        "Giappone": (2.0, 1.8),
        "Sud-Est Asiatico": (3.0, 2.5),
        "Sahel": (3.0, 2.5),
        "Mesoamerica": (2.5, 2.0),
    }
    default_size = (3.0, 2.5)

    provinces_out = {}
    geo_features = []
    centroids = {}

    for name, owner, lat, lon, terrain, population, resources, region in PROVINCES:
        w, h = province_sizes.get(region, default_size)
        w = w / 2.0
        h = h / 2.0
        coords = rect_polygon(lon, lat, w, h)
        feature = {
            "type": "Feature",
            "properties": {"name": name, "owner": owner},
            "geometry": {"type": "Polygon", "coordinates": [coords]}
        }
        geo_features.append(feature)
        provinces_out[name] = {
            "name": name,
            "owner": owner,
            "region": region,
            "terrain": terrain,
            "population": population,
            "neighbors": [],
            "resources": resources
        }
        centroids[name] = (lon, lat)

    # Calcola neighbor per distanza centroidi
    threshold = 7.0  # gradi
    names = list(centroids.keys())
    for i in range(len(names)):
        for j in range(i + 1, len(names)):
            n1, n2 = names[i], names[j]
            x1, y1 = centroids[n1]
            x2, y2 = centroids[n2]
            dist = math.hypot(x2 - x1, y2 - y1)
            if dist < threshold:
                provinces_out[n1]["neighbors"].append(n2)
                provinces_out[n2]["neighbors"].append(n1)

    # Rimuovi 'playable' dalle fazioni per compatibilità schema esistente
    factions_out = {}
    for key, val in FACTIONS.items():
        v = dict(val)
        v.pop("playable", None)
        factions_out[key] = v

    # GeoJSON
    geojson = {
        "type": "FeatureCollection",
        "crs": {"type": "name", "properties": {"name": "urn:ogc:def:crs:OGC:1.3:CRS84"}},
        "features": geo_features
    }

    with open(os.path.join(BASE_DIR, "data", "world", "factions_1000.json"), "w", encoding="utf-8") as f:
        json.dump(factions_out, f, ensure_ascii=False, indent=2)
    with open(os.path.join(BASE_DIR, "data", "world", "provinces_1000.json"), "w", encoding="utf-8") as f:
        json.dump(provinces_out, f, ensure_ascii=False, indent=2)
    with open(os.path.join(BASE_DIR, "data", "world", "map_1000.geojson"), "w", encoding="utf-8") as f:
        json.dump(geojson, f, ensure_ascii=False)

    print("Generati:")
    print(" - data/world/factions_1000.json", len(factions_out), "fazioni")
    print(" - data/world/provinces_1000.json", len(provinces_out), "province")
    print(" - data/world/map_1000.geojson", len(geo_features), "features")


if __name__ == "__main__":
    build()
