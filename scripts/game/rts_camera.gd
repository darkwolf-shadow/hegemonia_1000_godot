extends Node3D
# Camera RTS per battaglia 3D
# Panning WASD/frecce, zoom rotella, rotazione tasto destro (destra/sinistra + alto/basso)
# Dark Corporation / Stev

@export var move_speed: float = 30.0
@export var zoom_speed: float = 2.0
@export var min_zoom: float = 3.0
@export var max_zoom: float = 80.0
@export var rotation_speed: float = 0.005
@export var min_pitch: float = -80.0
@export var max_pitch: float = -15.0

var _camera: Camera3D
var _current_zoom: float = 25.0
var _rotating: bool = false
var _yaw: float = 0.0
var _pitch: float = -0.96  # circa -55 gradi in radianti
var _last_mouse_pos := Vector2.ZERO
var _mouse_initialized: bool = false

func _ready():
	_camera = $Camera3D
	_update_camera_transform()

func _process(delta: float):
	var input_dir := Vector3.ZERO
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_dir.x += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_dir.x -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_dir.z += 1
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_dir.z -= 1
	if input_dir != Vector3.ZERO:
		var forward := Vector3.FORWARD.rotated(Vector3.UP, _yaw)
		var right := Vector3.RIGHT.rotated(Vector3.UP, _yaw)
		var motion := (forward * -input_dir.z + right * input_dir.x).normalized()
		global_translate(motion * move_speed * delta)

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_current_zoom = clamp(_current_zoom - zoom_speed, min_zoom, max_zoom)
			_update_camera_transform()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_current_zoom = clamp(_current_zoom + zoom_speed, min_zoom, max_zoom)
			_update_camera_transform()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_rotating = event.pressed
			if event.pressed:
				_mouse_initialized = false
	if event is InputEventMouseMotion:
		if _rotating:
			if not _mouse_initialized:
				_last_mouse_pos = event.position
				_mouse_initialized = true
				return
			var delta: Vector2 = event.position - _last_mouse_pos
			_last_mouse_pos = event.position
			_yaw -= delta.x * rotation_speed
			_pitch = clamp(_pitch - delta.y * rotation_speed, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
			_update_camera_transform()

func _update_camera_transform():
	var offset := Vector3(0, 0, _current_zoom)
	offset = offset.rotated(Vector3.RIGHT, _pitch)
	offset = offset.rotated(Vector3.UP, _yaw)
	_camera.position = offset
	_camera.look_at(global_position)
