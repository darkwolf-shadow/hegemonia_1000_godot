# Battaglia in Tempo Reale 2.5D — Hegemonia 1000

Sistema di battaglia tattica 2.5D in tempo reale.
Dark Corporation / Stev

## Stato: implementato e funzionante

Il sistema di battaglia tempo reale 2.5D e' gia' implementato.
Una nuova scena 3D RTS e' in fase di integrazione.

### Scena 2.5D (originale, funzionante)

- `scripts/ui/battle_view.gd` (642 righe) — scena principale
- `scripts/game/battle_group.gd` (373 righe) — gruppo di unita'
- `scripts/game/battle_unit_visual.gd` (194 righe) — sprite e animazioni
- `scripts/game/projectile.gd` — proiettili arcieri/artiglieria
- `scripts/autoload/battle_system.gd` (152 righe) — sistema base (avvia/termina)
- `scenes/battle_view.tscn` — scena radice
- `scenes/battle_group.tscn` — scena gruppo
- `scenes/projectile.tscn` — scena proiettile

### Scena 3D RTS (nuova, in integrazione)

- `scripts/ui/battle_view_3d.gd` — scena principale 3D
- `scripts/game/rts_camera.gd` — camera RTS con zoom e rotazione
- `scripts/game/formation_manager_3d.gd` — formazioni con scheletri
- `scripts/game/terrain_generator.gd` — terreno con colline procedurali
- `scripts/game/battle_scenario.gd` — 8 tipi di scenario
- `scripts/game/faction_troops.gd` — indice truppe per fazione
- `scripts/game/horse_mesh.gd` — cavallo con scheletro 20 ossa
- `scripts/game/horse_animation.gd` — animazione 4 zampe
- `scripts/game/soldier_skeleton.gd` — scheletro soldato
- `scripts/game/soldier_animation.gd` — animazione camminata
- `scripts/game/projectile_system.gd` — frecce e proiettili
- `scripts/game/tree_mesh.gd` — alberi procedurali
- `scripts/game/texture_loader.gd` — materiali con texture PBR
- `scenes/battle_view_3d.tscn` — scena radice 3D (plains)
- `scenes/battle_hills.tscn` — scenario colline
- `scenes/battle_mountains.tscn` — scenario montagne
- `scenes/battle_forest.tscn` — scenario foresta
- `scenes/battle_desert.tscn` — scenario deserto
- `scenes/battle_coastal.tscn` — scenario costa
- `scenes/battle_snow.tscn` — scenario neve
- `scenes/battle_marsh.tscn` — scenario palude
- Caratteristiche: Node3D, WorldEnvironment (SSAO, nebbia volumetrica),
  DirectionalLight3D, terreno 300x300 con FastNoiseLite,
  scheletri soldati e cavalli, castelli, alberi e rocce
- 8 scenari con terrain_type diverso (plains, hills, mountains,
  forest, desert, coastal, snow, marsh)
- Indice truppe: 24 fazioni con unita' speciali (cataphractoi,
  berserker, samurai, war_elephant, jaguar_warrior, ecc.)

## Funzionalita' implementate

### Fasi di gioco
- **Deploy**: il giocatore posiziona le unita' trascinandole
- **Combat**: tempo reale con `_process(delta)` che aggiorna movimento, attacchi, morale
- Pulsanti Play / Pausa / Veloce (x3) / Inizia Battaglia / Torna alla Mappa

### Controlli del giocatore
- Click sinistro su un gruppo: selezione
- Click destro su terreno: muovi in quel punto
- Click destro su nemico: attacca quel nemico
- Pulsanti tattica nel pannello inferiore

### Sfondo del campo di battaglia
- Sfondo scelto in base al terreno della provincia
- File in `risorse/backgrounds/1000/png/` (plains, forest, mountain, desert, coastal)
- Fallback su `.svg` se il PNG non esiste

### Tattiche con bonus e malus
- **standard**: nessun bonus/malus
- **charge**: velocita' x1.6, attacco x1.35 per cavalleria/elefanti; x1.3/x1.2 per fanteria
- **shield_wall**: velocita' x0.6, difesa x1.4, attacco x0.8
- **skirmish**: arcieri/artiglieria attacco x1.1; altri x0.85
- **elephant_charge**: come charge per elefanti

### Ruoli e statistiche
- **Fanteria**: velocita' media, corto raggio (40)
- **Cavalleria**: veloce (x40), raggio 45, intervallo 1.4s
- **Arcieri**: lenti (x28), raggio 220, intervallo 1.8s, proiettili
- **Artiglieria**: molto lenta (x20), raggio 320, intervallo 3.0s, proiettili
- **Elefanti**: lenti (x22), raggio 50, intervallo 2.0s

### Morale ed esperienza
- Morale iniziale da `base_morale` della fazione
- Morale scende per perdite (x0.3 del danno)
- Morale rigenera 2.0/s (x1.5 con comandante)
- Se morale <= 0: il gruppo entra in rotta e fugge
- Se rotta per piu' di 3 secondi: il gruppo muore
- Comandante morto: morale -20 per tutto il lato
- Esperienza accumulata dopo la battaglia (`_gain_experience` in battle_system.gd)

