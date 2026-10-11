extends Node3D
# Gestore formazioni con unita' individuali animate
# Supporta tipi: spadaccini, lancieri, asceri, arciere, cavalleria, artiglieria
# Le unita' seguono l'altezza del terreno (terreno solido)
# Dark Corporation / Stev

@export var total_units: int = 50
@export var columns: int = 10
@export var spacing: float = 1.5
@export var formation_type: String = "line"
@export var side_color: Color = Color(0.8, 0.2, 0.2)
@export var unit_type: String = "fanteria"
@export var face_direction: float = 0.0
# Se true, la formazione avanza automaticamente verso il centro
# Arcieri e artiglieria non avanzano da soli
@export var auto_advance: bool = true

var _soldiers: Array[Node3D] = []
var _animations: Array[Node] = []
var _targets: Array[Vector3] = []
var _dead: Array[bool] = []
var _move_speed: float = 1.5
var _paused: bool = true
var _selected_index: int = -1
var _face_direction: float = 0.0
var _terrain: Node3D
var _enemies: Array = []
var _has_order: bool = false
var _engage_timer: float = 0.0
var _melee_timer: float = 0.0

const ENGAGE_DISTANCE := 10.0
const MELEE_RANGE := 1.6
const MELEE_RANGE_CAVALRY := 2.4
const ENGAGE_TICK := 0.5
const MELEE_TICK := 0.4
const KILL_CHANCE_INFANTRY := 0.18
const KILL_CHANCE_CAVALRY := 0.28

func set_paused(paused: bool):
	_paused = paused
	for anim in _animations:
		if is_instance_valid(anim):
			anim.set_walking(not paused)

func set_speed(speed: float):
	_move_speed = 1.5 * speed

func set_face_direction(angle: float):
	_face_direction = angle
	for s in _soldiers:
		if is_instance_valid(s):
			s.rotation.y = angle

# Imposta il riferimento al terreno per leggere l'altezza
func set_terrain(terrain: Node3D):
	_terrain = terrain

# Registra le formazioni nemiche per ingaggio automatico e melee
func set_enemies(enemies: Array):
	_enemies = enemies

func _ready():
	_face_direction = face_direction
	# Arcieri e artiglieria non avanzano da soli
	if unit_type in ["arciere", "artiglieria"]:
		auto_advance = false
	_setup_formation()

func _setup_formation():
	for s in _soldiers:
		if is_instance_valid(s):
			s.queue_free()
	_soldiers.clear()
	_animations.clear()
	_targets.clear()
	_dead.clear()
	_selected_index = -1
	
	for i in range(total_units):
		var pos := _formation_position(i).rotated(Vector3.UP, _face_direction)
		var unit: Node3D = preload("res://scripts/game/unit_factory.gd").create_unit(unit_type, side_color)
		unit.position = pos
		unit.rotation.y = _face_direction
		add_child(unit)
		_soldiers.append(unit)
		_targets.append(pos)
		_dead.append(false)
		# Applica la posa seduta del cavaliere dopo che e' nell'albero
		if unit_type == "cavalleria":
			var rider := unit.get_node_or_null("RiderOffset")
			if rider:
				var rskel: Skeleton3D = rider.get_node_or_null("Skeleton3D")
				if rskel:
					preload("res://scripts/game/soldier_skeleton.gd").apply_rider_pose(rskel)
		# Animazione per tutti i tipi, inclusa artiglieria (serventi)
		var anim_node := Node.new()
		anim_node.name = "Animation_%d" % i
		if unit_type == "cavalleria":
			anim_node.set_script(preload("res://scripts/game/horse_animation.gd"))
			add_child(anim_node)
			var horse := unit.get_node_or_null("Horse")
			if horse:
				var horse_skeleton := horse.get_node_or_null("HorseSkeleton")
				if horse_skeleton:
					anim_node.setup(horse_skeleton)
					anim_node._time = randf() * TAU
		elif unit_type == "artiglieria":
			# Artiglieria: anima il primo servente della macchina
			anim_node.set_script(preload("res://scripts/game/soldier_animation.gd"))
			add_child(anim_node)
			var machine := unit.get_child(0)
			if machine:
				var servant := machine.get_node_or_null("Servente_0")
				if servant and servant is Skeleton3D:
					anim_node.setup(servant)
					anim_node._time = randf() * TAU
		else:
			anim_node.set_script(preload("res://scripts/game/soldier_animation.gd"))
			add_child(anim_node)
			var skeleton: Skeleton3D = unit.get_node_or_null("Skeleton3D")
			if skeleton:
				anim_node.setup(skeleton)
				anim_node._time = randf() * TAU
		_animations.append(anim_node)
	# Allinea le unita' all'altezza del terreno dopo la creazione
	call_deferred("_align_to_terrain")

