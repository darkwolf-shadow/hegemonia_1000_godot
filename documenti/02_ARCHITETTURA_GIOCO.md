# Architettura di Gioco — Hegemonia 1000

Citta', edifici, alberi unita', risorse, navi e statistiche.
Dark Corporation / Stev

## Concetto generale

- La mappa strategica mostra le province come poligoni GeoJSON
- Cliccando (o zoomando) su una provincia si entra nella schermata provincia
- All'interno della provincia compaiono gli agglomerati urbani predefiniti
- Cliccando su un agglomerato si apre la schermata insediamento
- Il giocatore puo' fondare nuovi agglomerati in zone libere, pagando
  oro, legname e pietra
- La Provincia 3D visualizza agglomerati proporzionati, terreno locale,
  strade e porti costieri
- I fiumi e gli specchi d'acqua sono caratteristiche agricole; in questa
  fase non abilitano porti fluviali o navigazione interna
- La costruzione di una strada avviene con un trascinamento dal punto di
  origine al punto di arrivo e salva le coordinate nella provincia
- La costruzione di un porto richiede una provincia costiera e viene
  registrata nell'agglomerato

## Tipi di terreno delle province

Ogni provincia ha un tipo di terreno assegnato in base alla posizione
geografica (latitudine e longitudine). Il terreno influisce sulla
scena di battaglia 3D e in futuro su bonus/malus economici e militari.

| Terreno | Colline | Alberi | Rocce | Regioni tipiche |
|---------|---------|--------|-------|-----------------|
| plains | basse | 40 | 10 | steppe, savane |
| hills | medie | 50 | 20 | Europa centrale, Mediterraneo |
| mountains | alte | 30 | 40 | Asia centrale, Ande |
| forest | basse | 120 | 15 | Nord Europa, Asia sud-est |
| desert | medie | 5 | 25 | Nord Africa, Medio Oriente |
| coastal | basse | 30 | 15 | coste mediterranee |
| snow | medie | 20 | 30 | Russia, Siberia, nord |
| marsh | basse | 60 | 8 | delta fluviali, tropici |

Distribuzione attuale sulle 4327 province:
plains 28%, forest 20%, marsh 16%, hills 15%, snow 8%,
mountains 6%, coastal 5%, desert 4%.

## Tipi di agglomerato urbano

Ogni agglomerato ha un tipo che ne limita gli edifici e le unita' reclutabili.

### Civile (citta')
- Edifici base: centro cittadino, mercato, mulino, monastero, caserma
- Recluta: milizia contadina, fanteria base, arcieri base
- Produzione: oro, cibo, prestigio

### Militare (fortezza / castello / avamposto)
- Edifici: caserma avanzata, campo di tiro, scuderia, cortile del cavaliere,
  officina d'assedio, fortezza di frontiera
- Recluta: tutte le unita' terrestri, inclusi elite
- Bonus difesa per la provincia

### Industriale (centro estrattivo / borgo artigiano)
- Edifici: segheria, miniera, fucina, officina d'armi, capanne boscaioli
- Recluta: milizia contadina (forcone, ascia, falcetto)
- Produzione: legname, pietra, ferro, armi

### Commerciale / Portuale (porto / emporio)
- Edifici: molo, arsenale, mercato marittimo, magazzino
- Recluta: navi da trasporto e navi da guerra (se c'e' arsenale)
- Puo' evolvere in citta' con porto

## Edifici e unita' sbloccate

### Terrestri
- Centro cittadino -> milizia contadina
- Caserma (I) -> fanteria con lancia / scudo semplice
- Caserma (II) -> fanteria pesante, oplita, spadaccini
- Campo di tiro (I) -> arcieri leggeri
- Campo di tiro (II) -> arcieri a lungo arco / balestrieri
- Scuderia (I) -> cavalleria leggera
- Scuderia (II) -> cavalieri, cavalleria media
- Cortile del Cavaliere -> cavalleria pesante (richiede fucina + armatura)
- Officina d'Assedio (I) -> balista
- Officina d'Assedio (II) -> catapulta, ariete
- Officina d'Assedio (III) -> trabucco, torre d'assedio
- Fucina -> sblocca armature e armi avanzate
- Segheria -> sblocca navi e edifici in legno
- Miniera -> pietra, ferro, argento
- Officina d'Armi -> produzione armi, sblocca unita' elite
- Monastero -> prestigio, reliquie, cultura
- Mercato -> commercio oro
- Mulino -> cibo
- Fortezza di frontiera -> difesa provincia

