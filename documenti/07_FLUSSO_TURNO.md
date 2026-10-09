# Flusso del Turno — Hegemonia 1000

Diagramma del ciclo di gioco e dell'ordine di elaborazione.
Dark Corporation / Stev

## Ciclo di gioco

```
[Menu Principale]
       |
       v
[Nuova Partita] --> scelta fazione
       |
       v
[Mappa Strategica] <--+
       |               |
       |               |
   [Click provincia]   |
       |               |
       v               |
[Popup Provincia]      |
       |               |
       v               |
[Scena Provincia]      |
       |               |
       v               |
[Scena Agglomerato]    |
       |               |
       v               |
[Costruisci/Recluta]   |
       |               |
       +---------------+
       |
   [Fine Turno]
       |
       v
[Elaborazione Turno]
       |
       v
[Torna a Mappa Strategica]
```

## Ordine di elaborazione del turno

Quando il giocatore preme "Fine Turno", `GameState.advance_turn()`
esegue nell'ordine:

```
1. AIController.make_decisions()
   per ogni fazione AI:
   a. sviluppo economico (costruzione edifici)
   b. reclutamento unita
   c. upgrade edifici
   d. decisione militare (attacco/difesa)
   e. richiesta IA esterna (se disponibile)

2. EconomyEngine.apply_production()
   per ogni fazione:
   a. produce_resources(faction)
      - oro: tasse(pop*0.03) + edifici(base+suolo/5) + base
      - cibo: agricoltura(forza_lavoro*suolo*0.02) + edifici(base+suolo/5) + base
      - altre risorse: legname, ferro, pietra, armi, prestigio
   b. pay_maintenance(faction)
      - oro: mantenimento unita (5% del costo)
      - free upkeep: prime 20 unita gratuite
      - navi: mantenimento separato
   c. consume_food(faction)
      - cibo: unita (pop/20 per unita) + navi + popolazione (1%)
      - se cibo < 0: warning, cibo azzerato
   d. apply_population_growth(faction)
      - crescita percentuale basata su edifici (mulino, monastero)

3. BattleSystem.resolve_auto_battles()
   - battaglie tra AI risolte automaticamente
   - battaglie con giocatore: aperte in battle_view

4. GameState.advance_time()
   - mese += 1
   - se mese > 12: anno += 1, mese = 1

5. Aggiornamento cronaca eventi
```

## Flusso battaglia

```
[Attacco provincia nemica]
       |
       v
[Deploy]
   - trascina unita negli slot
   - scegli comandante
   - scegli formazione
       |
       v
[Inizia Battaglia]
       |
       v
[Combat tempo reale]
   - seleziona gruppo (click sx)
   - muovi (click dx su terreno)
   - attacca (click dx su nemico)
   - cambia tattica
   - pausa/veloce
       |
       v
[Fine battaglia]
   - un lato senza unita vive
   - o tutte in rotta
       |
       v
[Risultato]
   - vincitore occupa provincia
   - esperienza accumulata
   - ritorno a mappa
```

## Flusso costruzione

```
[Click slot vuoto in agglomerato]
       |
       v
[Catalogo costruzioni]
   - lista edifici disponibili
   - filtro per tipo agglomerato
   - mostra costi ed effetti
       |
       v
[Seleziona edificio]
   - mostra: costo, effetti, sblocca unita
       |
       v
[Click "Costruisci"]
   - verifica risorse sufficienti
   - se OK: costruisci
   - se KO: messaggio errore
       |
       v
[Edificio appears nella griglia]
```

## Flusso reclutamento

```
[Click "Reclutamento" in agglomerato]
       |
       v
[Vista reclutamento]
   - lista unita reclutabili
   - filtro per edifici presenti
       |
       v
[Seleziona unita]
   - mostra: costo, attacco, difesa, armatura, velocita
       |
       v
[Imposta quantita]
       |
       v
[Click "Recluta"]
   - verifica oro e risorse
   - verifica popolazione disponibile
   - se OK: recluta
   - se KO: messaggio errore
       |
       v
[Unita aggiunta all'esercito fazione]
```
