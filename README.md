# Hegemonia 1000

Strategico storico ambientato nell'anno 1000 d.C. — Godot 4 / GDScript.
Dark Corporation / Stev

## Obiettivo

Creare uno strategico a turni con mappa provinciale, fazioni storiche,
risorse, edifici, truppe, navi, micro-battaglie 2.5D e intelligenza
artificiale per le fazioni non giocate.

A differenza degli altri preset di Hegemonia (basati su Python/Flask),
questa versione parte da zero su Godot 4, senza Python e senza JavaScript.

## Fazioni giocabili

1. Impero Bizantino — capitale Costantinopoli
2. Sacro Romano Impero — capitale Roma
3. Vichinghi (Danimarca/Norvegia) — capitale Hedeby/Roskilde

Le altre 155 fazioni sono controllate dall'intelligenza artificiale.
Vedi `documenti/01_CONTESTO_STORICO.md` per l'elenco completo.

## Come aprire il progetto

1. Installa Godot 4.3 o superiore
2. Apri Godot, clicca "Importa"
3. Seleziona la cartella `Hegemonia_1000`
4. Clicca "Modifica" per aprire il progetto
5. Premi F5 per avviare il gioco

## Struttura del progetto

```
project.godot                  configurazione del motore
README.md                      questo file — introduzione e stato
AGENTS.md                      regole per sviluppo e aggiornamento doc
documenti/                          documentazione di progetto
  01_CONTESTO_STORICO.md       fazioni, province, capitali, unita'
  02_ARCHITETTURA_GIOCO.md     citta', edifici, alberi unita', risorse
  03_BATTAGLIA_TEMPO_REALE.md  sistema battaglia 2.5D
  04_REGISTRO_MODIFICHE.md     log delle modifiche al progetto
scripts/
  autoload/                    10 script sempre attivi (vedi sotto)
  core/                        classi: Faction, Province, Unit, Building
  game/                        battle_group, battle_unit_visual, projectile
  ui/                          scene UI: menu, mappa, provincia, battaglia
  *.py                         script di generazione dati (Python)
scenes/                        20 scene Godot (.tscn)
dati/
  config/game_config.json      regole: risorse, truppe, navi, edifici
  config/icons_1000.json       mappatura icone
  world/factions_1000.json     28 fazioni con dati completi
  world/provinces_1000.json    province con proprietario, terreno, vicini
  world/mappa_anno_1000.geojson mappa geografica (47 MB)
  scenarios/initial_state_1000.json stato iniziale partita
risorse/                        sprite, icone, temi, font, sfondi, modelli GLB
  modelli/edifici_glb/          modelli 3D medievali con texture catalogo
test/                         test automatici
strumenti/                         strumenti di calibrazione
```

## Autoload (sempre attivi)

| Nome | File | Ruolo |
|------|------|-------|
| GameState | game_state.gd | stato partita, turni, salvataggio |
| WorldData | world_data.gd | caricamento dati JSON da dati/ |
| EconomyEngine | economy_engine.gd | produzione, costi, cibo |
| AIController | ai_controller.gd | fazioni non giocate |
| BattleSystem | battle_system.gd | micro-battaglie |
| SaveManager | save_manager.gd | salvataggio partita |
| SettlementManager | settlement_manager.gd | agglomerati urbani |
| IconManager | icon_manager.gd | icone truppe e navi |
| UiHelper | ui_helper.gd | utility interfaccia |
| AIBridge | ai_bridge.gd | chiamate IA esterne (Gemini/Groq/Cerebras) |

## Scene principali

- `main_menu.tscn` — menu iniziale, scelta fazione
- `strategic_map.tscn` — mappa mondiale, gestione turno
- `province_scene.tscn` / `province_view.tscn` / `province_popup.tscn` — schermata provincia
- `settlement_scene.tscn` / `settlement_view.tscn` — schermata agglomerato
- `battle_view.tscn` / `battle_group.tscn` / `projectile.tscn` — battaglia 2.5D
- `catalog_scene.tscn` — catalogo unita'/edifici

