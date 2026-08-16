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
	# Corpo del dardo / freccia: linea visibile e contrastata
	_body = Polygon2D.new()
	_body.polygon = [Vector2(-28, -3), Vector2(28, -3), Vector2(28, 3), Vector2(-28, 3)]
	_body.color = Color(0.95, 0.85, 0.55, 0.95)
	add_child(_body)

	_head = Polygon2D.new()
	if is_artillery:
		_head.polygon = [Vector2(-14, -14), Vector2(18, -14), Vector2(18, 14), Vector2(-14, 14)]
		_head.color = Color(0.15, 0.15, 0.15, 1.0)
	else:
		_head.polygon = [Vector2(34, 0), Vector2(-10, -14), Vector2(6, 0), Vector2(-10, 14)]
		_head.color = Color(1.0, 0.75, 0.25, 1.0)
	add_child(_head)

	# Aggiunge un alone scuro per far risaltare il proiettile sullo sfondo
	var shadow := Polygon2D.new()
	shadow.polygon = [Vector2(-32, -5), Vector2(40, -5), Vector2(40, 5), Vector2(-32, 5)]
	shadow.color = Color(0.0, 0.0, 0.0, 0.35)
	shadow.z_index = -1
	add_child(shadow)

func _look_at_target():
	if not is_instance_valid(target):
		return
	look_at(target.global_position)
