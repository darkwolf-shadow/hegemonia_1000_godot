extends Node3D
# Provincia 3D: agglomerati, porti costieri e strade costruibili
# Dati persistenti nella singola provincia, senza fiumi navigabili
# Dark Corporation / Stev

var _province_name: String = ""
var _province: Dictionary = {}
var _settlement_root: Node3D
var _settlement_positions: Dictionary = {}
var _status_label: Label
var _build_mode: String = ""
var _road_start: Vector3 = Vector3.ZERO
var _road_preview: MeshInstance3D
var _camera_pivot: Node3D
var _camera: Camera3D
var _is_panning: bool = false
var _is_rotating: bool = false
var _last_mouse_pos := Vector2.ZERO
var _target_fov: float = 55.0

func _ready() -> void:
	_province_name = str(GameState.state.get("last_province", ""))
	if _province_name.is_empty():
		_province_name = "Entre Ríos"
	_province = GameState.state.get("provinces", {}).get(_province_name, {})
	if _province.is_empty():
		_province = WorldData.get_province(_province_name)
	_setup_environment()
	_setup_ui()
	_setup_terrain()
	_setup_decorations()
	_setup_settlements()
	_update_info()

func _setup_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.25, 0.55, 0.85)
	sky_mat.sky_horizon_color = Color(0.75, 0.8, 0.9)
	sky_mat.ground_bottom_color = Color(0.2, 0.25, 0.15)
	sky_mat.ground_horizon_color = Color(0.5, 0.55, 0.4)
	sky.sky_material = sky_mat
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_color = Color(0.6, 0.7, 0.8)
	env.ambient_light_energy = 0.6
	env.ssao_enabled = true
	env.ssao_radius = 1.5
	env.ssao_intensity = 1.5
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	var world_env := WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)
	var sun := DirectionalLight3D.new()
	sun.light_color = Color(1.0, 0.957, 0.839)
	sun.light_energy = 2.5
	sun.shadow_enabled = true
	sun.rotation_degrees = Vector3(-50, -30, 0)
	add_child(sun)
	_camera_pivot = Node3D.new()
	_camera_pivot.name = "CameraPivot"
	_camera_pivot.rotation_degrees.x = -48.0
	add_child(_camera_pivot)
	_camera = Camera3D.new()
	_camera.name = "Camera3D"
	_camera.position = Vector3(0, 0, 42)
	_camera.current = true
	_camera.fov = 55.0
	_camera_pivot.add_child(_camera)
	_camera.look_at(Vector3.ZERO)
	_target_fov = _camera.fov

func _setup_terrain() -> void:
	var geometry: Dictionary = _province.get("geometry", {})
	var rings: Array = _province_rings(geometry)
	if rings.is_empty():
		var fallback := MeshInstance3D.new()
		fallback.name = "ProvinceTerrain"
		fallback.set_script(preload("res://scripts/game/terrain_generator.gd"))
		fallback.map_size = Vector2(40, 30)
		fallback.subdivisions = Vector2i(80, 60)
		fallback.hill_height = _terrain_height()
		fallback.terrain_type = str(_province.get("terrain", "plains"))
		fallback.noise_seed = _province_name.hash()
		add_child(fallback)
		return
	var terrain := _create_province_mesh(rings[0])
	terrain.name = "ProvinceTerrain"
	add_child(terrain)

func _province_rings(geometry: Dictionary) -> Array:
	var result: Array = []
	var coordinates = geometry.get("coordinates", [])
	if geometry.get("type", "") == "MultiPolygon":
		for polygon in coordinates:
			if polygon is Array and not polygon.is_empty():
				result.append(polygon[0])
	elif geometry.get("type", "") == "Polygon" and not coordinates.is_empty():
		result.append(coordinates[0])
	return result

func _create_province_mesh(ring: Array) -> MeshInstance3D:
	var points := PackedVector2Array()
	var min_lon := INF
	var max_lon := -INF
	var min_lat := INF
	var max_lat := -INF
	for point in ring:
		var lon := float(point[0])
		var lat := float(point[1])
		points.append(Vector2(lon, lat))
		min_lon = minf(min_lon, lon)
		max_lon = maxf(max_lon, lon)
		min_lat = minf(min_lat, lat)
		max_lat = maxf(max_lat, lat)
	var center := Vector2((min_lon + max_lon) * 0.5, (min_lat + max_lat) * 0.5)
	var extent := Vector2(maxf(max_lon - min_lon, 0.01), maxf(max_lat - min_lat, 0.01))
	var local_points := PackedVector2Array()
	for point in points:
		local_points.append(Vector2((point.x - center.x) / extent.x * 32.0, -(point.y - center.y) / extent.y * 24.0))
	var triangulation := Geometry2D.triangulate_polygon(local_points)
	var vertices := PackedVector3Array()
	for point in local_points:
		vertices.append(Vector3(point.x, _local_height(point), point.y))
	var indices := PackedInt32Array(triangulation)
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var terrain := MeshInstance3D.new()
	terrain.mesh = array_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = _terrain_color(str(_province.get("terrain", "plains")))
	material.roughness = 0.9
	terrain.material_override = material
	terrain.create_trimesh_collision()
	return terrain

