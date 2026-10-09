extends Node3D
# Scena battaglia 3D RTS - Dark Corporation / Stev
# Sostituisce la vecchia battle_view 2D con una vista 3D isometrica

@onready var _rts_camera: Node3D = $RTSCamera
@onready var _attacker_swordsmen: Node3D = $AttackerSwordsmen
@onready var _attacker_pikemen: Node3D = $AttackerPikemen
@onready var _attacker_axemen: Node3D = $AttackerAxemen
@onready var _attacker_archers: Node3D = $AttackerArchers
@onready var _attacker_cavalry: Node3D = $AttackerCavalry
@onready var _attacker_artillery: Node3D = $AttackerArtillery
@onready var _defender_swordsmen: Node3D = $DefenderSwordsmen
@onready var _defender_pikemen: Node3D = $DefenderPikemen
@onready var _defender_axemen: Node3D = $DefenderAxemen
@onready var _defender_archers: Node3D = $DefenderArchers
@onready var _defender_cavalry: Node3D = $DefenderCavalry
@onready var _defender_artillery: Node3D = $DefenderArtillery
@onready var _terrain: MeshInstance3D = $Terrain
@onready var _dust_particles: GPUParticles3D = $DustParticles

var _all_formations: Array[Node3D] = []
var _selected_formation: int = -1
var _selected_unit: int = -1
var _projectile_system: Node3D
var _volley_timer: float = 0.0
var _scenario_config: Dictionary = {}

var _paused: bool = true
var _battle_started: bool = false
var _speed: float = 1.0

func _ready():
	# Carica la configurazione dello scenario dal terrain_type della scena
	var terrain_type: String = _terrain.terrain_type if _terrain.has_method("get_config") else "plains"
	_scenario_config = preload("res://scripts/game/battle_scenario.gd").get_config(terrain_type)
	_setup_formations()
	_setup_trees()
	_setup_castles()
	_setup_hud()
	# Sistema proiettili
	_projectile_system = Node3D.new()
	_projectile_system.name = "Projectiles"
	_projectile_system.set_script(preload("res://scripts/game/projectile_system.gd"))
	add_child(_projectile_system)
	_all_formations = [_attacker_swordsmen, _attacker_pikemen, _attacker_axemen,
		_attacker_archers, _attacker_cavalry, _attacker_artillery,
		_defender_swordsmen, _defender_pikemen, _defender_axemen,
		_defender_archers, _defender_cavalry, _defender_artillery]
	# Applica colori di fazione
	_apply_faction_colors()
	print("Battaglia 3D pronta. Scenario: %s. Premi Play per iniziare." % terrain_type)

func _apply_faction_colors():
	# Attaccanti: rosso (colore generico attaccante)
	var attacker_color := Color(0.8, 0.2, 0.2)
	# Difensori: blu (colore generico difensore)
	var defender_color := Color(0.2, 0.3, 0.8)
	# In futuro: colori reali dalle fazioni
	var attackers: Array[Node3D] = [_attacker_swordsmen, _attacker_pikemen, _attacker_axemen,
		_attacker_archers, _attacker_cavalry, _attacker_artillery]
	var defenders: Array[Node3D] = [_defender_swordsmen, _defender_pikemen, _defender_axemen,
		_defender_archers, _defender_cavalry, _defender_artillery]
	for f in attackers:
		if f and is_instance_valid(f):
			f.side_color = attacker_color
	for f in defenders:
		if f and is_instance_valid(f):
			f.side_color = defender_color

func _setup_formations():
	# Le formazioni sono gia' posizionate nella scena
	# Assicurati che siano in linea
	for f in _all_formations:
		if f:
			f.set_terrain(_terrain)
			f.set_formation("line")

