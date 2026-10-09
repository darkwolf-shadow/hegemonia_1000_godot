# Task operativo — Grafica stile Age of Empires 2.5D

**Dark Corporation / Stev**

Task per l'esecuzione su Summer Engine con controllo MCP (Devin).
Regola di checkpoint: implementazione e test automatici liberi; la verifica
grafica finale richiede la visione del progettista. Lo stato diventa
`IN ATTESA DI VISIONE DEL PROGETTISTA` dopo il push del branch.

## BASE DI LAVORO

- Repository: `darkwolf-shadow/hegemonia_1000_godot`
- Branch di partenza: `main` al commit `01a90d5` (post-migrazione Summer)
- Branch di lavoro: `feature/grafica-aoe-25d`
- Percorso locale: `D:\Dev\hegemonia_1000_godot`
- Engine: Summer Engine v0.7.0 (base Godot 4.7.2), porta API 6550
- Driver: `python D:\Dev\summer_mcp.py call <tool> '<args>'`
- Scene di verifica: `res://scenes/battle_view.tscn`, `res://scenes/strategic_map.tscn`
- Test: `res://tests/test_runner.tscn`

## OBIETTIVO

Portare la grafica del gioco allo stile Age of Empires in 2.5D: sprite 2D
su campo dipinto, formazioni di soldati individuali, profondita' isometrica,
pose animate. La logica di battaglia esistente (tempo reale, controllo
diretto, pausa, comandante, morale, tattiche) NON va riscritta: si sostituisce
solo la rappresentazione visiva e si estende dove serve.

Decisioni approvate dal progettista: controllo diretto dei gruppi, pausa
libera, comandante come unita' speciale con crollo del morale, bonus/malus
del terreno attivi in battaglia.

## FASE 1 — BATTAGLIA STILE AoE (unica fase sbloccata)

### 1.1 Formazioni multi-sprite

Oggi `BattleGroup` = un solo `Sprite2D` + etichetta numerica. Obiettivo:
ogni gruppo e' una formazione di soldati visibili.

- `battle_unit_visual.gd` diventa un contenitore di N sprite individuali.
- Numero di soldati visibili: `visibili = clamp(count, 3, 15)`;
  un soldato disegnato rappresenta un sottoinsieme delle unita' reali.
- Quando `count` scende, i soldati muoiono e scompaiono uno a uno
  (caduta + dissolvenza), non solo il numero sull'etichetta.
- Formazioni per ruolo:
  - fanteria: blocco rettangolare serrato;
  - cavalleria/elefanti: cuneo;
  - arcieri/balestrieri: linea larga e rada;
  - artiglieria: fila singola retrocessa.
- Ogni sprite mantiene il flip orizzontale gia' gestito da
  `set_facing_right`.

### 1.2 Pose e stati visivi

Stati minimi per sprite: `idle`, `march`, `charge`, `attack`, `death`.
Senza sprite sheet si usano trucchi economici gia' coerenti col progetto:

