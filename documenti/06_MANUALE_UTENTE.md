# Manuale Utente — Hegemonia 1000

Come si gioca, passo per passo.
Dark Corporation / Stev

## Avvio

1. Apri Godot 4.3 o superiore
2. Importa la cartella `Hegemonia_1000`
3. Premi F5 per avviare

## Menu principale

All'avvio vedi il menu con:
- **Fazione**: menu a tendina con 20 fazioni giocabili
- **Nuova partita**: inizia con la fazione selezionata
- **Carica**: riprende l'ultimo salvataggio
- **Catalogo**: sfoglia edifici, unita, navi senza giocare
- **Prova battaglia**: avvia una battaglia di test

## Fazioni consigliate

- **Impero Bizantino**: fazione forte, 240 province, economia solida
- **Sacro Romano Impero**: 96 province, bilanciato
- **Vichinghi**: difficile, suolo povero, deve razzire
- **Dinastia Song**: popoloso ma poche province (20)

## Mappa strategica

La mappa mostra tutte le province come poligoni colorati.

### Controlli
- **Click sinistro** su una provincia: apre il popup
- **Rotellina**: zoom avanti/indietro
- **Tasto destro + trascina**: sposta la mappa
- **Tasto centrale + trascina**: sposta la mappa

### Colori
- **Colore fazione**: province possedute
- **Nero**: nebbia di guerra (territorio sconosciuto)
- **Grigio scuro**: esplorato ma non posseduto

### Barra superiore
- **Turno**: mese e anno corrente
- **Fine Turno**: passa al turno successivo

### Cronaca (in basso)
Mostra gli eventi degli ultimi 20 turni.

## Schermata provincia

Cliccando "Entra" dal popup provincia si apre la vista territorio.

### Cosa vedi
- Poligono della provincia con terreno colorato
- Agglomerati urbani come icone con etichette
- Strade tra agglomerati (sterrate o in pietra)

### Controlli
- **Click su agglomerato**: entra nell'agglomerato
- **Rotellina**: zoom
- **Tasto destro + trascina**: sposta
- **ESC**: torna alla mappa strategica

## Schermata agglomerato

La griglia 5x5 mostra gli edifici dell'agglomerato.

### Cosa vedi
- Centro cittadino al centro (slot 12)
- Edifici esistenti negli slot circostanti
- Slot vuoti dove puoi costruire
- Strade dal centro a ogni edificio

### Costruire
1. Click su uno slot vuoto
2. Si apre il catalogo costruzioni
3. Seleziona un edificio per vedere costi ed effetti
4. Click "Costruisci" se hai risorse sufficienti

### Migliorare
1. Click su un edificio esistente
2. Vedi livello, effetti e costo miglioramento
3. Click "Migliora" se hai risorse

### Reclutare
1. Click "Reclutamento" in basso a destra
2. Si apre la vista reclutamento
3. Seleziona un'unita per vedere costo e statistiche
4. Imposta la quantita
5. Click "Recluta"

## Risorse

| Risorsa | Uso |
|---------|-----|
| Oro | costruzioni, reclutamento, mantenimento |
| Cibo | sopravvivenza popolazione e unita |
| Legname | costruzioni in legno, navi |
| Pietra | costruzioni in pietra |
| Ferro | armi, armature |
| Armi | unita elite |
| Prestigio | eventi, bonus |

## Turno

Ogni turno = 1 mese. Alla fine del turno:
1. EconomyEngine calcola produzione (oro, cibo, risorse)
2. EconomyEngine paga mantenimento unita
3. EconomyEngine consuma cibo (unita + popolazione)
4. EconomyEngine applica crescita popolazione
5. AIController esegue azioni fazioni non giocate
6. Avanza di un mese

## Battaglia

Quando attacchi una provincia nemica si apre la battaglia.

### Fase di deploy
- Trascina le unita negli slot (blu = attaccante, rosso = difensore)
- Scegli il comandante (checkbox)
- Click "Inizia Battaglia"

### Combattimento
- **Click sinistro**: seleziona un gruppo
- **Click destro su terreno**: muovi
- **Click destro su nemico**: attacca
- **Pulsanti**: Play, Pausa, Veloce (x3)
- **Tattiche**: standard, charge, shield_wall, skirmish

### Fine battaglia
- Un lato senza unita vive o tutte in rotta: sconfitta
- Il vincitore occupa la provincia
- Ritorno alla mappa strategica

## Consigli

- **Inizia con i Bizantini**: fazione forte e ricca
- **Costruisci mulini**: garantiscono cibo base
- **Costruisci mercati**: aumentano oro
- **Non reclutare troppe unita**: il mantenimento al 5% del costo pesa
- **Esplora prima di attaccare**: la nebbia nasconde i nemici
- **I Vichinghi devono razzire**: il nord e' povero di risorse
