extends Node3D
# Controller mappa 3D: Pan, Zoom, Rotazione, Tilt
# La mappa e' una SOLA PlaneMesh piatta con altezza solo nello shader
# Dark Corporation / Stev

@onready var _pivot: Node3D = $CameraPivot
@onready var _camera: Camera3D = $CameraPivot/Camera3D

@export var pan_speed: float = 0.5
@export var rotation_speed: float = 0.005
@export var zoom_speed: float = 4.0
@export var min_fov: float = 25.0
@export var max_fov: float = 75.0

var _is_panning: bool = false
var _last_mouse_pos := Vector2.ZERO
var _target_fov: float = 60.0
var _world_data: Node = null
var _province_lookup: Dictionary = {}
var _province_id_image: Image = null
var _province_popup: Control = null

func _ready():
	_setup_environment()
	_setup_terrain()
	_setup_hud()
	_setup_raycast_data()
	_pivot.rotation_degrees.x = -45.0
	_camera.position = Vector3(0, 0, 50.0)
	_target_fov = _camera.fov
	print("Mappa strategica 3D pronta. Sinistro/Destro: Pan. Rotellina: Zoom ottico.")

func _setup_environment():
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.25, 0.55, 0.85)
	sky_mat.sky_horizon_color = Color(0.6, 0.75, 0.9)
	sky_mat.ground_horizon_color = Color(0.5, 0.55, 0.45)
	sky_mat.ground_bottom_color = Color(0.2, 0.25, 0.15)
	env.sky.sky_material = sky_mat
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_color = Color(0.7, 0.75, 0.8)
	env.ambient_light_energy = 0.5
	env.fog_enabled = true
	env.fog_light_color = Color(0.7, 0.8, 0.9)
	env.fog_density = 0.0005
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	var world_env := WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)
	var sun := DirectionalLight3D.new()
	sun.light_color = Color(1.0, 0.95, 0.85)
	sun.light_energy = 1.8
	sun.shadow_enabled = true
	sun.rotation_degrees = Vector3(-50, -30, 0)
	add_child(sun)

func _setup_terrain():
	var terrain := MeshInstance3D.new()
	terrain.set_script(preload("res://scripts/game/terrain_heightmap.gd"))
	terrain.name = "Terrain"
	add_child(terrain)

func _setup_hud():
	var canvas := CanvasLayer.new()
	canvas.name = "HUD"
	add_child(canvas)
	var back_btn := Button.new()
	back_btn.text = "Torna al menu"
	back_btn.position = Vector2(20, 20)
	back_btn.size = Vector2(140, 40)
	back_btn.pressed.connect(_on_back)
	canvas.add_child(back_btn)
	var help := Label.new()
	help.position = Vector2(20, 70)
	help.size = Vector2(350, 100)
	help.text = "Sinistro: Pan\nDestro: Ruota/Inclina\nRotellina: Zoom\nClick: seleziona provincia\nESC: torna al menu"
	canvas.add_child(help)
	var popup_scene := load("res://scenes/province_popup.tscn")
	if popup_scene:
		_province_popup = popup_scene.instantiate()
		_province_popup.name = "ProvincePopup"
		_province_popup.enter_province.connect(_on_enter_province)
		canvas.add_child(_province_popup)

func _setup_raycast_data():
	_world_data = get_node_or_null("/root/WorldData")
	if _world_data:
		var lookup_path := "res://dati/world/province_id_lookup.json"
		var data: Dictionary = _world_data.load_json(lookup_path)
		_province_lookup = data
	var img := Image.new()
	var err := img.load("res://risorse/terreno/province_id_map.png")
	if err == OK:
		_province_id_image = img
		print("Province ID Map caricata: %dx%d" % [img.get_width(), img.get_height()])

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if _last_mouse_pos.distance_to(event.position) < 5.0:
				_select_province_at(event.position)
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == MOUSE_BUTTON_MIDDLE:
			_is_panning = event.pressed
			_last_mouse_pos = event.position
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_target_fov = maxf(_target_fov - zoom_speed, min_fov)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_target_fov = minf(_target_fov + zoom_speed, max_fov)
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_on_back()

	if event is InputEventMouseMotion:
		var delta: Vector2 = event.position - _last_mouse_pos
		_last_mouse_pos = event.position
		if _is_panning:
			var forward: Vector3 = global_transform.basis.z
			forward.y = 0
			forward = forward.normalized()
			var right: Vector3 = global_transform.basis.x
			right.y = 0
			right = right.normalized()
			var factor: float = _camera.position.z * 0.001 * pan_speed
			global_position -= (right * delta.x - forward * delta.y) * factor

func _process(delta: float):
	_camera.fov = lerpf(_camera.fov, _target_fov, delta * 12.0)

func _select_province_at(screen_pos: Vector2):
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return
	var from: Vector3 = cam.project_ray_origin(screen_pos)
	var dir: Vector3 = cam.project_ray_normal(screen_pos)
	var to: Vector3 = from + dir * 1000.0
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_bodies = true
	var result: Dictionary = space_state.intersect_ray(query)
	if result.is_empty():
		print("Nessun oggetto colpito.")
		return
	var uv: Vector2 = result.get("uv", Vector2.ZERO)
	_get_province_info_from_uv(uv)

func _get_province_info_from_uv(uv: Vector2):
	if _province_id_image == null:
		return
	var w := _province_id_image.get_width()
	var h := _province_id_image.get_height()
	var px := int(uv.x * w)
	var py := int((1.0 - uv.y) * h)
	px = clampi(px, 0, w - 1)
	py = clampi(py, 0, h - 1)
	var pixel_color := _province_id_image.get_pixel(px, py)
	var hex_code := pixel_color.to_html(false)
	var province_id = _province_lookup.get(hex_code)
	if province_id == null:
		print("Colore provincia non trovato: %s" % hex_code)
		return
	var province_name: String = str(province_id)
	var province_data: Dictionary = WorldData.get_province(province_name)
	if province_data.is_empty():
		print("Provincia %s trovata nella mappa ma dati mancanti." % province_name)
		return
	var owner: String = str(province_data.get("owner", "Nessuno"))
	print("PROVINCIA SELEZIONATA: %s | Fazione: %s" % [province_name, owner])
	if _province_popup:
		_province_popup.show_province(province_name)

func _on_enter_province(province_name: String):
	GameState.state["last_province"] = province_name
	get_tree().change_scene_to_file("res://scenes/province_scene_3d.tscn")

func _on_back():
	get_tree().change_scene_to_file("res://scenes/prova_egemonia_1000.tscn")
