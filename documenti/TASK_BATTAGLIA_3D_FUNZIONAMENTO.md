# TASK — Battaglia 3D: correzione funzionamento (posizionamento, quota, fronte, comandi)

**Branch di riferimento:** `devin/riordino-cartelle-italiano` (commit `264d28a`)
**Branch di lavoro:** `docs/task-battaglia-3d` → poi `feature/battaglia-3d-fix`
**Priorità:** ALTA — il sistema 3D esiste ma è inutilizzabile allo stato attuale
**Vincolo:** i manichini low-poly attuali restano. Texture e vestizione sono fuori scope.

---

## 1. Contesto

Il branch `devin/riordino-cartelle-italiano` contiene un sistema di battaglia 3D
procedurale completo: terreno heightmap, soldati/cavalli/macchine costruiti da
primitive con scheletro animato, formazioni, proiettili, castelli, camera RTS.

L'obiettivo è che la battaglia 3D **funzioni** come una battaglia in stile
AoE/Empire: due schieramenti a fronte sui lati opposti della mappa, formazioni
che mantengono la linea, combattimento che si sviluppa sul terreno, comandi del
giocatore su formazioni e plotoni. La resa grafica dei modelli NON è in scope:
i soldati-manichino attuali sono segnaposto accettabili.

## 2. Audit dei problemi (verificati nel codice)

### Critici

| ID | Problema | Evidenza |
|---|---|---|
| B1 | **Tutte le 12 formazioni spawnano a (0,0,0)** | In `scenes/battle_view_3d.tscn` nessun nodo formazione ha `position`. Truppe accatastate al centro della mappa. |
| B2 | **`_setup_formations()` chiamato prima di popolare `_all_formations`** | In `battle_view_3d.gd` la chiamata è a riga ~36, l'array viene riempito a riga ~45. Risultato: `set_terrain()` e `set_formation("line")` mai applicati → `_terrain` resta `null` → `get_height_at` non viene mai chiamato → **tutti i soldati a quota y=0**, affondano/galleggiano sulle colline. |
| B3 | **Quota calcolata in spazio misto locale/globale** | `_align_to_terrain()` e `_process` assegnano a `soldier.position.y` (locale) l'altezza **globale** del terreno. Corretto solo se il nodo formazione è a y=0; si rompe appena le formazioni vengono posizionate o spostate. Anche `move_formation` include la componente Y dell'offset → derive verticali. |
| B4 | **Pulsante "Carica" manda tutti al centro mappa** | `_on_charge()` chiama `move_formation(Vector3(0,0,0))` — target hardcoded all'origine invece che verso il nemico. |

### Funzionali (bloccano la battaglia)

| ID | Problema | Evidenza |
|---|---|---|
| B5 | **Nessuno schieramento iniziale** | Manca una fase di deploy: le formazioni dovrebbero partire su due linee a fronte (attaccanti a x<0 verso +X, difensori a x>0 verso -X, coerente con i `face_direction` già impostati nella scena). La battaglia deve potersi sviluppare su tutta la mappa 300×300, non solo al centro. |
| B6 | **Comandi non collegati ai plotoni/singole unità** | `move_unit()` e `select_unit_at()` esistono in `formation_manager_3d.gd` ma non sono raggiungibili dall'input: il click seleziona solo la formazione intera (raggio 8 m dal centro) e il click destro muove solo la formazione intera. |
| B7 | **Nessun combattimento corpo a corpo** | `take_damage()` non è mai invocato da contatto tra formazioni. Le truppe si attraversano senza scontrarsi; manca ogni risoluzione melee (danno, morte, ripiegamento) e ogni separazione fisica tra unità. |
| B8 | **`auto_advance` dichiarato ma mai usato** | L'export dice "la formazione avanza automaticamente" ma `_process` muove i soldati solo verso `_targets`; nessuna logica di avanzata/ingaggio autonomo verso il nemico. |

### Minori (da correggere nel passaggio)