func _local_height(point: Vector2) -> float:
	var terrain := str(_province.get("terrain", "plains")).to_lower()
	var base := _terrain_height() * 0.18
	var variation := sin(point.x * 0.35 + _province_name.hash() * 0.001) * cos(point.y * 0.28) * base * 0.35
	if terrain in ["plains", "coastal", "marsh"]:
		return maxf(0.0, base * 0.35 + variation)
	return maxf(0.0, base + variation)

func _terrain_color(terrain_name: String) -> Color:
	match terrain_name.to_lower():
		"forest": return Color(0.18, 0.30, 0.14)
		"mountains": return Color(0.34, 0.32, 0.28)
		"hills": return Color(0.30, 0.38, 0.18)
		"desert": return Color(0.62, 0.48, 0.26)
		"marsh": return Color(0.22, 0.34, 0.24)
		"coastal": return Color(0.24, 0.39, 0.25)
		"snow": return Color(0.72, 0.75, 0.73)
		_: return Color(0.30, 0.45, 0.22)

func _terrain_height() -> float:
	match str(_province.get("terrain", "plains")).to_lower():
		"mountains": return 8.0
		"hills": return 4.0
		"forest": return 2.5
		"desert": return 1.5
		_: return 1.8

func _setup_decorations() -> void:
	# Dettagli leggeri e coerenti con il terreno: non sostituiscono i dati della provincia
	var terrain := str(_province.get("terrain", "plains")).to_lower()
	var decoration_root := Node3D.new()
	decoration_root.name = "DettagliTerreno"
	add_child(decoration_root)
	if terrain in ["forest", "foresta"]:
		for i in range(18):
			var tree := MeshInstance3D.new()
			tree.mesh = preload("res://scripts/game/tree_mesh.gd").create_tree_mesh()
			tree.position = Vector3(-17.0 + float(i % 6) * 6.0, 0.15, -10.0 + float(i / 6) * 6.0)
			tree.scale = Vector3.ONE * 0.7
			decoration_root.add_child(tree)
	elif terrain in ["mountains", "hills"]:
		for i in range(8):
			var rock := MeshInstance3D.new()
			var rock_mesh := SphereMesh.new()
			rock_mesh.radius = 0.7
			rock_mesh.height = 1.4
			var rock_mat := StandardMaterial3D.new()
			rock_mat.albedo_color = Color(0.28, 0.26, 0.23)
			rock_mat.roughness = 1.0
			rock_mesh.material = rock_mat
			rock.mesh = rock_mesh
			rock.position = Vector3(-15.0 + float(i) * 4.0, 0.5, -9.0 + float(i % 3) * 7.0)
			rock.scale = Vector3(1.5, 0.7, 1.0)
			decoration_root.add_child(rock)

func _setup_settlements() -> void:
	_settlement_root = Node3D.new()
	_settlement_root.name = "Agglomerati"
	add_child(_settlement_root)
	var settlements: Dictionary = _province.get("settlements", {})
	if settlements.is_empty():
		SettlementManager.ensure_settlement(_province, _province_name, "civil")
		settlements = _province.get("settlements", {})
	var names: Array = settlements.keys()
	for i in range(names.size()):
		var name: String = str(names[i])
		var data: Dictionary = settlements[name]
		var pos := _stored_position(data, i, names.size())
		_settlement_positions[name] = pos
		var settlement := _create_settlement_marker(name, data)
		settlement.position = pos
		_settlement_root.add_child(settlement)
	_draw_saved_roads()

func _create_settlement_marker(name: String, data: Dictionary) -> Node3D:
	var marker := Node3D.new()
	marker.name = "Agglomerato_%s" % name
	var mesh_instance := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.35
	mesh.bottom_radius = 0.55
	mesh.height = 0.8
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.72, 0.45, 0.16)
	material.roughness = 0.8
	mesh.material = material
	mesh_instance.mesh = mesh
	mesh_instance.position.y = 0.4
	marker.add_child(mesh_instance)
	var label := Label3D.new()
	label.text = name
	label.position = Vector3(0, 1.1, 0)
	label.font_size = 32
	label.outline_size = 6
	label.modulate = Color(1.0, 0.9, 0.65)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	marker.add_child(label)
	var body := StaticBody3D.new()
	var collision := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.8
	collision.shape = shape
	collision.position.y = 0.5
	body.add_child(collision)
	marker.add_child(body)
	return marker

