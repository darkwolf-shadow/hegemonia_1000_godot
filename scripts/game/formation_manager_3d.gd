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
		var pos := _formation_position(i)
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
			s.position.y = _get_terrain_height(s.position)

func _formation_position(index: int) -> Vector3:
	var sp := spacing
	if unit_type == "cavalleria":
		sp = spacing * 2.0
	elif unit_type == "artiglieria":
		sp = spacing * 3.0
	match formation_type:
		"line":
			var row := index / columns
			var col := index % columns
			return Vector3(col * sp - columns * sp / 2.0, 0, row * sp)
		"square":
			var side := int(sqrt(float(total_units)))
			var row := index / side
			var col := index % side
			return Vector3(col * sp - side * sp / 2.0, 0, row * sp - side * sp / 2.0)
		"wedge":
			var row := index / columns
			var col := index % columns
			var offset := float(row) * sp * 0.5
			return Vector3(col * sp - columns * sp / 2.0 + offset, 0, row * sp)
		"column":
			return Vector3(0, 0, index * sp)
		_:
			var row := index / columns
			var col := index % columns
			return Vector3(col * sp, 0, row * sp)

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
	for i in range(_soldiers.size()):
		if not is_instance_valid(_soldiers[i]):
			continue
		# Salta i morti: restano a terra e non si muovono piu'
		if i < _dead.size() and _dead[i]:
			continue
		var soldier: Node3D = _soldiers[i]
		# Ignora la componente Y per il calcolo della distanza orizzontale
		var flat_target := Vector3(_targets[i].x, 0, _targets[i].z)
		var flat_pos := Vector3(soldier.position.x, 0, soldier.position.z)
		var flat_dist := flat_target.distance_to(flat_pos)
		if flat_dist > 0.1:
			var dir := (flat_target - flat_pos).normalized()
			soldier.position.x += dir.x * _move_speed * delta
			soldier.position.z += dir.z * _move_speed * delta
			# Segui l'altezza del terreno (terreno solido)
			soldier.position.y = _get_terrain_height(soldier.position)
			# Orienta il soldato verso la direzione di movimento
			# Il davanti del soldato e' -Z (standard Godot)
			# atan2(-dir.x, -dir.z) allinea -Z alla direzione di movimento
			soldier.rotation.y = atan2(-dir.x, -dir.z)
			if i < _animations.size() and is_instance_valid(_animations[i]):
				_animations[i].set_walking(true)
				_animations[i].set_speed(_move_speed)
		else:
			# Arrivato: allinea al terreno e guarda la direzione della formazione
			soldier.position.y = _get_terrain_height(soldier.position)
			soldier.rotation.y = _face_direction
			if i < _animations.size() and is_instance_valid(_animations[i]):
				_animations[i].set_walking(false)

func move_formation(new_center_global: Vector3):
	var local_target := to_local(new_center_global)
	var current_center := Vector3.ZERO
	for s in _soldiers:
		if is_instance_valid(s):
			current_center += s.position
	current_center /= max(_soldiers.size(), 1)
	var offset := local_target - current_center
	for i in range(_soldiers.size()):
		_targets[i] = _soldiers[i].position + offset

func move_unit(index: int, target_global: Vector3):
	if index < 0 or index >= _soldiers.size():
		return
	_targets[index] = to_local(target_global)

func select_unit_at(point_global: Vector3) -> int:
	var local_point := to_local(point_global)
	var best_idx := -1
	var best_dist := 9999.0
	for i in range(_soldiers.size()):
		if not is_instance_valid(_soldiers[i]):
			continue
		var d := _soldiers[i].position.distance_to(local_point)
		if d < best_dist and d < 3.0:
			best_dist = d
			best_idx = i
	_selected_index = best_idx
	return best_idx

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

func set_formation(type: String):
	formation_type = type
	_setup_formation()

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
	var terrain_y := _get_terrain_height(soldier.position)
	soldier.position.y = terrain_y
	# Ruota il corpo a terra (caduto su un fianco)
	soldier.rotation.z = PI / 2.0
	# Abbassa leggermente per non penetrare nel terreno
	soldier.position.y -= 0.3