## Stato del progetto (verificato 2026-08-21)

### Completato
- Struttura Godot 4 con 10 autoload funzionanti
- 20 scene create (menu, mappa, provincia, agglomerato, battaglia, catalogo)
- 32 script GDScript (autoload, core, game, ui)
- Dati storici completi: 158 fazioni, 4327 province, mappa GeoJSON 47 MB
- 3917 province con insediamenti (edifici e livelli)
- game_config.json con 56 unita', 32 edifici, navi, tattiche
- Script Python di generazione dati (world_data, backgrounds, icons, settlements)
- Sistema di battaglia tempo reale 3D con scheletri, cavalli, artiglieria
- Sistema economico basato su popolazione
- IA con obiettivi per nazione (20 file dati/factions/*.json)
- IA esterna (AIBridge) con routing Gemini/Groq/Cerebras
- 376 icone PNG 256x256 + 108 SVG per 6 regioni culturali
- 32 texture edifici stile MTW2 (76x76 px)
- Background PNG per terrain (plains 1792x1024, forest, desert, mountains 256x256)
- Texture interfaccia MTW2 (stratpage, sharedpage, battlepage 512x512)
- Scena battaglia 3D RTS con terreno solido, formazioni, menu tattico
- BAT sul desktop per avviare direttamente la battaglia

### In corso
- Scena insediamento 3D (ora 2D con griglia colori, da convertire in 3D)
- Stato iniziale vuoto (factions e provinces sono {}, da popolare)
- Bilanciamento economico fine
- Transizione battaglia 2D -> 3D (scena 3D creata, da integrare con logica esistente)

### Da fare
- Popolare stato iniziale con 158 fazioni e 4327 province
- Creare scena insediamento 3D con edifici billboard e atmosfera medievale
- Integrare logica battaglia (morale, danno, IA) nella scena 3D
- Sostituire capsule mesh con modelli 3D soldati (.glb)
- Aggiungere texture medievali CC0 a soldati e edifici
- Creare pannelli UI per albero evolutivo unita' in stile pergamena
- Aggiungere suoni e musica
- Testare partita completa end-to-end
- Verificare bilanciamento su partita lunga (50+ turni)

## Flusso di un turno

1. Giocatore esegue ordini (movimenti, reclutamenti, costruzioni, attacchi)
2. Se ci sono attacchi con il giocatore, si apre `battle_view`
3. Le battaglie tra AI vengono risolte automaticamente
4. AIController esegue le azioni delle fazioni non giocate
5. EconomyEngine calcola produzione, mantenimento, cibo
6. Avanza di un mese
7. Vengono controllati eventi storici e obiettivi
8. Viene aggiornata la cronaca

## Documentazione di progetto

I file in `documenti/` sono le linee guida vive per lo sviluppo.
Ogni modifica al codice o al progetto deve essere riportata nei file
di documentazione.

### Indice documentazione

| File | Contenuto |
|------|-----------|
| `README.md` | Introduzione, struttura, stato (questo file) |
| `AGENTS.md` | Regole per sviluppo e aggiornamento doc |
| `documenti/01_CONTESTO_STORICO.md` | Fazioni, province, capitali, unita' |
| `documenti/02_ARCHITETTURA_GIOCO.md` | Citta', edifici, alberi unita', risorse |
| `documenti/03_BATTAGLIA_TEMPO_REALE.md` | Sistema battaglia 2.5D |
| `documenti/04_REGISTRO_MODIFICHE.md` | Log modifiche + tentativi riusciti/falliti |
| `documenti/05_ROADMAP.md` | Roadmap dettagliata con fasi e priorita' |
| `documenti/06_MANUALE_UTENTE.md` | Come si gioca, passo per passo |
| `documenti/07_FLUSSO_TURNO.md` | Diagramma flusso turno e battaglia |
| `documenti/08_API_IA_ESTERNA.md` | Documentazione AIBridge (Gemini/Groq/Cerebras) |

Vedi `AGENTS.md` per le regole complete di aggiornamento.
