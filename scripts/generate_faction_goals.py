#!/usr/bin/env python3
"""Genera gli obiettivi per le 20 fazioni giocabili di Hegemonia 1000.
Modello: Hegemonia_1700 adattato al contesto dell'anno 1000.
Dark Corporation / Stev"""

import json
import os

OUT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "data", "factions")
os.makedirs(OUT_DIR, exist_ok=True)

# ============================================================
# Definizione obiettivi per fazione
# Ogni fazione ha: obiettivi_storici, obiettivi_produttivi,
# obiettivi_militari, comportamento, catena_priorita
# ============================================================

FACTIONS = {
    "Impero Bizantino": {
        "comportamento": "imperiale",
        "obiettivi_storici": [
            "Riconquistare i territori perduti dell'Impero Romano d'Oriente",
            "Contenere l'espansione del Califfato Fatimide in Siria",
            "Mantenere il controllo del Bosforo e del commercio nel Mar Nero",
            "Rafforzare le difese dei Balcani contro Slavi e Bulgari",
            "Preservare l'eredita' culturale e religiosa ortodossa",
            "Sviluppare la marina da guerra nel Mediterraneo orientale"
        ],
        "obiettivi_produttivi": {
            "oro": {"target_mensile": 800, "edifici": ["mercato", "mercato_marittimo"], "priorita": "alta"},
            "armi": {"target_mensile": 8, "edifici": ["fucina", "officina_armi"], "priorita": "alta", "dipende": ["ferro"]},
            "cibo": {"target_mensile": 600, "edifici": ["mulino", "magazzino"], "priorita": "media"},
            "prestigio": {"target_mensile": 10, "edifici": ["monastero"], "priorita": "media"}
        },
        "obiettivi_militari": {
            "fanteria_min": 30, "cavalleria_min": 25, "arcieri_min": 20,
            "artiglieria_min": 5, "navi_min": 12,
            "scaling": {"modalita": "difensiva", "rivali": ["Impero Fatimide", "Sacro Romano Impero"], "regola": "mantieni fanteria >= rivali * 0.8"}
        },
        "catena_priorita": ["centro_cittadino", "mercato", "mulino", "miniera", "fucina", "caserma_i", "campo_tiro_i", "scuderia_i", "arsenale_i", "officina_armi", "caserma_ii", "scuderia_ii", "arsenale_ii", "caserma_iii", "scuderia_iii"]
    },
    "Sacro Romano Impero": {
        "comportamento": "imperiale",
        "obiettivi_storici": [
            "Consolidare il controllo sull'Italia e sul Papato",
            "Contenere l'espansione ungherese verso occidente",
            "Rafforzare le frontiere orientali contro gli Slavi",
            "Mantenere la supremazia militare in Europa centrale",
            "Sviluppare il commercio lungo le rotte del Reno e del Danubio"
        ],
        "obiettivi_produttivi": {
            "oro": {"target_mensile": 600, "edifici": ["mercato", "strade"], "priorita": "alta"},
            "armi": {"target_mensile": 6, "edifici": ["fucina", "officina_armi"], "priorita": "alta", "dipende": ["ferro"]},
            "cibo": {"target_mensile": 400, "edifici": ["mulino", "magazzino"], "priorita": "media"},
            "pietra": {"target_mensile": 30, "edifici": ["miniera"], "priorita": "media"}
        },
        "obiettivi_militari": {
            "fanteria_min": 25, "cavalleria_min": 15, "arcieri_min": 15,
            "artiglieria_min": 3, "navi_min": 0,
            "scaling": {"modalita": "difensiva", "rivali": ["Regno di Francia", "Regno d'Ungheria"], "regola": "mantieni fanteria >= rivali * 0.8"}
        },
        "catena_priorita": ["centro_cittadino", "mercato", "mulino", "miniera", "fucina", "caserma_i", "campo_tiro_i", "scuderia_i", "fortezza_frontiera", "officina_armi", "caserma_ii", "scuderia_ii", "caserma_iii", "scuderia_iii"]
    },
    "Vichinghi": {
        "comportamento": "razziatore",
        "obiettivi_storici": [
            "Razziare le coste dell'Inghilterra e della Francia",
            "Mantenere il controllo del Mare del Nord e del Baltico",
            "Stabilire colonie in Islanda, Groenlandia e Vinland",
            "Sviluppare il commercio di ambra, pellicce e schiavi",
            "Rafforzare la flotta da guerra drakkar"
        ],
        "obiettivi_produttivi": {
            "oro": {"target_mensile": 400, "edifici": ["mercato", "molo_i"], "priorita": "alta"},
            "legname": {"target_mensile": 40, "edifici": ["capanna_boscaioli", "segheria"], "priorita": "alta"},
            "armi": {"target_mensile": 4, "edifici": ["fucina"], "priorita": "media", "dipende": ["ferro"]},
            "cibo": {"target_mensile": 300, "edifici": ["mulino"], "priorita": "media"}
        },
        "obiettivi_militari": {
            "fanteria_min": 15, "cavalleria_min": 5, "arcieri_min": 10,
            "artiglieria_min": 0, "navi_min": 15,
            "scaling": {"modalita": "aggressiva", "rivali": ["Regno d'Inghilterra", "Regno di Francia"], "regola": "mantieni navi >= rivali * 1.2"}
        },
        "catena_priorita": ["centro_cittadino", "capanna_boscaioli", "segheria", "molo_i", "mercato", "caserma_i", "campo_tiro_i", "scuderia_i", "molo_ii", "arsenale_i", "fucina", "scuderia_ii"]
    },
    "Regno di Francia": {
        "comportamento": "emergente",
        "obiettivi_storici": [
            "Consolidare il potere reale contro i grandi feudatari",
            "Contenere l'espansione vichinga in Normandia",
            "Riconquistare i territori della Loira",
            "Sviluppare l'agricoltura nella pianura francese",
            "Rafforzare le difese contro il Sacro Romano Impero"
        ],
        "obiettivi_produttivi": {
            "oro": {"target_mensile": 500, "edifici": ["mercato", "strade"], "priorita": "alta"},
            "cibo": {"target_mensile": 500, "edifici": ["mulino", "magazzino"], "priorita": "alta"},
            "armi": {"target_mensile": 5, "edifici": ["fucina"], "priorita": "media", "dipende": ["ferro"]},
            "legname": {"target_mensile": 20, "edifici": ["capanna_boscaioli", "segheria"], "priorita": "media"}
        },
        "obiettivi_militari": {
            "fanteria_min": 20, "cavalleria_min": 15, "arcieri_min": 10,
            "artiglieria_min": 2, "navi_min": 5,
            "scaling": {"modalita": "bilanciata", "rivali": ["Vichinghi", "Sacro Romano Impero"], "regola": "mantieni fanteria >= rivali * 0.9"}
        },
        "catena_priorita": ["centro_cittadino", "mulino", "mercato", "capanna_boscaioli", "segheria", "miniera", "fucina", "caserma_i", "campo_tiro_i", "scuderia_i", "fortezza_frontiera", "molo_i", "caserma_ii", "scuderia_ii"]
    },
    "Califfato di Cordova": {
        "comportamento": "imperiale",
        "obiettivi_storici": [
            "Mantenere il controllo di al-Andalus contro i regni cristiani",
            "Sviluppare il commercio nel Mediterraneo occidentale",
            "Rafforzare la flotta nello Stretto di Gibilterra",
            "Preservare la supremazia culturale e scientifica di Cordova",
            "Contenere l'avanzata dei regni di Leon e Navarra"
        ],
        "obiettivi_produttivi": {
            "oro": {"target_mensile": 500, "edifici": ["mercato", "mercato_marittimo"], "priorita": "alta"},
            "armi": {"target_mensile": 6, "edifici": ["fucina", "officina_armi"], "priorita": "alta", "dipende": ["ferro"]},
            "cibo": {"target_mensile": 300, "edifici": ["mulino"], "priorita": "media"},
            "prestigio": {"target_mensile": 8, "edifici": ["monastero"], "priorita": "media"}
        },
        "obiettivi_militari": {
            "fanteria_min": 20, "cavalleria_min": 15, "arcieri_min": 15,
            "artiglieria_min": 3, "navi_min": 8,
            "scaling": {"modalita": "aggressiva", "rivali": ["Regno di Francia", "Regno d'Inghilterra"], "regola": "mantieni cavalleria >= rivali * 1.0"}
        },
        "catena_priorita": ["centro_cittadino", "mercato", "mulino", "miniera", "fucina", "caserma_i", "campo_tiro_i", "scuderia_i", "molo_i", "arsenale_i", "officina_armi", "caserma_ii", "scuderia_ii", "molo_ii", "arsenale_ii"]
    },
    "Impero Fatimide": {
        "comportamento": "imperiale",
        "obiettivi_storici": [
            "Mantenere il controllo dell'Egitto e del Mar Rosso",
            "Contestare la supremazia bizantina in Siria",
            "Controllare le rotte commerciali dell'Oceano Indiano",
            "Sviluppare il commercio di spezie e oro lungo il Nilo",
            "Rafforzare la marina nel Mediterraneo orientale"
        ],
        "obiettivi_produttivi": {
            "oro": {"target_mensile": 700, "edifici": ["mercato", "mercato_marittimo"], "priorita": "alta"},
            "armi": {"target_mensile": 7, "edifici": ["fucina", "officina_armi"], "priorita": "alta", "dipende": ["ferro"]},
            "cibo": {"target_mensile": 500, "edifici": ["mulino", "magazzino"], "priorita": "alta"},
            "prestigio": {"target_mensile": 10, "edifici": ["monastero"], "priorita": "media"}
        },
        "obiettivi_militari": {
            "fanteria_min": 25, "cavalleria_min": 20, "arcieri_min": 15,
            "artiglieria_min": 5, "navi_min": 10,
            "scaling": {"modalita": "aggressiva", "rivali": ["Impero Bizantino", "Califfato Abbaside"], "regola": "mantieni fanteria >= rivali * 1.0"}
        },
        "catena_priorita": ["centro_cittadino", "mercato", "mulino", "magazzino", "miniera", "fucina", "caserma_i", "campo_tiro_i", "scuderia_i", "molo_i", "arsenale_i", "officina_armi", "caserma_ii", "scuderia_ii", "cortile_cavaliere", "arsenale_ii"]
    },
    "Regno d'Ungheria": {
        "comportamento": "emergente",
        "obiettivi_storici": [
            "Consolidare il dominio magiaro nel bacino dei Carpazi",
            "Razziare l'Europa centrale e bizantina",
            "Mantenere la pressione militare sul Sacro Romano Impero",
            "Sviluppare l'allevamento di cavalli nella Pannonia",
            "Contenere l'espansione bizantina nei Balcani"
        ],
        "obiettivi_produttivi": {
            "oro": {"target_mensile": 400, "edifici": ["mercato", "strade"], "priorita": "alta"},
            "armi": {"target_mensile": 5, "edifici": ["fucina"], "priorita": "alta", "dipende": ["ferro"]},
            "cibo": {"target_mensile": 300, "edifici": ["mulino"], "priorita": "media"},
            "legname": {"target_mensile": 20, "edifici": ["capanna_boscaioli", "segheria"], "priorita": "media"}
        },
        "obiettivi_militari": {
            "fanteria_min": 15, "cavalleria_min": 20, "arcieri_min": 10,
            "artiglieria_min": 2, "navi_min": 0,
            "scaling": {"modalita": "aggressiva", "rivali": ["Sacro Romano Impero", "Impero Bizantino"], "regola": "mantieni cavalleria >= rivali * 1.1"}
        },
        "catena_priorita": ["centro_cittadino", "mercato", "mulino", "capanna_boscaioli", "segheria", "miniera", "fucina", "caserma_i", "scuderia_i", "campo_tiro_i", "fortezza_frontiera", "scuderia_ii", "caserma_ii", "cortile_cavaliere"]
    },
    "Principato di Kiev": {
        "comportamento": "razziatore",
        "obiettivi_storici": [
            "Controllare le rotte commerciali dal Baltico al Mar Nero",
            "Razziare l'Impero Bizantino via fiume",
            "Mantenere il dominio sulle tribu' slave orientali",
            "Sviluppare il commercio di pellicce, ambra e miele",
            "Rafforzare la flotta fluviale sul Dnepr"
        ],
        "obiettivi_produttivi": {
            "oro": {"target_mensile": 350, "edifici": ["mercato", "strade"], "priorita": "alta"},
            "legname": {"target_mensile": 30, "edifici": ["capanna_boscaioli", "segheria"], "priorita": "alta"},
            "armi": {"target_mensile": 4, "edifici": ["fucina"], "priorita": "media", "dipende": ["ferro"]},
            "cibo": {"target_mensile": 300, "edifici": ["mulino"], "priorita": "media"}
        },
        "obiettivi_militari": {
            "fanteria_min": 15, "cavalleria_min": 15, "arcieri_min": 10,
            "artiglieria_min": 0, "navi_min": 8,
            "scaling": {"modalita": "aggressiva", "rivali": ["Impero Bizantino", "Regno di Polonia"], "regola": "mantieni cavalleria >= rivali * 0.9"}
        },
        "catena_priorita": ["centro_cittadino", "capanna_boscaioli", "segheria", "mercato", "mulino", "miniera", "fucina", "caserma_i", "scuderia_i", "campo_tiro_i", "molo_i", "arsenale_i", "scuderia_ii", "caserma_ii", "cortile_cavaliere"]
    },
    "Regno di Polonia": {
        "comportamento": "emergente",
        "obiettivi_storici": [
            "Consolidare la cristianizzazione della Polonia",
            "Contenere l'espansione del Sacro Romano Impero",
            "Rafforzare le frontiere contro i Pruzzi e i Pecheneghi",
            "Sviluppare l'agricoltura lungo la Vistola",
            "Mantenere l'alleanza con Roma"
        ],
        "obiettivi_produttivi": {
            "oro": {"target_mensile": 300, "edifici": ["mercato", "strade"], "priorita": "alta"},
            "cibo": {"target_mensile": 300, "edifici": ["mulino", "magazzino"], "priorita": "alta"},
            "armi": {"target_mensile": 3, "edifici": ["fucina"], "priorita": "media", "dipende": ["ferro"]},
            "prestigio": {"target_mensile": 5, "edifici": ["monastero"], "priorita": "media"}
        },
        "obiettivi_militari": {
            "fanteria_min": 12, "cavalleria_min": 8, "arcieri_min": 8,
            "artiglieria_min": 0, "navi_min": 0,
            "scaling": {"modalita": "difensiva", "rivali": ["Sacro Romano Impero", "Principato di Kiev"], "regola": "mantieni fanteria >= rivali * 0.7"}
        },
        "catena_priorita": ["centro_cittadino", "mulino", "mercato", "monastero", "capanna_boscaioli", "segheria", "miniera", "fucina", "caserma_i", "campo_tiro_i", "scuderia_i", "fortezza_frontiera", "caserma_ii", "scuderia_ii"]
    },
    "Califfato Abbaside": {
        "comportamento": "religioso",
        "obiettivi_storici": [
            "Mantenere il califfato spirituale dell'Islam",
            "Contenere l'espansione dei Buyidi e dei Ghaznavidi",
            "Preservare Baghdad come centro culturale e scientifico",
            "Sviluppare il commercio lungo la Via della Seta",
            "Rafforzare le difese contro le tribu' turche"
        ],
        "obiettivi_produttivi": {
            "oro": {"target_mensile": 400, "edifici": ["mercato", "strade"], "priorita": "alta"},
            "armi": {"target_mensile": 5, "edifici": ["fucina", "officina_armi"], "priorita": "alta", "dipende": ["ferro"]},
            "cibo": {"target_mensile": 300, "edifici": ["mulino", "magazzino"], "priorita": "media"},
            "prestigio": {"target_mensile": 8, "edifici": ["monastero"], "priorita": "alta"}
        },
        "obiettivi_militari": {
            "fanteria_min": 15, "cavalleria_min": 15, "arcieri_min": 10,
            "artiglieria_min": 3, "navi_min": 0,
            "scaling": {"modalita": "difensiva", "rivali": ["Sultanato Ghaznavide", "Impero Fatimide"], "regola": "mantieni fanteria >= rivali * 0.8"}
        },
        "catena_priorita": ["centro_cittadino", "mercato", "mulino", "monastero", "miniera", "fucina", "caserma_i", "campo_tiro_i", "scuderia_i", "fortezza_frontiera", "officina_armi", "caserma_ii", "scuderia_ii", "cortile_cavaliere"]
    },
    "Sultanato Ghaznavide": {
        "comportamento": "imperiale",
        "obiettivi_storici": [
            "Espandere il dominio turco-musulmano in India settentrionale",
            "Razziare i templi indiani per tesori e prestigio",
            "Controllare le rotte commerciali dell'Afghanistan",
            "Contenere l'espansione dei Qarakhanidi",
            "Mantenere la supremazia militare turca"
        ],
        "obiettivi_produttivi": {
            "oro": {"target_mensile": 400, "edifici": ["mercato", "strade"], "priorita": "alta"},
            "armi": {"target_mensile": 6, "edifici": ["fucina", "officina_armi"], "priorita": "alta", "dipende": ["ferro"]},
            "cibo": {"target_mensile": 250, "edifici": ["mulino"], "priorita": "media"},
            "legname": {"target_mensile": 15, "edifici": ["capanna_boscaioli", "segheria"], "priorita": "media"}
        },
        "obiettivi_militari": {
            "fanteria_min": 15, "cavalleria_min": 20, "arcieri_min": 15,
            "artiglieria_min": 3, "navi_min": 0,
            "scaling": {"modalita": "aggressiva", "rivali": ["Califfato Abbaside", "Dinastia Song"], "regola": "mantieni cavalleria >= rivali * 1.2"}
        },
        "catena_priorita": ["centro_cittadino", "mercato", "mulino", "capanna_boscaioli", "segheria", "miniera", "fucina", "caserma_i", "scuderia_i", "campo_tiro_i", "officina_armi", "scuderia_ii", "caserma_ii", "cortile_cavaliere", "officina_assedio_i", "officina_assedio_ii"]
    },
    "Dinastia Song": {
        "comportamento": "egemone_asia",
        "obiettivi_storici": [
            "Difendersi dagli attacchi dell'Impero Khitan Liao",
            "Sviluppare l'economia e il commercio marittimo",
            "Innovare la tecnologia (polvere da sparo, stampa, bussola)",
            "Mantenere il controllo della Cina meridionale",
            "Rafforzare la marina fluviale e costiera"
        ],
        "obiettivi_produttivi": {
            "oro": {"target_mensile": 600, "edifici": ["mercato", "mercato_marittimo"], "priorita": "alta"},
            "armi": {"target_mensile": 8, "edifici": ["fucina", "officina_armi"], "priorita": "alta", "dipende": ["ferro"]},
            "cibo": {"target_mensile": 400, "edifici": ["mulino", "magazzino"], "priorita": "alta"},
            "legname": {"target_mensile": 30, "edifici": ["capanna_boscaioli", "segheria"], "priorita": "media"}
        },
        "obiettivi_militari": {
            "fanteria_min": 20, "cavalleria_min": 10, "arcieri_min": 20,
            "artiglieria_min": 5, "navi_min": 10,
            "scaling": {"modalita": "difensiva", "rivali": ["Impero Khitan Liao"], "regola": "mantieni fanteria >= rivali * 1.0"}
        },
        "catena_priorita": ["centro_cittadino", "mercato", "mulino", "magazzino", "capanna_boscaioli", "segheria", "miniera", "fucina", "caserma_i", "campo_tiro_i", "scuderia_i", "molo_i", "officina_armi", "campo_tiro_ii", "caserma_ii", "molo_ii", "arsenale_i", "officina_assedio_i", "officina_assedio_ii", "officina_assedio_iii"]
    },
    "Impero Khitan Liao": {
        "comportamento": "imperiale",
        "obiettivi_storici": [
            "Mantenere il dominio sulla Cina settentrionale",
            "Riscuotere il tributo dalla Dinastia Song",
            "Rafforzare la cavalleria nomade delle steppe",
            "Controllare le rotte commerciali della Manciuria",
            "Contenere l'espansione dei Jurchen"
        ],
        "obiettivi_produttivi": {
            "oro": {"target_mensile": 500, "edifici": ["mercato", "strade"], "priorita": "alta"},
            "armi": {"target_mensile": 6, "edifici": ["fucina", "officina_armi"], "priorita": "alta", "dipende": ["ferro"]},
            "cibo": {"target_mensile": 300, "edifici": ["mulino"], "priorita": "media"},
            "legname": {"target_mensile": 20, "edifici": ["capanna_boscaioli", "segheria"], "priorita": "media"}
        },
        "obiettivi_militari": {
            "fanteria_min": 15, "cavalleria_min": 25, "arcieri_min": 15,
            "artiglieria_min": 3, "navi_min": 0,
            "scaling": {"modalita": "aggressiva", "rivali": ["Dinastia Song"], "regola": "mantieni cavalleria >= rivali * 1.5"}
        },
        "catena_priorita": ["centro_cittadino", "mercato", "mulino", "capanna_boscaioli", "segheria", "miniera", "fucina", "caserma_i", "scuderia_i", "campo_tiro_i", "officina_armi", "scuderia_ii", "caserma_ii", "scuderia_iii", "cortile_cavaliere", "officina_assedio_i", "officina_assedio_ii"]
    },
    "Impero Chola": {
        "comportamento": "marinaro",
        "obiettivi_storici": [
            "Dominare il commercio nell'Oceano Indiano",
            "Espandere l'influenza nel Sud-est asiatico",
            "Mantenere il controllo di Sri Lanka",
            "Sviluppare la marina da guerra",
            "Rafforzare il commercio con Cina e mondo islamico"
        ],
        "obiettivi_produttivi": {
            "oro": {"target_mensile": 400, "edifici": ["mercato", "mercato_marittimo"], "priorita": "alta"},
            "armi": {"target_mensile": 4, "edifici": ["fucina"], "priorita": "media", "dipende": ["ferro"]},
            "cibo": {"target_mensile": 300, "edifici": ["mulino"], "priorita": "media"},
            "legname": {"target_mensile": 25, "edifici": ["capanna_boscaioli", "segheria"], "priorita": "alta"}
        },
        "obiettivi_militari": {
            "fanteria_min": 12, "cavalleria_min": 5, "arcieri_min": 10,
            "artiglieria_min": 2, "navi_min": 15,
            "scaling": {"modalita": "aggressiva", "rivali": ["Regno di Srivijaya"], "regola": "mantieni navi >= rivali * 1.3"}
        },
        "catena_priorita": ["centro_cittadino", "mercato", "mulino", "capanna_boscaioli", "segheria", "molo_i", "mercato_marittimo", "miniera", "fucina", "caserma_i", "campo_tiro_i", "molo_ii", "arsenale_i", "arsenale_ii", "officina_assedio_i", "officina_assedio_ii"]
    },
    "Regno Khmer": {
        "comportamento": "egemone_asia",
        "obiettivi_storici": [
            "Mantenere il dominio sull'Indocina",
            "Sviluppare il sistema di irrigazione del Tonle Sap",
            "Costruire templi monumentali (Angkor)",
            "Contenere l'espansione dei Cham",
            "Sviluppare il commercio fluviale del Mekong"
        ],
        "obiettivi_produttivi": {
            "oro": {"target_mensile": 500, "edifici": ["mercato", "strade"], "priorita": "alta"},
            "cibo": {"target_mensile": 400, "edifici": ["mulino", "magazzino"], "priorita": "alta"},
            "armi": {"target_mensile": 4, "edifici": ["fucina"], "priorita": "media", "dipende": ["ferro"]},
            "prestigio": {"target_mensile": 8, "edifici": ["monastero"], "priorita": "alta"}
        },
        "obiettivi_militari": {
            "fanteria_min": 20, "cavalleria_min": 10, "arcieri_min": 10,
            "artiglieria_min": 3, "navi_min": 5,
            "scaling": {"modalita": "difensiva", "rivali": ["Dai Viet", "Regno di Srivijaya"], "regola": "mantieni fanteria >= rivali * 1.0"}
        },
        "catena_priorita": ["centro_cittadino", "mulino", "mercato", "magazzino", "monastero", "capanna_boscaioli", "segheria", "miniera", "fucina", "caserma_i", "campo_tiro_i", "scuderia_i", "molo_i", "officina_assedio_i", "officina_assedio_ii", "caserma_ii", "scuderia_ii"]
    },
    "Regno Heian": {
        "comportamento": "isolazionista",
        "obiettivi_storici": [
            "Mantenere la pace interna e il sistema imperiale",
            "Rafforzare il potere dei samurai contro i pirati",
            "Sviluppare la cultura di corte Heian",
            "Contenere i pirati wako nel Mar del Giappone",
            "Mantenere il commercio con la Cina Song"
        ],
        "obiettivi_produttivi": {
            "oro": {"target_mensile": 350, "edifici": ["mercato", "strade"], "priorita": "alta"},
            "cibo": {"target_mensile": 300, "edifici": ["mulino", "magazzino"], "priorita": "alta"},
            "armi": {"target_mensile": 4, "edifici": ["fucina"], "priorita": "media", "dipende": ["ferro"]},
            "prestigio": {"target_mensile": 6, "edifici": ["monastero"], "priorita": "media"}
        },
        "obiettivi_militari": {
            "fanteria_min": 15, "cavalleria_min": 10, "arcieri_min": 10,
            "artiglieria_min": 0, "navi_min": 5,
            "scaling": {"modalita": "difensiva", "rivali": [], "regola": "mantieni fanteria >= 15"}
        },
        "catena_priorita": ["centro_cittadino", "mulino", "mercato", "magazzino", "monastero", "miniera", "fucina", "caserma_i", "campo_tiro_i", "scuderia_i", "molo_i", "caserma_ii", "scuderia_ii", "cortile_cavaliere"]
    },
    "Regno di Srivijaya": {
        "comportamento": "marinaro",
        "obiettivi_storici": [
            "Controllare lo Stretto di Malacca",
            "Mantenere il monopolio del commercio di spezie",
            "Rafforzare la flotta contro i pirati",
            "Sviluppare il commercio con Cina, India e mondo islamico",
            "Contenere l'espansione dei Chola"
        ],
        "obiettivi_produttivi": {
            "oro": {"target_mensile": 450, "edifici": ["mercato", "mercato_marittimo"], "priorita": "alta"},
            "legname": {"target_mensile": 30, "edifici": ["capanna_boscaioli", "segheria"], "priorita": "alta"},
            "cibo": {"target_mensile": 250, "edifici": ["mulino"], "priorita": "media"},
            "armi": {"target_mensile": 3, "edifici": ["fucina"], "priorita": "media", "dipende": ["ferro"]}
        },
        "obiettivi_militari": {
            "fanteria_min": 10, "cavalleria_min": 3, "arcieri_min": 8,
            "artiglieria_min": 0, "navi_min": 12,
            "scaling": {"modalita": "difensiva", "rivali": ["Impero Chola"], "regola": "mantieni navi >= rivali * 1.0"}
        },
        "catena_priorita": ["centro_cittadino", "mercato", "mulino", "capanna_boscaioli", "segheria", "molo_i", "mercato_marittimo", "miniera", "fucina", "caserma_i", "campo_tiro_i", "molo_ii", "arsenale_i", "arsenale_ii"]
    },
    "Impero del Ghana": {
        "comportamento": "commerciale",
        "obiettivi_storici": [
            "Controllare il commercio dell'oro trans-sahariano",
            "Mantenere il monopolio del sale",
            "Rafforzare le rotte commerciali verso il Nord Africa",
            "Contenere le tribu' berbere nomadi",
            "Sviluppare l'agricoltura lungo il Niger"
        ],
        "obiettivi_produttivi": {
            "oro": {"target_mensile": 600, "edifici": ["mercato", "strade"], "priorita": "alta"},
            "cibo": {"target_mensile": 300, "edifici": ["mulino", "magazzino"], "priorita": "alta"},
            "armi": {"target_mensile": 3, "edifici": ["fucina"], "priorita": "media", "dipende": ["ferro"]},
            "legname": {"target_mensile": 15, "edifici": ["capanna_boscaioli", "segheria"], "priorita": "media"}
        },
        "obiettivi_militari": {
            "fanteria_min": 15, "cavalleria_min": 10, "arcieri_min": 8,
            "artiglieria_min": 0, "navi_min": 0,
            "scaling": {"modalita": "difensiva", "rivali": ["Tribù Berberi del Maghreb"], "regola": "mantieni cavalleria >= rivali * 0.8"}
        },
        "catena_priorita": ["centro_cittadino", "mercato", "mulino", "magazzino", "strade", "capanna_boscaioli", "segheria", "miniera", "fucina", "caserma_i", "campo_tiro_i", "scuderia_i", "fortezza_frontiera", "caserma_ii", "scuderia_ii"]
    },
    "Toltechi": {
        "comportamento": "imperiale",
        "obiettivi_storici": [
            "Mantenere il dominio sull'altopiano centrale messicano",
            "Rafforzare il culto di Quetzalcoatl",
            "Contenere l'espansione dei Maya a sud",
            "Sviluppare l'agricoltura con le chinampas",
            "Mantenere il commercio di ossidiana e giada"
        ],
        "obiettivi_produttivi": {
            "oro": {"target_mensile": 300, "edifici": ["mercato", "strade"], "priorita": "alta"},
            "cibo": {"target_mensile": 300, "edifici": ["mulino", "magazzino"], "priorita": "alta"},
            "armi": {"target_mensile": 3, "edifici": ["fucina"], "priorita": "media", "dipende": ["ferro"]},
            "prestigio": {"target_mensile": 6, "edifici": ["monastero"], "priorita": "media"}
        },
        "obiettivi_militari": {
            "fanteria_min": 12, "cavalleria_min": 0, "arcieri_min": 10,
            "artiglieria_min": 0, "navi_min": 0,
            "scaling": {"modalita": "aggressiva", "rivali": ["Regni Maya"], "regola": "mantieni fanteria >= rivali * 1.1"}
        },
        "catena_priorita": ["centro_cittadino", "mulino", "mercato", "magazzino", "monastero", "capanna_boscaioli", "segheria", "miniera", "fucina", "caserma_i", "campo_tiro_i", "fortezza_frontiera", "caserma_ii", "campo_tiro_ii"]
    },
    "Regni Maya": {
        "comportamento": "regionale",
        "obiettivi_storici": [
            "Mantenere l'indipendenza delle citta'-stato maya",
            "Contenere l'espansione tolteca",
            "Preservare la cultura maya e il calendario",
            "Sviluppare l'agricoltura del milpa",
            "Rafforzare le difese delle citta'-stato"
        ],
        "obiettivi_produttivi": {
            "oro": {"target_mensile": 250, "edifici": ["mercato", "strade"], "priorita": "alta"},
            "cibo": {"target_mensile": 250, "edifici": ["mulino", "magazzino"], "priorita": "alta"},
            "armi": {"target_mensile": 2, "edifici": ["fucina"], "priorita": "media", "dipende": ["ferro"]},
            "prestigio": {"target_mensile": 5, "edifici": ["monastero"], "priorita": "media"}
        },
        "obiettivi_militari": {
            "fanteria_min": 10, "cavalleria_min": 0, "arcieri_min": 8,
            "artiglieria_min": 0, "navi_min": 0,
            "scaling": {"modalita": "difensiva", "rivali": ["Toltechi"], "regola": "mantieni fanteria >= rivali * 0.8"}
        },
        "catena_priorita": ["centro_cittadino", "mulino", "mercato", "magazzino", "monastero", "capanna_boscaioli", "segheria", "miniera", "fucina", "caserma_i", "campo_tiro_i", "fortezza_frontiera", "caserma_ii"]
    }
}

# ============================================================
# Genera file JSON per ogni fazione
# ============================================================

count = 0
for fname, fdata in FACTIONS.items():
    # Nome file: rimuovi spazi e caratteri speciali
    safe_name = fname.replace(" ", "_").replace("'", "").replace("à", "a").replace("è", "e").replace("ì", "i").replace("ò", "o").replace("ù", "u")
    out_path = os.path.join(OUT_DIR, f"{safe_name}.json")
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(fdata, f, ensure_ascii=False, indent=2)
    count += 1

print(f"Generati {count} file obiettivi in {OUT_DIR}")
for fname in FACTIONS.keys():
    safe_name = fname.replace(" ", "_").replace("'", "").replace("à", "a").replace("è", "e").replace("ì", "i").replace("ò", "o").replace("ù", "u")
    print(f"  {safe_name}.json")
