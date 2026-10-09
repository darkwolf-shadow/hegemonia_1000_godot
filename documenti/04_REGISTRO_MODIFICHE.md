# Registro Modifiche — Hegemonia 1000

Log delle modifiche al progetto. Ogni voce registra data, cosa e' stato
cambiato e riferimento ai file coinvolti.
Dark Corporation / Stev

## Come usare questo file

Ogni volta che si modifica il codice o i dati del progetto, aggiungere
una voce in cima alla sezione "Cronologia" con:
- **Data**: YYYY-MM-DD
- **Modifica**: descrizione breve
- **File**: file modificati
- **Motivo**: perche' della modifica

## Cronologia

### 2026-08-22 — Passo 79: Modalita' prova con risorse infinite e texture catalogo corrette
- **Modalita' prova Agglomerato**:
  - Se aperta dal menu `Prova di Egemonia 1000`, imposta `GameState.state["render_test_mode"] = true`
  - Costruzioni, miglioramenti ed espansioni non consumano risorse in questa modalita'
  - La partita normale mantiene i costi
- **Icone corrette**:
  - Il manifest indicava `res://assets/icons/1000/...`, percorso assente nel progetto
  - `icon_manager.gd` ora corregge il percorso verso `res://risorse/icone/1000/...`
  - OptionButton usa `add_icon_item` con le icone reali del catalogo
- **Texture sui GLB**:
  - La factory applica sempre la facciata con l'icona catalogo anche quando il GLB viene caricato
  - Il GLB non viene piu' restituito prima dell'applicazione della texture
- **Verifica**: menu prova e Agglomerato 3D avviati senza errori

### 2026-08-22 — Passo 78: Modelli GLB degli edifici creati con Blender
- **Strumento verificato**:
  - Blender 4.2.3 LTS
  - Percorso: `G:\Unity_Toolchain\Blender\blender-4.2.3-windows-x64\blender.exe`
- **Backup di sicurezza creato prima della modifica**:
  - `G:\my_steve_game\Gioco_Maps\Hegemonia_1000_backup_20260822.zip`
- **Modelli GLB creati** in `risorse/modelli/edifici_glb/`:
  - `centro_cittadino.glb`
  - `caserma_i.glb`, `caserma_ii.glb`, `caserma_iii.glb`
  - `mercato.glb`, `monastero.glb`, `mulino.glb`, `miniera.glb`
  - `molo_i.glb`, `fortezza_frontiera.glb`
- **Struttura dei modelli**:
  - corpo edificio 3D
  - tetto
  - torre per edifici principali
  - bandiera per caserme e moli
  - facciata con icona PNG del catalogo come texture
  - materiali con ruvidita' medievale
- **Collegamento runtime**:
  - `scripts/game/medieval_building_factory.gd` carica prima il GLB
  - fallback procedurale mantenuto se una risorsa non e' disponibile
- **Verifica doppia GLB**:
  - controllo 1: 10 GLB, tutti con intestazione `glTF`, dimensione totale 1.286.408 byte
  - controllo 2: 10 nomi attesi, tutti sopra 5000 byte con texture incorporata possibile
- **Verifica Godot**: `settlement_scene_3d.tscn` avviata senza errori

### 2026-08-22 — Passo 77: Primi modelli 3D edifici da icone esistenti
- **Asset verificati**: 10 icone edificio europee, 256x256 (mulino e fortezza 256x204)
- **Strumento verificato**: Blender non installato
- **Modelli creati** in `risorse/modelli/edifici/`:
  - 10 file `.obj`
  - 10 file `.mtl`
  - centro_cittadino, caserma_i/ii/iii, mercato, monastero, mulino, miniera, molo_i, fortezza_frontiera
- **Struttura del modello**: corpo, tetto, eventuale torre/bandiera e materiale con `map_Kd` collegata all'icona del catalogo
- **Factory**: `scripts/game/medieval_building_factory.gd` prova a caricare il modello OBJ e usa il modello procedurale come fallback
- **Scena Agglomerato**: gli edifici usano la factory invece dei soli Sprite3D
- **Verifica doppia file**:
  - controllo 1: 10 OBJ, 10 MTL, 100 facce totali
  - controllo 2: 10 OBJ, 10 MTL, 10 MTL con texture `map_Kd`
- **Verifica Godot**: `settlement_scene_3d.tscn` avviata senza errori
- **Nota**: gli OBJ sono modelli modulari generati dalla forma e vestiti con le icone; non sono fotogrammetria o modelli medievali professionali

### 2026-08-22 — Passo 76: Camera Provincia e Agglomerato, icone edifici e griglia nascosta
- **Provincia 3D**:
  - Rotazione esplicita sul `CameraPivot` con tasto destro
  - Inclinazione verticale con tasto destro
  - Pan con tasto sinistro o centrale
  - Zoom ottico con rotellina tramite FOV
- **Agglomerato 3D**:
  - Rotellina ora modifica solo il FOV, non la distanza fisica della camera
  - Tasto destro: rotazione e inclinazione
  - Tasto sinistro: spostamento visuale
  - Griglia dei quadrati resa invisibile: resta solo la griglia logica
  - Menu edifici con icone reali tramite `OptionButton.add_icon_item`
  - Edifici mostrati con icone 3D del catalogo invece dei cubi colorati
  - Testo di selezione non viene piu' accumulato
- **Asset verificati**: nel progetto non sono presenti GLB/OBJ medievali; il sistema usa quindi le icone PNG esistenti senza percorsi fittizi
- **Verifica**: Provincia 3D e Agglomerato 3D avviati senza errori dopo la correzione di tipo `Vector2`

### 2026-08-22 — Passo 75: Interazione Provincia 3D e icone edificio nell'Agglomerato
- **Provincia 3D**:
  - CameraPivot e Camera3D aggiunti a runtime
  - Tasto sinistro/centrale: spostamento della visuale
  - Tasto destro: rotazione e inclinazione
  - Rotellina: zoom tramite FOV
  - ESC torna al menu
- **Agglomerato 3D**:
  - Eliminata la rappresentazione degli edifici tramite cubi colorati
  - Gli edifici usano le icone reali del catalogo tramite `IconManager`
  - Mantengono slot e nomi senza coprire il terreno con volumi sproporzionati
  - Il testo dello slot viene sostituito, non accumulato a ogni click
  - La griglia resta logica e gli slot selezionati vengono gestiti dal pannello
- **Asset**: verificata la cartella Hegemonia 1000; non contiene file GLB/OBJ medievali, quindi non sono stati inventati percorsi inesistenti
- **Verifica**: `province_scene_3d.tscn` e `settlement_scene_3d.tscn` avviate senza errori

### 2026-08-22 — Passo 74: Provincia 3D separata e Agglomerato 3D con griglia interattiva
- **Provincia 3D**:
  - mantiene un solo terreno con la forma geografica reale della provincia
  - gli agglomerati sono indicatori piccoli, non modelli completi
  - il terreno resta visibile e selezionabile
- **Agglomerato 3D rifatto**:
  - terreno unico proporzionato all'agglomerato
  - griglia logica da 5x5 a 13x13, livelli 1-5
  - slot selezionabili con click
  - pannello per scegliere e costruire edifici
  - edificio migliorato mantiene lo stesso slot
  - coda costruzioni con durata in turni e stato `is_under_construction`
  - costi risorse per costruzione e miglioramento/espansione
  - espansione aggiorna griglia, spazio disponibile e dimensione cinta
  - staccionata al livello mura 0, mura ai livelli successivi
  - illuminazione medievale senza nebbia
  - zoom e rotazione visuale
- **Correzione clipping**: nella scena Agglomerato non vengono piu' usati piu' terreni completi sovrapposti
- **Verifica**: `settlement_scene_3d.tscn` avviata senza errori dopo la correzione del formato HUD

### 2026-08-22 — Passo 73: Provincia 3D usa la forma geografica reale
- **Correzione principale**: eliminato il quadrato generico come terreno della provincia
- `province_scene_3d.gd` ora legge `geometry` dalla provincia caricata da GeoJSON
- Converte il ring esterno in coordinate locali e crea una superficie triangolata con la forma reale della provincia
- La mesh della provincia ha un rilievo locale leggero coerente con il tipo di terreno, senza palizzate o edifici completi sovrapposti
- Colori del terreno differenziati per pianura, foresta, colline, montagne, deserto, palude, costa e neve
- Collisione sulla superficie della provincia per interazione futura
- Gli agglomerati restano marcatori piccoli e separati dalla scena dettagliata
- **Verifica**: `province_scene_3d.tscn` avviata senza errori
- **Limite noto**: per MultiPolygon viene visualizzato il ring principale; isole secondarie e fiumi saranno aggiunti con il sistema geografico dedicato

### 2026-08-22 — Passo 72: Agglomerato 3D collegato ai dati reali e griglia logica
- `settlement_scene_3d.gd` non usa piu' l'agglomerato fittizio di prova
- Carica provincia e agglomerato da `GameState.state`
- Usa la regione culturale della fazione per le risorse visive
- Aggiunta griglia logica persistente per l'agglomerato:
  - livello espansione limitato a 1-5
  - dimensione griglia = 3 + livello*2
  - slot massimi = griglia quadrata
  - ogni edificio mantiene il proprio slot durante l'evoluzione
  - aggiunti `building_slots`, `construction_queue`, `walls_level`
- La scena 3D dettagliata resta distinta dai marcatori della Provincia 3D
- **Verifica**: settlement_scene_3d.tscn avviata senza errori
- **Da completare**: UI visuale degli slot, costruzione con timer di turno, espansione mura e aggiornamento visuale della cinta

### 2026-08-22 — Passo 71: Provincia 3D corretta - marcatori proporzionati invece di agglomerati sovrapposti
- **Causa verificata**:
  - `settlement_3d.gd` crea un terreno interno di 60x60 e mura con raggio 25
  - La provincia locale e' 40x30
  - Inserendo piu' agglomerati completi nella provincia, i loro terreni si sovrapponevano e coprivano tutto
- **Correzione**:
  - La Provincia 3D crea ora un solo terreno locale
  - Ogni agglomerato nella Provincia e' un marcatore 3D piccolo (cilindro + nome)
  - Ogni marcatore ha collisione per il click
  - Il dettaglio completo resta nella scena separata `settlement_scene_3d.tscn`
  - Click sul marcatore apre la scena dell'agglomerato corretto
- **Risultato**: la provincia resta visibile, gli agglomerati sono proporzionati e non si accatastano
- **Verifica**: scena Provincia 3D avviata senza errori

### 2026-08-22 — Passo 70: Rifinitura visiva Provincia 3D in stile medievale
- **Illuminazione**: cielo, sole direzionale, ombre e SSAO simili alla battaglia, senza nebbia
- **Terreno**: dettagli decorativi leggeri coerenti con il tipo reale della provincia:
  - alberi per foreste
  - rocce per colline e montagne
- **Interfaccia**: pannello scuro con bordo caldo medievale, testo color pergamena, dati provincia e comandi separati
- **Agglomerati**: dimensionamento proporzionato al numero presente, senza immagini che coprono la mappa
- **Riferimento progettuale**: gerarchia leggibile di terreno, insediamenti e informazioni, come nelle mappe strategiche e nelle schermate di villaggio medievali
- **Verifica**: scena Provincia 3D avviata senza errori

### 2026-08-22 — Passo 69: Costruzione interattiva completa nella Provincia 3D
- **Validazione richiesta aggiornata**:
  - Nessuna gestione porti fluviali o navigazione fluviale
  - Le coste consentono il porto
  - Fiumi/specchi d'acqua restano caratteristiche agricole senza porto
- **Agglomerato**:
  - Bottone attiva la modalita' di costruzione
  - Click sul terreno determina la posizione locale
  - Coordinate `[x,z]` salvate nell'agglomerato della provincia
  - Costo: 100 oro, 20 legname, 20 pietra
  - Le risorse vengono sottratte dalla fazione salvata in GameState
  - La scena viene rigenerata dopo la costruzione
- **Strada**:
  - Bottone "Costruisci strada"
  - Click sinistro sul punto iniziale, trascinamento, rilascio sul punto finale
  - Anteprima gialla durante il trascinamento
  - Costo: 25 oro, 10 legname, 5 pietra
  - Origine/destinazione salvate in `province["roads"]`
  - Strada mostrata immediatamente nella scena 3D
- **Porto**:
  - Bottone attivo solo se `terrain` e' coastal/costiera/coast oppure `properties.costiera` e' vero
  - Costo: 150 oro, 25 legname, 25 pietra
  - Aggiunge `porto` agli edifici dell'agglomerato principale
  - Impedisce duplicati e costruzione in provincia non costiera
- **Test**: `province_scene_3d.tscn` avviata senza errori dopo la correzione di sintassi

### 2026-08-22 — Passo 68: Costruzione interattiva agglomerati, porti costieri e strade
- **Provincia 3D completata per il ciclo base**:
  - Terreno locale 3D senza nebbia, illuminazione coerente con la battaglia
  - Agglomerati caricati dalla singola provincia e ridimensionati proporzionalmente
  - Posizioni esistenti lette dai campi `position` oppure da `x`/`y`
- **Nuovo agglomerato**:
  - Bottone "Costruisci agglomerato" attiva la modalita' costruzione
  - Click sulla mappa registra la posizione locale `[x, z]`
  - Crea un agglomerato civile con `SettlementManager.ensure_settlement`
  - Stato persistente in `GameState.state.provinces[nome_provincia]`
- **Strade**:
  - Bottone "Costruisci strada"
  - Click e trascinamento dal punto iniziale al punto finale
  - Rilascio del tasto sinistro salva la strada con origine e destinazione
  - Strada mostrata subito in 3D
  - Dati salvati nell'array `province["roads"]`
- **Porti**:
  - Bottone disponibile solo per province con terreno `coastal/costiera/coast` o proprieta' `costiera`
  - Costruzione del porto nell'agglomerato principale
  - Fiumi e specchi d'acqua non vengono trattati come porti navigabili
- **Costi agglomerato**: il nuovo flusso mantiene la registrazione nella provincia; i costi economici dettagliati saranno centralizzati nel prossimo passaggio per usare la fazione attiva invece di valori locali
- **Verifica**: `province_scene_3d.tscn` avviata senza errori

### 2026-08-22 — Passo 67: Provincia 3D con dati persistenti e accesso agli agglomerati
- **Provincia 3D usa lo stato reale**:
  - Legge prima `GameState.state.provinces`, poi usa `WorldData` come fallback
  - Il terreno locale usa il tipo di terreno reale e un seme derivato dal nome provincia
  - Gli agglomerati presenti vengono visualizzati con `settlement_3d.gd`
- **Agglomerati**:
  - Scala proporzionata al numero di agglomerati presenti
  - Click su un agglomerato -> salvataggio `last_settlement` -> apertura scena `settlement_scene_3d.tscn`
  - La scena agglomerato non usa piu' dati fittizi: legge provincia, agglomerato, proprietario, tipo ed edifici dallo stato
- **Costruzione**:
  - Il nuovo agglomerato viene scritto nella singola provincia di `GameState`
  - Costi verificati prima dell'operazione: 100 oro, 20 legname, 20 pietra
  - Dopo la costruzione la scena viene rigenerata e l'agglomerato compare sul terreno
- **Strade**: viene visualizzata una strada 3D tra agglomerati consecutivi
- **Illuminazione**: cielo, luce direzionale, ombre e SSAO coerenti con la battaglia, senza nebbia
- **Verifica**: `province_scene_3d.tscn` e `settlement_scene_3d.tscn` avviate senza errori
- **Da completare**: posizionamento libero con coordinate geografiche, riconoscimento fiumi navigabili/costa/montagna, porti, rete stradale scelta dal giocatore e costi configurabili nei dati di gioco

### 2026-08-22 — Passo 66: Prima scena Provincia 3D con terreno, agglomerati e strade
- **Scena nuova**: `scenes/province_scene_3d.tscn`
- **Script nuovo**: `scripts/ui/province_scene_3d.gd`
- Legge la provincia selezionata da `GameState.state["last_province"]`
- Recupera dati reali da `WorldData`: terreno, popolazione, proprietario, agglomerati
- Usa `terrain_generator.gd` con altezza e tipo terreno coerenti con la provincia
- Illuminazione simile alla battaglia: cielo, DirectionalLight3D, ombre, ambient light, SSAO, senza nebbia
- Agglomerati creati con `settlement_3d.gd` e scala proporzionata al numero di agglomerati
- Strade 3D tra gli agglomerati, senza generare geometria dai poligoni GeoJSON
- HUD con provincia, terreno, popolazione, numero agglomerati e bottone menu
- Pulsante preliminare per costruire un agglomerato con costi verificati: 100 oro, 20 legname, 20 pietra
- Mappa 3D strategica aggiornata: il popup apre ora `province_scene_3d.tscn`
- Menu prova aggiornato: Provincia 3D e Provincia dati 2D restano selezionabili
- **Limite noto**: la posizione iniziale degli agglomerati e' ancora distribuita sul terreno; posizionamento interattivo su costa/fiume/montagna, porti e rete stradale con costi saranno il passaggio successivo
- **Verifica**: scena Provincia 3D avviata senza errori

### 2026-08-22 — Passo 65: Mappa strategica 3D collegata al flusso Provincia
- **Indagine vecchia mappa completata**:
  - `strategic_map.tscn` + `strategic_map.gd` sono la mappa strategica originale
  - Funzioni di riferimento: colori fazione, mare escluso dai click, nebbia, popup, turno, cronaca, ingresso provincia/agglomerato
