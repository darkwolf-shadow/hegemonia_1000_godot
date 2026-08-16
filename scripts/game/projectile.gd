extends Node2D

var target: Node2D = null
var damage: float = 0.0
var is_artillery: bool = false
var speed: float = 280.0

var _shape: Polygon2D

func init(target_node: Node2D, dmg: float, artillery: bool = false):
	target = target_node
	damage = dmg
	is_artillery = artillery
	_build_shape()
	_look_at_target()

func _ready():
	set_process(false)

func update(delta: float):
	if not is_instance_valid(target):
		queue_free()
		return
	var dir := target.global_position - global_position
	var dist: float = dir.length()
	if dist < 10.0:
		hit()
		return
	global_position += dir.normalized() * speed * delta
	_look_at_target()

func hit():
	if is_instance_valid(target):
		target.take_damage(damage)
	queue_free()

func _build_shape():
	_shape = Polygon2D.new()
	if is_artillery:
		_shape.polygon = [Vector2(-4, -4), Vector2(4, -4), Vector2(4, 4), Vector2(-4, 4)]
		_shape.color = Color(0.2, 0.2, 0.2)
	else:
		_shape.polygon = [Vector2(8, 0), Vector2(-4, -4), Vector2(0, 0), Vector2(-4, 4)]
		_shape.color = Color(0.55, 0.35, 0.15)
	add_child(_shape)

func _look_at_target():
	if not is_instance_valid(target):
		return
	look_at(target.global_position)
