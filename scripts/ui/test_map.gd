extends Node3D
# TestMap: piano geografico ad alta risoluzione con camera RTS
# Sinistro/centrale: Pan; destro: Rotazione/Tilt; rotella: Zoom
# Dark Corporation / Stev

@onready var _pivot: Node3D = $CameraPivot
@onready var _camera: Camera3D = $CameraPivot/Camera3D

@export var pan_speed: float = 0.5
@export var rotation_speed: float = 0.005
@export var zoom_speed: float = 4.0
@export var min_fov: float = 25.0
@export var max_fov: float = 75.0

var _is_panning := false
var _last_mouse_pos := Vector2.ZERO
var _target_fov: float = 60.0

func _ready() -> void:
	var mesh_instance := MeshInstance3D.new()
	var plane_mesh := PlaneMesh.new()
	plane_mesh.size = Vector2(200.0, 100.0)
	plane_mesh.subdivide_width = 500
	plane_mesh.subdivide_depth = 250
	mesh_instance.mesh = plane_mesh
	mesh_instance.name = "Terrain"
	add_child(mesh_instance)
	var shader := load("res://risorse/shader/terrain_political.gdshader")
	var mat := ShaderMaterial.new()
	mat.shader = shader
	var height_image := Image.load_from_file(ProjectSettings.globalize_path("res://risorse/terreno/heightmap_terra.png"))
	var province_image := Image.load_from_file(ProjectSettings.globalize_path("res://risorse/terreno/province_id_map.png"))
	if height_image and province_image:
		mat.set_shader_parameter("heightmap_tex", ImageTexture.create_from_image(height_image))
		mat.set_shader_parameter("province_id_tex", ImageTexture.create_from_image(province_image))
	mat.set_shader_parameter("sea_level", 0.5)
	mat.set_shader_parameter("ocean_color", Color(0.08, 0.25, 0.55))
	mat.set_shader_parameter("land_base_color", Color(0.3, 0.6, 0.25))
	mesh_instance.material_override = mat
	mesh_instance.create_trimesh_collision()
	_camera.position = Vector3(0, 0, 45.0)
	_target_fov = _camera.fov
	print("TestMap: PlaneMesh 4096x2048, controlli camera attivi.")
	print("Controlli: Sinistro/Destro Pan, Rotellina Zoom ottico, ESC menu.")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == MOUSE_BUTTON_MIDDLE:
			_is_panning = event.pressed
			_last_mouse_pos = event.position
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_target_fov = maxf(_target_fov - zoom_speed, min_fov)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_target_fov = minf(_target_fov + zoom_speed, max_fov)
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file("res://scenes/prova_egemonia_1000.tscn")
	if event is InputEventMouseMotion:
		var delta: Vector2 = event.position - _last_mouse_pos
		_last_mouse_pos = event.position
		if _is_panning:
			var right: Vector3 = global_transform.basis.x
			right.y = 0.0
			right = right.normalized()
			var forward: Vector3 = global_transform.basis.z
			forward.y = 0.0
			forward = forward.normalized()
			global_position -= (right * delta.x - forward * delta.y) * 0.08 * pan_speed

func _process(delta: float) -> void:
	_camera.fov = lerpf(_camera.fov, _target_fov, delta * 12.0)
