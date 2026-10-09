# Appunti — task grafica AoE 2.5D

**Dark Corporation / Stev**

## Decisione del progettista

La battaglia deve essere in stile Age of Empires / Empire, quindi 3D/2.5D.
Dopo analisi di cosa esiste gia', scelta la strada **A: 2.5D con sprite**,
senza modelli 3D veri. Opzione "3D dopo" resta aperta: la logica dei gruppi
resta riusabile.

Risposte operative raccolte:
- controllo diretto dei gruppi (stile RTS);
- pausa libera, nessun limite;
- comandante come unita' speciale: se muore, morale del lato crolla;
- bonus/malus del terreno attivi in battaglia.

## Cosa esiste gia' (verificato leggendo il codice)

- Tempo reale, selezione gruppi, ordini clic, pausa/x3, fase deploy,
  tattiche per gruppo, comandante, proiettili per arcieri/artiglieria,
  sfondo per bioma, IA tattica ogni 1.2 s, polvere cavalleria, sprite di
  carica (copertura parziale: cavalleria in tutte le regioni, milizia solo
  european).
- `BattleGroup` disegna UNO sprite per gruppo + contatore: questo e'
  il gap visivo principale verso AoE.

## Cosa il task cambia

- Formazioni multi-sprite (3-15 soldati per gruppo), morte individuale,
  pose idle/march/charge/attack/death, scala prospettica + z-sort + ombre,
  telecamera pan/zoom sul campo.
- Fasi 2 (mappa) e 3 (effetti) scritte ma bloccate al checkpoint visivo.

## Note tecniche

- Icone unita' sono PNG 256x256 per regione; niente sprite sheet:
  le pose si simulano con trasformazioni (rotazione, lunge, bob, fade).
- `IconManager.get_battle_sprite` restituisce texture di carica solo dove
  presente: serve fallback esplicito.
- Campo battaglia attuale: gruppi spawnati a x ±600, area piccola;
  formazioni larghe richiedono campo piu' ampio e camera mobile.

## Stato

- Task file: `docs/task_grafica_aoe_25d.md`
- Avvio: su branch `feature/grafica-aoe-25d`, Fase 1 sbloccata.