# Allinea tutte le unita' all'altezza del terreno
func _align_to_terrain():
	for s in _soldiers:
		if is_instance_valid(s):
			s.position.y = _terrain_height_local(s.position)

# Altezza terreno alla posizione locale, convertita in spazio locale
# (get_height_at restituisce Y globale: tolgo la Y globale di questo nodo)
func _terrain_height_local(local_pos: Vector3) -> float:
	var g := _get_terrain_height(local_pos)
	return g - global_position.y

# Geometrie formazioni: il fronte e' sempre verso -Z locale
# (gli slot vengono ruotati di _face_direction all'assegnazione)
func _formation_position(index: int) -> Vector3:
	var sp := spacing
	if unit_type == "cavalleria":
		sp = spacing * 2.0
	elif unit_type == "artiglieria":
		sp = spacing * 3.0
	match formation_type:
		"line":
			# Fronte largo: due file sole
			var cols: int = maxi(1, int(ceil(total_units / 2.0)))
			var row: int = index / cols
			var col: int = index % cols
			return Vector3(col * sp - (cols - 1) * sp / 2.0, 0, row * sp)
		"square":
			# Blocco compatto quadrato (lati uguali)
			var side := int(ceil(sqrt(float(total_units))))
			var row := index / side
			var col := index % side
			return Vector3(col * sp - (side - 1) * sp / 2.0, 0,
				row * sp - (side - 1) * sp / 2.0)
		"wedge":
			# Cuneo triangolare vero: punta di 1 uomo davanti,
			# ogni fila dietro ha un uomo in piu'
			var r := 0
			var idx := index
			while idx >= r + 1:
				idx -= r + 1
				r += 1
			return Vector3((float(idx) - float(r) / 2.0) * sp, 0, float(r) * sp)
		"column":
			# Colonna a due file: marcia
			return Vector3((index % 2) * sp - sp / 2.0, 0, float(index / 2) * sp)
		_:
			return Vector3(0, 0, index * sp)

# Legge l'altezza del terreno alle coordinate globali (x, z)
func _get_terrain_height(local_pos: Vector3) -> float:
	if _terrain == null or not is_instance_valid(_terrain):
		return 0.0
	if not _terrain.has_method("get_height_at"):
		return 0.0
	var global_pos := to_global(local_pos)
	return _terrain.get_height_at(global_pos.x, global_pos.z)

func _process(delta: float):
	if _paused:
		return
	var any_moving := false
	for i in range(_soldiers.size()):
		if not is_instance_valid(_soldiers[i]):
			continue
		# Salta i morti: restano a terra e non si muovono piu'
		if i < _dead.size() and _dead[i]:
			continue
		var soldier: Node3D = _soldiers[i]
		# In contatto melee: il soldato tiene la posizione e combatte
		if _is_engaged(soldier):
			if i < _animations.size() and is_instance_valid(_animations[i]):
				_animations[i].set_walking(false)
			soldier.rotation.y = _face_direction
			continue
		# Ignora la componente Y per il calcolo della distanza orizzontale
		var flat_target := Vector3(_targets[i].x, 0, _targets[i].z)
		var flat_pos := Vector3(soldier.position.x, 0, soldier.position.z)
		var flat_dist := flat_target.distance_to(flat_pos)
		if flat_dist > 0.1:
			any_moving = true
			var dir := (flat_target - flat_pos).normalized()
			soldier.position.x += dir.x * _move_speed * delta
			soldier.position.z += dir.z * _move_speed * delta
			# Segui l'altezza del terreno (terreno solido)
			soldier.position.y = _terrain_height_local(soldier.position)
			# Orienta il soldato verso la direzione di movimento
			# Il davanti del soldato e' -Z (standard Godot)
			# atan2(-dir.x, -dir.z) allinea -Z alla direzione di movimento
			soldier.rotation.y = atan2(-dir.x, -dir.z)
			if i < _animations.size() and is_instance_valid(_animations[i]):
				_animations[i].set_walking(true)
				_animations[i].set_speed(_move_speed)
		else:
			# Arrivato: allinea al terreno e guarda la direzione della formazione
			soldier.position.y = _terrain_height_local(soldier.position)
			soldier.rotation.y = _face_direction
			if i < _animations.size() and is_instance_valid(_animations[i]):
				_animations[i].set_walking(false)
	# Ordine completato: riprende il comportamento automatico
	if _has_order and not any_moving:
		_has_order = false
	# Tick strategico: ingaggio automatico e risoluzione corpo a corpo
	_update_engagement(delta)
	_update_melee(delta)