func _setup_trees():
	# Alberi in base al tipo di terreno dello scenario
	var tree_mesh := preload("res://scripts/game/tree_mesh.gd").create_tree_mesh()
	var trunk_mat := preload("res://scripts/game/texture_loader.gd").create_tree_trunk_material()
	var leaves_mat := preload("res://scripts/game/texture_loader.gd").create_tree_leaves_material()
	# Colore foglie dallo scenario
	var tree_color: Color = _scenario_config.get("tree_color", Color(0.2, 0.4, 0.15))
	var leaves_mat_scenario := StandardMaterial3D.new()
	leaves_mat_scenario.albedo_color = tree_color
	leaves_mat_scenario.roughness = 0.85
	var tree_count: int = _scenario_config.get("tree_count", 40)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("trees_seed_1000")
	for i in range(tree_count):
		var tree := MeshInstance3D.new()
		tree.mesh = tree_mesh
		tree.cast_shadow = 1
		tree.material_override = leaves_mat_scenario
		var angle := rng.randf_range(0, TAU)
		var dist := rng.randf_range(60, 130)
		var x := cos(angle) * dist
		var z := sin(angle) * dist
		var terrain_y: float = 0.0
		if _terrain.has_method("get_height_at"):
			terrain_y = _terrain.get_height_at(x, z)
		tree.position = Vector3(x, terrain_y, z)
		var s := rng.randf_range(0.8, 1.8)
		tree.scale = Vector3(s, s, s)
		tree.rotation.y = rng.randf_range(0, TAU)
		add_child(tree)
	_setup_rocks()

func _setup_rocks():
	var rock_mat := preload("res://scripts/game/texture_loader.gd").create_rock_material()
	var rock_count: int = _scenario_config.get("rock_count", 15)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("rocks_seed_1000")
	for i in range(rock_count):
		var rock := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		var size := rng.randf_range(0.4, 1.8)
		sphere.radius = size * 0.6
		sphere.height = size * 0.8
		rock.mesh = sphere
		rock.material_override = rock_mat
		rock.cast_shadow = 1
		var angle := rng.randf_range(0, TAU)
		var dist := rng.randf_range(35, 85)
		var x := cos(angle) * dist
		var z := sin(angle) * dist
		var terrain_y: float = 0.0
		if _terrain.has_method("get_height_at"):
			terrain_y = _terrain.get_height_at(x, z)
		rock.position = Vector3(x, terrain_y + size * 0.3, z)
		rock.scale = Vector3(rng.randf_range(0.8, 1.3), rng.randf_range(0.6, 1.0), rng.randf_range(0.8, 1.3))
		rock.rotation = Vector3(rng.randf_range(0, 0.5), rng.randf_range(0, TAU), rng.randf_range(0, 0.5))
		add_child(rock)

func _setup_castles():
	# Aspetta che il terreno sia generato
	await get_tree().process_frame
	# Castello difensore su collina a destra
	_create_castle(Vector3(120, 0, 0), Color(0.5, 0.45, 0.4))
	# Castello attaccante su collina a sinistra
	_create_castle(Vector3(-120, 0, 0), Color(0.4, 0.35, 0.3))