### Navali
- Molo (I) -> canoe, piccole imbarcazioni da pesca/trasporto
- Molo (II) -> galea, nave da carico
- Arsenale (I) -> drakkar, dromone
- Arsenale (II) -> giunca, nave da guerra, nave torre

## Alberi evolutivi unita' terra

### Fanteria
Milizia contadina (forcone) -> Lancieri -> Oplita -> Fanteria pesante

Milizia contadina (ascia) -> Picchieri -> Guardia d'onore

### Arcieri
Arcieri leggeri -> Arcieri a lungo arco -> Balestrieri -> Balestrieri pesanti / Shenbi Nu (solo Song)

### Cavalleria leggera
Esploratori a cavallo -> Cavalleria leggera arcieri -> Cavalleria leggera con giavellotto (jinete, magiari, turchi)

### Cavalleria pesante
Scudieri / Cavalieri in armatura leggera -> Cavalieri corazzati -> Cavalieri pesanti elite (cataphractoi, loricati, mamluk, ghulam)

### Artiglieria (niente polvere da sparo nel 1000)
Balista -> Catapulta -> Trabucco -> Ariete / Torre d'assedio

### Milizia contadina
Contadini armati -> Milizia urbana -> Milizia addestrata

## Alberi evolutivi navi

Canoa -> Nave da pesca/trasporto -> Galea -> Dromone (Bizantino) / Drakkar (Vichinghi) / Giunca (Oriente) -> Nave da guerra / Nave torre (Song)

## Unita' particolari per fazione (edifici richiesti)

### Impero Bizantino
- Toxotai — arcieri evoluti (Campo di tiro II + Monastero)
- Cataphractoi — cavalleria pesante (Cortile del Cavaliere + Fucina)
- Varangian Guard — fanteria pesante (Caserma II + Mercato)
- Dromone — nave da guerra (Arsenale I)
- Fuoco greco — attacco navale speciale (Arsenale II + Monastero)

### Sacro Romano Impero
- Milites — fanteria pesante (Caserma II)
- Ministeriales — cavalleria feudale (Scuderia II)
- Loricati — cavalleria pesante corazzata (Cortile del Cavaliere)

### Vichinghi
- Bondi — milizia libera (Centro cittadino)
- Huskarl — fanteria pesante con ascia (Caserma II)
- Berserker — fanteria d'assalto (Caserma II + Officina d'Armi)
- Drakkar — nave veloce (Arsenale I)

### Regno di Francia
- Milites franci — cavalleria pesante (Scuderia II)
- Balestrieri — arcieri evoluti (Campo di tiro II)

### Califfato di Cordova
- Jinete — cavalleria leggera giavellotto (Scuderia I)
- Guardia Nera — fanteria scelta (Caserma II + Mercato)

### Impero Fatimide
- Mamluk cavalry — cavalleria pesante (Cortile del Cavaliere)
- Arcieri Armeni — arcieri evoluti (Campo di tiro I)
- Lancieri Sudanese — fanteria pesante (Caserma II)

### Califfato Abbaside
- Ghilman — cavalleria pesante (Cortile del Cavaliere)
- Fanteria Daylami — fanteria montanara (Caserma II)