- **Popup provincia collegato alla mappa 3D**:
  - Click sul terreno -> UV -> provincia reale da Province ID Map
  - Il popup esistente mostra nome, proprietario, regione, terreno, popolazione e risorse
  - Pulsante di ingresso salva `GameState.state["last_province"]` e apre `province_scene.tscn`
- **Correzione risorsa popup**:
  - Percorso aggiornato da `risorse/ui_textures` a `risorse/texture_interfaccia`
- **Stato**:
  - Mappa strategica 3D: flusso selezione/popup completato
  - Mappa provincia 3D con terreno locale e insediamenti: da implementare nel prossimo passaggio
- **Verifica**: mappa 3D avviata senza errori

### 2026-08-22 — Passo 64: Comportamento uniforme di Escape tra tutte le scene
- **Regola applicata**: Escape non chiude il gioco nelle scene aperte dal menu di prova
- Escape ora torna sempre a `res://scenes/prova_egemonia_1000.tscn` in:
  - TestMap
  - Mappa strategica 3D
  - Mappa strategica 2D
  - Provincia
  - Agglomerato urbano 3D
  - Agglomerato urbano
  - Battaglia 3D
  - Reclutamento
  - Rendering edifici e unita'
  - Controller camera riutilizzabile
- Restano riservati alla chiusura del programma:
  - bottone "Esci" del menu di prova
  - bottone di uscita esplicito del menu principale/battaglia
- **Verifica**: 8 scene avviate in modalita' headless; 7 senza errori. `province_scene.tscn` conserva un errore preesistente di risorsa mancante `res://risorse/ui_textures/southern_european/stratpage_01.png`, non collegato a Escape.

### 2026-08-22 — Passo 63: Controlli mappa corretti: Pan con entrambi i tasti, Zoom ottico
- **Spostamento mappa**:
  - Tasto sinistro tenuto premuto: Pan
  - Tasto destro tenuto premuto: Pan
  - Tasto centrale tenuto premuto: Pan
  - Rimossa la rotazione associata al tasto destro
- **Rotellina**:
  - Modifica soltanto il campo visivo della Camera3D (FOV)
  - Non modifica posizione X/Z della mappa
  - Non produce piu' spostamento orizzontale
- **Applicato a**:
  - scripts/ui/test_map.gd
  - scripts/ui/strategic_map_scene_3d.gd
- **Correzione compilazione**: eliminato riferimento residuo a _target_zoom nella TestMap
- **Verifica**: TestMap e mappa strategica avviate senza errori

### 2026-08-22 — Passo 62: Qualita' mappa 4096x2048 e controlli zoom/pan/rotazione
- **Risoluzione heightmap aumentata**:
  - Rigenerata dai 4327 feature GeoJSON
  - 4020 feature terrestri processate, 307 marine escluse
  - Risoluzione passata da 2048x1024 a 4096x2048
  - Copertura terra verificata: 33.79%
- **TestMap aggiornata**:
  - Struttura CameraPivot -> Camera3D
  - Rotella modifica esclusivamente la distanza della camera (zoom)
  - Tasto sinistro/centrale trascinato: Pan
  - Tasto destro trascinato: rotazione orizzontale e Tilt
  - Camera iniziale piu' vicina: distanza 45
  - PlaneMesh con 500x250 suddivisioni
- **Campionamento**: heightmap ora filter_linear per ridurre la pixelatura visiva
- **Verifica**: TestMap avviata senza errori

### 2026-08-22 — Passo 61: ESC dalla mappa torna al menu di prova
- **Corretto il comportamento del tasto Escape in TestMap**:
  - Prima: chiudeva l'applicazione con `get_tree().quit()`
  - Ora: carica `res://scenes/prova_egemonia_1000.tscn`
  - Le scene possono essere provate una dopo l'altra senza riavviare Godot
- La mappa controller aveva gia' il ritorno al menu; ora anche il bypass usa lo stesso comportamento
- **Verifica**: TestMap avviata senza errori

### 2026-08-22 — Passo 60: Ripristino dettagli pixel-perfect, heightmap senza blur
- **Heightmap ripristinata alla maschera netta**:
  - Soglia 128 applicata a heightmap_terra.png
  - Terra = 255, mare = 0
  - Nessun livello grigio e nessun blur
  - Copertura terra verificata: 34.23%
- **Shader pixel-perfect**:
  - heightmap_tex cambiata da filter_linear a filter_nearest
  - repeat_disable mantenuto
  - Rimossi smoothstep e interpolazioni dalla costa
  - Terra sollevata di 0.15, mare a Y=0
- **Obiettivo**: preservare stretti e dettagli di Sicilia, Grecia, Manica e Gibilterra senza fusione dei pixel
- **Verifica**: TestMap avviata senza errori

### 2026-08-22 — Passo 59: Heightmap riaffilata e micro-blur raggio 1
- **Dettagli costieri recuperati**:
  - Heightmap precedente riaffilata con soglia 128 (grigi spinti a bianco/nero)
  - Applicato Gaussian Blur minimo raggio 1
  - Risoluzione invariata 2048x1024
  - Pixel intermedi costieri: 112289
  - Copertura terra: 34.23%
  - Italia, Grecia, Bretagna e stretti conservano piu' dettaglio
- **Shader**:
  - Aggiunto smoothstep solo nella fascia sea_level -> sea_level+0.01
  - Elevazione interna invariata a 0.25
  - Mare invariato a Y=0
- **Verifica**: TestMap avviata senza errori

### 2026-08-22 — Passo 58: Rilievo continentale ridotto a 0.25
- **Altezza del plateau ridotta**:
  - Moltiplicatore shader vertex: 0.8 -> 0.25
  - Le coste mantengono il gradiente gia' creato dal Gaussian Blur raggio 3
  - Le ombre del bordo continentale risultano meno marcate
- **Non applicato ulteriore blur**:
  - La heightmap e' gia' sfumata
  - Un secondo blur cumulativo renderebbe i confini meno precisi
- **Verifica**: TestMap avviata senza errori

### 2026-08-22 — Passo 57: Heightmap sfumata e altezza proporzionale ridotta
- **Heightmap sfumata**:
  - Applicato Gaussian Blur raggio 3 a heightmap_terra.png
  - Risoluzione invariata 2048x1024, scala di grigi
  - Ora presenti tutti i 256 livelli di grigio
  - Pixel intermedi costa: 396482
  - Copertura terra sopra 128: 34.24%
- **Shader**:
  - Rimosso smoothstep dal vertex()
  - Elevazione proporzionale con scala 0.8
  - h <= sea_level resta mare piatto Y=0
  - h > sea_level viene elevato gradualmente
- **Verifica**: TestMap avviata senza errori

### 2026-08-22 — Passo 56: Costa smussata + normali da heightmap per ombre rilievi
- **Coste smussate**: smoothstep solo sui primi 0.02 sopra sea_level
  - costa_factor = smoothstep(sea_level, sea_level + 0.02, h)
  - VERTEX.y += (h - sea_level) * 3.2 * costa_factor
  - Le montagne nell'entroterra mantengono tutta l'altezza
- **Normali da heightmap**: calcolo gradiente nel fragment() per ombre rilievi
  - h_right e h_up letti dalla heightmap
  - normal_map = normalize(vec3((h - h_right) * 10.0, 1.0, (h - h_up) * 10.0))
  - NORMAL mixato con normal_map
- **Verifica**: Godot parte senza errori

### 2026-08-22 — Passo 55: Rifinitura visuale shader - altezza 3.2, colori provincia, specular mare
- **Altezza bilanciata**: height_scale 1.8 -> 3.2 hardcoded nel vertex()
- **Rimosso smoothstep**: le montagne ora si vedono meglio
- **Colori provincia**: fragment() mescola land_base_color con province_id_tex (60% provincia)
- **Mare riflettente**: ROUGHNESS 0.2, SPECULAR 0.5
- **Rimossa uniform height_scale**: non piu' necessaria, valore fisso 3.2 nello shader
- **Verifica**: Godot parte senza errori

### 2026-08-22 — Passo 54: Shader corretto - filter_linear, smoothstep, height_scale 1.8
- **Problema cuspidi verticali risolto**:
  - heightmap_tex: filter_nearest -> filter_linear, repeat_disable
  - height_scale: 8.0 -> 1.8
  - Aggiunto smoothstep nel vertex() per ammorbidire le coste
- **Shader vertex() corretto**:
  - float factor = smoothstep(sea_level, sea_level + 0.05, h)
  - VERTEX.y += (h - sea_level) * height_scale * factor
  - Mare resta piatto a Y=0
- **Verifica**: Godot parte senza errori

### 2026-08-22 — Passo 53: Riattivati rilievi e camera piu' vicina
- **Shader vertex riattivato**:
  - Terra: sollevata in base all'altezza della heightmap
  - Mare: piatto a Y=0
  - height_scale = 8.0
- **Camera TestMap avvicinata**:
  - Posizione iniziale (0, 20, 40) invece di (0, 30, 60)
  - Zoom minimo 5, massimo 300
- **Verifica**: Godot parte senza errori

### 2026-08-22 — Passo 52: Heightmap corretta con GeoJSON filtrato - coste reali
- **Causa mappa tutta verde/arancione**:
  - Il GeoJSON contiene 4327 feature: 3934 province terrestri + 393 feature marine
  - Le feature marine (ocean, sea, bay, gulf, strait, channel, sound, reef, fjord, lagoon) coprivano gli oceani di bianco
  - Risultato: 99.6% terra, tutto verde, niente mare visibile
- **Soluzione**:
  - Script Python: legge GeoJSON originale (47MB)
  - Filtra solo feature con featurecla = "Admin-1 states provinces" o "N/D"
  - Salta 307 feature marine
  - Disegna 4020 poligoni terrestri su sfondo nero
  - Risoluzione 2048x1024 equirettangolare
- **Risultato verificato**:
  - Copertura terra: 34.4% (realistico, Terra reale = 29%)
  - Atlantico centro: mare (valore 0)
  - Pacifico: mare (valore 0)
  - Europa, Brasile, Australia, USA, Siberia, Etiopia, Cile: terra (valore 255)
  - Coste corrispondono ai confini reali delle province
- **File modificato**: risorse/terreno/heightmap_terra.png
- **Verifica**: Godot parte senza errori

### 2026-08-22 — Passo 51: Heightmap reale da GeoJSON con coste reali
- **Problema risolto**: la vecchia heightmap era generata con rumore procedurale, non con geografia reale
- **Nuova heightmap generata da poligoni GeoJSON**:
  - Script Python: legge mappa_3d.json con 4327 province
  - Per ogni provincia: disegna il poligono pieno bianco su immagine nera
  - Risoluzione: 2048x1024 equirettangolare
  - Mare = nero (valore 0), terra = bianco (valore 255)
  - Le coste corrispondono esattamente ai confini reali delle province
- **Risultato**:
  - Copertura terra: 70.1%
  - Valori: min=0 (mare), max=255 (terra)
  - Ora lo shader con sea_level=0.5 mostra:
    - Mare reale (Atlantico, Pacifico, Indiano) in blu
    - Continenti reali in verde
    - Coste riconoscibili
- **File modificato**: risorse/terreno/heightmap_terra.png
- **Verifica**: Godot parte senza errori

### 2026-08-22 — Passo 50: TestMap controllabile, terra verde, mare blu, sea_level 0.5
- **TestMap aggiornata**:
  - Camera piu' vicina (0, 30, 60)
  - Controlli mouse: sinistro Pan, destro Ruota/Tilt, rotellina Zoom
  - ESC per uscire
- **Shader semplificato**:
  - Terra: colore base verde puro, senza mix politico
  - Mare: blu oceano
  - sea_level = 0.5 per far apparire piu' oceano
  - VERTEX.y = 0.0: mappa perfettamente piatta
- **Test**: test_map.tscn parte senza errori

### 2026-08-22 — Passo 49: Test mappa piatta + bypass TestMap + shader piatto
- **Verificata causa colore arancione**:
  - heightmap_terra.png e' in scala di grigi (mode L), valori 90-255
  - 90/255 = 0.35 -> se sea_level = 0.35, tutto e' terra
  - Il minimo e' leggermente sopra 0.35, quindi lo shader non trova mai mare
- **Correzioni shader**:
  - sea_level alzato a 0.4 per far diventare blu i pixel piu' bassi
  - VERTEX.y forzato a 0.0: mappa completamente piatta, niente cuspidi
  - height_scale = 0.0 per disabilitare rilievi in fase di test
- **Verifica generazione mesh**:
  - Cercati ImmediateMesh/ArrayMesh/SurfaceTool nel progetto
  - Unici utilizzi: weapon_mesh, soldier_mesh, horse_mesh, unit_factory, siege_engine, tree_mesh, terrain_generator (battaglia)
  - Nessuno di questi e' collegato alla scena strategic_map_3d
- **TestMap.tscn creata**:
  - scripts/ui/test_map.gd: elimina nodi residui e crea unica PlaneMesh 200x100
  - scenes/test_map.tscn: camera e luce, nient'altro
  - Test obiettivo: verificare che con unica mesh piatta il mare sia blu
- **Menu prova aggiornato** con "Mappa (test bypass)" per avviare TestMap
- **Verifica**: test_map e strategic_map partono senza errori

### 2026-08-22 — Passo 48: Hard reset mappa 3D - PlaneMesh piatta, shader unico, no mesh GeoJSON
- **Hard reset completo della mappa 3D**:
  - scripts/game/terrain_heightmap.gd: unica PlaneMesh 200x100 piatta, 500x250 suddivisioni
  - L'altezza viene applicata SOLO nello shader vertex()
  - scripts/game/map_borders.gd: svuotato, nessuna mesh 3D generata
  - scripts/ui/strategic_map_scene_3d.gd: rimosso oceano separato e bordi 3D
- **Shader terrain_political.gdshader riscritto**:
  - Altezza solo in vertex()
  - h <= sea_level -> mare blu oceano, Y=0
  - h > sea_level -> terra con colore politico dalla province_id_map
  - Niente normali, niente texture confini (per ora)
- **Verifica struttura**:
  - Una sola MeshInstance3D nella scena 3D: il terreno
  - GeoJSON usato solo per dati logici, nessuna mesh visibile
  - Camera3D current = true
- **Verifica**: Godot parte senza errori, Province ID Map caricata

### 2026-08-22 — Passo 47: Hard reset mappa 3D - unica PlaneMesh, mari blu, 126504 vertici
- **Diagnosi problema mare giallo**:
  - L'heightmap minima e' 90/255 = 0.35, uguale al vecchio sea_level
  - Risultato: quasi tutta la superficie veniva trattata come terra (colore giallo/verde)
  - Soluzione: sea_level alzato da 0.35 a 0.4
  - Ora i valori 0.35 vengono correttamente colorati di blu oceano
- **Mappa come unica PlaneMesh**:
  - File: scripts/game/terrain_heightmap.gd
  - Una sola PlaneMesh, nessun poligono GeoJSON estruso sull'asse Y
  - Suddivisioni aumentate a 500x250 (126504 vertici)
  - Dimensione mondo 360x180
  - Altezza massima aumentata a 15.0 per rilievi piu' marcati
- **Mare blu**:
  - PlaneMesh oceano a Y = -0.1
  - Shader terrain_political.gdshader colora di blu oceano (0.1, 0.35, 0.6) dove h < 0.4
  - Nessun overlay politico sull'acqua
- **Camera**:
  - Camera3D figlia di CameraPivot
  - Marcata come current = true
  - Script Pan/Rotazione/Tilt/Zoom su MapController
- **Verifica struttura**:
  - scenes/strategic_map_3d.tscn contiene solo MapController, CameraPivot, Camera3D
  - scripts/game/map_borders.gd crea solo linee sottili a Y+0.01, non estrude poligoni
  - scenes/strategic_map.tscn e' la scena 2D, non 3D, non interferisce
- **Verifica runtime**: Godot parte senza errori, 126504 vertici

### 2026-08-22 — Passo 46: Mappa con HUD, tasto torna al menu e ESC
- **HUD aggiunto alla mappa 3D**:
  - Bottone "Torna al menu" in alto a sinistra
  - Label con istruzioni: Pan, Rotazione/Tilt, Zoom, Click selezione, ESC
- **ESC torna al menu** "Prova di Egemonia 1000" invece di chiudere il gioco
- **File modificato**: scripts/ui/strategic_map_scene_3d.gd
- **Verifica**: Godot parte senza errori

### 2026-08-22 — Passo 45: Mari blu + camera completa (Pan/Rotazione/Tilt/Zoom) + raycast province
- **Mappa 3D aggiornata con controlli completi**:
  - Tasto sinistro/centrale trascinato: Pan
  - Tasto destro trascinato: Rotazione orizzontale e Tilt verticale
  - Rotellina: Zoom fluido (5-200)
  - Click sinistro (non trascinamento): selezione provincia via raycast UV
- **Oceano blu**:
  - PlaneMesh a Y = -0.1 con colore Blu Oceano (0.1, 0.35, 0.6)
  - Materiale lucido per riflettere la luce
- **Shader terrain_political.gdshader corretto**:
  - Zone con h < sea_level: colore blu oceano, senza overlay politico
  - Zone di terra: gradiente verde/marrone/grigio/neve + colore politico + confini
  - Rimosso il "deserto giallo" sull'acqua
- **Raycast per province**:
  - Click sul terreno -> raycast -> coordinate UV
  - Lettura pixel da Province ID Map
  - Lookup nel dizionario province_id_lookup.json
  - Stampa nome provincia e fazione proprietaria
  - Mare rilevato dal colore blu e saltato
- **File creati/modificati**:
  - scripts/ui/map_camera_controller.gd (nuovo script camera)
  - scripts/ui/strategic_map_scene_3d.gd (completo, con oceano e raycast)
  - risorse/shader/terrain_political.gdshader (mari blu)
