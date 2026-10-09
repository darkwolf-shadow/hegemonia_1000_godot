# AGENTS.md — Hegemonia 1000

Regole per lo sviluppo e la manutenzione del progetto.
Dark Corporation / Stev

## Regola fondamentale: documentazione viva

I file in `documenti/` sono le linee guida vive per lo sviluppo.
Servono sia all'umano che all'IA per sapere sempre:
- in che stato e' il progetto
- cosa e' stato fatto
- cosa resta da fare
- come e' strutturato il gioco

### Obbligo di aggiornamento

**Ogni modifica al codice, ai dati o al progetto deve essere riportata
nei file di documentazione.**

Dopo ogni lavoro:
1. Aggiornare `documenti/04_REGISTRO_MODIFICHE.md` con data, modifica,
   file coinvolti e motivo
2. Aggiornare i file tematici se la modifica ne cambia il contenuto:
   - `documenti/01_CONTESTO_STORICO.md` — se cambiano fazioni, province, unita'
   - `documenti/02_ARCHITETTURA_GIOCO.md` — se cambiano edifici, regole, risorse
   - `documenti/03_BATTAGLIA_TEMPO_REALE.md` — se cambia il sistema di battaglia
3. Aggiornare `README.md` — se cambiano struttura, autoload, scene o stato

### Formato dei file

- Tutti i file di documentazione sono `.md` (Markdown)
- I file `.txt` non vengono piu' usati per la documentazione
- I file sono numerati per essere letti in ordine:
  - `README.md` — introduzione e stato
  - `documenti/01_CONTESTO_STORICO.md` — fazioni e dati storici
  - `documenti/02_ARCHITETTURA_GIOCO.md` — meccaniche di gioco
  - `documenti/03_BATTAGLIA_TEMPO_REALE.md` — sistema battaglia
  - `documenti/04_REGISTRO_MODIFICHE.md` — log modifiche

## Regole di sviluppo

1. **Modifiche chirurgiche**: fare solo la modifica richiesta, non
   riscrivere file interi se non necessario
2. **Non toccare cio' che funziona**: se una parte non e' oggetto della
   richiesta, non modificarla
3. **Verifica prima di affermare**: controllare sempre lo stato reale
   dei file, processi e dati prima di fare affermazioni
4. **Sintassi pulita**: codice compatto, moderno, senza commenti
   superflui
5. **Test dopo le modifiche**: verificare la sintassi e il
   funzionamento dopo ogni modifica
6. **Pulizia**: eliminare file temporanei di test dopo la verifica

## Struttura del progetto

Vedi `README.md` per la struttura completa delle cartelle, autoload,
scene e file di dati.

## File di dati JSON

- `dati/config/game_config.json` — regole, truppe, navi, edifici
- `dati/world/factions_1000.json` — 158 fazioni
- `dati/world/provinces_1000.json` — 4327 province
- `dati/world/mappa_anno_1000.geojson` — mappa (47 MB, formato compatto)
- `dati/scenarios/initial_state_1000.json` — stato iniziale

### Formato GeoJSON
Il file `mappa_anno_1000.geojson` e' in formato COMPATTO (senza indentazione).
Mai salvarlo con `indent=2` o `indent=4`: un GeoJSON da 47 MB diverrebbe
140 MB e Godot non riuscirebbe a caricarlo.

## Autoload Godot

10 autoload attivi (vedi `project.godot`):
GameState, WorldData, EconomyEngine, AIController, BattleSystem,
SaveManager, SettlementManager, IconManager, UiHelper, AIBridge

## Stato attuale (2026-08-21)

- Struttura Godot 4 completa con 10 autoload, 20 scene, 32 script
- Dati storici completi: 158 fazioni, 4327 province, mappa 47 MB
- 3917 province con insediamenti (edifici e livelli)
- Battaglia 3D tempo reale con scheletri, cavalli, artiglieria, formazioni
- Stato iniziale da popolare (factions e provinces vuoti)
- Da fare: scena insediamento 3D, popolare stato iniziale, texture medievali

Vedi `README.md` per lo stato dettagliato e la roadmap.