| ID | Problema |
|---|---|
| B9 | Pulsante "Veloce x3" applica `set_speed(5.0)` (incoerente). |
| B10 | `_archer_volley` usa `get_soldier(i * 3)` con indici oltre il numero di unità. |
| B11 | `take_damage` ruota l'intero nodo unità (arma inclusa) e sprofonda di 0.3 sotto il terreno. |
| B12 | Menu formazione in pixel fissi (970, 200): non responsive. |
| B13 | `formation_system.gd` (2D, slot in pixel) non è usato dal sistema 3D: verificare se unificare o eliminare il duplicato. |

## 3. Obiettivi della task

### Fase A — Posizionamento e quota (bloccante)

1. **A1** Spostare il riempimento di `_all_formations` prima di `_setup_formations()`.
2. **A2** Schieramento iniziale nella scena: posizioni reali su due linee a fronte
   (es. attaccanti x≈-60, difensori x≈+60, file lungo z), archi/artiglieria in
   seconda linea. Verificare coerenza con `face_direction` (attaccanti verso +X).
3. **A3** Correggere la quota: altezza terreno sempre in coordinate globali;
   il soldato mantiene y locale coerente col genitore. Nessuna deriva Y in
   `move_formation` (offset solo XZ; y ricalcolata dal terreno a ogni frame).
4. **A4** "Carica" deve puntare al centro della formazione nemica più vicina,
   non a (0,0,0).

### Fase B — Comandi e svolgimento

5. **B1** Selezione: click su formazione (raggio più ampio o su singola unità),
   click destro = muovi; mantenere la forma relativa della formazione.
6. **B2** Ordini su plotoni: consentire selezione di un sottoinsieme
   (es. drag-select o selezione singola unità con `select_unit_at`) e ordine di
   movimento solo a quel gruppo via `move_unit`.
7. **B3** Ingaggio: formazioni con `auto_advance` avanzano verso il nemico
   più vicino entro un raggio; contatto corpo a corpo attiva scambio di danni
   (`take_damage`) con morti visibili e coesione di formazione mantenuta
   (niente accatastamento: separazione minima tra unità).
8. **B4** Correzioni minori B9–B12.

### Fase C — Verifica visiva (checkpoint)

9. Screenshot/video da Summer: schieramento iniziale, avanzata a fronte,
   impatto, morti, mappa usata oltre il centro. **Fermarsi per l'approvazione
   dell'utente prima di proseguire oltre la Fase C.**

## 4. Criteri di accettazione

- All'avvio: due schieramenti ordinati su lati opposti, truppe a terra sul
  terreno (nessun soldato interrato o fluttuante, colline incluse).
- Le linee si affrontano: orientamento fronte verso il nemico sia in
  schieramento sia al termine di un movimento ordinato.
- "Carica" e avanzata muovono verso il nemico, non verso il centro.
- Il giocatore può muovere una formazione ovunque sulla mappa; la forma
  (linea/quadrato/cuneo/colonna) si conserva durante lo spostamento.
- Le formazioni mantengono la linea: niente collasso al punto centrale,
  niente sovrapposizione totale tra soldati.
- Contatto = combattimento: i soldati a contatto si infliggono danni e
  cadono; la battaglia ha un esito.
- Zero errori runtime nel debugger; warning preesistenti tollerati.

## 5. Fuori scope

- Texture, vestizione, qualità dei modelli (manichini OK).
- Modelli GLB degli edifici: i castelli procedurali attuali restano.
- Migrazione Summer/Godot 4.7 del branch (task separata di integrazione).
- Merge con la grafica 2.5D di `feature/grafica-aoe-25d`.

## 6. Note tecniche

- File principali: `scripts/ui/battle_view_3d.gd`,
  `scripts/game/formation_manager_3d.gd`, `scenes/battle_view_3d.tscn` e le
  7 varianti per bioma (`battle_*.tscn` condividono la stessa logica — le
  correzioni devono valere per tutte).
- Il terreno espone `get_height_at(x, z)` in coordinate globali.
- Convenzione: il "davanti" del soldato è -Z; `face_direction` attaccanti
  = -π/2 → +X. Mantenere questa convenzione ovunque.
- Testare in Summer su `battle_view_3d.tscn` (plains) e almeno una variante
  collinare (`battle_hills.tscn`) per verificare la quota.