### Sultanato Ghaznavide
- Ghulam cavalry — cavalleria pesante (Cortile del Cavaliere)
- Elefanti da guerra (Officina d'Assedio II + Mercato)

### Regno d'Ungheria
- Cavalleria Magiara — cavalleria leggera arcieri (Scuderia I + Campo di tiro I)

### Principato di Kiev
- Druzhina — cavalleria pesante (Cortile del Cavaliere)
- Voi — milizia cittadina (Centro cittadino)

### Regno di Polonia
- Druzyna — cavalleria pesante (Cortile del Cavaliere)

### Dinastia Song
- Balestrieri — arcieri evoluti (Campo di tiro II)
- Shenbi Nu — balestrieri scelti (Campo di tiro III + Officina d'Armi)
- Lancia di Fuoco — fanteria con armi a fuoco primitive (Officina d'Armi)
- Nave Torre — nave da guerra (Arsenale II)

### Impero Khitan Liao
- Arcieri a cavallo Khitan (Scuderia I + Campo di tiro I)
- Lancieri Liao — cavalleria pesante (Scuderia II)

### Impero Chola
- Fanteria Tamil — fanteria base (Caserma I)
- Corpo degli Elefanti (Cortile del Cavaliere / Officina d'Assedio II)
- Nave da Guerra Indiana (Arsenale I)

### Regno Khmer
- Lancieri Khmer — fanteria (Caserma I)
- Elefanti Khmer (Officina d'Assedio II)

### Regno Heian
- Samurai — cavalleria arcieri (Scuderia II + Monastero)
- Fanteria Yamato — fanteria (Caserma I)

### Regno di Srivijaya
- Arcieri Malese — arcieri (Campo di tiro I)
- Nave da guerra malese (Arsenale I)

### Impero del Ghana
- Cavalleria Soninke (Scuderia I)
- Lancieri Sudani — fanteria (Caserma I)

### Toltechi / Regni Maya
- Atlatl — lanciatori di giavellotto (Campo di tiro I)
- Holcan / Guerriero Giaguaro / Guerriero Aquila (Caserma II + Monastero)
- Canoa da guerra (Molo I)

## Statistiche delle unita'

Ogni unita' terrestre e navale ha:
- attacco (forza offensiva)
- difesa (resistenza ai danni)
- armatura (riduzione danni)
- velocita' (movimento e iniziativa)
- morale (se scende troppo l'unita' fugge)
- esperienza (accumulata in battaglia)
- costo_oro
- costo_risorse (legname, pietra, ferro, armi, cibo)
- popolazione (abitanti consumati)
- manutenzione_oro_per_turno
- manutenzione_cibo_per_turno

### Formula danno in battaglia
```
danno = attacco * bonus_tattica * (morale/100) * fattore_casualita'
difesa_effettiva = difesa + armatura * 0.5
```

Le unita' speciali hanno tratti: "incursori", "anti-cavalleria",
"assedio", "navale", "fuoco greco".

## Risorse

```
oro, legname, pietra, ferro, argento, armi, cibo
```

- Niente rame (estrazione limitata nell'anno 1000)
- Niente munizioni
- Niente carbonella
- armi = spade, asce, lance

## Edifici (riepilogo)

- monastero (ricerca + cibo)
- castello (difesa)
- fucina (ferro)
- mulino (cibo)
- mercato (entrate)
- Niente universita, banche, teatri

## Valuta

- oro

## Transizione 1000 -> 1300

- drakkar -> cocca
- dromone -> galea
- catapulta -> trabucco

## Scene Godot

- `strategic_map.tscn` — mappa strategica con zoom su provincia
- `province_scene.tscn` / `province_view.tscn` — provincia ingrandita con agglomerati
- `settlement_scene.tscn` / `settlement_view.tscn` — schermata agglomerato
- `battle_view.tscn` — battaglia con morale e statistiche

## File JSON

- `dati/config/game_config.json` — edifici, unita', navi, tratti, albero tecnologico
- `dati/world/provinces_1000.json` — province con campo "settlements"
- `dati/world/factions_1000.json` — fazioni con agglomerati ed edifici iniziali
- `dati/scenarios/initial_state_1000.json` — snapshot iniziale

## Fasi di implementazione

- **Fase A**: aggiornare game_config.json con edifici, unita', navi, tratti (completata)
- **Fase B**: creare autoload e script per agglomerati ed edifici (completata)
- **Fase C**: creare scene province_view, settlement_view e pannelli UI (completata)
- **Fase D**: inserire agglomerati predefiniti nelle province (completata: 3917 province, 155 capitali)
- **Fase E**: albero tecnologico edifici con requires, upgrades, construction_turns (completata)
- **Fase F**: recruit_pool per reclutamento unita' basato su edifici (completata)
- **Fase G**: effetti arricchiti (happiness, trade_bonus, weapon_bonus, armour_bonus, free_upkeep, recruitment_slots, population_growth, defense_bonus, law_bonus) (completata)
- **Fase E**: battaglia tempo reale 2.5D con morale, armatura, velocita' (completata)
- **Fase F**: miglioramento grafico battaglia (sprite, sfondi, effetti) (da fare)
- **Fase G**: testare con test_runner.gd e correzioni (da fare)

## Sistema IA (architettura ibrida)

L'IA segue il modello Hegemonia 1700: sviluppo economico deterministico
per le decisioni di routine, IA esterna per le decisioni strategiche
di alto livello (diplomazia, narrazione).

### AIController (deterministico)
- Carica 20 file obiettivi da `dati/factions/*.json`
- Sviluppo economico: costruisce edifici secondo `catena_priorita`
- Reclutamento: basato su `obiettivi_militari` + espansione militare
  (imperiale/razziatore: 5 unita'/turno, emergente: 3, marinaro: 2)
- Upgrade edifici automatico
- Decisione militare: attacco/difesa basato su atteggiamento

### AIBridge (IA esterna)
- Autoload per chiamate HTTPRequest a provider esterni
- Routing per token size (modello Hegemonia 1700):
  - sotto 7.000 token -> Cerebras (gpt-oss-120b)
  - 7.000-28.000 token -> Groq (openai/gpt-oss-120b)
  - sopra 28.000 token -> Gemini (gemini-3.1-flash-lite)
- Provider supportati: Gemini, Groq, Cerebras, OpenRouter, Cohere
- Prompt compatto per fazione (rispetta limiti token)
- Max 10 richieste pending contemporanee
- Contatori richieste con limiti free tier
- Fallback deterministico se nessun provider disponibile
- Configurazione in `config_api.json` (stesso formato Hegemonia 1700)

### Obiettivi per nazione (dati/factions/*.json)
Ogni file contiene:
- `obiettivi_storici`: contesto storico e obiettivi narrativi
- `obiettivi_produttivi`: target mensili per risorsa
- `obiettivi_militari`: minimi per fanteria, cavalleria, arcieri, artiglieria, elefanti, navi
- `comportamento`: imperiale, razziatore, emergente, marinaro, commerciale, religioso, isolazionista, regionale
- `catena_priorita`: ordine di costruzione edifici

### Bilanciamento economico
- **Modello basato su popolazione** (allineato a 800aC e 1700):
  - ORO = tasse(pop * 0.03) + edifici(base + suolo/5) + base_fazione
  - CIBO = agricoltura(forza_lavoro * suolo * 0.02) + edifici(base + suolo/5) + base
  - forza_lavoro = 70% popolazione
  - suolo_agricolo derivato dalla latitudine (tropicale=5, polare=0)
  - edifici: base fissa (garantisce sopravvivenza) + bonus da suolo fertile
  - anche fazioni con suolo povero (Vichinghi, suolo 0.8) sopravvivono
    grazie agli edifici, ma con risorse basse (devono razzire)
- Trade bonus: media per provincia (non somma totale)
- Free upkeep: limitato a 20 unita' gratuite
- Mantenimento unita': 5% del costo di reclutamento (oro/turno)
- Cibo unita': pop/20 per turno (pop = uomini nell'unita')
- Cibo popolazione civile: 1% della popolazione per turno
- Unita' iniziali: max 1 per provincia (min 10)
- Verificato con simulazione 12 turni: la popolazione e' il motore
  principale. Song (550K pop) produce piu' dei Bizantini (207K pop)
  nonostante abbia 20 province vs 240
