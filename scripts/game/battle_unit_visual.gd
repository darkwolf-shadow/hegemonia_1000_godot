class_name BattleUnitVisual
extends Node2D

var unit_type: String = "fanteria"
var role: String = "infantry"
var side_color: Color = Color.WHITE
var count: int = 1
var max_count: int = 1
var selected: bool = false
var commander: bool = false
var facing_right: bool = true
var moving: bool = false
var visual_mode: String = "realistic"

var _anim_time: float = 0.0
var _sprite: Sprite2D
var _base_y: float = 0.0
var _base_scale: Vector2 = Vector2(0.18, 0.18)


func setup(type_name: String, region: String, p_role: String, p_side_color: Color, p_count: int, p_max_count: int, p_mode: String = "realistic"):
	unit_type = type_name
	role = p_role
	side_color = p_side_color
	count = p_count
	max_count = p_max_count
	visual_mode = p_mode

	if _sprite == null:
		_sprite = Sprite2D.new()
		_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		_sprite.centered = true
		add_child(_sprite)

	var tex := _load_texture(region)
	if tex != null:
		_sprite.texture = tex

	_apply_mode()
	set_facing_right(true)
	_base_y = position.y


func _load_texture(region: String) -> Texture2D:
	var tex := IconManager.get_battle_sprite(unit_type, region)
	if tex == null:
		tex = IconManager.get_unit_icon(unit_type, region)
	return tex


func _apply_mode():
	# "realistic" e "3D" condividono lo stesso sprite pre-renderizzato;
	# la scala varia leggermente per dare profondità
	var s: float = _base_scale.x
	if visual_mode == "3d":
		s *= 1.08
	_sprite.scale = Vector2(s, s)


func set_visual_mode(p_mode: String):
	if visual_mode == p_mode:
		return
	visual_mode = p_mode
	_apply_mode()


func set_facing_right(p_right: bool):
	facing_right = p_right
	if _sprite != null:
		_sprite.scale.x = abs(_sprite.scale.x) * (1.0 if p_right else -1.0)


func set_moving(p_moving: bool):
	moving = p_moving
	if not moving:
		position.y = _base_y


func set_selected(p_selected: bool):
	selected = p_selected
	queue_redraw()


func set_commander(p_commander: bool):
	commander = p_commander
	queue_redraw()


func _ready():
	set_process(true)


func _process(delta: float):
	if moving:
		_anim_time += delta * 10.0
		position.y = _base_y + sin(_anim_time) * 3.0
	else:
		_anim_time = 0.0
		position.y = _base_y
	queue_redraw()


func _draw():
	if selected:
		draw_arc(Vector2.ZERO, 70.0, 0.0, TAU, 32, Color.GOLD, 4.0, true)
	if commander:
		var star: PackedVector2Array = _star_points(Vector2(0, -95), 16.0, 8.0)
		draw_colored_polygon(star, Color.GOLD)
	var ratio := float(count) / float(max_count) if max_count > 0 else 1.0
	draw_rect(Rect2(Vector2(-28, 70), Vector2(56 * ratio, 6)), Color.DARK_RED)
	draw_rect(Rect2(Vector2(-28, 70), Vector2(56, 6)), Color.WHITE, false, 1.0)


func _star_points(center: Vector2, outer: float, inner: float) -> PackedVector2Array:
	var pts: PackedVector2Array = PackedVector2Array()
	for i in range(10):
		var r: float = outer if i % 2 == 0 else inner
		var a: float = -PI / 2.0 + i * TAU / 10.0
		pts.append(center + Vector2(cos(a), sin(a)) * r)
	return pts