func _create_castle(position: Vector3, color: Color):
	var castle := Node3D.new()
	castle.name = "Castle"
	castle.position = position
	# Altezza del terreno in quella posizione
	if _terrain.has_method("get_height_at"):
		castle.position.y = _terrain.get_height_at(position.x, position.z)
	add_child(castle)
	var stone_mat := preload("res://scripts/game/texture_loader.gd").create_stone_material()
	# Mura perimetrali (4 lati)
	var wall_height: float = 6.0
	var wall_thickness: float = 1.5
	var castle_size: float = 15.0
	# Muro nord
	_add_wall(castle, Vector3(0, wall_height/2, -castle_size), Vector3(castle_size*2, wall_height, wall_thickness), stone_mat)
	# Muro sud
	_add_wall(castle, Vector3(0, wall_height/2, castle_size), Vector3(castle_size*2, wall_height, wall_thickness), stone_mat)
	# Muro est
	_add_wall(castle, Vector3(castle_size, wall_height/2, 0), Vector3(wall_thickness, wall_height, castle_size*2), stone_mat)
	# Muro ovest
	_add_wall(castle, Vector3(-castle_size, wall_height/2, 0), Vector3(wall_thickness, wall_height, castle_size*2), stone_mat)
	# Torri agli angoli (4 torri cilindriche)
	for tx in [-castle_size, castle_size]:
		for tz in [-castle_size, castle_size]:
			var tower := MeshInstance3D.new()
			var cyl := CylinderMesh.new()
			cyl.top_radius = 2.0
			cyl.bottom_radius = 2.5
			cyl.height = wall_height + 3.0
			tower.mesh = cyl
			tower.material_override = stone_mat
			tower.cast_shadow = 1
			tower.position = Vector3(tx, (wall_height + 3.0) / 2, tz)
			castle.add_child(tower)
	# Torre centrale (maschio/keep)
	var keep := MeshInstance3D.new()
	var keep_box := BoxMesh.new()
	keep_box.size = Vector3(8, 10, 8)
	keep.mesh = keep_box
	keep.material_override = stone_mat
	keep.cast_shadow = 1
	keep.position = Vector3(0, 5, 0)
	castle.add_child(keep)
	# Merlature sulla torre centrale (piccoli cubi in cima)
	for mx in [-3, -1, 1, 3]:
		for mz in [-3, -1, 1, 3]:
			var merlon := MeshInstance3D.new()
			var m_box := BoxMesh.new()
			m_box.size = Vector3(1.5, 1.5, 1.5)
			merlon.mesh = m_box
			merlon.material_override = stone_mat
			merlon.cast_shadow = 1
			merlon.position = Vector3(mx, 11, mz)
			castle.add_child(merlon)

func _add_wall(parent: Node3D, pos: Vector3, size: Vector3, mat: Material):
	var wall := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	wall.mesh = box
	wall.material_override = mat
	wall.cast_shadow = 1
	wall.position = pos
	parent.add_child(wall)

func _setup_hud():
	var canvas := CanvasLayer.new()
	canvas.name = "HUDCanvas"
	add_child(canvas)
	# Pannello trasparente (marrone scuro, alpha 0.6)
	var panel := Panel.new()
	panel.size = Vector2(800, 80)
	panel.position = Vector2(100, 600)
	# StyleBox trasparente
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.1, 0.05, 0.6)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.6, 0.5, 0.3, 0.8)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	panel.add_theme_stylebox_override("panel", style)
	canvas.add_child(panel)
	# Pulsanti
	var play_btn := Button.new()
	play_btn.text = "Play"
	play_btn.position = Vector2(10, 20)
	play_btn.size = Vector2(80, 40)
	play_btn.pressed.connect(_on_play)
	panel.add_child(play_btn)
	var pause_btn := Button.new()
	pause_btn.text = "Pausa"
	pause_btn.position = Vector2(100, 20)
	pause_btn.size = Vector2(80, 40)
	pause_btn.pressed.connect(_on_pause)
	panel.add_child(pause_btn)
	var fast_btn := Button.new()
	fast_btn.text = "Veloce x3"
	fast_btn.position = Vector2(190, 20)
	fast_btn.size = Vector2(80, 40)
	fast_btn.pressed.connect(_on_fast)
	panel.add_child(fast_btn)
	var charge_btn := Button.new()
	charge_btn.text = "Carica"
	charge_btn.position = Vector2(290, 20)
	charge_btn.size = Vector2(80, 40)
	charge_btn.pressed.connect(_on_charge)
	panel.add_child(charge_btn)
	var shield_btn := Button.new()
	shield_btn.text = "Muro Scudi"
	shield_btn.position = Vector2(380, 20)
	shield_btn.size = Vector2(80, 40)
	shield_btn.pressed.connect(_on_shield_wall)
	panel.add_child(shield_btn)
	var standard_btn := Button.new()
	standard_btn.text = "Standard"
	standard_btn.position = Vector2(470, 20)
	standard_btn.size = Vector2(80, 40)
	standard_btn.pressed.connect(_on_standard)
	panel.add_child(standard_btn)
	# Pulsante Esci
	var exit_btn := Button.new()
	exit_btn.text = "Esci (ESC)"
	exit_btn.position = Vector2(560, 20)
	exit_btn.size = Vector2(80, 40)
	exit_btn.pressed.connect(_on_exit)
	panel.add_child(exit_btn)
	# Etichetta fase (sfondo semi-trasparente)
	var phase_bg := ColorRect.new()
	phase_bg.color = Color(0, 0, 0, 0.5)
	phase_bg.position = Vector2(5, 5)
	phase_bg.size = Vector2(210, 25)
	canvas.add_child(phase_bg)
	var phase_label := Label.new()
	phase_label.name = "PhaseLabel"
	phase_label.text = "Pausa - Premi Play"
	phase_label.position = Vector2(10, 8)
	phase_label.size = Vector2(200, 20)
	phase_label.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
	canvas.add_child(phase_label)