- `idle`: sprite base, micro-bob lento sfasato per soldato;
- `march`: bob piu' marcato (esiste gia'), leggera rotazione ±4°;
- `charge`: usa `IconManager.get_battle_sprite` se presente, piu'
  polvere (esiste gia') e inclinazione in avanti;
- `attack`: scatto breve verso il bersaglio (lunge 8-12 px);
- `death`: rotazione a terra + fade out in ~0.4 s, poi rimozione.
- Fallback obbligatorio: se manca lo sprite di carica, riusa quello base.
  Mai lasciare sprite nullo.

### 1.3 Profondita' 2.5D

- Scala prospettica: sprite piu' in basso sullo schermo sono piu' grandi
  (fattore dolce, es. scala 0.85→1.15 sull'asse Y del campo).
- `z_index` ordinato per `position.y`: chi e' piu' in basso copre chi
  e' piu' in alto.
- Ombra ellittica sotto ogni soldato (disegnata in `_draw`, colore nero
  alpha ~0.25, offset di qualche pixel).

### 1.4 Campo e telecamera

- `BattleField` scrollabile: trascinamento ai bordi o WASD/freccie;
- zoom con rotella mouse (limiti 0.6x–1.6x);
- estendere l'area utile del campo oltre i ±600 attuali solo se serve
  alle formazioni; sfondo resta il PNG del bioma, ripetuto/tile se
  il campo e' piu' grande dello schermo.

### 1.5 Conservazione del gameplay

Non modificare: calcolo danni, morale, rotta, tattiche e loro modificatori,
IA avversaria, segnali `selected`/`died`/`commander_died`, flusso
deploy→combat→fine. I pannelli UI restano, adattati se servono spazi.

## FASE 2 — MAPPA STRATEGICA (bloccata fino ad approvazione Fase 1)

- Province con riempimento per terreno + tinta del proprietario
  (overlay semi-trasparente), bordi piu' leggibili.
- Icone unita'/insediamenti gia' esistenti, dimensionate allo zoom.
- Obiettivo estetico: mappa dipinta tipo AoE/miniatura, non foglio Excel.

## FASE 3 — EFFETTI E FINITURA (bloccata fino ad approvazione Fase 2)

- Proiettili con arco parabolico (arcieri) e tracciato (artiglieria).
- Flash d'impatto, breve shake su carica di cavalleria.
- Stendardo della fazione sopra il comandante.
- Sfondi di battaglia aggiuntivi se i biomi reali lo richiedono.

## CONFINE DEL TASK

File autorizzati:
- `scripts/game/battle_unit_visual.gd`, `scripts/game/battle_group.gd`,
  `scripts/game/projectile.gd` e nuovi script in `scripts/game/`;
- `scripts/ui/battle_view.gd`, `scenes/battle_view.tscn`,
  `scenes/battle_group.tscn`, `scenes/projectile.tscn`;
- `scripts/autoload/icon_manager.gd` solo per aggiungere fallback;
- nuovi asset sotto `assets/` (sprite pose, ombre, effetti);
- `scripts/ui/strategic_map.gd` e scene collegate solo in Fase 2/3.

File esclusi: `battle_system.gd` (regole), `ai_controller.gd`,
`economy_engine.gd`, `game_state.gd`, `world_data.gd`, JSON in `data/`
(salvo aggiunta di campi puramente estetici concordati).

## RIPRODUZIONE E VERIFICA

1. Avvio scena battaglia diretta: `summer_open_scene` +
   `summer_play` su `res://scenes/battle_view.tscn`
   (fallback di test gia' presente: Bizantini vs Fatimidi a Nicea).
2. `test_runner.tscn` deve continuare a passare interamente.
3. Controlli automatici attesi:
   - gruppo con count pieno mostra N soldati; count dimezzato -> meta'
     soldati scomparsi con animazione di morte;
   - nessuno sprite nullo anche per unita' senza icona di carica;
   - selezione, ordini, pausa, tattiche, comandante funzionano come prima;
   - fps accettabile con ~200 soldati visibili (log durata frame se >30 ms).

Log attesi in console:

```text
[TEST][BATTLE_GFX][PASS] group=<tipo> sprites=<n_visibili> count=<n_reali>
[TEST][BATTLE_GFX][PASS] kill=<tipo> soldati_rimossi=<n> durata_morte=<ms>
[TEST][BATTLE_GFX][FAIL] group=<tipo> motivo=<descrizione>
```

## CHECKPOINT VISIVO

Al termine dei test automatici: fermarsi, fare `summer_screenshot` della
battaglia in deploy e in combattimento, commit e push del branch,
riferire al progettista con screenshot e log. Non procedere a Fase 2
senza approvazione esplicita.

## CONSEGNA

- Branch `feature/grafica-aoe-25d` pubblicato.
- Report: file toccati, soldati per gruppo, formazioni implementate,
  differenze visive prima/dopo, eventuali limiti noti.