### Comandante
- Checkbox "Comandante" nel pannello unita'
- Un solo comandante per lato
- Stella d'oro disegnata sopra l'unita'
- Bonus attacco x1.25
- Bonus rigenerazione morale x1.5
- Morte del comandante: morale -20 per tutto il lato

### IA avversaria
- L'IA sceglie la tattica con `AIController.choose_battle_tactic`
- Aggiornamento ogni 1.2 secondi
- L'IA targeting il nemico piu' vicino
- Snapshot della battaglia passato all'AIController

### Proiettili
- Visibili per arcieri e artiglieria
- Spawn da `battle_group.gd` -> `projectile.tscn`
- Danno consegnato al bersaglio

### Vista 3D / Realistico
- Toggle pulsante "Vista: 3D" / "Vista: Realistico"
- Scala sprite leggermente maggiore in modalita' 3D (x1.08)
- Sprite da `IconManager.get_unit_icon` e `IconManager.get_battle_sprite`

### Animazioni
- Bobbing verticale durante il movimento (sin)
- Ampiezza maggiore durante la carica (4px vs 2px)
- Particelle di polvere per cavalleria/elefanti
- Direzione della faccia (sinistra/destra)

### Fine battaglia
- Rilevamento: un lato non ha piu' gruppi vivi o tutti in rotta
- Risultato: attaccante / difensore / pareggio
- Pannello finale con vincitore
- Il vincitore occupa la provincia
- Ritorno alla mappa strategica

## Problemi noti

### Grafica
- L'aspetto grafico non e' ancora curato come promesso
- Gli sprite sono semplici forme colorate, non illustrazioni storiche
- Da migliorare: sfondi, sprite unita', effetti visivi, interfaccia

### Da migliorare
- Aggiungere ostacoli sul campo di battaglia (alberi, rocce, fiumi)
- Aggiungere bonus terreno in battaglia (foresta = difesa, collina = attacco)
- Migliorare l'IA micro-tattica (priorita' target, ritirata intelligente)
- Aggiungere suoni e musica
- Aggiungere log eventi di battaglia scorrevole

## Sistema formazioni militari

Ogni gruppo di unita' ha una formazione che definisce:
- la disposizione spaziale degli slot (blocchi)
- i bonus/malus a attacco, difesa, velocita', morale, gittata
- l'area di occupazione sul campo (raggio e larghezza)
- le collisioni con altri gruppi

### Formazioni disponibili

| Formazione | Attacco | Difesa | Velocita' | Morale | Gittata | Descrizione |
|------------|---------|--------|-----------|--------|---------|-------------|
| Linea | 1.1 | 0.9 | 1.0 | 1.0 | 1.0 | Largo fronte, buono contro fanteria |
| Quadrato | 0.8 | 1.4 | 0.6 | 1.2 | 0.9 | Compatto, anti-cavalleria |
| Cuneo | 1.3 | 0.7 | 1.1 | 1.1 | 0.8 | Rompe linee nemiche |
| Ala | 1.15 | 0.8 | 1.1 | 0.9 | 1.0 | Avvolge i fianchi |
| Sparsa | 0.9 | 0.7 | 1.0 | 0.8 | 1.2 | Arcieri distanziati |
| Colonna | 0.9 | 1.0 | 1.3 | 1.0 | 0.7 | Movimento veloce |

### Formazioni per ruolo

- **Fanteria**: Linea, Quadrato, Colonna
- **Cavalleria**: Cuneo, Ala, Colonna
- **Arcieri**: Sparsa, Linea
- **Artiglieria**: Linea, Sparsa
- **Elefanti**: Cuneo, Linea

### Cambio formazione

- Il giocatore puo' cambiare formazione durante la pausa tattica
- Il cambio richiede 2 secondi (tempo di riformazione)
- Durante il riformamento la velocita' e' ridotta del 50%
- I modificatori si applicano immediatamente

### Collisioni tra gruppi

- Ogni gruppo occupa un'area circolare basata sulla formazione
- I gruppi non si sovrappongono durante il movimento
- Se c'e' collisione, il gruppo prova a scivolare lateralmente
- Raggi: Linea 80, Quadrato 60, Cuneo 100, Ala 110, Sparsa 90, Colonna 30

### Griglia di deploy

- Durante la fase di posizionamento, il campo mostra 8 slot per il giocatore
- Zone colorate: blu per attaccante (sinistra), rosso per difensore (destra)
- Gli slot scompaiono quando inizia il combattimento

### File coinvolti

- `scripts/game/formation_system.gd` (149 righe) — definizioni formazioni
- `scripts/game/battle_group.gd` — integrazione formazioni nel gruppo
- `scripts/game/battle_unit_visual.gd` — visualizzazione slot blocchi
- `scripts/ui/battle_view.gd` — pulsanti formazione e griglia deploy

## File di dati

- `dati/config/game_config.json` — tattiche, unita', statistiche
- `dati/config/icons_1000.json` — mappatura icone unita'
- `WorldData.terrain_modifiers` — modificatori di terreno
- `WorldData.tactics` — bonus tattiche per tipo unita'