# true se il soldato ha un nemico vivo entro la gittata di mischia
func _is_engaged(soldier: Node3D) -> bool:
	var rng := _melee_range()
	var gp := soldier.global_position
	for ef in _enemies:
		if ef == null or not is_instance_valid(ef):
			continue
		for j in range(ef.get_unit_count()):
			if ef.is_dead(j):
				continue
			var es: Node3D = ef.get_soldier(j)
			if es and gp.distance_squared_to(es.global_position) < rng * rng:
				return true
	return false

func _melee_range() -> float:
	return MELEE_RANGE_CAVALRY if unit_type == "cavalleria" else MELEE_RANGE

# Avanzata automatica verso la formazione nemica piu' vicina
func _update_engagement(delta: float):
	_engage_timer += delta
	if _engage_timer < ENGAGE_TICK:
		return
	_engage_timer = 0.0
	if not auto_advance or _has_order:
		return
	var target := _nearest_enemy_center()
	if target == Vector3.INF:
		return
	var my_center := get_center_global()
	var flat := Vector3(target.x - my_center.x, 0, target.z - my_center.z)
	# Ferma l'avanzata quando la prima linea e' a contatto
	if flat.length() > ENGAGE_DISTANCE:
		move_formation(target, false)
	else:
		set_face_direction(atan2(-flat.x, -flat.z))

func _nearest_enemy_center() -> Vector3:
	var my_center := get_center_global()
	var best := Vector3.INF
	var best_d := INF
	for ef in _enemies:
		if ef == null or not is_instance_valid(ef):
			continue
		if ef.living_count() == 0:
			continue
		var c: Vector3 = ef.get_center_global()
		var d := Vector2(my_center.x - c.x, my_center.z - c.z).length()
		if d < best_d:
			best_d = d
			best = c
	return best

# Risoluzione corpo a corpo: i soldati a contatto tirano per uccidere
func _update_melee(delta: float):
	_melee_timer += delta
	if _melee_timer < MELEE_TICK:
		return
	_melee_timer = 0.0
	if _enemies.is_empty():
		return
	var rng := _melee_range()
	var kill_chance := KILL_CHANCE_CAVALRY if unit_type == "cavalleria" else KILL_CHANCE_INFANTRY
	for i in range(_soldiers.size()):
		if _dead[i] or not is_instance_valid(_soldiers[i]):
			continue
		var gp: Vector3 = _soldiers[i].global_position
		for ef in _enemies:
			if ef == null or not is_instance_valid(ef):
				continue
			for j in range(ef.get_unit_count()):
				if ef.is_dead(j):
					continue
				var es: Node3D = ef.get_soldier(j)
				if es == null:
					continue
				if gp.distance_squared_to(es.global_position) < rng * rng:
					if randf() < kill_chance:
						ef.take_damage(j, 1.0)
					break

# Muove l'intera formazione conservando la forma relativa.
# La direzione della formazione si aggiorna verso la meta.
# player_order=false quando il movimento e' l'avanzata automatica.
func move_formation(new_center_global: Vector3, player_order: bool = true):
	var current_center := get_center_global()
	var flat_dir := Vector3(new_center_global.x - current_center.x, 0,
		new_center_global.z - current_center.z)
	if flat_dir.length() > 0.5:
		_face_direction = atan2(-flat_dir.x, -flat_dir.z)
	# Offset solo orizzontale: la Y arriva sempre dal terreno
	var offset := Vector3(flat_dir.x, 0, flat_dir.z)
	for i in range(_soldiers.size()):
		_targets[i] = _soldiers[i].position + offset
	if player_order:
		_has_order = true

func move_unit(index: int, target_global: Vector3):
	if index < 0 or index >= _soldiers.size():
		return
	var lt := to_local(target_global)
	_targets[index] = Vector3(lt.x, 0, lt.z)

# Centro globale della formazione (media dei soldati vivi)
func get_center_global() -> Vector3:
	var center := Vector3.ZERO
	var count := 0
	for i in range(_soldiers.size()):
		if _dead[i] or not is_instance_valid(_soldiers[i]):
			continue
		center += _soldiers[i].global_position
		count += 1
	if count > 0:
		return center / count
	return global_position

func living_count() -> int:
	var n := 0
	for d in _dead:
		if not d:
			n += 1
	return n

func is_dead(index: int) -> bool:
	return index < 0 or index >= _dead.size() or _dead[index]