func _on_play():
	_paused = false
	_speed = 1.0
	_battle_started = true
	# Le formazioni NON si muovono automaticamente
	# Il giocatore le posiziona con click destro
	for f in _all_formations:
		if f and is_instance_valid(f):
			f.set_paused(false)
			f.set_speed(1.0)
	_update_phase_label("Play: truppe pronte. Click sx su truppa, click dx per muovere")

func _on_pause():
	_paused = true
	for f in _all_formations:
		if f and is_instance_valid(f):
			f.set_paused(true)
	_update_phase_label("Battaglia in pausa")

func _on_fast():
	_paused = false
	_speed = 3.0
	_battle_started = true
	for f in _all_formations:
		if f and is_instance_valid(f):
			f.set_paused(false)
			f.set_speed(5.0)
	_update_phase_label("Battaglia veloce x3 - click dx per muovere")

func _on_charge():
	_attacker_swordsmen.set_formation("wedge")
	_attacker_swordsmen.move_formation(Vector3(0, 0, 0))
	_attacker_cavalry.move_formation(Vector3(0, 0, 5))
	_dust_particles.emitting = true

func _on_shield_wall():
	_attacker_swordsmen.set_formation("square")
	_attacker_pikemen.set_formation("square")

func _on_standard():
	_attacker_swordsmen.set_formation("line")
	_attacker_pikemen.set_formation("line")

func _on_exit():
	get_tree().quit()

# Usa _unhandled_input per non intercettare i click sui pulsanti UI
func _unhandled_input(event: InputEvent):
	# ESC torna al menu di prova
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file("res://scenes/prova_egemonia_1000.tscn")
	# Click sinistro: seleziona formazione e mostra menu
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_left_click()
	# Click destro: muove la formazione selezionata verso il punto
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		_handle_right_click()

func _handle_left_click():
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	var mouse_pos := get_viewport().get_mouse_position()
	var from := camera.project_ray_origin(mouse_pos)
	var dir := camera.project_ray_normal(mouse_pos)
	var t := -from.y / dir.y
	if t <= 0 or t > 500:
		return
	var point := from + dir * t
	# Cerca la formazione piu' vicina al click (distanza 2D, raggio 8m)
	var best_form := -1
	var best_dist := 9999.0
	for fi in range(_all_formations.size()):
		var f: Node3D = _all_formations[fi]
		if f == null or not is_instance_valid(f):
			continue
		# Centro della formazione (media posizioni globali)
		var center := Vector3.ZERO
		var count := 0
		for i in range(f.get_unit_count()):
			var s: Node3D = f.get_soldier(i)
			if s and is_instance_valid(s):
				center += s.global_position
				count += 1
		if count > 0:
			center /= count
			# Distanza 2D (solo x, z) - ignora l'altezza
			var d2d := sqrt(pow(center.x - point.x, 2) + pow(center.z - point.z, 2))
			if d2d < best_dist and d2d < 8.0:
				best_dist = d2d
				best_form = fi
	if best_form >= 0:
		_selected_formation = best_form
		_show_formation_menu(mouse_pos)
		var fname := _formation_name(_selected_formation)
		_update_phase_label("Selezionato: %s - click dx per muovere" % fname)
	else:
		# Nessuna formazione trovata: chiudi il menu se aperto
		_close_menu()
		_update_phase_label("Nessuna formazione qui. Click su una truppa.")

