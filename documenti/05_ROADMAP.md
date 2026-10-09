# Roadmap — Hegemonia 1000

Piano di sviluppo con priorita, fasi e obiettivi.
Dark Corporation / Stev

## Fase 1 - Fondamenta (COMPLETATA)

| Task | Stato | Data |
|------|-------|------|
| Struttura Godot 4 con autoload | COMPLETATO | 2026-08-14 |
| 28 fazioni storiche con dati | COMPLETATO | 2026-08-14 |
| 529 province con GeoJSON 47 MB | COMPLETATO | 2026-08-14 |
| game_config.json (unita, navi, edifici) | COMPLETATO | 2026-08-14 |
| 11 scene Godot create | COMPLETATO | 2026-08-14 |
| Ricalibrazione province storiche | COMPLETATO | 2026-08-17 |
| Agglomerati urbani (3917 province) | COMPLETATO | 2026-08-19 |
| Albero tecnologico edifici | COMPLETATO | 2026-08-19 |
| Sistema formazioni militari | COMPLETATO | 2026-08-19 |

## Fase 2 - Economia e IA (COMPLETATA)

| Task | Stato | Data |
|------|-------|------|
| IA con obiettivi per nazione (20 file) | COMPLETATO | 2026-08-19 |
| IA esterna AIBridge (Gemini/Groq/Cerebras) | COMPLETATO | 2026-08-20 |
| Correzione oro Bizantini (trade bonus) | COMPLETATO | 2026-08-20 |
| Mantenimento al 5% del costo | COMPLETATO | 2026-08-20 |
| Cibo unita pop/20 (scala migliaia) | COMPLETATO | 2026-08-20 |
| Economia basata su popolazione | COMPLETATO | 2026-08-20 |
| Edifici come sopravvivenza minima | COMPLETATO | 2026-08-20 |
| Riduzione unita iniziali (1/prov) | COMPLETATO | 2026-08-20 |

## Fase 3 - Battaglia (PARZIALE)

| Task | Stato | Note |
|------|-------|------|
| Battaglia tempo reale 2.5D | COMPLETATO | deploy, combat, morale |
| Formazioni (linea, cuneo, ecc.) | COMPLETATO | 6 formazioni |
| Comandanti e bonus | COMPLETATO | stella d'oro, morale |
| Proiettili arcieri/artiglieria | COMPLETATO | visibili |
| IA tattica avversaria | COMPLETATO | scelta tattica ogni 1.2s |
| Bug battle_group.gd corretto | COMPLETATO | 2026-08-20 |
| Sprite unita storiche | DA FARE | ora forme colorate |
| Ostacoli campo (alberi, rocce) | COMPLETATO | alberi/rocce seguono terreno |
| Bonus terreno in battaglia | DA FARE | |
| Scenari multipli per provincia | COMPLETATO | 8 tipi di terreno |
| Indice truppe per fazione | COMPLETATO | 24 fazioni, unita' speciali |
| Suoni e musica | DA FARE | |
| Log eventi battaglia | DA FARE | |

## Fase 4 - Interfaccia (PARZIALE)

| Task | Stato | Note |
|------|-------|------|
| Menu principale con scelta fazione | COMPLETATO | |
| Mappa strategica con nebbia | COMPLETATO | stile Leaflet |
| Popup provincia | COMPLETATO | |
| Scena provincia con agglomerati | COMPLETATO | |
| Scena agglomerato con griglia 5x5 | COMPLETATO | |
| Catalogo costruzioni | COMPLETATO | popup con costi/effetti |
| Reclutamento unita | COMPLETATO | |
| Pannelli albero evolutivo | DA FARE | |
| Schermata diplomazia | DA FARE | |
| Schermata ricerca | DA FARE | |
| Notifiche ed eventi | DA FARE | |

## Fase 5 - Bilanciamento (IN CORSO)

| Task | Stato | Note |
|------|-------|------|
| Fazioni grandi producono troppo | DA RIFINIRE | Bizantini 154K in 12 turni |
| Suolo agricolo solo da latitudine | DA RIFINIRE | province ora hanno terrain diverso |
| Terrain reali per province | COMPLETATO | 8 tipi: plains, hills, mountains, forest, desert, coastal, snow, marsh |
| Test partita 50+ turni | DA FARE | |
| Test end-to-end con umano | DA FARE | |

## Fase 6 - Contenuto (DA FARE)

| Task | Stato | Note |
|------|-------|------|
| Eventi storici (es. Crociate) | DA FARE | |
| Diplomazia tra fazioni | DA FARE | |
| Mercenario e truppe ausiliarie | DA FARE | |
| Commercio tra province | DA FARE | |
| Ribellioni e guerre civili | DA FARE | |
| Scenario 1000 -> 1300 | DA FARE | transizione storica |

## Priorita attuali (ordine di lavoro)

1. **Bilanciamento fazioni grandi**: ridurre produzione Bizantini
2. ~~Terrain reali per province~~ COMPLETATO (8 tipi di terreno)
3. **Sprite unita storiche**: sostituire forme colorate
4. **Schermata diplomazia**: base per interazioni tra fazioni
5. **Test end-to-end**: partita completa giocata da umano

## Obiettivo finale

Strategico storico a turni con:
- Mappa provinciale mondiale anno 1000
- 28 fazioni storiche con obiettivi
- Economia basata su popolazione e suolo agricolo
- Battaglie tattiche 2.5D con formazioni
- IA deterministica + esterna per narrazione
- Diplomazia, commercio, eventi storici
- Transizione 1000 -> 1300 con evoluzione unita