func select_unit_at(point_global: Vector3) -> int:
	var local_point := to_local(point_global)
	var best_idx := -1
	var best_dist := 9999.0
	for i in range(_soldiers.size()):
		if not is_instance_valid(_soldiers[i]) or is_dead(i):
			continue
		var p: Vector3 = _soldiers[i].position
		# Distanza 2D: ignora la quota del terreno
		var d := Vector2(p.x - local_point.x, p.z - local_point.z).length()
		if d < best_dist and d < 3.0:
			best_dist = d
			best_idx = i
	_selected_index = best_idx
	return best_idx

# Raggio dell'impronta della formazione: distanza massima di un soldato
# vivo dal centro. Usata dalla vista per la selezione al click.
func footprint_radius() -> float:
	var center := get_center_global()
	var r := 4.0
	for i in range(_soldiers.size()):
		if is_dead(i) or not is_instance_valid(_soldiers[i]):
			continue
		var d := Vector2(_soldiers[i].global_position.x - center.x,
			_soldiers[i].global_position.z - center.z).length()
		if d > r:
			r = d
	return r + 2.0

func get_selected_index() -> int:
	return _selected_index

func get_soldier(index: int) -> Node3D:
	if index < 0 or index >= _soldiers.size():
		return null
	if is_instance_valid(_soldiers[index]):
		return _soldiers[index]
	return null

func get_unit_count() -> int:
	return _soldiers.size()

# Cambia formazione riassegnando i posti attorno al centro ATTUALE.
# I soldati non vengono ricreati: marcio solo verso il nuovo slot,
# quindi funziona anche mentre la formazione e' in movimento.
func set_formation(type: String):
	formation_type = type
	if _soldiers.is_empty():
		_setup_formation()
		return
	# Centroide degli slot della nuova formazione (ruotati verso il fronte)
	var centroid := Vector3.ZERO
	for i in range(_soldiers.size()):
		centroid += _formation_position(i).rotated(Vector3.UP, _face_direction)
	centroid /= max(_soldiers.size(), 1)
	# Sposta gli slot affinche' il centroide coincida col centro attuale
	var offset := _local_center() - centroid
	for i in range(_soldiers.size()):
		if i < _dead.size() and _dead[i]:
			continue
		_targets[i] = _formation_position(i).rotated(Vector3.UP, _face_direction) + offset

# Centro della formazione in coordinate locali (soldati vivi)
func _local_center() -> Vector3:
	var center := Vector3.ZERO
	var count := 0
	for i in range(_soldiers.size()):
		if i < _dead.size() and _dead[i]:
			continue
		if is_instance_valid(_soldiers[i]):
			center += _soldiers[i].position
			count += 1
	return center / count if count > 0 else Vector3.ZERO

# Ordine FERMO: tiene la posizione, niente avanzata automatica
func hold_position():
	auto_advance = false
	_has_order = false
	for i in range(_soldiers.size()):
		if is_instance_valid(_soldiers[i]):
			_targets[i] = _soldiers[i].position

# Ordine AVANZA: riprende l'avanzata autonoma verso il nemico
func resume_advance():
	if unit_type in ["arciere", "artiglieria"]:
		auto_advance = false
	else:
		auto_advance = true
	_has_order = false
	set_paused(false)

# Ordine RITIRATA: indietreggia di ~40m lontano dal nemico, poi tiene
func retreat():
	var my_center := get_center_global()
	var away := Vector3(-sin(_face_direction), 0, -cos(_face_direction))
	var enemy := _nearest_enemy_center()
	if enemy != Vector3.INF:
		var from_enemy := Vector3(my_center.x - enemy.x, 0, my_center.z - enemy.z)
		if from_enemy.length() > 0.5:
			away = from_enemy.normalized()
	move_formation(my_center + away * 40.0)
	auto_advance = false

func take_damage(index: int, damage: float):
	if index < 0 or index >= _soldiers.size():
		return
	if not is_instance_valid(_soldiers[index]):
		return
	# Marca il soldato come morto
	_dead[index] = true
	var soldier: Node3D = _soldiers[index]
	# Ferma l'animazione
	if index < _animations.size() and is_instance_valid(_animations[index]):
		_animations[index].set_walking(false)
	# Fa cadere il soldato a terra: rotazione di 90 gradi (supino)
	# Disgiunto dalla formazione: non riceve piu' ordini di movimento
	var terrain_y := _terrain_height_local(soldier.position)
	soldier.position.y = terrain_y
	# Ruota il corpo a terra (caduto su un fianco)
	soldier.rotation.z = PI / 2.0