func _handle_right_click():
	# Chiudi il menu se aperto (non blocca il click destro)
	_close_menu()
	if _selected_formation < 0:
		_update_phase_label("Prima seleziona una formazione (click sx)")
		return
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	var mouse_pos := get_viewport().get_mouse_position()
	var from := camera.project_ray_origin(mouse_pos)
	var dir := camera.project_ray_normal(mouse_pos)
	var t := -from.y / dir.y
	if t <= 0 or t > 500:
		return
	var point := from + dir * t
	var f: Node3D = _all_formations[_selected_formation]
	if f and is_instance_valid(f):
		f.move_formation(point)
		f.set_paused(false)
		var fname := _formation_name(_selected_formation)
		_update_phase_label("%s -> (%.0f, %.0f)" % [fname, point.x, point.z])

# Pannello fisso per la formazione selezionata (non blocca i click sulla mappa)
func _show_formation_menu(mouse_pos: Vector2):
	var canvas := get_node_or_null("HUDCanvas")
	if canvas == null:
		return
	# Rimuovi menu esistente
	var old_menu := canvas.get_node_or_null("FormationMenu")
	if old_menu:
		old_menu.queue_free()
	# Pannello fisso in basso a destra (non intercetta i click sulla mappa)
	var panel := Panel.new()
	panel.name = "FormationMenu"
	panel.position = Vector2(970, 200)
	panel.size = Vector2(220, 300)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.08, 0.04, 0.92)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.6, 0.5, 0.3, 0.9)
	panel.add_theme_stylebox_override("panel", style)
	canvas.add_child(panel)
	# Titolo formazione
	var title := Label.new()
	title.text = "Formazione:"
	title.position = Vector2(10, 8)
	title.size = Vector2(200, 20)
	title.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
	panel.add_child(title)
	# Pulsanti formazione
	var ftype_map := {"linea": "line", "quadrato": "square", "cuneo": "wedge", "colonna": "column"}
	var fy := 30
	for ftype in ["linea", "quadrato", "cuneo", "colonna"]:
		var btn := Button.new()
		btn.text = ftype
		btn.position = Vector2(10, fy)
		btn.size = Vector2(200, 28)
		var ftype_key: String = ftype_map[ftype]
		btn.pressed.connect(_set_formation.bind(ftype_key))
		panel.add_child(btn)
		fy += 32
	# Titolo comportamento
	var title2 := Label.new()
	title2.text = "Comportamento:"
	title2.position = Vector2(10, fy + 5)
	title2.size = Vector2(200, 20)
	title2.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
	panel.add_child(title2)
	fy += 33
	# Pulsanti comportamento
	for btype in ["fermo", "avanza", "carica", "ritirata"]:
		var btn := Button.new()
		btn.text = btype
		btn.position = Vector2(10, fy)
		btn.size = Vector2(200, 28)
		btn.pressed.connect(_set_behavior.bind(btype))
		panel.add_child(btn)
		fy += 32

func _set_formation(ftype: String):
	if _selected_formation < 0:
		return
	var f: Node3D = _all_formations[_selected_formation]
	if f and is_instance_valid(f):
		f.set_formation(ftype)
		var fname := _formation_name(_selected_formation)
		_update_phase_label("%s: formazione %s" % [fname, ftype])
	_close_menu()

