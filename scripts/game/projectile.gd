extends Node2D

var target: Node2D = null
var damage: float = 0.0
var is_artillery: bool = false
var speed: float = 320.0

var _body: Polygon2D
var _head: Polygon2D

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
	if dist < 12.0:
		hit()
		return
	global_position += dir.normalized() * speed * delta
	_look_at_target()

func hit():
	if is_instance_valid(target):
		target.take_damage(damage)
	queue_free()

func _build_shape():
	# Corpo del dardo / freccia: linea visibile
	_body = Polygon2D.new()
	_body.polygon = [Vector2(-16, -2), Vector2(16, -2), Vector2(16, 2), Vector2(-16, 2)]
	_body.color = Color(0.35, 0.22, 0.12, 0.95)
	add_child(_body)

	_head = Polygon2D.new()
	if is_artillery:
		_head.polygon = [Vector2(-10, -10), Vector2(10, -10), Vector2(10, 10), Vector2(-10, 10)]
		_head.color = Color(0.1, 0.1, 0.1, 1.0)
	else:
		_head.polygon = [Vector2(22, 0), Vector2(-6, -10), Vector2(4, 0), Vector2(-6, 10)]
		_head.color = Color(0.75, 0.55, 0.25, 1.0)
	add_child(_head)

func _look_at_target():
	if not is_instance_valid(target):
		return
	look_at(target.global_position)
