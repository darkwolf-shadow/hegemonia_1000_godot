extends Node3D
# MapCameraController: Pan, Zoom, Rotazione 3D e Tilt
# Dark Corporation / Stev

@export var pan_speed: float = 0.5
@export var rotation_speed: float = 0.005
@export var zoom_speed: float = 5.0
@export var min_zoom: float = 5.0
@export var max_zoom: float = 200.0

@onready var _pivot: Node3D = $CameraPivot
@onready var _camera: Camera3D = $CameraPivot/Camera3D

var _is_panning: bool = false
var _is_rotating: bool = false
var _last_mouse_pos := Vector2.ZERO
var _target_zoom: float = 50.0

func _ready():
	_target_zoom = _camera.position.z

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_MIDDLE:
			_is_panning = event.pressed
			_last_mouse_pos = event.position
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_is_rotating = event.pressed
			_last_mouse_pos = event.position
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_target_zoom -= zoom_speed * (_target_zoom * 0.05)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_target_zoom += zoom_speed * (_target_zoom * 0.05)
		_target_zoom = clampf(_target_zoom, min_zoom, max_zoom)
		if event.keycode == KEY_ESCAPE and event.pressed:
			get_tree().change_scene_to_file("res://scenes/prova_egemonia_1000.tscn")

	if event is InputEventMouseMotion:
		var delta: Vector2 = event.position - _last_mouse_pos
		_last_mouse_pos = event.position
		# Rotazione con tasto destro
		if _is_rotating:
			rotation.y -= delta.x * rotation_speed
			_pivot.rotation.x = clampf(_pivot.rotation.x - delta.y * rotation_speed, deg_to_rad(-85.0), deg_to_rad(-10.0))
		# Pan con tasto sinistro
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
	_camera.position.z = lerp(_camera.position.z, _target_zoom, delta * 12.0)