func _set_behavior(btype: String):
	if _selected_formation < 0:
		return
	var f: Node3D = _all_formations[_selected_formation]
	if f and is_instance_valid(f):
		match btype:
			"fermo":
				f.set_paused(true)
			"avanza":
				f.set_paused(false)
				f.set_speed(1.0)
			"carica":
				f.set_paused(false)
				f.set_speed(5.0)
				f.set_formation("wedge")
			"ritirata":
				f.set_paused(false)
				f.set_speed(2.0)
				# Inverte la direzione
				var curr: float = f.face_direction
				f.set_face_direction(curr + PI)
		var fname := _formation_name(_selected_formation)
		_update_phase_label("%s: %s" % [fname, btype])
	_close_menu()

func _close_menu():
	var menu := get_node_or_null("HUDCanvas/FormationMenu")
	if menu:
		menu.queue_free()

# Restituisce il nome leggibile della formazione
func _formation_name(idx: int) -> String:
	var names := ["AttSpadaccini", "AttLancieri", "AttAsceri", "AttArcieri",
		"AttCavalleria", "AttArtiglieria",
		"DefSpadaccini", "DefLancieri", "DefAsceri", "DefArcieri",
		"DefCavalleria", "DefArtiglieria"]
	if idx >= 0 and idx < names.size():
		return names[idx]
	return "?"

func _update_phase_label(text: String):
	var canvas = get_node_or_null("HUDCanvas")
	if canvas:
		var label = canvas.get_node_or_null("PhaseLabel")
		if label:
			label.text = text

func _process(delta: float):
	# Non chiamare move_formation ogni frame: i target sono fissi
	# impostati quando si preme Play. I soldati avanzano da soli.
	# Gestione volute di frecce e artiglieria
	if _battle_started and not _paused:
		_volley_timer += delta
		if _volley_timer >= 2.0:
			_volley_timer = 0.0
			_fire_volley()

func _fire_volley():
	# Arcieri attaccanti sparano verso i difensori e viceversa
	_archer_volley(_attacker_archers, _defender_swordsmen, true)
	_archer_volley(_defender_archers, _attacker_swordsmen, false)
	# Artiglieria
	_artillery_volley(_attacker_artillery, _defender_swordsmen, true)
	_artillery_volley(_defender_artillery, _attacker_swordsmen, false)

func _archer_volley(archers: Node3D, targets: Node3D, attacker: bool):
	if archers == null or not is_instance_valid(archers):
		return
	if targets == null or not is_instance_valid(targets):
		return
	# Solo alcuni arcieri sparano per volta (5 per voluta)
	var count: int = min(5, archers.get_unit_count())
	for i in range(count):
		var archer: Node3D = archers.get_soldier(i * 3)
		if archer == null:
			continue
		# Bersaglio: un soldato casuale nella formazione nemica
		var target_count: int = targets.get_unit_count()
		if target_count == 0:
			continue
		var target_idx: int = randi() % target_count
		var target_soldier: Node3D = targets.get_soldier(target_idx)
		if target_soldier == null:
			continue
		# Origine: posizione dell'arciere + altezza del braccio (1.3m)
		var origin := archer.global_position + Vector3(0, 1.3, 0)
		# Bersaglio: posizione del soldato nemico
		var target_pos := target_soldier.global_position
		_projectile_system.spawn_arrow(origin, target_pos)

func _artillery_volley(artillery: Node3D, targets: Node3D, attacker: bool):
	if artillery == null or not is_instance_valid(artillery):
		return
	if targets == null or not is_instance_valid(targets):
		return
	var count: int = artillery.get_unit_count()
	for i in range(count):
		var engine: Node3D = artillery.get_soldier(i)
		if engine == null:
			continue
		var target_count: int = targets.get_unit_count()
		if target_count == 0:
			continue
		var target_idx: int = randi() % target_count
		var target_soldier: Node3D = targets.get_soldier(target_idx)
		if target_soldier == null:
			continue
		var origin := engine.global_position + Vector3(0, 1.0, 0)
		var target_pos := target_soldier.global_position
		_projectile_system.spawn_artillery_projectile(origin, target_pos)