- **Verifica**: Godot parte senza errori, 65884 vertici, Province ID Map caricata

### 2026-08-22 — Passo 44: Mappa 3D con camera RTS + pannello modifica rendering
- **Mappa 3D rifatta con struttura Pivot/Gimbal**:
  - Nodo radice: MapController
  - Figlio: CameraPivot (inclinazione)
  - Nipote: Camera3D (zoom)
- **Controlli camera mappa 3D**:
  - Tasto sinistro o centrale trascinato: Pan (muove la mappa)
  - Rotellina: Zoom fluido con lerp (10-150)
  - Inclinazione iniziale 45 gradi
  - Limiti bordi mappa configurabili
- **Luce e ambiente mappa**:
  - DirectionalLight3D angolato (-50, -30, 0) con ombre
  - ProceduralSkyMaterial con cielo azzurro pulito
  - Ambient light grigio-azzurro
  - Nebbia lontana
- **Struttura scena**:
  - File: scenes/strategic_map_3d.tscn
  - Script: scripts/ui/strategic_map_scene_3d.gd
  - Rimossa vecchia camera orbitale con drag sinistro/destro
- **Pannello modifica rendering**:
  - File: scenes/render_editor_panel.tscn + scripts/ui/render_editor_panel.gd
  - Per gli edifici: cambia texture tra quelle disponibili
  - Per le unita': cambia colore fazione
  - Per entrambi: cambia scala e rotazione Y
  - Bottoni Applica, Ripristina, Chiudi
  - Si apre automaticamente al click su un oggetto
- **Render view aggiornato**:
  - Gestisce le modifiche dal pannello
  - Ricrea l'unita' con il nuovo colore mantenendo posizione/rotazione/scala
  - Cambia texture dello Sprite3D edificio
- **Verifica**: Godot parte senza errori sia per strategic_map_3d che per render_view

### 2026-08-22 — Passo 43: Render view corretto: disposizione, controlli, selezione
- **Problemi corretti nella scena render_view**:
  - Edifici e unita' sovrapposti -> ora disposti su griglia a due file con distanze adeguate
  - Pixel size edifici ridotto da 0.015 a 0.008 per evitare sovrapposizioni
  - Edifici: 2 file (5+5) distanti tra loro, con etichette sotto ognuno
  - Unita': fila singola a z=3.0 con distanza 4.0 tra loro
  - Pavimento ingrandito a 60x30 per contenere tutta la griglia
- **Tasto "Torna indietro" aggiunto** in alto a sinistra (HUD)
  - Torna alla scena prova_egemonia_1000.tscn
- **Controlli camera interattivi**:
  - Tasto destro trascinato: ruota la camera (orbit)
  - Tasto destro trascinato verticalmente: inclina la camera (pitch)
  - Rotellina: zoom (distanza 6-40)
  - ESC: esci
- **Selezione oggetti con click sinistro**:
  - Raycast dalla telecamera
  - Seleziona edifici (nome "Building_...") e unita' (nome "Unit_...")
  - Mostra scatola wireframe gialla attorno all'oggetto selezionato
  - Info sullo schermo con il nome dell'oggetto
- **HUD con istruzioni**:
  - Pulsante torna indietro
  - Label info selezione
  - Label con istruzioni mouse
- **File modificati**:
  - scripts/ui/render_view.gd (riscritto, 267 righe)
  - scenes/render_view.tscn (aggiornato con CameraPivot)
- **Verifica**: Godot parte senza errori

### 2026-08-22 — Passo 42: Menu prova aggiornato + scena rendering edifici/unita'
- **Eliminati BAT vecchi dal desktop**:
  - Battaglia_Hegemonia1000.bat
  - Avvia_Egemonia_1000.bat
  - Mappa_3D_Egemonia_1000.bat
  - Ora rimane solo "Prova di Egemonia 1000.bat"
- **Menu Prova di Egemonia 1000 aggiornato** con 6 scene:
  - Mappa (strategic_map_3d.tscn)
  - Provincia (province_scene.tscn)
  - Agglomerato urbano (settlement_scene_3d.tscn)
  - Battaglia (battle_view_3d.tscn)
  - Reclutamento (catalog_scene.tscn)
  - Rendering edifici e unita' (render_view.tscn)
- **Scena render_view.tscn creata**:
  - File: scripts/ui/render_view.gd
  - Mostra 10 edifici come billboard 3D con icone PNG
  - Mostra 6 tipi di unita' (spadaccini, lancieri, asceri, arciere, cavalleria, artiglieria)
  - Edifici con etichette sotto
  - Unita' con etichette e animazione di camminata
  - Pavimento griglia, luce solare, cielo blu scuro
  - Tasti ESC per uscire
- **Verifica**: Godot parte senza errori per tutte le scene testate

### 2026-08-22 — Passo 41: BAT "Prova di Egemonia 1000" con accesso a tutte le scene
- **Struttura copiata da Hegemonia Spazio**:
  - @echo off
  - cd /d "percorso_progetto"
  - start "" "percorso_eseguibile" --path . "res://scenes/prova_egemonia_1000.tscn"
- **Scena prova_egemonia_1000.tscn creata**:
  - Control con VBoxContainer e bottoni
  - Un bottone per ogni scena principale:
    - Menu principale
    - Mappa strategica 3D
    - Battaglia 3D
    - Catalogo unita'
    - Provincia
    - Insediamento 3D
    - Mappa provincia 2D
  - Bottone "Esci"
  - Script: scripts/ui/prova_egemonia_1000.gd
- **BAT sul desktop**:
  - "C:\Users\DevinAgent\Desktop\Prova di Egemonia 1000.bat"
  - Apre Godot in console e carica la scena di prova
  - Da li si puo' accedere a tutte le scene tramite i bottoni
- **Verifica**: Godot parte senza errori

### 2026-08-22 — Passo 40: Smussatura coste + interattivita' click mouse
- **Muri verticali sulle coste eliminati**:
  - Prima: salto brusco da y=0 (mare) a (elev-sea_level)*max_height (terra)
  - Ora: zona di transizione di 0.03 intorno al sea_level
  - Mare aperto: y=-0.5 (sotto il livello del mare)
  - Costa: interpolazione morbida con curva smoothstep
  - Terra: altezza con curva quadratica per partenza graduale
- **Interattivita' click mouse implementata**:
  - Collision shape: ConcavePolygonShape3D dalla mesh del terreno
  - Raycast del mouse sulla mesh 3D
  - Coordinate UV del punto di impatto
  - Lettura colore dalla Province ID Map
  - Lookup nel dizionario province_id_lookup.json
  - Identificazione istantanea della provincia cliccata
  - Visualizzazione nome provincia e fazione proprietaria su HUD
- **HUD aggiunto**:
  - CanvasLayer con Label in alto a sinistra
  - Mostra provincia selezionata e fazione proprietaria
  - Messaggio "Mare o zona non selezionabile" se si clicca sul mare
- **Differenziazione click vs trascinamento**:
  - Click singolo (senza trascinamento): seleziona provincia
  - Trascinamento con tasto sinistro: inclina la mappa
- **File modificati**:
  - scripts/game/terrain_heightmap.gd (smussatura + collision + pick)
  - scripts/ui/strategic_map_scene_3d.gd (HUD + click handler)
- **Verifica**: Godot parte senza errori, 65884 vertici, collision attiva

### 2026-08-22 — Passo 39: Mouse/zoom corretti + shader politico con colori nazioni
- **Controlli mouse corretti**:
  - Tasto sinistro trascinato: inclina la mappa (pitch verticale)
  - Tasto destro trascinato: ruota la mappa (yaw orizzontale)
  - Rotellina: zoom (cambia FOV 20-90, non sposta la telecamera)
  - Spazio: rotazione automatica
  - ESC: esci
- **Province ID Map generata** (province_id_map.png, 120 KB):
  - Ogni provincia ha un colore RGB unico basato sull'indice
  - Usata per il picking del mouse (raycast -> UV -> colore -> provincia)
  - Dizionario lookup: province_id_lookup.json (91 KB)
- **Political Map generata** (political_map.png, 60 KB):
  - Ogni provincia colorata con il colore della fazione proprietaria
  - 158 fazioni con colori generati con golden angle HSL (massima separazione)
  - Province senza proprietario: grigio neutro
  - Colori fazioni salvati in faction_colors.json
- **Borders texture generata** (borders_texture.png, 83 KB):
  - Linee scure sui perimetri dei poligoni GeoJSON
  - Segmenti che attraversano il cambio data saltati
- **Shader terrain_political.gdshader** creato:
  - Vertex: sposta vertici in base all'altezza (heightmap)
  - Fragment: fonde colore fisico terreno + colore politico nazione
  - Colore fisico variabile per altezza:
    - Mare: blu
    - Pianure: verde
    - Colline: marrone chiaro
    - Montagne: grigio marrone
    - Neve: bianco (sopra snow_line)
  - political_opacity = 0.55 (semitrasparenza colore nazione)
  - Confini: linee scure sopra tutto
- **terrain_heightmap.gd aggiornato**:
  - Carica heightmap + political_map + borders_texture
  - Applica shader con tutte le texture
  - Funzione get_province_at_uv() per picking mouse
- **File creati/modificati**:
  - risorse/terreno/province_id_map.png (nuovo)
  - risorse/terreno/political_map.png (nuovo)
  - risorse/terreno/borders_texture.png (nuovo)
  - risorse/shader/terrain_political.gdshader (nuovo)
  - dati/world/province_id_lookup.json (nuovo)
  - dati/world/faction_colors.json (nuovo)
  - scripts/game/terrain_heightmap.gd (aggiornato con shader)
  - scripts/ui/strategic_map_scene_3d.gd (mouse/zoom corretti)
- **Verifica**: Godot parte senza errori, 65884 vertici, shader applicato

### 2026-08-22 — Passo 38: Mappa 3D corretta con heightmap DEM (non estrusione poligoni)
- **ERRORE CORRETTO**: la versione precedente estrudeva i poligoni GeoJSON
  sull'asse Y creando "grattacieli" di cemento. Era completamente sbagliato.
- **Approccio corretto applicato**:
  1. Heightmap DEM grayscale (2048x1024, proiezione equirettangolare 2:1)
  2. PlaneMesh con 360x180 suddivisioni, vertici spostati in base all'altezza
  3. Confini GeoJSON proiettati come linee piatte a quota Y+0.01 (non estruse)
  4. Longitudini clampate tra -180 e +180 per evitare artefatti cambio data
- **Heightmap generata proceduralmente** con Python:
  - Maschera terra/mare dai poligoni GeoJSON reali (4327 province)
  - Altezze base per tipo di terreno: mountains=235, snow=210, hills=185, forest=155, plains=145, desert=150, coastal=135, marsh=132
  - Rumore Perlin frattale per dettagli rilievi (4 ottave bassa freq + 3 ottave alta freq)
  - Mare a valore 90 (sotto livello del mare)
  - File: risorse/terreno/heightmap_terra.png (0.3 MB)
- **Generatore terreno** (terrain_heightmap.gd):
  - Carica heightmap con Image.load_from_file
  - PlaneMesh 360x180 unita', 360x180 suddivisioni = 65884 vertici
  - Sposta Y di ogni vertice in base al valore grigio della heightmap
  - Ricalcola normali con SurfaceTool.generate_normals()
  - sea_level = 0.35 (soglia terra/mare)
  - max_height = 12 unita' Godot
