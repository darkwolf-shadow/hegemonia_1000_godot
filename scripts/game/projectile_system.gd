extends Node3D
# Sistema di proiettili per arcieri e artiglieria
# Frecce e proiettili volano dall'arciere/artiglieria verso il bersaglio
# Dark Corporation / Stev

var _projectiles: Array[Dictionary] = []
var _max_projectiles: int = 200

func _process(delta: float):
	var alive: Array[Dictionary] = []
	for p in _projectiles:
		if not p.has("node") or not is_instance_valid(p["node"]):
			continue
		var node: Node3D = p["node"]
		p["time"] += delta
		# Traiettoria parabolica per frecce e proiettili
		var t: float = p["time"]
		var total_time: float = p["total_time"]
		if t >= total_time:
			# Arrivato a destinazione
			node.queue_free()
			continue
		var progress: float = t / total_time
		# Posizione lineare tra origine e destinazione
		var pos: Vector3 = p["origin"].lerp(p["target"], progress)
		# Aggiunge arco parabolico (altezza massima a meta' percorso)
		var arc_height: float = p["arc_height"]
		var arc: float = arc_height * sin(progress * PI)
		pos.y += arc
		node.position = pos
		# Orienta il proiettile nella direzione di volo
		var next_progress: float = min(progress + 0.05, 1.0)
		var next_pos: Vector3 = p["origin"].lerp(p["target"], next_progress)
		next_pos.y += arc_height * sin(next_progress * PI)
		if node.global_position.distance_to(next_pos) > 0.01:
			node.look_at(next_pos)
		alive.append(p)
	_projectiles = alive

# Lancia una freccia da origine a target
func spawn_arrow(origin: Vector3, target: Vector3):
	if _projectiles.size() >= _max_projectiles:
		return
	var arrow := MeshInstance3D.new()
	arrow.mesh = preload("res://scripts/game/weapon_mesh.gd").create_arrow()
	arrow.position = origin
	arrow.scale = Vector3(0.8, 0.8, 0.8)
	add_child(arrow)
	# Tempo di volo: dipende dalla distanza (1 secondo ogni 20m)
	var dist: float = origin.distance_to(target)
	var flight_time: float = clamp(dist / 20.0, 0.5, 3.0)
	# Altezza arco: 30% della distanza
	var arc: float = dist * 0.3
	_projectiles.append({
		"node": arrow,
		"origin": origin,
		"target": target,
		"time": 0.0,
		"total_time": flight_time,
		"arc_height": arc,
	})

# Lancia un proiettile di artiglieria (piu' grosso e lento)
func spawn_artillery_projectile(origin: Vector3, target: Vector3):
	if _projectiles.size() >= _max_projectiles:
		return
	var proj := MeshInstance3D.new()
	# Sfera di pietra 0.3m di raggio
	var sphere := SphereMesh.new()
	sphere.radius = 0.15
	sphere.height = 0.3
	proj.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.4, 0.35, 0.3)
	mat.roughness = 0.9
	proj.material_override = mat
	proj.position = origin
	add_child(proj)
	var dist: float = origin.distance_to(target)
	var flight_time: float = clamp(dist / 10.0, 1.0, 5.0)
	var arc: float = dist * 0.4
	_projectiles.append({
		"node": proj,
		"origin": origin,
		"target": target,
		"time": 0.0,
		"total_time": flight_time,
		"arc_height": arc,
	})

func clear_projectiles():
	for p in _projectiles:
		if p.has("node") and is_instance_valid(p["node"]):
			p["node"].queue_free()
	_projectiles.clear()