func _stored_position(data: Dictionary, index: int, count: int) -> Vector3:
	if data.has("position") and data["position"] is Array and data["position"].size() >= 2:
		return Vector3(float(data["position"][0]), 0.4, float(data["position"][1]))
	if data.has("x") and data.has("y"):
		return Vector3((float(data["x"]) - 0.5) * 30.0, 0.4, (float(data["y"]) - 0.5) * 20.0)
	var angle: float = float(index) * TAU / max(1, count)
	return Vector3(cos(angle) * 6.0, 0.4, sin(angle) * 4.0)

func _settlement_scale(count: int) -> float:
	return clampf(1.8 / maxf(1.0, sqrt(float(count))), 0.35, 1.2)

func _draw_saved_roads() -> void:
	var roads: Array = _province.get("roads", [])
	for road in roads:
		if road is Dictionary and road.has("from") and road.has("to"):
			_create_road(Vector3(road["from"][0], 0.5, road["from"][1]), Vector3(road["to"][0], 0.5, road["to"][1]))

func _create_road(from: Vector3, to: Vector3) -> void:
	var road := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.12, 0.04, from.distance_to(to))
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.32, 0.22, 0.12)
	material.roughness = 1.0
	mesh.material = material
	road.mesh = mesh
	road.position = (from + to) * 0.5 + Vector3.UP * 0.08
	road.look_at(to, Vector3.UP)
	_settlement_root.add_child(road)

func _setup_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "HUD"
	add_child(canvas)
	var panel := Panel.new()
	panel.position = Vector2(12, 12)
	panel.size = Vector2(280, 450)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.10, 0.07, 0.04, 0.88)
	panel_style.border_color = Color(0.55, 0.38, 0.16, 0.95)
	panel_style.set_border_width_all(2)
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", panel_style)
	canvas.add_child(panel)
	var back := Button.new()
	back.text = "Torna al menu"
	back.position = Vector2(20, 20)
	back.size = Vector2(150, 40)
	back.pressed.connect(_on_back)
	canvas.add_child(back)
	_status_label = Label.new()
	_status_label.position = Vector2(28, 75)
	_status_label.size = Vector2(250, 140)
	_status_label.add_theme_color_override("font_color", Color(0.95, 0.86, 0.65))
	_status_label.add_theme_font_size_override("font_size", 16)
	canvas.add_child(_status_label)
	var build := Button.new()
	build.text = "Costruisci agglomerato"
	build.position = Vector2(20, 230)
	build.size = Vector2(220, 40)
	build.pressed.connect(_start_settlement_mode)
	canvas.add_child(build)
	var road := Button.new()
	road.text = "Costruisci strada"
	road.position = Vector2(20, 280)
	road.size = Vector2(220, 40)
	road.pressed.connect(_start_road_mode)
	canvas.add_child(road)
	var port := Button.new()
	port.text = "Costruisci porto costiero"
	port.position = Vector2(20, 330)
	port.size = Vector2(220, 40)
	port.disabled = not _is_coastal()
	port.pressed.connect(_build_port)
	canvas.add_child(port)
	var help := Label.new()
	help.text = "ESC: torna al menu\nAgglomerato: clicca una posizione\nStrada: clicca e trascina da origine a fine"
	help.position = Vector2(20, 385)
	canvas.add_child(help)

func _update_info() -> void:
	if _status_label:
		_status_label.text = "Provincia: %s\nTerreno: %s\nPopolazione: %s\nAgglomerati: %d\nModalita': %s" % [_province_name, _province.get("terrain", "N/D"), _province.get("population", 0), _settlement_positions.size(), _build_mode if not _build_mode.is_empty() else "nessuna"]

func _is_coastal() -> bool:
	return str(_province.get("terrain", "")).to_lower() in ["coastal", "costiera", "coast"] or bool(_province.get("properties", {}).get("costiera", false))

func _start_settlement_mode() -> void:
	_build_mode = "agglomerato"
	_update_info()

func _start_road_mode() -> void:
	_build_mode = "strada"
	_update_info()