- **Generatore confini** (map_borders.gd):
  - Legge mappa_3d.json (poligoni semplificati)
  - Per ogni segmento del perimetro crea un rettangolo sottile (0.03 unita')
  - Linee piatte a quota Y+0.05 sopra il terreno
  - Salta segmenti che attraversano la linea del cambio data (>180 gradi)
  - 8274 confini generati
  - Material con no_depth_test per visibilita' sempre sopra
- **Scena** (strategic_map_3d.tscn):
  - Terrain (MeshInstance3D con terrain_heightmap.gd)
  - Borders (Node3D con map_borders.gd)
  - CameraPivot con Camera3D orbitale
  - Oceano: piano blu semitrasparente sotto il terreno
  - Cielo procedurale + nebbia + sole con ombre
- **Vecchio script eliminato**: scripts/game/strategic_map_3d.gd (estrusione poligoni)
- **File creati/modificati**:
  - risorse/terreno/heightmap_terra.png (nuovo, 0.3 MB)
  - scripts/game/terrain_heightmap.gd (nuovo, 86 righe)
  - scripts/game/map_borders.gd (nuovo, 97 righe)
  - scripts/ui/strategic_map_scene_3d.gd (riscritto, 101 righe)
  - scenes/strategic_map_3d.tscn (riscritto, 18 righe)
- **Verifica**: Godot parte senza errori, 65884 vertici, 8274 confini

### 2026-08-21 — Passo 37: Mappa strategica 3D da dati GeoJSON realali
- **Dati GeoJSON verificati**:
  - 4327 province (3684 poligoni + 643 multi-poligoni)
  - Coordinate 2D (lon, lat), nessuna elevazione incorporata
  - Estensione: lat [-83, +79], lon [-179, +180] (tutto il mondo)
  - 8 tipi di terreno: plains(1200), forest(852), marsh(699), hills(640), snow(331), mountains(241), coastal(198), desert(166)
- **Pre-elaborazione Python**:
  - GeoJSON 45 MB -> mappa_3d.json 6.1 MB (poligoni ridotti a 40 punti)
  - Colori e altezze calcolati per tipo di terreno
  - Script temporaneo eliminato dopo l'uso
- **Generatore mappa 3D** (strategic_map_3d.gd):
  - Proiezione equirettangolare: lon -> X, lat -> Z
  - Ogni provincia e' una mesh estrusa con altezza basata sul terreno
  - Colori per tipo: verde(forest), marrone(hills), grigio(mountains), giallo(desert), bianco(snow)
  - Altezze: mountains=8m, hills=3m, snow=4m, forest=1m, plains=0.5m, desert=0.3m
  - Confini delle province come linee 3D scure
  - Facciate laterali per dare volume alle elevazioni
- **Scena mappa 3D** (strategic_map_3d.tscn):
  - Telecamera orbitale con rotazione automatica opzionale
  - Cielo procedurale con nebbia atmosferica
  - Luce direzionale (sole) con ombre
  - Comandi: frecce per ruotare, su/giu per altezza, rotellina per zoom, spazio per rotazione
- **BAT sul desktop**:
  - Mappa_3D_Egemonia_1000.bat: avvia direttamente la mappa 3D
  - Avvia_Egemonia_1000.bat: avvia il gioco completo dal menu
- **File creati**:
  - dati/world/mappa_3d.json (6.1 MB, poligoni semplificati)
  - scripts/game/strategic_map_3d.gd (204 righe, generatore terreno)
  - scripts/ui/strategic_map_scene_3d.gd (88 righe, scena con telecamera)
  - scenes/strategic_map_3d.tscn (14 righe)
  - Mappa_3D_Egemonia_1000.bat (desktop)
- **Verifica**: Godot costruisce tutte le 4327 province senza errori

### 2026-08-21 — Passo 36: Orientamento, frecce, animazione, carica, morti
- **Orientamento soldato corretto**:
  - Davanti del soldato = -Z (standard Godot)
  - Piedi: offset z=+0.08 -> z=-0.08 (puntano in avanti -Z)
  - Formula orientamento: atan2(-dir.x, -dir.z) allinea -Z alla direzione
  - face_direction scena: attaccanti -PI/2 (guardano +X), difensori +PI/2 (guardano -X)
  - Definite le 6 direzioni: davanti=-Z, dietro=+Z, destra=+X, sinistra=-X, alto=+Y, basso=-Y
- **Frecce migliorate**:
  - Asta: cilindro raggio 0.015 (era 0.008), 6 segmenti (era 3)
  - Punta: cono piu' grande (raggio 0.04, altezza 0.10)
  - Impennatura: 3 alette alla base (piume)
  - Ora le frecce sono visibili e non sembrano palle di cannone
- **Movimenti piu' fluidi** (ampiezze ridotte):
  - Anche: 0.40 -> 0.25
  - Cosce: 0.30 -> 0.20
  - Ginocchia: 0.50 -> 0.35
  - Braccia: 0.30 -> 0.20
  - Gomiti: 0.30 -> 0.20
  - Busto: 0.04 -> 0.02
  - Bobbing: 0.03 -> 0.02
- **Carica a velocita' maggiore**:
  - Marcia: 1.5 m/s (lenta e ritmata)
  - Carica: 5.0 m/s (era 3.0, ora e' una vera corsa)
  - Ritirata: 2.0 m/s
- **Morti: caduta e disgiunzione**:
  - Array _dead aggiunto per tracciare i soldati morti
  - take_damage: il soldato cade a terra (rotazione.z = PI/2)
  - Il soldato morto non riceve piu' ordini di movimento
  - Resta a terra nella posizione dove e' caduto
  - Animazione fermata
  - Disgiunto dalla formazione (salto nel _process)
- **File modificati**:
  - scripts/game/soldier_skeleton.gd (piedi -Z)
  - scripts/game/formation_manager_3d.gd (orientamento, morti, _dead)
  - scripts/game/soldier_animation.gd (ampiezze ridotte)
  - scripts/game/weapon_mesh.gd (frecce migliorate)
  - scripts/ui/battle_view_3d.gd (carica 5.0 m/s)
  - scenes/battle_view_3d.tscn (face_direction corretti)
- **Verifica**: Godot parte senza errori

### 2026-08-21 — Passo 35: Scheletro cavallo completato con osso Coda
- **Principio applicato**: lo scheletro e' fondamentale, ogni parte mobile
  deve avere un osso di incernieratura con genitore ben definito
- **Osso Coda aggiunto**: figlio del Bacino, incernierato sul posteriore
  - Prima la coda era solo una mesh attaccata al Bacino (non animabile)
  - Ora ha un osso proprio con mesh attaccata tramite BoneAttachment3D
  - Animazione coda: oscillazione laterale (asse Y) durante il movimento
- **Gerarchia scheletro cavallo verificata** (21 ossi):
  - Bacino (radice, posteriore)
    - Dorso (colonna vertebrale)
      - Collo -> Testa (incernierati in avanti)
      - SpallaAntSx -> CosciaAntSx -> GambaAntSx -> ZoccoloAntSx
      - SpallaAntDx -> CosciaAntDx -> GambaAntDx -> ZoccoloAntDx
    - Coda (incernierata dietro, oscillante)
    - AncaPostSx -> CosciaPostSx -> GambaPostSx -> ZoccoloPostSx
    - AncaPostDx -> CosciaPostDx -> GambaPostDx -> ZoccoloPostDx
- **File modificati**:
  - scripts/game/horse_mesh.gd (osso Coda aggiunto, mesh spostata)
  - scripts/game/horse_animation.gd (animazione coda aggiunta)
- **Verifica**: Godot parte senza errori

### 2026-08-21 — Passo 34: Correzione movimento, orientamento, animazione, cavallo
- **Velocita' di movimento ridotta**: 8.0 -> 1.5 m/s (marcia realistica)
- **Marcia all'indietro corretta**:
  - Il soldato ora si orienta verso la direzione di movimento con atan2(dir.x, dir.z)
  - Quando fermo, guarda la direzione della formazione (_face_direction)
  - Valori face_direction corretti nella scena: attaccanti +PI/2, difensori -PI/2
- **Artiglieria animata**: i serventi ora hanno animazione di camminata
  (prima erano esclusi con "if unit_type != artiglieria")
- **Passi sincronizzati con velocita'**:
  - soldier_animation: frequenza = velocita' / 0.7m (lunghezza passo)
  - horse_animation: frequenza = velocita' / 1.5m (lunghezza falcata)
  - Aggiunto set_speed() a entrambe le animazioni
- **Testa del cavallo corretta**:
  - Collo allungato: offset z=-0.5 (era -0.4), altezza +0.25 (era +0.15)
  - Testa spostata in avanti: offset z=-0.45 (era -0.3)
  - Mesh collo allungata: z=0.50 (era 0.35)
  - Mesh testa piu' piccola e spostata: z=-0.25 (era -0.20)
  - Orecchie riposizionate
- **Proiettili corretti**: look_at() con controllo distanza > 0.01m
- **File modificati**:
  - scripts/game/formation_manager_3d.gd (velocita', orientamento, artiglieria)
  - scripts/game/soldier_animation.gd (sincronizzazione passi)
  - scripts/game/horse_animation.gd (sincronizzazione falcate)
  - scripts/game/horse_mesh.gd (collo e testa allungati)
  - scripts/game/projectile_system.gd (controllo look_at)
  - scenes/battle_view_3d.tscn (face_direction corretti)
- **Verifica**: Godot parte senza errori

### 2026-08-21 — Passo 33: Stato iniziale popolato, scena insediamento 3D
- **Documentazione corretta**:
  - Province: 529 -> 4327 (verificato da file JSON)
  - Fazioni: 28 -> 158 (verificato da file JSON)
  - Stato iniziale: era vuoto (factions e provinces = {})
  - Scene: 11 -> 20, script: 20 -> 32
  - Aggiornato README.md, AGENTS.md
- **Stato iniziale popolato**:
  - 158 fazioni con capitale, oro, cibo, province
  - 4327 province con proprietario, terreno, popolazione, risorse, insediamenti
  - 3917 insediamenti con edifici e livelli
  - 157 fazioni con almeno una provincia
  - Script Python temporaneo usato e poi eliminato
- **Scena insediamento 3D creata**:
  - scripts/game/settlement_3d.gd (generatore insediamento 3D)
  - scripts/ui/settlement_scene_3d.gd (scena con telecamera orbitale)
  - scenes/settlement_scene_3d.tscn (scena Godot)
  - Terreno base 60x60 metri
  - Palizzata di legno (40 tronchi, anno 1000) o mura di pietra (con torri)
  - Porta d'ingresso con pilastri
  - Edifici come billboard (icone 256x256 esistenti)
  - 15 alberi decorativi con tronco e chioma
  - Fuoco da campo con luce dinamica
  - Cielo procedurale con nebbia atmosferica
  - Telecamera orbitale con rotazione automatica
  - Comandi: frecce per ruotare, su/giu per altezza, rotellina per zoom
  - Spazio per attivare/disattivare rotazione automatica
- **File creati**:
  - scripts/game/settlement_3d.gd (251 righe)
  - scripts/ui/settlement_scene_3d.gd (95 righe)
  - scenes/settlement_scene_3d.tscn (23 righe)
- **Verifica**: Godot parte senza errori

### 2026-08-21 — Passo 32: Cartelle in italiano, riferimenti storici anno 1000
- **Cartelle rinominate in italiano**:
  - docs → documenti
  - tools → strumenti
  - tests → test
  - assets → risorse
  - data → dati
- **Sottocartelle rinominate**:
  - risorse/textures/rocks → risorse/textures/rocce
  - risorse/textures/terrain → risorse/textures/terreno
  - risorse/textures/trees → risorse/textures/alberi
  - risorse/ui_textures → risorse/texture_interfaccia
  - risorse/backgrounds → risorse/sfondi
  - risorse/icons → risorse/icone
- **File texture rinominati in italiano**:
  - rock_color.png → roccia_colore.png
  - rock_normal.png → roccia_normale.png
  - rock_ao.png → roccia_ao.png
  - stone_color.png → pietra_colore.png
  - stone_normal.png → pietra_normale.png
  - stone_ao.png → pietra_ao.png
  - stone_beach.png → pietra_spiaggia.png
  - ground_color.png → terreno_colore.png
  - ground_normal.png → terreno_normale.png
  - ground_roughness.png → terreno_rugosita.png
  - grass.jpg → erba.jpg
  - gravel.jpg → ghiaia.jpg
  - gravel_color.png → ghiaia_colore.png
  - gravel_normal.png → ghiaia_normale.png
  - gravel_roughness.png → ghiaia_rugosita.png
  - ground.jpg → terreno.jpg
- **Riferimenti aggiornati**:
  - 8 file .gd (ai_controller, icon_manager, world_data, terrain_generator, texture_loader, battle_view, province_scene, province_view)
  - 2 file .tscn (province_popup, province_scene)
  - 1 file .tscn (test/test_runner)
  - 6 file .md (README, AGENTS, 01-04 documenti)
  - 0 riferimenti residui a percorsi inglesi
- **Riferimenti storici creati**:
  - documenti/09_RIFERIMENTI_STORICI.md
  - Contiene: castelli motta-recinto, armi, armature, abiti, interfacce
  - Cartelle per immagini: risorse/riferimenti/castelli, armi, armature, abiti, interfacce
- **Verifica**: Godot parte senza errori dopo tutti i rename

### 2026-08-21 — Passo 31: Correzione controllo tattico (menu, velocita', click)
- **Menu dappertutto**:
  - Causa: _input() intercettava tutti i click, anche sui pulsanti
  - Correzione: sostituito con _unhandled_input() (ignora click su UI)
  - Raggio selezione ridotto da 15m a 8m
  - Distanza calcolata in 2D (solo x, z), ignora l'altezza
  - Se nessuna formazione trovata, chiude il menu e mostra messaggio
- **Soldati fermi anche con ordine**:
  - Causa: velocita' 2.0 m/s, 40 metri = 20 secondi (sembra fermo)
  - Correzione: velocita' base aumentata da 2.0 a 8.0 m/s
  - set_speed() ora usa 8.0 * moltiplicatore (prima era 2.0)
  - 40 metri a 8 m/s = 5 secondi (visibile)
- **PopupPanel bloccava click destro**:
  - Causa: PopupPanel intercetta gli input quando e' aperto
  - Correzione: sostituito con Panel fisso in basso a destra
  - Il pannello non intercetta i click sulla mappa
  - Click destro chiude il menu prima di muovere la formazione
- **File modificati**:
  - scripts/ui/battle_view_3d.gd (_unhandled_input, Panel fisso, chiude menu)
  - scripts/game/formation_manager_3d.gd (velocita' 8.0 m/s)

### 2026-08-21 — Passo 30: Controllo tattico, menu formazione, no auto-avanzamento
- **Rimosso auto-avanzamento**:
  - _on_play() non muove piu' le formazioni verso il centro
  - _on_fast() non muove piu' le formazioni verso il centro
  - Le formazioni restano ferme nelle posizioni della scena
  - Il giocatore decide quando e dove muoverle
- **Menu contestuale** (click sinistro su formazione):
  - PopupPanel con opzioni di formazione e comportamento
  - Formazioni: Linea, Quadrato, Cuneo, Colonna
  - Comportamenti: Fermo, Avanza, Carica, Ritirata
  - Il menu appare alla posizione del mouse
- **Click destro muove formazione**:
  - Click destro sulla mappa muove la formazione selezionata
  - Usa move_formation() con le coordinate globali del click
  - Le unita' seguono l'altezza del terreno durante il movimento
- **Comportamenti**:
  - Fermo: mette in pausa la formazione
  - Avanza: sblocca a velocita' normale
  - Carica: velocita' x3 + formazione a cuneo
  - Ritirata: velocita' x2 + inverte direzione (180 gradi)
- **Selezione formazione**:
  - Click sinistro seleziona la formazione piu' vicina (raggio 15m)
  - Mostra il nome della formazione nell'etichetta
  - Nomi: AttSpadaccini, AttLancieri, ecc.
- **File modificato**:
  - scripts/ui/battle_view_3d.gd (menu, click destro, no auto-avanzamento)

### 2026-08-21 — Passo 29: Cavallo riposizionato, cosce soldato, orientamento
- **Cavallo riposizionato** (horse_mesh.gd):
  - Bacino al posteriore (z=+0.3), non al centro
  - Dorso al centro (z=-0.5)
  - Corpo da z=+0.3 a z=-1.3 (1.6m lungo)
  - Zampe anteriori a z=-1.0 (sotto il davanti del corpo)
  - Zampe posteriori a z=+0.3 (sotto il posteriore)
  - Testa a z=-1.4 (davanti al corpo, muso 0.50m lungo)
  - Collo a z=-0.9 (collega corpo e testa)
  - Coda a z=+0.6 (dietro)
  - Sella a z=-0.5 (centro del dorso)
- **Cosce soldato attaccate** (soldier_skeleton.gd):
  - Causa: osso AncaSx a y=0.85, CosciaSx a y=0.45 (gap 0.40m)
  - Correzione: CosciaSx offset ridotto da -0.40 a -0.05
  - Ora coscia parte da y=0.80 (subito sotto l'anca)
  - Mesh coscia copre da y=0.40 a y=0.80 (attaccata al bacino)
  - GambaSx offset da -0.35 a -0.40 (ginocchio piu' basso)
  - PiedeSx offset da -0.05 a -0.35 (piede a terra)
- **Cavaliere sulla sella** (unit_factory.gd):
  - RiderOffset z da 0 a -0.5 (sella e' a z=-0.5)
  - Prima il cavaliere era sul posteriore del cavallo
- **Orientamento soldati** (formation_manager_3d.gd):
  - Causa: rotation.y impostata solo in _process() durante movimento
  - La battaglia inizia in pausa, quindi i soldati non venivano ruotati
  - Correzione: unit.rotation.y = _face_direction in _setup_formation()
  - Ora i soldati guardano il nemico fin dall'inizio
- **File modificati**:
  - scripts/game/horse_mesh.gd (riscritto, posizioni calcolate)
  - scripts/game/soldier_skeleton.gd (cosce attaccate, gambe accorciate)
  - scripts/game/unit_factory.gd (cavaliere z=-0.5)
  - scripts/game/formation_manager_3d.gd (rotazione iniziale)

### 2026-08-21 — Passo 28: Scheletro soldato ridefinito, cavallo e cavaliere corretti
- **Scheletro soldato ridefinito** (soldier_skeleton.gd):
  - Bacino abbassato da y=1.0 a y=0.90 (piedi a terra)
  - Testa alzata da offset 0.25 a 0.35 (non piu' dentro il busto)
  - Gamba accorciata da 0.40 a 0.35 (stinchi non piu' sottoterra)
  - Aggiunta mesh Bacino: scatola 0.42x0.25x0.28 (riempie il vuoto)
  - Busto accorciato da 0.35 a 0.30 (non copre la testa)
  - Testa rimpicciolita da r=0.18 a r=0.15 (proporzionata)
  - Stinchi accorciati da 0.40 a 0.30 (non affondano)
  - Piedi rimpiccioliti (0.10x0.05x0.20)
- **Cavallo riscritto** (horse_mesh.gd):
  - Testa GRANDE: 0.25x0.35x0.60 (muso lungo visibile)
  - Collo CORTO: 0.20x0.40x0.30 (non copre la testa)
  - Corpo: 0.45x0.50x1.60
  - Zampe sotto il corpo (non in avanti)
  - Sella e staffe ai lati
- **Cavaliere corretto** (unit_factory.gd):
  - RiderOffset alzato da 0.82 a 0.93 (sopra la sella, non dentro)
  - Bacino cavaliere a y=1.83 (sella a 1.83)
  - Cosce orizzontali asse X 80 gradi (sul dorso)
  - Stinchi pendenti asse X -80 gradi (lungo i fianchi)
- **File modificati**:
  - scripts/game/soldier_skeleton.gd (scheletro + mesh ridefiniti)
  - scripts/game/horse_mesh.gd (riscritto, 168 righe)
  - scripts/game/unit_factory.gd (RiderOffset corretto)

### 2026-08-20 — Passo 27: Correzione cavaliere altezza e gambe laterali
- **Problema cavaliere su trampolino**:
  - Causa: RiderOffset a y=1.85 + bacino soldato a y=1.0 = 2.85 globale
  - La sella del cavallo e' a ~1.82, il cavaliere fluttuava a 1 metro sopra
  - Correzione: RiderOffset abbassato a y=0.82 (1.82 - 1.0 = 0.82)
  - Ora il bacino del cavaliere e' a 1.82, all'altezza della sella
- **Problema gambe accovacciate invece di penzoloni**:
  - Causa: rotazione cosce sull'asse X (flessione avanti/indietro)
  - Le cosce si piegavano in avanti verso il collo del cavallo
  - Correzione: rotazione sull'asse Z (abduzione laterale)
  - Coscia sx: +75 gradi asse Z (apre a sinistra)
  - Coscia dx: -75 gradi asse Z (apre a destra)
  - Stinchi: tornano verticali con rotazione opposta asse Z
  - Ora le gambe penzolano ai lati del cavallo
- **Problema apply_rider_pose non applicata**:
  - Causa: chiamata prima che il nodo fosse nell'albero della scena
  - Correzione: spostata nel formation_manager dopo add_child(unit)
- **Collo del cavallo**: sostituito cilindro ruotato con scatola inclinata
  (piu' visibile, meno probabilita' di scomparire)
- **Verifica**: test conferma rotazioni corrette (CosciaSx 75 gradi asse Z)
- **File modificati**:
  - scripts/game/unit_factory.gd (RiderOffset abbassato a 0.82)
  - scripts/game/soldier_skeleton.gd (apply_rider_pose asse Z)
  - scripts/game/formation_manager_3d.gd (apply_rider_pose dopo add_child)
  - scripts/game/horse_mesh.gd (collo a scatola inclinata)

### 2026-08-20 — Passo 26: Terreno solido, cavallo corretto, cavaliere gambe penzoloni
- **Terreno solido** (principio fondamentale):
  - Le unita' seguono l'altezza del terreno, non affondano
  - formation_manager_3d.gd legge get_height_at(x,z) dal terrain
  - Durante il movimento, la Y viene aggiornata ad ogni frame
  - Riferimento al terrain passato dal battle_view_3d con set_terrain()
  - Allineamento iniziale con call_deferred("_align_to_terrain")
- **Cavallo riscritto** (horse_mesh.gd):
  - Testa chiaramente staccata in avanti (muso 0.55m lungo)
  - Collo inclinato 45 gradi verso l'alto/avanti (cilindro ruotato)
  - Corpo 1.8m lunghezza, 0.55m altezza, 0.5m larghezza
  - Zampe sotto il corpo, scendono verticali
  - Aggiunte orecchie sulla testa
  - Staffe ai lati della sella (per i piedi del cavaliere)
  - Sella con pomolo e cantle
- **Cavaliere corretto** (unit_factory.gd + soldier_skeleton.gd):
  - Posizione seduta a y=1.85 (sopra la sella)
  - Funzione statica apply_rider_pose() applica:
    - Cosce orizzontali (85 gradi, lungo il dorso del cavallo)
    - Stinchi pendenti verticali (-85 gradi, lungo i fianchi)
  - Gambe penzoloni ai lati del cavallo, non appoggiate sopra
  - Piedi verso le staffe
- **Arcieri e artiglieria fermi**:
  - Aggiunto flag auto_advance (default true)
  - Arcieri e artiglieria: auto_advance = false
  - Non avanzano automaticamente verso il centro
  - Il giocatore li posiziona con click
- **Onagro alzato** (siege_engine.gd):
  - Base alzata a y=0.5 (era 0.4) per evitare z-fighting
  - Tutte le parti rialzate di 0.1m
- **File modificati**:
  - scripts/game/formation_manager_3d.gd (terreno solido, auto_advance)
  - scripts/game/horse_mesh.gd (riscritto, 193 righe)
  - scripts/game/unit_factory.gd (cavaliere, apply_rider_pose)
  - scripts/game/soldier_skeleton.gd (apply_rider_pose statica)
  - scripts/game/siege_engine.gd (onagro alzato)
  - scripts/ui/battle_view_3d.gd (set_terrain alle formazioni)

### 2026-08-20 — Passo 25: Cavallo proporzioni, cavaliere gambe penzoloni, onagro ingrandito
- **Cavallo riscritto** (horse_mesh.gd):
  - Bacino al centro del corpo a y=1.5 (altezza garrese)
  - Dorso va in avanti (-Z) dal bacino, non piu' arretrato
  - Testa allineata con il corpo (non piu' arretrata)
  - Zampe attaccate al dorso/bacino e scendono verticali
  - Aggiunte orecchie sulla testa
  - Aggiunte staffe ai lati della sella (per i piedi del cavaliere)
  - Sella piu' grande (0.4 x 0.15 x 0.7m)
  - Cosce zampe piu' spesse (0.10), stinchi 0.07
- **Cavaliere corretto** (unit_factory.gd):
  - Posizione seduta a y=1.9 (sopra la sella a y=1.85)
  - Cosce orizzontali (85 gradi) lungo il dorso del cavallo
  - Stinchi pendenti verticali (-85 gradi) lungo i fianchi
  - Gambe penzoloni ai lati del cavallo, non appoggiate sopra
  - I piedi vanno nelle staffe
- **Onagro ingrandito** (siege_engine.gd):
  - Dimensioni storiche: 2.5m lungo, 1.5m largo, 1.5m alto
  - Telaio massiccio 2.5 x 0.8 x 1.5m (era 1.8 x 0.6 x 1.5)
  - 4 montanti verticali angolari (rinforzo)
  - Ruote grandi diametro 0.7m (era 0.5m)
  - Braccio 2.5m lungo (era 2.0m), sezione 0.25m
  - Cucchiaio piu' grande (raggio 0.25, era 0.15)
  - Torsione piu' grande (0.15 raggio, 0.8m alta)
  - Aggiunto contrappeso di pietra sul retro
  - Serventi piu' distanti (3.5m, era 1.5m)
  - Fonti: Wikipedia (onager 2-6 tonnellate), Museo Galileo
    (163x355x118cm), Universitaet Erlangen (2.5x1.5x1.5m)
- **File modificati**:
  - scripts/game/horse_mesh.gd (riscritto, 190 righe)
  - scripts/game/unit_factory.gd (cavaliere gambe penzoloni)
  - scripts/game/siege_engine.gd (onagro ingrandito, serventi distanti)

### 2026-08-20 — Passo 24: Correzione scheletri (soldati, cavalli, artiglieria)
- **Problema principale**: soldier_skeleton.gd chiamava
  `set_bone_rest` ma NON `set_bone_pose`. In Godot 4 il
  BoneAttachment3D segue la **pose**, non la **rest**. Senza
  pose, tutte le parti del corpo collassavano al centro dello
  scheletro (origine 0,0,0).
- **Sintomi**:
  - Soldati senza testa, senza braccia, con una sola gamba
  - Cavalieri con corpo compresso in un punto
  - Serventi artiglieria con solo busto che oscillava
  - Piedi all'incontrato e affondanti nel terreno
- **Correzione**: aggiunto `set_bone_pose` dopo `set_bone_rest`
  per ogni osso nel soldier_skeleton.gd
- **Verifica**: test dedicato conferma 20 ossa con pose corretta
  per soldato, cavallo e serventi
- **File modificato**:
  - scripts/game/soldier_skeleton.gd (aggiunto set_bone_pose)

### 2026-08-20 — Passo 23: Illuminazione PBR e Post-Processing cinematografico
- **DirectionalLight3D (Sole)**:
  - Rotazione: X=-35 gradi, Y=45 gradi (luce angolata drammatica)
  - Colore: bianco/giallo solare caldo (RGB 255,244,214)
  - Energia: 2.5 (da 2.0)
  - Shadow mode: PSSM 4 Splits (da Orthogonal)
  - Shadow bias: 0.02 (da 0.05, ombre piu' nette)
  - Shadow blend splits attivato
  - Distanza ombre: 200m (da 150m)
- **WorldEnvironment (Post-Processing)**:
  - Tonemap: ACES (mode 3, da Filmic mode 2)
  - Tonemap white: 1.0
  - SSAO intensity: 2.0 (da 3.0, micro-ombre sotto soldati)
  - Glow intensity: 0.8 (da 0.6), strength 0.9 (da 0.8)
  - Glow normalized: true (nuovo)
  - Ambient light energy: 0.6 (da 0.4, piu' rimbalzo luce)
  - Ambient light color: piu' neutro (0.6, 0.7, 0.8)
- **Materiali PBR (texture_loader.gd)**:
  - Terreno: roughness map come texture (canale green)
    + roughness 0.8 (erba opaca, da 0.95)
  - Rocce: AO map come roughness texture (canale red)
    + roughness 0.7 (semi-lucido, da 0.85)
  - Pietra castello: AO map come roughness texture
    + roughness 0.7 (da 0.8)
  - Normal map gia' presenti per terreno, rocce e pietra
- **Scene aggiornate**: tutte le 8 scene (plains + 7 scenari)
  con stessa configurazione luce e environment
- **File modificati**:
  - scenes/battle_view_3d.tscn (luce, environment)
  - scenes/battle_hills.tscn, battle_mountains.tscn, battle_forest.tscn,
    battle_desert.tscn, battle_coastal.tscn, battle_snow.tscn,
    battle_marsh.tscn (stesse modifiche)
  - scripts/game/texture_loader.gd (roughness map, valori PBR)

### 2026-08-20 — Passo 22: Diversificazione terrain delle province
- **Problema**: tutte le 4327 province avevano terrain="plains"
- **Soluzione**: script Python che assegna il terrain in base a
  latitudine/longitudine della provincia
- **Distribuzione risultante**:
  - plains: 1200 (28%)
  - forest: 852 (20%)
  - marsh: 699 (16%)
  - hills: 640 (15%)
  - snow: 331 (8%)
  - mountains: 241 (6%)
  - coastal: 198 (5%)
  - desert: 166 (4%)
- **Logica geografica**:
  - lat > 55: snow (nord Europa, Russia, Siberia)
  - lat 45-55, long -10 to 40: forest o hills (Europa centrale)
  - lat 30-45, long -10 to 40: hills o coastal (Mediterraneo)
  - lat 15-35, long -10 to 50: desert (Nord Africa, Medio Oriente)
  - lat 30-55, long 70-120: mountains o plains (Asia centrale)
  - lat -10 to 30, long 90-140: forest o marsh (Asia sud-est)
  - Americhe: snow/forest/hills/mountains in base a latitudine
  - Africa subsahariana: plains o marsh
- **File modificato**:
  - dati/world/provinces_1000.json (3127 province aggiornate)
- **Seed**: 1000 (riproducibile)

### 2026-08-20 — Passo 21: Scenari multipli e indice truppe per fazione
- **Sistema scenari** (battle_scenario.gd):
  - 8 tipi di terreno: plains, hills, mountains, forest, desert,
    coastal, snow, marsh
  - Ogni tipo ha: altezza colline, frequenza rumore, numero alberi,
    numero rocce, colori erba/terreno/foglie, nebbia, presenza acqua
  - Funzione get_terrain_for_province(lat, lon) determina il tipo
    di terreno in base alla posizione geografica
- **Terrain generator aggiornato**:
  - Legge la configurazione dal tipo di terreno
  - Materiali diversi per deserto (sabbia gialla), neve (bianco),
    foresta (verde scuro), montagne (grigio)
- **Scene multiple create** (7 nuove):
  - battle_hills.tscn, battle_mountains.tscn, battle_forest.tscn,
    battle_desert.tscn, battle_coastal.tscn, battle_snow.tscn,
    battle_marsh.tscn
  - Ogni scena usa un terrain_type diverso
- **Indice truppe per fazione** (faction_troops.gd):
  - 24 fazioni con colori univoci
  - Unità speciali per ogni fazione (cataphractoi, berserker,
    samurai, war_elephant, jaguar_warrior, ecc.)
  - Mapping unità speciali -> tipo base per la scena 3D
  - Funzione get_army_composition che converte le unità del JSON
    in composizione per la scena di battaglia
- **Vegetazione adattiva**: alberi e rocce in numero variabile
  in base al tipo di terreno (foresta=120 alberi, deserto=5)
- **File nuovi**:
  - scripts/game/battle_scenario.gd (165 righe)
  - scripts/game/faction_troops.gd (164 righe)
  - scenes/battle_hills.tscn
  - scenes/battle_mountains.tscn
  - scenes/battle_forest.tscn
  - scenes/battle_desert.tscn
  - scenes/battle_coastal.tscn
  - scenes/battle_snow.tscn
  - scenes/battle_marsh.tscn
- **File modificati**:
  - scripts/game/terrain_generator.gd (terrain_type, config scenario)
  - scripts/ui/battle_view_3d.gd (scenario config, faction colors)
  - scenes/battle_view_3d.tscn (terrain_type = plains)

### 2026-08-20 — Documentazione errori e lezioni apprese
Aggiunta sezione "Errori e lezioni apprese" in fondo a questo file
con tutti gli errori commessi nella sessione del 2026-08-20, per
non ripeterli in futuro.

### 2026-08-20 — Passo 20: Cavallo con scheletro, zampe animate, castelli, rotazione
- **Cavallo riscritto con scheletro** (horse_mesh.gd):
  - Skeleton3D con 20 ossa: bacino, dorso, collo, testa + 4 zampe
  - Ogni zampa: spalla/anca -> coscia -> gamba -> zoccolo
  - Mesh attaccate alle ossa con BoneAttachment3D
  - Sella, pomolo e cantle sul dorso
- **Animazione cavallo** (horse_animation.gd):
  - Le 4 zampe si muovono alternativamente (camminata)
  - Zampe anteriori: ginocchio piega IN AVANTI (come umano)
  - Zampe posteriori: ginocchio piega ALL'INDIETRO (opposto)
  - Coscia oscilla, gamba si piega durante il sollevamento
  - Confermato da ricerca: anatomia equina differenza anteriore/posteriore
- **Cavalleria**: ora anima il cavallo, non il cavaliere
  - Il cavaliere sta seduto fermo, il cavallo muove le zampe
- **Castelli non piu' sotto terra**: await get_tree().process_frame
  prima di posizionare, cosi' il terreno e' gia' generato
- **Soldati non piu' di lato**: face_direction impostato nella scena
  - Attaccanti: -1.5708 radianti (-PI/2, guardano verso +X)
  - Difensori: +1.5708 radianti (+PI/2, guardano verso -X)
  - Si fronteggiano faccia a faccia
- **File nuovi**:
  - scripts/game/horse_animation.gd (57 righe)
- **File modificati**:
  - scripts/game/horse_mesh.gd (riscritto con scheletro, 184 righe)
  - scripts/game/formation_manager_3d.gd (animazione cavallo, face_direction export)
  - scripts/ui/battle_view_3d.gd (await per castelli)
  - scenes/battle_view_3d.tscn (face_direction per tutte le formazioni)

### 2026-08-20 — Passo 19: Terreno 3D con colline, nebbia, castelli
- **Terreno variabile (heightmap procedurale)**:
  - Nuovo script terrain_generator.gd: deforma un PlaneMesh con
    FastNoiseLite (Simplex, 4 ottave, frequenza 0.012)
  - Colline alte fino a 12m ai bordi, pianura al centro
    (campo di battaglia pianeggiante nel raggio di 40m)
  - 300x300m, 150x150 suddivisioni (22500 vertici)
  - Ricalcolo normali per illuminazione corretta sulle colline
  - Metodo get_height_at(x,z) per posizionare oggetti sul terreno
- **Nebbia volumetrica**:
  - Volumetric Fog attivata (densita' 0.01, lunghezza 64m)
  - Depth fog (densita' 0.008) per sfumare lo sfondo
  - Colore azzurro/grigio atmosferico
  - Aerial perspective 0.5 per profondita' visiva
- **Castelli scenici**:
  - Due castelli su colline ai bordi (x=120 e x=-120)
  - Mura perimetrali in pietra (4 lati, alte 6m)
  - 4 torri cilindriche agli angoli (alte 9m)
  - Torre centrale (maschio/keep) 8x10x8m con merlature
  - Texture stone_color con mappa normale
  - Ombre proiettate sul terreno
- **Vegetazione migliorata**:
  - 60 alberi (invece di 40) distribuiti fino a 130m
  - Alberi e rocce seguono l'altezza del terreno (get_height_at)
  - Rocce posizionate sulle colline, non fluttuanti
- **File nuovo**:
  - scripts/game/terrain_generator.gd (72 righe)
- **File modificati**:
  - scenes/battle_view_3d.tscn (terrain_generator, nebbia volumetrica)
  - scripts/ui/battle_view_3d.gd (castelli, alberi su colline, rocce su terreno)

### 2026-08-20 — Passo 18: Proiettili in volo (frecce e artiglieria)
- **Sistema proiettili** (projectile_system.gd):
  - Frecce: traiettoria parabolica, tempo di volo proporzionale
    alla distanza, arco 30% della distanza
  - Proiettili artiglieria: sfere di pietra 0.3m, traiettoria
    parabolica con arco 40%, piu' lenti delle frecce
  - Massimo 200 proiettili simultanei
  I proiettili si orientano nella direzione di volo
- **Volate automatiche**: ogni 2 secondi, 5 arcieri per parte
  sparano frecce verso soldati nemici casuali. Anche l'artiglieria
  spara proiettili di pietra.
- **File nuovo**:
  - scripts/game/projectile_system.gd (94 righe)
- **File modificati**:
  - scripts/ui/battle_view_3d.gd (sistema volate, _fire_volley)
  - scripts/game/formation_manager_3d.gd (get_unit_count)

### 2026-08-20 — Passo 17: Velocita' corretta, fronteggiamiento, non ammucchiata
- **Velocita' ridotta**: da 8.0 a 2.0 m/s (velocita' di marcia umana,
  non scatti velocissimi)
- **Soldati di lato corretti**: la rotazione veniva calcolata ogni
  frame con atan2 rispetto alla direzione di movimento, causando
  orientamenti sbagliati. Ora la rotazione e' fissa:
  - Attaccanti: -PI/2 (guardano verso +X, verso il centro)
  - Difensori: +PI/2 (guardano verso -X, verso il centro)
  - Si fronteggiano faccia a faccia
- **Non si ammucchiano in centro**: invece di mandare tutti a (0,0,0),
  gli attaccanti si fermano a x=-8 e i difensori a x=+8. Rimangono
  a 16 metri di distanza e si fronteggiano senza sovrapporsi.
- **Rotazione fissa durante il movimento**: non cambia piu' ogni
  frame, viene impostata una sola volta all'inizio della battaglia
- **File modificati**:
  - scripts/game/formation_manager_3d.gd (velocita' 2.0, rotazione fissa)
  - scripts/ui/battle_view_3d.gd (target -8/+8, rotazioni fronteggiamiento)

### 2026-08-20 — Passo 16: Camera sottoterra + rotazione ripristinata
- **Camera sottoterra**: _pitch era inizializzato a -55.0 ma veniva
  usato come radianti (-55 radianti = 9 giri completi = sottoterra).
  Corretto a -0.96 radianti (circa -55 gradi).
- **Rotazione ripristinata sul tasto destro**: era stata spostata al
  tasto centrale che non funziona bene. Tornata sul tasto destro.
- **Click sinistro unificato**: click su un'unita' = seleziona,
  click sul terreno = muovi l'unita' selezionata li'.
  Non serve piu' il tasto destro per muovere.
- **File modificati**:
  - scripts/game/rts_camera.gd (pitch in radianti, rotazione tasto destro)
  - scripts/ui/battle_view_3d.gd (click sinistro selezione+movimento)

### 2026-08-20 — Passo 15: Soldati che si fermano dopo 3 passi
- **Causa**: `_process` chiamava `move_formation(Vector3(0,0,0))` ogni
  frame. Questo ricalcolava i target ogni frame basandosi sulla
  posizione attuale dei soldati. I target venivano continuamente
  aggiornati e i soldati non avanzavano mai davvero: facevano un
  piccolo passo, il target veniva ricalcolato, e si fermavano.
- **Correzione**: `move_formation` viene chiamato UNA SOLA VOLTE quando
  si preme Play. I target vengono fissati e i soldati avanzano
  stabilmente verso di essi senza essere disturbati.
- `_process` in battle_view_3d.gd non chiama piu' move_formation
- Aggiunto `set_speed(speed)` al formation_manager per Veloce x3
- **File modificati**:
  - scripts/ui/battle_view_3d.gd (move_formation una volta, non ogni frame)
  - scripts/game/formation_manager_3d.gd (set_speed)

### 2026-08-20 — Passo 14: Soldati fermi + selezione unita'
- **Soldati fermi (bug critico)**:
  - Causa: `move_formation` riceveva coordinate globali (0,0,0) ma
    confrontava con posizioni locali dei soldati. Il nodo formazione
    e' a x=-30, quindi il centro locale era gia' (0,0,0) e l'offset
    risultava zero. I soldati non si muovevano mai.
  - Correzione: `to_local(new_center_global)` converte il target
    globale in coordinate locali prima di calcolare l'offset
- **Velocita' aumentata**: da 3.0 a 8.0 m/s (i soldati erano troppo lenti)
- **Selezione unita' singola**:
  - Click sinistro: seleziona l'unita' piu' vicina al punto cliccato
    (raggio 3m). Cerca in tutte le formazioni.
  - Click destro: muove l'unita' selezionata verso il punto cliccato
  - Etichetta mostra formazione e unita' selezionata
- **Rotazione camera spostata**: da tasto destro a tasto centrale
  (il tasto destro ora muove le unita')
- **File modificati**:
  - scripts/game/formation_manager_3d.gd (to_local, selezione, get_soldier)
  - scripts/ui/battle_view_3d.gd (selezione click, movimento click)
  - scripts/game/rts_camera.gd (rotazione al tasto centrale)

### 2026-08-20 — Passo 13: Camera che salta e soldati di fianco
- **Camera che saltava al tasto destro**:
  - Causa: `look_at(Vector3.ZERO)` guardava sempre l'origine del mondo,
    non la posizione della camera. Quando ci si spostava con WASD,
    la camera saltava all'origine.
  - Correzione: `look_at(global_position)` guarda la posizione
    globale del nodo camera (il centro dell'orbita)
  - Aggiunto reset della posizione mouse quando si preme il tasto
    destro, per evitare salti dal movimento accumulato
- **Soldati che avanzavano di fianco**:
  - Causa: `atan2(dir.x, dir.z)` faceva guardare il +Z (dietro)
    nella direzione di movimento. Il fronte del soldato (-Z)
    guardava dalla parte opposta.
  - Correzione: `atan2(-dir.x, -dir.z)` fa guardare il fronte
    (-Z, dove c'e' la faccia e lo scudo) verso il nemico
- **File modificati**:
  - scripts/game/rts_camera.gd (look_at global_position, reset mouse)
  - scripts/game/formation_manager_3d.gd (rotazione fronte corretta)

### 2026-08-20 — Passo 12: Correzioni multiple (scheletro, camera, pausa, cavalleria)
- **Scheletro corretto**: i piedi erano sottoterra (bacino a y=0.9 ma
  gambe lunghe 1.2m = piedi a y=-0.3). Bacino alzato a y=1.0, piede
  con offset corto (0.05 invece di 0.4). Ora i piedi sono a terra.
- **Coscia ingrandita**: raggio da 0.10 a 0.13 (piu' visibile),
  gamba raggio 0.09 (distinta dalla coscia)
- **Rocce rotonde**: sostituito BoxMesh con SphereMesh deformata
  (scale casuale per non essere perfettamente sferiche)
- **Camera corretta**:
  - Rotazione alto/basso con tasto destro (non solo destra/sinistra)
  - Zoom minimo da 10 a 3 (ci si avvicina agli omini)
  - Camera puntata sul centro (0,0,0) dove stanno i soldati
  - Movimento WASD relativo alla rotazione camera
  - FOV da 50 a 55
- **Pausa funzionante**: aggiunto flag _paused al formation_manager,
  _process ritorna subito se in pausa. Play/Pausa/Play ora funziona.
- **Cavalieri seduti**: cosce ruotate 80 gradi (orizzontali), gambe
  pendenti verticali. Rider a y=1.4 sopra la sella.
- **Sella aggiunta**: scatola sul dorso del cavallo + pomolo anteriore
  e posteriore
- **Artiglieria entrambi i lati**: aggiunta AttackerArtillery (2 macchine)
  oltre a DefenderArtillery. Posizioni piu' vicine (38 invece di 45).
- **File modificati**:
  - scripts/game/soldier_skeleton.gd (bacino 1.0, piede offset corto)
  - scripts/game/rts_camera.gd (rotazione pitch, zoom 3, orbit)
  - scripts/game/formation_manager_3d.gd (flag _paused)
  - scripts/game/horse_mesh.gd (sella + pomolo + cantle)
  - scripts/game/unit_factory.gd (cavalieri seduti)
  - scripts/ui/battle_view_3d.gd (pausa, rocce rotonde, artiglieria)
  - scenes/battle_view_3d.tscn (camera, artiglieria entrambi lati)

### 2026-08-20 — Passo 11: Texture reali per terreno, rocce e alberi
- **Texture importate da Hegemonia Spaziale** (non per gli uomini,
  ma per mappa, alberi, rocce, pietre, muri)
- **Texture terreno** (risorse/textures/terrain/):
  - ground_color.png + ground_normal.png + ground_roughness.png
    (terreno con mappa normale per rilievo 3D)
  - gravel_color.png + gravel_normal.png + gravel_roughness.png
    (ghiaia)
  - grass.jpg (erba)
  - ground.jpg (terreno generico)
- **Texture rocce e pietre** (risorse/textures/rocks/):
  - rock_color.png + rock_normal.png + rock_ao.png
    (roccia naturale con normale e ambient occlusion)
  - stone_color.png + stone_normal.png + stone_ao.png
    (pietra lavorata per muri)
  - stone_beach.png (pietra di fiume)
- **Nuovo script texture_loader.gd**: crea materiali con texture
  reali per terreno, rocce, pietre, legno, foglie
- **Terreno**: ora usa ground_color con mappa normale per rilievo
  3D, ripetuto 20x sul terreno grande
- **Alberi**: tronchi marroni con materiale legno, chiome verdi
- **Rocce**: 15 rocce procedurali con texture rock_color e normale,
  posizionate sui bordi del campo di battaglia
- **File nuovi**:
  - scripts/game/texture_loader.gd (80 righe)
  - risorse/textures/terrain/ (8 file)
  - risorse/textures/rocks/ (7 file)
  - risorse/textures/trees/ (1 file)
- **File modificato**:
  - scripts/ui/battle_view_3d.gd (texture reali invece di procedurali)

### 2026-08-20 — Passo 10: Asceri con arma a due mani (niente scudo)
- **Correzione**: gli asceri non hanno scudo, usano arma a due mani
- **3 armi a due mani** create (weapon_mesh.gd):
  1. **Ascia da battaglia**: manico 1.4m + testa grande con due lame
  2. **Alabarda**: manico 1.6m + punta + lama laterale + gancio
  3. **Daikatana**: spada lunga 1.2m con elsa per due mani (per giapponesi)
- **Arma attaccata alla mano destra**, mano sinistra libera
  (nella realta' impugna piu' in basso sul manico)
- **Niente scudo**: gli asceri usano entrambe le mani per l'arma
- **Scelta casuale** del tipo di arma per ogni asciere
- **File modificati**:
  - scripts/game/weapon_mesh.gd (ascia 2 mani, alabarda, daikatana)
  - scripts/game/unit_factory.gd (asceri senza scudo, arma 2 mani)

### 2026-08-20 — Passo 9: Fanteria divisa in sottotipi (spadaccini, lancieri, asceri)
- **Fanteria divisa in 3 sottotipi** con armi diverse:
  1. **Spadaccini**: spada nella mano destra, scudo nella sinistra
  2. **Lancieri**: lancia corta (1.8m) nella mano destra, scudo nella sinistra
  3. **Asceri**: ascia (manico + testa + lama) nella mano destra, scudo nella sinistra
- **Armi nuove create** (weapon_mesh.gd):
  - Ascia: manico cilindro 0.6m + testa scatola + lama cono
  - Lancia corta (pike): asta 1.8m + punta conica (piu' corta della
    lancia da cavalleria che e' 2.5m)
- **Tutti i sottotipi hanno scudo** nella mano sinistra
- **Scene aggiornate con formazioni miste**:
  - Attaccanti: 15 spadaccini + 15 lancieri + 10 asceri + 12 arcieri + 8 cavalleria
  - Difensori: 15 spadaccini + 15 lancieri + 10 asceri + 12 arcieri + 8 cavalleria + 2 artiglieria
- **Colori distinti per sottotipo**:
  - Spadaccini: rosso acceso (attaccanti) / blu acceso (difensori)
  - Lancieri: rosso-arancio / blu chiaro
  - Asceri: rosso scuro / blu scuro
  - Arcieri: verde
  - Cavalleria: rosso sangue / blu navy
- **File modificati**:
  - scripts/game/weapon_mesh.gd (aggiunta ascia e lancia corta)
  - scripts/game/unit_factory.gd (3 sottotipi fanteria)
  - scenes/battle_view_3d.tscn (11 formazioni miste)
  - scripts/ui/battle_view_3d.gd (gestione 11 formazioni)

### 2026-08-20 — Passo 8: Artiglieria storica anno 1000 (onagro, balista)
- **Ricerca storica**: confermato che nell'anno 1000 NON esistevano
  cannoni (arrivano nel XIV secolo con la polvere da sparo)
- **Macchine d'assedio disponibili nell'anno 1000**:
  - Onagro: catapulta a torsione con braccio singolo, lancia pietre
  - Balista: macchina a torsione, lancia grandi dardi
  - Petraria/mangano: macchina a trazione manuale
- **Sostituita la catapulta generica** con onagro e balista storici
- **Onagro**: base di legno, 4 ruote, braccio inclinato con cucchiaio,
  due cilindri di torsione laterali
- **Balista**: base di legno, 4 ruote, guide orizzontali per il dardo,
  dardo caricato con punta metallica, due bracci di torsione con corde
- **6 serventi per macchina**: soldati senza armi posizionati attorno
  alla macchina, rivolti verso di essa, con colori neutri (marrone)
- **File nuovo**:
  - scripts/game/siege_engine.gd (288 righe) - onagro, balista, serventi
- **File modificato**:
  - scripts/game/unit_factory.gd (usa siege_engine invece di catapulta)

### 2026-08-20 — Passo 7: Unità complete con armi, cavallo, artiglieria
- **4 tipi di unita'** creati con equipaggiamento:
  1. **Fanteria**: spada nella mano destra, scudo nella mano sinistra
  2. **Arciere**: arco nella mano sinistra, faretra con frecce sulla
     coscia destra, colore verde fazione
  3. **Cavalleria**: soldato a cavallo con lancia nella mano destra,
     scudo nella mano sinistra. Cavallo con proporzioni reali
     (2.4m lungo, 1.5m alto)
  4. **Artiglieria**: catapulta con base, braccio inclinato,
     contrappeso e 4 ruote
- **Cavallo**: mesh completa con corpo, collo inclinato, testa,
  criniera, coda, 4 zampe (coscia + gamba + zoccolo)
- **Armi create** (weapon_mesh.gd):
  - Spada: lama + elsa + pomolo (metallico)
  - Scudo: scatola rettangolare (cuoio)
  - Arco: semicerchio verticale (legno)
  - Faretra: cilindro con 3 frecce
  - Lancia: asta 2.5m + punta conica
  - Freccia: cilindro sottile + punta
- **Attacchi alle mani**: BoneAttachment3D su ManoDx/ManoSx per
  arma e scudo. Le armi seguono le mani durante l'animazione.
- **Unit factory**: unit_factory.gd crea unita' complete per tipo
- **Formazioni miste nella scena**:
  - Attaccanti: 30 fanteria + 15 arcieri + 10 cavalleria
  - Difensori: 30 fanteria + 15 arcieri + 3 artiglieria
- **Spaziatura adattata**: cavalleria 2x, artiglieria 3x
- **File nuovi**:
  - scripts/game/weapon_mesh.gd (232 righe) - mesh armi
  - scripts/game/horse_mesh.gd (151 righe) - cavallo
  - scripts/game/unit_factory.gd (264 righe) - factory unita'
- **File modificati**:
  - scripts/game/formation_manager_3d.gd (supporta tipi unita')
  - scenes/battle_view_3d.tscn (6 formazioni miste)
  - scripts/ui/battle_view_3d.gd (gestione 6 formazioni)

### 2026-08-20 — Passo 6: Scheletro corretto, braccia pendenti, addome aggiunto
- **Problema**: le braccia erano in orizzontale (aperte lateralmente)
  invece che verticali (pendenti lungo il corpo). Mancava l'addome.
  I soldati erano inguardabili.
- **Causa**: gli offset delle ossa figlie delle braccia erano su x
  (laterale) invece che su y negativo (verso il basso)
- **Correzione struttura scheletro** (20 ossa):
  - Colonna vertebrale: Bacino -> Addome -> Busto -> Testa
  - Braccio: Spalla -> Braccio -> Avambraccio -> Mano
    (tutti pendenti verso il basso, y negativo)
  - Gamba: Anca -> Coscia -> Gamba -> Piede
    (tutti pendenti verso il basso, y negativo)
- **Addome aggiunto**: nuovo osso tra Bacino e Busto
- **Braccia corrette**: BraccioSx figlio di SpallaSx con offset
  (0, -0.25, 0) invece di (-0.2, 0, 0). Avambraccio e mano
  ugualmente pendenti verso il basso.
- **Simmetria**: braccio sinistro e destro identici (specchiati su x)
- **Mesh**: tutte verticali, offset verso il basso (y negativo)
- **Animazione aggiornata**: usa Busto invece di Tronco, Addome
  aggiunto come osso stabile
- **File modificati**:
  - scripts/game/soldier_skeleton.gd (20 ossa, braccia pendenti, addome)
  - scripts/game/soldier_animation.gd (Busto, Addome)
  - scripts/game/formation_manager_3d.gd (Busto invece di Tronco)
- **Processi Godot**: terminati tutti i processi di test rimasti attivi

### 2026-08-20 — Passo 5: Scheletro completo 19 ossa, mesh ingrandite, mouse libero
- **Problema**: i soldati avevano un solo pezzo per arto visibile
  (mesh troppo piccole e sovrapposte), il mouse rimaneva bloccato
  dall'edge panning, non si poteva ruotare la visuale
- **Scheletro completo 19 ossa** (era 15):
  - Braccio: Spalla -> Braccio -> Avambraccio -> Mano (4 ossa, 3 giunture)
  - Gamba: Anca -> Coscia -> Gamba -> Piede (4 ossa, 3 giunture)
  - Tronco, Testa, Bacino
- **Mesh ingrandite** (raddoppiate):
  - Tronco: 0.5x0.5x0.3 (era 0.35x0.4x0.2)
  - Testa: raggio 0.18 (era 0.12)
  - Braccio: raggio 0.09, lunghezza 0.25
  - Avambraccio: raggio 0.07, lunghezza 0.25
  - Mano: scatola 0.12x0.12x0.08 (nuova)
  - Coscia: raggio 0.12, lunghezza 0.4
  - Gamba: raggio 0.1, lunghezza 0.4
  - Piede: scatola 0.15x0.08x0.25 (nuova)
- **Animazione aggiornata**: ora muove anche ginocchia (Coscia/Gamba)
  e caviglie (Piede), gomiti (Braccio/Avambraccio) e polsi (Mano)
- **Edge panning disabilitato**: il mouse non si blocca piu' sui bordi
- **Rotazione con tasto destro**: premi tasto destro + trascina per
  ruotare la visuale (era tasto centrale che non funzionava)
- **File modificati**:
  - scripts/game/soldier_skeleton.gd (19 ossa, mesh ingrandite, mani/piedi)
  - scripts/game/soldier_animation.gd (nuove giunture animate)
  - scripts/game/rts_camera.gd (edge pan off, rotazione tasto destro)
  - scripts/game/formation_manager_3d.gd (colore anche su cosce)

### 2026-08-20 — Correzione soldati invisibili (BoneAttachment3D)
- **Problema**: i soldati non si vedevano nella scena. Le mesh erano
  figlie dirette dello Skeleton3D ma non seguivano le ossa
- **Causa**: in Godot 4, MeshInstance3D figlia di Skeleton3D non
  segue automaticamente le ossa. Serve BoneAttachment3D come ponte
- **Soluzione**: per ogni osso con mesh, creato BoneAttachment3D con
  bone_name e bone_idx, poi MeshInstance3D come figlia del
  BoneAttachment3D. Ora le mesh seguono le ossa correttamente
- **Offset mesh**: ogni mesh ha un offset rispetto all'articolazione
  (es. tronco spostato +0.2 in alto, braccia -0.15 in basso)
- **File modificato**: scripts/game/soldier_skeleton.gd (BoneAttachment3D)
- **File modificato**: scripts/game/formation_manager_3d.gd (cerca mesh
  sotto Attach_ invece che direttamente sotto scheletro)

### 2026-08-20 — Passo 4: Soldati con scheletro, giunture e animazione
- **Scheletro soldato**: 15 ossa con giunture:
  - Bacino, Tronco, Testa
  - SpallaSx/Dx, BraccioSx/Dx, AvambraccioSx/Dx (gomito)
  - AncaSx/Dx, GambaSx/Dx, StincoSx/Dx (ginocchio)
- **Mesh per osso**: ogni osso ha una mesh associata (box per tronco,
  sfera per testa, cilindri per braccia/gambe). Posizionate all'altezza
  corretta (piedi a terra, ~1.8m totale)
- **Animazione camminata**: soldier_animation.gd muove:
  - Gambe: oscillazione alternata anche + ginocchia
  - Braccia: oscillazione opposta alle gambe + gomiti
  - Tronco: leggera oscillazione
  - Bacino: bobbing verticale
  - Offset casuale per soldato (non sincronizzati)
- **Animazione idle**: respirazione leggera quando fermi
- **Rotazione verso direzione**: i soldati si girano verso dove camminano
- **Colori fazione**: tronco e braccia colorati per fazione
  (rosso attaccanti, blu difensori)
- **Sostituito MultiMesh**: ora usa soldati individuali con Skeleton3D
  per supportare animazione. Ridotto a 50 per fazione (100 totali)
  per performance
- **File nuovi**:
  - scripts/game/soldier_skeleton.gd (189 righe) - scheletro + mesh
  - scripts/game/soldier_animation.gd (83 righe) - animazione camminata
- **File modificati**:
  - scripts/game/formation_manager_3d.gd (soldati individuali animati)
  - scenes/battle_view_3d.tscn (50 unita' per fazione, colori fazione)
- **Nota**: le texture PBR saranno aggiunte successivamente dall'utente.
  La struttura scheletrica e' pronta per ricevere modelli .glb reali.

### 2026-08-20 — Passo 3: Ambiente 3D completo (cielo, erba, alberi, PBR)
- **Cielo procedurale**: ProceduralSkyMaterial con cielo blu, orizzonte
  chiaro, nuvole (noise), sole a 45 gradi. Sostituisce il fondo nero.
- **Erba 3D**: grass_generator.gd con MultiMeshInstance3D, 2000 ciuffi
  d'erba distribuiti casualmente sul terreno (evita il centro).
  Variazione colore verde, ombre disabilitate per performance.
- **Alberi 3D**: tree_mesh.gd genera alberi low-poly (tronco cilindro +
  chioma conica a 3 livelli). 40 alberi posizionati sui bordi.
- **Illuminazione migliorata**: DirectionalLight3D con luce calda
  dorata (1, 0.92, 0.7), energia 2.0, ombre alta qualita',
  rotazione 45 gradi X e Y per ombre lunghe definite.
- **Fog/nebbia**: aggiunta nebbia leggera per profondita' atmosferica.
- **Materiale soldati PBR-like**: roughness 0.6, metallic 0.3,
  specular 0.5, shading per-pixel. Aspetto metallico per armatura.
- **SSAO intensificato**: radius 1.5, intensity 3.0 per ombre profonde.
- **File nuovi**:
  - scripts/game/tree_mesh.gd (81 righe) - generatore albero low-poly
  - scripts/game/grass_generator.gd (55 righe) - erba 3D con MultiMesh
- **File modificati**:
  - scripts/ui/battle_view_3d.gd (alberi sui bordi)
  - scripts/game/soldier_mesh.gd (materiale PBR-like)
  - scenes/battle_view_3d.tscn (cielo, nebbia, luce migliore, GrassGenerator)
- **Limitazione**: per qualita' AAA reale servono modelli .glb con
  texture PBR (non procedurali). La struttura c'e', basta sostituire
  le mesh.

### 2026-08-20 — Correzione controlli camera e uscita scena 3D
- **Problema**: WASD/frecce non funzionavano (usavano InputAction ui_*
  che richiedono mappatura), ESC non usciva, mouse non cliccabile sui
  pulsanti perche' edge panning catturava sempre il mouse
- **Correzione WASD/frecce**: usato Input.is_key_pressed() con KEY_W,
  KEY_A, KEY_S, KEY_D, KEY_UP/DOWN/LEFT/RIGHT direttamente
- **Correzione ESC**: aggiunto _input() in battle_view_3d.gd che
  chiama get_tree().quit() quando si preme ESC
- **Correzione edge panning**: aggiunto _is_mouse_over_ui() che
  verifica se il mouse e' sopra un controllo UI tramite
  viewport.gui_get_hovered_control(). Edge panning disabilitato
  quando il mouse e' sopra la UI
- **Pulsante Esci**: aggiunto pulsante "Esci (ESC)" nel pannello UI
- **File modificati**:
  - scripts/game/rts_camera.gd (WASD diretto, edge pan con controllo UI)
  - scripts/ui/battle_view_3d.gd (ESC, pulsante Esci)

### 2026-08-20 — Passo 2: Miglioramento estetico scena 3D
- **Soldato low-poly procedurale**: creato `soldier_mesh.gd` che genera
  un soldato combinando primitive (corpo cilindro, testa sfera, gambe,
  scudo box, lancia cilindro). Sostituisce le capsule bianche.
  - Usa vertex_color_use_as_albedo per colorare attaccanti (rosso) e
    difensori (blu) tramite MultiMesh
- **Texture erba procedurale**: NoiseTexture2D con FastNoiseLite Simplic
  512x512 seamless, UV scale 10x per ripetere su tutto il terreno
- **Illuminazione migliorata**: DirectionalLight3D ruotato 45 gradi
  su X e Y (sole pomeridiano), ombre attivate con pancake size 100m,
  energia aumentata a 1.5
- **UI trasparente**: pannello con StyleBoxFlat marrone scuro alpha 0.6,
  bordo dorato, angoli arrotondati. Etichetta fase con sfondo
  semi-trasparente nero.
- **File nuovi**:
  - scripts/game/soldier_mesh.gd (143 righe) - generatore mesh soldato
- **File modificati**:
  - scripts/game/formation_manager_3d.gd (usa soldato procedurale)
  - scripts/ui/battle_view_3d.gd (texture erba, UI trasparente)
  - scenes/battle_view_3d.tscn (luce migliorata, rimosso CapsuleMesh)

### 2026-08-20 — Scena battaglia 3D RTS e bilanciamento cap per settlement
- **Scena 3D RTS creata**: `battle_view_3d.tscn` con:
  - Node3D radice con WorldEnvironment (SSAO, Tonemap Filmic, Glow)
  - DirectionalLight3D con ombre attivate (max distance 200m)
  - Terreno 3D PlaneMesh 200x200 con materiale erba PBR
  - Camera RTS isometrica (45 gradi, zoom 10-80, panning WASD/bordi)
  - MultiMeshInstance3D per 400 unita' (200 attaccanti + 200 difensori)
  - GPUParticles3D per polvere carica
  - CanvasLayer con HUD tattico (Play, Pausa, Veloce, Carica, Muro Scudi, Standard)
- **Script creati**:
  - `scripts/game/rts_camera.gd` - camera RTS con panning, zoom, rotazione
  - `scripts/game/formation_manager_3d.gd` - formazioni 3D con MultiMesh
  - `scripts/ui/battle_view_3d.gd` - scena principale battaglia 3D
- **Formazioni 3D**: line, square, wedge, column (cambio dinamico)
- **Placeholder unita'**: CapsuleMesh (raggio 0.3, altezza 1.2), da sostituire con .glb
- **BAT desktop**: `Battaglia_Hegemonia1000.bat` avvia direttamente la scena 3D
- **Bilanciamento**: cap produzione edifici per settlement (50 oro, 40 cibo)
  - Bizantini: 247.424 oro in 13 turni (era 3.866.637, ridotto 15x)
  - Vichinghi: 4.408 oro, 2.939 cibo (sopravvivono, nessun warning)
  - Song: 192.243 oro (popolazione domina, 20 province)
  - Fatimidi: 41.164 oro (142 unita' da mantenere)
- **Tentativi falliti e corretti**:
  - Cap 1/3 edifici: Vichinghi in deficit di cibo (base troppo bassa)
  - Cap 2x tasse: Fatimidi crollano a 2.191 (mantenimento 142 unita')
  - Cap 3x tasse: Bizantini ancora a 249.226 (cap non si attiva)
  - Cap 8% popolazione: Bizantini ancora a 246.455 (cap si attiva appena)
  - Cap per settlement 50 oro: accettabile, Bizantini 247.424
- **File modificati**:
  - scripts/autoload/economy_engine.gd (cap per settlement)
  - scripts/battle_test_launcher.gd (usa scena 3D)
- **File nuovi**:
  - scripts/game/rts_camera.gd
  - scripts/game/formation_manager_3d.gd
  - scripts/ui/battle_view_3d.gd
  - scenes/battle_view_3d.tscn
  - C:\Users\DevinAgent\Desktop\Battaglia_Hegemonia1000.bat

### 2026-08-20 — Documentazione completa: roadmap, manuale, flusso, API
- **File docs nuovi**:
  - documenti/05_ROADMAP.md - roadmap con 6 fasi, priorita', obiettivo finale
  - documenti/06_MANUALE_UTENTE.md - come si gioca passo per passo
  - documenti/07_FLUSSO_TURNO.md - diagramma flusso turno, battaglia, costruzione
  - documenti/08_API_IA_ESTERNA.md - documentazione AIBridge (prompt, risposta, endpoint)
- **README aggiornato**: indice documentazione, stato progetto allineato
- **Registro modifiche aggiornato**: sezione tentativi riusciti e falliti

### 2026-08-20 — Aggiornamento stato progetto e documentazione tentativi
- **Verifica**: letto tutto il README e i 4 file docs per verificare
  che la documentazione rifletta lo stato reale
- **Aggiornato README.md**: stato progetto allineato ai risultati
  verificati (9 scene OK, flusso OK, economia basata su popolazione,
  IA esterna, 376 icone)
- **Aggiunta sezione "Problemi risolti e tentativi"** in questo file:
  riepilogo di tutti i tentativi falliti e riusciti, per memoria
  storica del progetto
- **File modificati**: README.md, documenti/04_REGISTRO_MODIFICHE.md

## Problemi risolti e tentativi (riepilogo)

Questa sezione raccoglie i tentativi significativi, riusciti e falliti,
per preservare la memoria del percorso di sviluppo.

### Tentativi riusciti

1. **Battaglia tempo reale 2.5D**: implementata con deploy, combat,
   morale, formazioni, comandanti, proiettili, IA tattica. Funzionante.
2. **Sistema agglomerati**: 3917 province con settlements, 155 capitali,
   4 tipi (civile, militare, industriale, portuale), edifici con livelli
3. **Sistema economico basato su popolazione**: allineato a 800aC e 1700.
   La popolazione e' il motore (tasse + agricoltura), gli edifici
   garantiscono sopravvivenza minima. Vichinghi sopravvivono anche
   con suolo 0.8.
4. **IA con obiettivi per nazione**: 20 file JSON con obiettivi storici,
   produttivi, militari, comportamento e catena priorita
5. **IA esterna (AIBridge)**: routing per token size, fallback
   deterministico, max 10 richieste pending
6. **Icone culturali**: 376 PNG + 108 SVG per 6 regioni (europea,
   orientale, asiatica, indiana, africana, americana)
7. **Catalogo costruzioni**: popup con edifici, costi, effetti,
   sblocco unita'. 5 edifici costruibili verificati.
8. **Reclutamento**: 5 unita' reclutabili verificati, con costo e
   statistiche

### Tentativi falliti e corretti

1. **Oro Bizantini a 3.866.637 in 12 turni**: il trade_bonus veniva
   sommato su tutti i 240 settlement (2490% totale, moltiplicatore
   25.9x). Corretto in media per provincia.
2. **Mantenimento allo 0,1%**: era completamente sballato rispetto
   a 800aC (8%) e 1700 (25%). Corretto al 5% (adattato alla scala
   migliaia di Hegemonia 1000).
3. **Cibo unita' pop/2 (scala milioni)**: causava famine perche' in
   Hegemonia 1000 la scala e' migliaia. Corretto in pop/20.
4. **Cibo 1700 diretto (500 per fanteria)**: causava famine (95 unita'
   x 500 = 47.500 cibo/turno contro 8.000 produzione). Corretto con
   scala migliaia.
5. **Unita' iniziali eccessive**: 100 fazioni su 158 avevano troppe
   unita' rispetto alle province (Song 131 unita' con 20 province).
   Ridotto a max 1 unita'/provincia.
6. **Produzione indipendente dalla popolazione**: i Bizantini (201K
   abitanti) producevano quanto i Song (531K abitanti) perche'
   contavano solo gli edifici fissi. Corretto con modello basato
   su popolazione.
7. **Vichinghi in deficit di cibo con suolo 0.8**: morivano di fame
   perche' gli edifici erano scalati per suolo. Corretto: edifici
   producono base fissa + bonus da suolo.
8. **Bug battle_group.gd**: `var min_dist :=` con tipo non inferibile
   in GDScript 4.7. Corretto in `var min_dist: float =`.
9. **Reclutamento inattivo**: le fazioni partivano sopra i minimi
   militari e non reclutavano mai. Aggiunta espansione militare
   basata su comportamento.
10. **Eccessive richieste IA esterna**: 256 richieste pending in una
    simulazione. Corretto con limite a 10 richieste contemporanee.
11. **Parse error path Windows**: script di test con path non
    escapato. Corretto rimuovendo il path non necessario.
12. **new_game() senza argomenti**: il test chiamava `new_game()`
    ma la firma richiede `new_game(faction_name: String)`. Corretto.

### Limitazioni note

- **Grafica battaglia**: sprite semplici forme colorate, non
  illustrazioni storiche. Da migliorare.
- **Bilanciamento fazioni grandi**: Bizantini con 240 province
  producono ancora molto (154.085 oro in 12 turni). Da rifinire.
- **Suolo agricolo derivato solo da latitudine**: tutte le province
  hanno terrain "plains". In futuro aggiungere terrain reali.
- **Test end-to-end non ancora eseguito**: serve una partita
  completa giocata da un umano per verificare il flusso completo.

### 2026-08-20 — Verifica flusso di gioco e correzione bug battle_group
- **Verifica**: test caricamento di tutte le 9 scene del gioco
  - main_menu, strategic_map, province_scene, settlement_scene,
    settlement_view, province_view, province_popup, catalog_scene,
    battle_view: tutte OK
- **Bug trovato e corretto**: `battle_group.gd` riga 475 aveva
  `var min_dist :=` con tipo non inferibile (GDScript 4.7 non riesce
  a inferire quando child e' Node2D generico). Corretto in
  `var min_dist: float =`
- **Conseguenza**: l'errore di parse in battle_group.gd impediva il
  caricamento dello script, causando anche "Nonexistent function init"
  in battle_view. Ora entrambi caricano correttamente
- **Flusso di gioco verificato**:
  - 4327 province abitate, 3917 con settlements
  - Settlements con edifici preesistenti (es. 6 edifici Bizantini)
  - Catalogo costruzioni funzionante: 5 edifici costruibili
  - Reclutamento funzionante: 5 unita' reclutabili
- **File modificato**: scripts/game/battle_group.gd (1 riga)

### 2026-08-20 — Edifici come garanzia di sopravvivenza minima
- **Problema**: con suolo 0.8 (nord), i Vichinghi andavano in deficit
  di cibo e morivano di fame. Non realistico: anche in terre povere
  le persone sopravvivono grazie agli edifici (mulini, centri cittadini)
- **Correzione**: gli edifici ora producono il loro valore base fisso,
  non scalato per suolo. Il suolo aggiunge solo un bonus aggiuntivo
  - ORO edifici = base fissa + bonus(suolo/5)
  - CIBO edifici = base fissa + bonus(suolo/5)
  - Agricoltura resta scalata per suolo (forza_lavoro * suolo * coeff)
- **Risultato**: i Vichinghi ora sopravvivono (cibo 12.000 -> 2.914
  in 12 turni, senza deficit). Oro basso (5.104) - realistico per
  fazione povera che deve razzire. Nessun warning di fame
- **File modificati**: scripts/autoload/economy_engine.gd

### 2026-08-20 — Riprogettazione sistema economico basato su popolazione
- **Problema strutturale**: la produzione era indipendente dalla popolazione.
  I Bizantini (201K abitanti) producevano quanto i Song (531K abitanti)
  perche' contavano solo gli edifici fissi, non le persone
- **Nuovo modello produzione** (economy_engine.gd riscritto):
  - ORO = tasse(pop * 0.03) + edifici(suolo/3) + base_fazione
  - CIBO = agricoltura(forza_lavoro * suolo * 0.02) + edifici(suolo/3) + base
  - forza_lavoro = 70% popolazione (come Hegemonia 1700)
  - suolo_agricolo derivato dalla latitudine (tropicale=5, polare=0)
  - edifici scalati per suolo: un mercato in terra fertile produce di piu'
  - trade_bonus: media per provincia (mantiene correzione precedente)
- **Suolo agricolo per latitudine** (modello 1700 adattato):
  - 0-10 gradi: 5 (tropicale)
  - 10-25: 4 (subtropicale)
  - 25-40: 3 (temperato caldo)
  - 40-55: 2 (temperato freddo)
  - 55-65: 1 (boreale)
  - 65+: 0 (polare/tundra)
- **Consumo cibo popolazione civile**: 1% della popolazione per turno
- **Risultato simulazione 12 turni**:
  - Song (550K pop, 20 prov): 186.192 oro - la popolazione conta!
  - Bizantini (207K pop, 240 prov): 154.085 oro
  - Khmer (81K pop, suolo 4.1): 124.073 oro - tropicale fertile
  - Vichinghi (41K pop, suolo 0.8): -1.479 oro - deficit realistico nord
  - Ghana (42K pop, suolo 4.0): 80.041 oro
- **File modificati**:
  - scripts/autoload/economy_engine.gd (modello produzione riscritto)
- **Allineamento**: modello coerente con Hegemonia 800aC e 1700 dove
  la popolazione e' il motore principale dell'economia

### 2026-08-20 — Ribilanciamento mantenimento, cibo e unita' iniziali
- **Verifica**: confrontati i costi di mantenimento con Hegemonia 800aC
  (8% del costo) e Hegemonia 1700 (25% del costo). Hegemonia 1000 aveva
  mantenimento allo 0,1% - completamente sballato
- **Correzione mantenimento oro**: ricalcolato al 5% del costo di
  reclutamento (adattato alla scala migliaia di Hegemonia 1000)
  - fanteria: 1 -> 50 oro/turno
  - cavalleria: 3 -> 90 oro/turno
  - elefanti: 5 -> 250 oro/turno
- **Correzione cibo unita'**: ricalcolato come pop/20 (in 800aC e 1700
  era pop/2, ma con scala milioni; in 1000 con scala migliaia serve /20)
  - fanteria (1000 uomini): 1 -> 50 cibo/turno
  - cavalleria (500 uomini): 2 -> 25 cibo/turno
  - elefanti (100 uomini): 4 -> 5 cibo/turno
- **Aggiunto consumo cibo popolazione civile**: pop/100 per turno
  (in 1700 era 1:1 con scala milioni, qui 1:100 con scala migliaia)
- **Ridotte unita' iniziali**: 100 fazioni su 158 avevano troppe unita'
  rispetto alle province. Ridotto a max 1 unita'/provincia (min 10)
  - Song: 131 -> 18 (20 province)
  - Abbasidi: 97 -> 23 (26 province)
  - Vichinghi: 72 -> 59 (62 province)
- **Ridotta espansione militare AI**: da 5 a 2 unita'/turno per fazioni
  imperiali, da 3 a 1 per emergenti
- **File modificati**:
  - dati/config/game_config.json (maintenance e food di 58 unita')
  - dati/world/factions_1000.json (unita' e navi iniziali di 100 fazioni)
  - scripts/autoload/economy_engine.gd (consumo cibo popolazione civile)
  - scripts/autoload/ai_controller.gd (espansione militare ridotta)
- **Simulazione 12 turni**: tutte le 20 fazioni principali sopravvivono.
  Bizantini oro 18.000 -> 81.783 (in calo rispetto ai 3,8M precedenti).
  Song in difficolta' con cibo (0 cibo al turno 10). Fazioni piccole
  bilanciate. Da rifinire: produzione eccessiva fazioni grandi

### 2026-08-20 — Correzione bilanciamento economico, reclutamento e IA esterna
- **Problema oro Bizantini**: l'oro cresceva a 3.866.637 in 12 turni perche'
  il trade_bonus veniva sommato su tutti i 240 settlement (2490% totale,
  moltiplicatore 25.9x). Corretto in economy_engine.gd:
  - trade_bonus: ora media per provincia, non somma totale
  - free_upkeep: limitato a max 20 unita' gratuite
  - population_growth: ora media per provincia
- **Risultato**: Bizantini da 18.000 a 177.804 in 12 turni (era 3.866.637)
- **Problema reclutamento**: le fazioni partivano sopra i minimi militari
  e non reclutavano mai. Aggiunta logica di espansione militare in
  ai_controller.gd: recluta unita' extra in base al comportamento
  (imperiale/razziatore: 5/turno, emergente: 3, marinaro: 2, ecc.)
- **Risultato**: Sacro Romano Impero 93->172, Fatimidi 106->189, Vichinghi 72->132
- **IA esterna**: creato autoload AIBridge (scripts/autoload/ai_bridge.gd)
  con chiamate HTTPRequest a Gemini/Groq/Cerebras/OpenRouter/Cohere.
  Routing per token size come Hegemonia 1700:
  - sotto 7.000 token -> Cerebras
  - 7.000-28.000 token -> Groq
  - sopra 28.000 token -> Gemini
  - max 10 richieste pending contemporanee
  - fallback deterministico se nessun provider disponibile
  - prompt compatto per fazione (rispetta limiti token)
  - contatori richieste per provider con limiti free tier
- **File modificati**:
  - scripts/autoload/economy_engine.gd (trade_bonus, free_upkeep, population_growth)
  - scripts/autoload/ai_controller.gd (espansione militare, integrazione AIBridge)
  - project.godot (aggiunto autoload AIBridge)
- **File nuovi**:
  - scripts/autoload/ai_bridge.gd (330 righe)
  - config_api.json (copiato da Hegemonia_1700, stesso provider)

### 2026-08-19 — Sistema IA con obiettivi per nazione
- **Modifica**: creati 20 file obiettivi in dati/factions/ per le fazioni
  giocabili (modello Hegemonia_1700). Ogni file contiene:
  obiettivi_storici, obiettivi_produttivi, obiettivi_militari,
  comportamento, catena_priorita
- **Riscritto**: scripts/autoload/ai_controller.gd (467 righe) con:
  - caricamento obiettivi da JSON
  - sviluppo economico deterministico (costruzione edifici per catena)
  - reclutamento basato su obiettivi militari e recruit_pool
  - upgrade edifici automatico
  - aggiornamento recruit_pool per turno
  - decisione militare basata su modalita' (aggressiva/difensiva/bilanciata)
- **File nuovi**: dati/factions/*.json (20 file), scripts/generate_faction_goals.py
- **Simulazione**: 12 turni con Godot 4.7.1, tutte le 20 nazioni sopravvivono
  e costruiscono edifici. Problema identificato: bilanciamento economico
  (oro cresce troppo), da correggere in fase di rifinitura

### 2026-08-19 — Sistema edifici avanzato (albero tecnologico, recruit_pool, effetti)
- **Modifica**: arricchito game_config.json con:
  - albero tecnologico: requires (prerequisiti), upgrades (evoluzione),
    construction_turns (turni di costruzione) per tutti i 30 edifici
  - recruit_pool: 20 edifici militari hanno pool di reclutamento con
    initial, rate, max, experience (modello Medieval II Total War)
  - effetti arricchiti: happiness_bonus, population_growth_bonus,
    trade_bonus, defense_bonus, law_bonus, weapon_bonus, armour_bonus,
    free_upkeep, recruitment_slots
  - technology_tree: 13 categorie di edifici
  - settlement_types: base_population, max_slots
- **File modificati**: dati/config/game_config.json (50KB -> 62KB),
  scripts/autoload/settlement_manager.gd (aggiunto upgrade edifici,
  recruit_pool, effetti aggregati),
  scripts/autoload/economy_engine.gd (trade_bonus, free_upkeep,
  population_growth, happiness, defense_bonus, weapon_bonus, armour_bonus)
- **File nuovi**: scripts/upgrade_game_config.py
- **Motivo**: il sistema economico era basato su moltiplicatori semplici,
  ora e' basato su edifici con evoluzione e catene di sblocco come
  Medieval Total War

### 2026-08-19 — Sistema formazioni militari per battaglia
- **Modifica**: aggiunto sistema di formazioni (linea, quadrato, cuneo,
  ala, sparsa, colonna) con bonus/malus, collisioni tra gruppi, griglia
  di deploy con slot, cambio formazione con tempo di riformazione
- **File nuovi**: scripts/game/formation_system.gd
- **File modificati**: scripts/game/battle_group.gd, scripts/game/battle_unit_visual.gd,
  scripts/ui/battle_view.gd
- **Motivo**: le unita' devono disporsi in formazioni militari diverse,
  occupare spazio fisico e non sovrapporsi

### 2026-08-19 — Generazione agglomerati urbani
- **Modifica**: correzione di generate_settlements.py (i nomi storici delle
  capitali non corrispondono ai nomi moderni nel JSON). Nuovo approccio:
  la provincia piu' popolosa di ogni fazione diventa la capitale.
  3917 province su 4327 hanno ora settlements con edifici.
  155 capitali create con edifici avanzati (fucina, monastero, arsenale).
  410 province escluse (Terra di Nessuno, Mare Aperto, Isole Disabitate)
- **File**: scripts/generate_settlements.py, dati/world/provinces_1000.json
- **Motivo**: 0 province su 4327 avevano settlements, il sistema non funzionava

### 2026-08-19 — Correzione documentazione battaglia
- **Modifica**: il documento 03_BATTAGLIA_TEMPO_REALE.md descriveva la
  battaglia come "proposta da fare" ma in realta' e' gia' implementata.
  Verificato il codice effettivo (battle_view.gd 642 righe, battle_group.gd
  373 righe, battle_unit_visual.gd 194 righe) e riscritto il documento
  per riflettere lo stato reale
- **File**: documenti/03_BATTAGLIA_TEMPO_REALE.md, README.md, documenti/02_ARCHITETTURA_GIOCO.md
- **Motivo**: la documentazione deve descrivere lo stato reale, non le
  proposte superate

### 2026-08-19 — Riorganizzazione documentazione
- **Modifica**: conversione di tutti i file .txt in .md, unificazione
  dei doppioni, creazione di un sistema di documentazione vivo
- **File**: README.md, documenti/01_CONTESTO_STORICO.md, documenti/02_ARCHITETTURA_GIOCO.md,
  documenti/03_BATTAGLIA_TEMPO_REALE.md, documenti/04_REGISTRO_MODIFICHE.md, AGENTS.md
- **Motivo**: i file .txt erano sparsi, doppi e non ordinati; servono
  linee guida vive per lo sviluppo continuo
- **File eliminati**: documenti/PIANO_ARCHITETTURA.txt, documenti/ARCHITETTURA_CITTA_ED_UNITA.txt,
  documenti/Proposta_battaglia_tempo_reale.txt, documenti/RIEPILOGO_ANNO_1000.txt,
  NOTE_SVILUPPO.md (contenuto integrato nei nuovi .md),
  strumenti/recalibration_log.txt (contenuto integrato nel registro)

### 2026-08-17 — Ricalibrazione province
- **Modifica**: ricalibrazione di 529 province con assegnazione corretta
  delle fazioni storiche
- **File**: dati/world/provinces_1000.json, strumenti/recalibration_log.txt
- **Motivo**: correzione nomi fazioni (Califfato Fatimide -> Impero Fatimide)
  e assegnazione province Vichinghi non storiche a Terra di Nessuno
- **Dettaglio**: 529 province cambiate. Principali:
  - Califfato Fatimide -> Impero Fatimide (tutte le province nord-africane)
  - Vichinghi -> Terra di Nessuno (province baltiche non storiche)
  - Impero del Ghana -> Terra di Nessuno (province non storiche)

### 2026-08-16 — Architettura citta' ed unita'
- **Modifica**: definizione completa dei tipi di agglomerato urbano
  (civile, militare, industriale, commerciale), alberi evolutivi
  delle unita' terrestri e navali, unita' particolari per fazione
- **File**: documenti/ARCHITETTURA_CITTA_ED_UNITA.txt, NOTE_SVILUPPO.md
- **Motivo**: serviva una struttura chiara per edifici e unita'

### 2026-08-16 — Proposta battaglia tempo reale
- **Modifica**: stesura della proposta per trasformare la battaglia
  da round a tempo reale 2.5D con posizionamento, pausa tattica e IA
- **File**: documenti/Proposta_battaglia_tempo_reale.txt
- **Motivo**: la battaglia a round era troppo semplice

### 2026-08-14 — Creazione progetto Godot
- **Modifica**: creazione del progetto Godot 4 con struttura base,
  autoload, scene, script e dati JSON iniziali
- **File**: project.godot, scripts/autoload/*.gd, scripts/core/*.gd,
  scripts/ui/*.gd, scenes/*.tscn, dati/config/game_config.json,
  dati/world/factions_1000.json, dati/world/provinces_1000.json
- **Motivo**: partenza del progetto da zero su Godot

### 2026-08-14 — Piano architettura
- **Modifica**: stesura del piano architettonico del progetto Godot
  con struttura cartelle, autoload, scene, file JSON, flusso turno
- **File**: documenti/PIANO_ARCHITETTURA.txt, README.md
- **Motivo**: definire l'architettura prima di scrivere il codice

### 2026-08-14 — Riepilogo storico
- **Modifica**: ricerca storica sulle fazioni, province, capitali
  e unita' del mondo intorno all'anno 1000 d.C.
- **File**: documenti/RIEPILOGO_ANNO_1000.txt
- **Motivo**: servivano dati storici accurati per il gioco


## Errori e lezioni apprese (sessione 2026-08-20)

Questa sezione documenta gli errori commessi per non ripeterli.

### 1. Camera sottoterra
- **Sintomo**: la camera era sotto il terreno, si vedeva solo nero
- **Causa**: `_pitch` inizializzato a -55.0 ma usato come radianti.
  -55 radianti = 9 giri completi = la camera finiva sottoterra
- **Correzione**: inizializzato a -0.96 radianti (circa -55 gradi)
- **Lezione**: in Godot le rotazioni sono in radianti, non gradi.
  Usare `deg_to_rad()` o inserire direttamente il valore in radianti

### 2. Soldati fermi dopo 3 passi
- **Sintomo**: i soldati facevano un passo e si fermavano
- **Causa**: `_process` chiamava `move_formation` ogni frame, che
  ricalcolava i target basandosi sulla posizione attuale. I target
  venivano aggiornati continuamente e i soldati non avanzavano mai
- **Correzione**: `move_formation` chiamato una sola volta a Play
- **Lezione**: non ricalcolare i target ogni frame se devono essere
  fissi. Impostare il target una volta e lasciare che i soldati
  avanzino da soli

### 3. Soldati di lato (guardano le farfalle)
- **Sintomo**: i soldati avanzavano mostrando il fianco invece del
  fronte
- **Causa**: `atan2(dir.x, dir.z)` faceva guardare il +Z (dietro)
  nella direzione di movimento. Il fronte (-Z) guardava dalla parte
  opposta
- **Correzione**: rotazione fissa `face_direction` impostata nella
  scena, non calcolata ogni frame
- **Lezione**: il fronte di un modello Godot e' -Z. Per farlo
  guardare verso il nemico, usare `atan2(-dir.x, -dir.z)` oppure
  impostare una rotazione fissa. Non ricalcolare ogni frame

### 4. Castelli sotto terra o sospesi
- **Sintomo**: i castelli erano sotto il terreno o fluttuanti
- **Causa**: `get_height_at` veniva chiamato in `_ready` prima che
  il terrain_generator avesse finito di generare il terreno
- **Correzione**: `await get_tree().process_frame` prima di
  posizionare i castelli
- **Lezione**: quando si dipende da un altro nodo che si genera in
  `_ready`, aspettare un frame con `await` prima di usare i suoi
  metodi

### 5. Cavalieri in piedi sul cavallo
- **Sintomo**: i cavalieri stavano in piedi sul cavallo invece che
  seduti
- **Causa**: lo scheletro del cavaliere era in posa eretta, senza
  piegare le gambe
- **Correzione**: cosce ruotate 80 gradi (orizzontali), gambe
  pendenti verticali, sella aggiunta sul dorso del cavallo
- **Lezione**: per la posizione seduta, le cosce devono essere
  orizzontali e le gambe pendenti. Aggiungere sempre una sella
  visibile

### 6. Rocce quadrate
- **Sintomo**: le rocce erano scatole quadrate, non realistiche
- **Causa**: usato BoxMesh per le rocce
- **Correzione**: usato SphereMesh deformata con scale casuale
- **Lezione**: per le rocce naturali, usare sfere deformate o mesh
  irregolari, mai scatole

### 7. Coscia invisibile e piedi sottoterra
- **Sintomo**: la coscia non si vedeva, i piedi erano sottoterra
- **Causa**: bacino a y=0.9 ma gambe lunghe 1.2m = piedi a y=-0.3
  (sottoterra). Coscia raggio 0.10 troppo sottile
- **Correzione**: bacino alzato a y=1.0, piede offset corto (0.05),
  coscia raggio 0.13
- **Lezione**: calcolare sempre l'altezza totale dello scheletro
  per assicurarsi che i piedi siano a y=0. Bacino + gambe deve
  essere uguale all'altezza del bacino

### 8. Cavallo senza animazione zampe
- **Sintomo**: il cavaliere camminava sul cavallo fermo
- **Causa**: il cavallo non aveva scheletro, solo mesh statiche.
  L'animazione del soldato veniva applicata al cavaliere
- **Correzione**: cavallo riscritto con Skeleton3D, animazione
  dedicata horse_animation.gd che muove le 4 zampe
- **Lezione**: per animare un animale, serve uno scheletro con
  ossa. Le zampe anteriori e posteriori del cavallo si piegano in
  direzioni opposte (anteriori in avanti, posteriori all'indietro)

### 9. Pausa che non ripartiva
- **Sintomo**: Play -> Pausa -> Play non funzionava
- **Causa**: il formation_manager continuava a muoversi anche in
  pausa perche' non aveva un flag _paused
- **Correzione**: aggiunto flag _paused che ferma il _process
- **Lezione**: il pause deve fermare davvero il _process dei nodi
  figli, non solo quello del padre

### 10. Camera che salta al tasto destro
- **Sintomo**: toccando il tasto destro la camera saltava
- **Causa**: `look_at(Vector3.ZERO)` guardava l'origine del mondo,
  non la posizione della camera. Reset del mouse mancante
- **Correzione**: `look_at(global_position)` + reset posizione
  mouse alla pressione
- **Lezione**: look_at deve guardare il punto di focus della
  camera, non l'origine del mondo. Resettare la posizione mouse
  quando si inizia una rotazione

### 11. Texture non caricate (No loader found)
- **Sintomo**: le texture PNG copiate non venivano caricate
- **Causa**: Godot deve importare le texture prima di poterle
  caricare con `load()`. I file PNG copiati non avevano .import
- **Correzione**: avviato Godot in modalita' editor con `--import`
  per fargli importare tutte le texture
- **Lezione**: quando si copiano texture esterne in un progetto
  Godot, avviare sempre l'editor una volta con `--import` per
  generare i file .import e la cache in .godot/imported

### 12. Variabili con tipo non inferibile
- **Sintomo**: errori "Cannot infer the type of variable"
- **Causa**: usato `:=` con risultati di funzioni che restituiscono
  tipi non determinati staticamente (es. Dictionary.lerp)
- **Correzione**: dichiarato il tipo esplicito (es. `var pos: Vector3`)
- **Lezione**: in GDScript 4, quando il tipo non e' inferibile,
  dichiararlo esplicitamente con `: Tipo`

### 13. Scheletri senza set_bone_pose (parti del corpo al centro)
- **Sintomo**: soldati senza testa, braccia, gambe; tutto compresso
  in un punto; serventi con solo busto; cavalli sproporzionati
- **Causa**: `set_bone_rest` impostato ma `set_bone_pose` mancante.
  In Godot 4 il BoneAttachment3D segue la **pose**, non la **rest**.
  Senza pose, tutte le mesh collassano all'origine (0,0,0)
- **Correzione**: aggiunto `set_bone_pose(idx, Transform3D(Basis(), offset))`
  dopo ogni `set_bone_rest` nella creazione dello scheletro
- **Lezione**: in Godot 4, impostare SEMPRE entrambi:
  `set_bone_rest` (posizione di riposo) e `set_bone_pose`
  (posizione corrente). Senza pose, il BoneAttachment3D non
 funziona

