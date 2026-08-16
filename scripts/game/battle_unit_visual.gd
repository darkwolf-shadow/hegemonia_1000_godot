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
var tactic: String = "standard"

var _anim_time: float = 0.0
var _sprite: Sprite2D
var _idle_texture: Texture2D = null
var _charge_texture: Texture2D = null
var _dust: CPUParticles2D
var _base_y: float = 0.0
var _base_scale: Vector2 = Vector2(0.18, 0.18)
var _region: String = "european"

const CHARGE_TACTICS := ["charge", "elephant_charge"]


func setup(type_name: String, region: String, p_role: String, p_side_color: Color, p_count: int, p_max_count: int, p_mode: String = "realistic"):
	unit_type = type_name
	role = p_role
	side_color = p_side_color
	count = p_count
	max_count = p_max_count
	visual_mode = p_mode
	_region = region

	if _sprite == null:
		_sprite = Sprite2D.new()
		_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		_sprite.centered = true
		add_child(_sprite)

	_idle_texture = IconManager.get_unit_icon(unit_type, region)
	_charge_texture = IconManager.get_battle_sprite(unit_type, region)

	_update_texture()
	_apply_mode()
	set_facing_right(true)
	_base_y = position.y


func _update_texture():
	if _sprite == null:
		return
	if moving and tactic in CHARGE_TACTICS and _charge_texture != null:
		_sprite.texture = _charge_texture
	else:
		_sprite.texture = _idle_texture if _idle_texture != null else _charge_texture


func _apply_mode():
	# "realistic" e "3D" condividono lo stesso sprite pre-renderizzato;
	# la scala varia leggermente per dare profondita'
	var s: float = _base_scale.x
	if visual_mode == "3d":
		s *= 1.08
	if _sprite != null:
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
	if _dust != null:
		var offset := Vector2(-70.0, 25.0)
		_dust.position = offset if p_right else Vector2(-offset.x, offset.y)
		_dust.direction = Vector2(-1.0, 0.0) if p_right else Vector2(1.0, 0.0)


func set_tactic(p_tactic: String):
	if tactic == p_tactic:
		return
	tactic = p_tactic
	_update_texture()
	_update_dust()


func set_moving(p_moving: bool):
	moving = p_moving
	if not moving:
		position.y = _base_y
	_update_texture()
	_update_dust()


func _update_dust():
	if _dust == null:
		return
	var can_emit := role == "cavalry" or role == "elephant" or _role_has_hooves()
	var should_emit := moving and can_emit
	_dust.emitting = should_emit
	if should_emit:
		var charging := tactic in CHARGE_TACTICS
		_dust.speed_scale = 2.0 if charging else 1.0
		_dust.scale_amount_min = 5.0 if charging else 3.0
		_dust.scale_amount_max = 10.0 if charging else 7.0
		_dust.amount = 40 if charging else 24


func _role_has_hooves() -> bool:
	var key := unit_type.to_lower()
	return key.contains("caval") or key.contains("cataphract") or key.contains("mamluk") or key.contains("ghilman") or key.contains("ghulam") or key.contains("lancer") or key.contains("drak") or key.contains("druzhina") or key.contains("jinete") or key.contains("magyar") or key.contains("horse") or key.contains("soninke") or key.contains("elephant")


func set_selected(p_selected: bool):
	selected = p_selected
	queue_redraw()


func set_commander(p_commander: bool):
	commander = p_commander
	queue_redraw()


func _ready():
	set_process(true)
	_create_dust()


func _create_dust():
	if _dust != null:
		return
	_dust = CPUParticles2D.new()
	_dust.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_dust.amount = 24
	_dust.lifetime = 0.8
	_dust.one_shot = false
	_dust.local_coords = false
	_dust.explosiveness = 0.0
	_dust.randomness = 1.0
	_dust.lifetime_randomness = 0.5
	_dust.gravity = Vector2(0, -6)
	_dust.direction = Vector2(-1.0, 0.0)
	_dust.spread = 70.0
	_dust.initial_velocity_min = 40.0
	_dust.initial_velocity_max = 90.0
	_dust.angular_velocity_min = -30.0
	_dust.angular_velocity_max = 30.0
	_dust.scale_amount_min = 3.0
	_dust.scale_amount_max = 7.0
	_dust.color = Color(0.66, 0.52, 0.32, 0.75)
	_dust.z_index = -1
	add_child(_dust)
	set_facing_right(facing_right)
	_dust.emitting = false


func _process(delta: float):
	if moving:
		_anim_time += delta * 12.0
		var amp := 4.0 if tactic in CHARGE_TACTICS else 2.0
		position.y = _base_y + sin(_anim_time) * amp
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