func _build_port() -> void:
	if not _is_coastal():
		_status_label.text += "\nPorto possibile solo in provincia costiera."
		return
	var names: Array = _province.get("settlements", {}).keys()
	if names.is_empty():
		_status_label.text += "\nServe un agglomerato costiero."
		return
	var settlement: Dictionary = _province["settlements"][names[0]]
	var buildings: Array = settlement.get("buildings", [])
	if "porto" in buildings:
		_status_label.text += "\nIl porto esiste gia'."
		return
	if not _pay_cost({"oro": 150, "legname": 25, "pietra": 25}):
		_status_label.text += "\nRisorse insufficienti per il porto."
		return
	if "porto" not in buildings:
		buildings.append("porto")
		settlement["buildings"] = buildings
		_persist()
		_status_label.text += "\nPorto costiero costruito."

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_on_back()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_MIDDLE:
			_is_panning = event.pressed
			_last_mouse_pos = event.position
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_is_rotating = event.pressed
			_last_mouse_pos = event.position
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_target_fov = maxf(_target_fov - 4.0, 25.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_target_fov = minf(_target_fov + 4.0, 75.0)
	if event is InputEventMouseMotion:
		var delta: Vector2 = event.position - _last_mouse_pos
		_last_mouse_pos = event.position
		if _is_rotating:
			_camera_pivot.rotation.y -= delta.x * 0.005
			_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x - delta.y * 0.005, -1.35, -0.15)
		if _is_panning:
			global_position += Vector3(-delta.x, 0.0, -delta.y) * 0.02
		if _build_mode == "strada" and _road_preview:
			_create_preview(_road_start, _mouse_to_ground(event.position))
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var point := _mouse_to_ground(event.position)
		if event.pressed:
			if _build_mode == "strada":
				_road_start = point
				_create_preview(point, point)
			elif _build_mode == "agglomerato":
				_create_new_settlement(point)
		else:
			if _build_mode == "strada" and _road_preview:
				var end := _mouse_to_ground(event.position)
				if _road_start.distance_to(end) > 0.5:
					_persist_road(_road_start, end)
				_create_preview(Vector3.ZERO, Vector3.ZERO, false)
				_build_mode = ""
				_update_info()
	if event is InputEventMouseMotion and _build_mode == "strada" and _road_preview:
		_create_preview(_road_start, _mouse_to_ground(event.position))

func _mouse_to_ground(screen_pos: Vector2) -> Vector3:
	var camera := get_viewport().get_camera_3d()
	var from := camera.project_ray_origin(screen_pos)
	var direction := camera.project_ray_normal(screen_pos)
	var t := -from.y / direction.y if abs(direction.y) > 0.001 else 0.0
	return from + direction * maxf(t, 0.0)

func _create_new_settlement(pos: Vector3) -> void:
	var cost := {"oro": 100, "legname": 20, "pietra": 20}
	if not _pay_cost(cost):
		_status_label.text += "\nRisorse insufficienti per il nuovo agglomerato."
		return
	var new_name := "%s - Nuovo %d" % [_province_name, _settlement_positions.size() + 1]
	SettlementManager.ensure_settlement(_province, new_name, "civil")
	var data: Dictionary = _province["settlements"][new_name]
	data["position"] = [pos.x, pos.z]
	_settlement_positions[new_name] = pos
	_persist()
	_settlement_root.queue_free()
	_settlement_positions.clear()
	_setup_settlements()
	_build_mode = ""
	_status_label.text += "\nAgglomerato creato in posizione %.1f, %.1f." % [pos.x, pos.z]
	_update_info()

func _pay_cost(cost: Dictionary) -> bool:
	var owner := str(_province.get("owner", ""))
	var factions: Dictionary = GameState.state.get("factions", {})
	var faction: Dictionary = factions.get(owner, {})
	var resources: Dictionary = faction.get("resources", {})
	for resource in cost:
		if int(resources.get(resource, 0)) < int(cost[resource]):
			return false
	for resource in cost:
		resources[resource] = int(resources.get(resource, 0)) - int(cost[resource])
	faction["resources"] = resources
	factions[owner] = faction
	GameState.state["factions"] = factions
	return true

func _persist_road(from: Vector3, to: Vector3) -> void:
	var cost := {"oro": 25, "legname": 10, "pietra": 5}
	if not _pay_cost(cost):
		_status_label.text += "\nRisorse insufficienti per la strada."
		return
	if not _province.has("roads"):
		_province["roads"] = []
	_province["roads"].append({"from": [from.x, from.z], "to": [to.x, to.z], "type": "sterrata"})
	_create_road(from, to)
	_persist()

func _persist() -> void:
	GameState.state.provinces[_province_name] = _province

func _create_preview(from: Vector3, to: Vector3, visible: bool = true) -> void:
	if not visible:
		if _road_preview:
			_road_preview.queue_free()
			_road_preview = null
		return
	if _road_preview == null:
		_road_preview = MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.16, 0.06, 1.0)
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(0.8, 0.7, 0.2)
		mesh.material = material
		_road_preview.mesh = mesh
		add_child(_road_preview)
	_road_preview.position = (from + to) * 0.5 + Vector3.UP * 0.2
	_road_preview.scale.z = maxf(from.distance_to(to), 0.1)
	_road_preview.look_at(to, Vector3.UP)

func _process(delta: float) -> void:
	if _camera:
		_camera.fov = lerpf(_camera.fov, _target_fov, delta * 10.0)

func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/prova_egemonia_1000.tscn")
