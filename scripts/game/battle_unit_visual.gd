class_name BattleUnitVisual
extends Node2D

## Rappresentazione 2.5D stile Age of Empires: ogni gruppo e' una
## formazione di soldati individuali con pose, profondita' e morti visibili.

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
var _idle_texture: Texture2D = null
var _charge_texture: Texture2D = null
var _dust: CPUParticles2D
var _region: String = "european"

var _soldiers: Array = []            # Sprite2D visibili, in formazione
var _soldier_phase: PackedFloat32Array = PackedFloat32Array()
var _soldier_base: PackedVector2Array = PackedVector2Array()
var _dying: Array = []               # {sprite, t}
var _lunge_t: float = 0.0
var _shown: int = 0

const CHARGE_TACTICS := ["charge", "elephant_charge"]
# le icone units/ raffigurano gia' una squadra (~9 figure): poche tessere
# grandi danno decine di soldati visibili senza perdere leggibilita'
const MAX_SOLDIERS := 6
const MIN_SOLDIERS := 2
const BASE_SCALE := 0.26             # icona 256px -> ~66px a scala 1.0


func setup(type_name: String, region: String, p_role: String, p_side_color: Color, p_count: int, p_max_count: int, p_mode: String = "realistic"):
	unit_type = type_name
	role = p_role
	side_color = p_side_color
	count = p_count
	max_count = p_max_count
	visual_mode = p_mode
	_region = region

	_idle_texture = IconManager.get_unit_icon(unit_type, region)
	_charge_texture = IconManager.get_battle_sprite(unit_type, region)

	_sync_soldiers(true)
	_update_textures()


func _soldiers_target() -> int:
	if count <= 0:
		return 0
	return clampi(int(ceil(float(count) / maxf(1.0, float(max_count)) * MAX_SOLDIERS)), MIN_SOLDIERS, MAX_SOLDIERS)


func _formation_offsets(n: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	match role:
		"cavalry", "elephant":
			# cuneo: vertice avanti, file crescenti
			var spacing: float = 52.0 if role == "elephant" else 44.0
			var dir: float = 1.0 if facing_right else -1.0
			var row := 0
			while pts.size() < n:
				for i in range(row + 1):
					if pts.size() >= n:
						break
					pts.append(Vector2(dir * -row * spacing * 0.8, (i - row / 2.0) * spacing))
				row += 1
		"ranged":
			# linea larga e rada
			var cols := mini(n, 3)
			for i in range(n):
				var r: int = i / cols
				var c: int = i % cols
				pts.append(Vector2(-50.0 - r * 48.0, (c - (cols - 1) / 2.0) * 52.0))
		"artillery":
			# fila singola retrocessa
			for i in range(n):
				pts.append(Vector2(-70.0 - (i % 2) * 60.0, (i / 2 - 1) * 70.0))
		_:
			# fanteria: blocco serrato 2x3
			var cols := mini(n, 3)
			for i in range(n):
				var r: int = i / cols
				var c: int = i % cols
				pts.append(Vector2(r * 46.0 - 23.0, (c - (cols - 1) / 2.0) * 46.0))
	return pts


func _sync_soldiers(instant: bool = false):
	var target := _soldiers_target()
	while _soldiers.size() < target:
		_add_soldier(_soldiers.size())
	while _soldiers.size() > target:
		var s: Sprite2D = _soldiers.pop_back()
		if instant:
			s.queue_free()
		else:
			_start_death(s)
	_rebuild_offsets()
	_shown = _soldiers.size()


func _add_soldier(idx: int):
	var s := Sprite2D.new()
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	s.centered = true
	s.texture = _idle_texture if _idle_texture != null else _charge_texture
	add_child(s)
	_soldiers.append(s)
	_soldier_phase.append(randf() * TAU)
	_soldier_base.append(Vector2.ZERO)
	_rebuild_offsets()


func _rebuild_offsets():
	var pts := _formation_offsets(_soldiers.size())
	for i in range(_soldiers.size()):
		var p: Vector2 = pts[i] if i < pts.size() else Vector2.ZERO
		_soldier_base[i] = p
		var s: Sprite2D = _soldiers[i]
		s.position = p
		s.z_index = int(p.y)


func _update_textures():
	for s in _soldiers:
		if moving and tactic in CHARGE_TACTICS and _charge_texture != null:
			s.texture = _charge_texture
		else:
			s.texture = _idle_texture if _idle_texture != null else _charge_texture


func _apply_depth():
	# scala prospettica: chi e' piu' in basso (y globale) e' piu' grande
	for i in range(_soldiers.size()):
		var s: Sprite2D = _soldiers[i]
		var gy: float = s.global_position.y
		var f: float = clampf(0.85 + (gy / 1080.0) * 0.35, 0.8, 1.2)
		var sc: float = BASE_SCALE * f * (1.08 if visual_mode == "3d" else 1.0)
		s.scale = Vector2(sc * (1.0 if facing_right else -1.0), sc)


func play_attack():
	_lunge_t = 0.18


func set_visual_mode(p_mode: String):
	if visual_mode == p_mode:
		return
	visual_mode = p_mode


func set_facing_right(p_right: bool):
	if facing_right == p_right:
		return
	facing_right = p_right
	_rebuild_offsets()
	if _dust != null:
		var offset := Vector2(-70.0, 25.0)
		_dust.position = offset if p_right else Vector2(-offset.x, offset.y)
		_dust.direction = Vector2(-1.0, 0.0) if p_right else Vector2(1.0, 0.0)


func set_tactic(p_tactic: String):
	if tactic == p_tactic:
		return
	tactic = p_tactic
	_update_textures()
	_update_dust()


func set_moving(p_moving: bool):
	moving = p_moving
	if not moving:
		for i in range(_soldiers.size()):
			_soldiers[i].position.y = _soldier_base[i].y
			_soldiers[i].rotation_degrees = 0.0
	_update_textures()
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


func _start_death(s: Sprite2D):
	s.z_index = -100
	_dying.append({"sprite": s, "t": 0.0})


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
	_sync_soldiers()

	# pose di marcia / carica / attacco
	var bob_amp := 3.0 if tactic in CHARGE_TACTICS else 1.5
	if moving:
		_anim_time += delta * 10.0
	else:
		_anim_time = 0.0

	var charging := moving and tactic in CHARGE_TACTICS
	for i in range(_soldiers.size()):
		var s: Sprite2D = _soldiers[i]
		var base: Vector2 = _soldier_base[i]
		if moving:
			s.position = base + Vector2(0, sin(_anim_time + _soldier_phase[i]) * bob_amp)
			s.rotation_degrees = 10.0 if charging else 0.0
		elif _lunge_t > 0.0:
			var dir: float = 1.0 if facing_right else -1.0
			var k: float = _lunge_t / 0.18
			s.position = base + Vector2(dir * 12.0 * k, 0)
			s.rotation_degrees = 0.0
		else:
			s.position = base
			s.rotation_degrees = 0.0

	if _lunge_t > 0.0:
		_lunge_t = maxf(0.0, _lunge_t - delta)

	# morti: caduta + dissolvenza
	for i in range(_dying.size() - 1, -1, -1):
		var d: Dictionary = _dying[i]
		var s: Sprite2D = d.sprite
		d.t += delta
		var t: float = d.t / 0.45
		if is_instance_valid(s):
			s.rotation_degrees = 90.0 * t
			s.modulate.a = 1.0 - t
			if t >= 1.0:
				s.queue_free()
				_dying.remove_at(i)
		else:
			_dying.remove_at(i)

	_apply_depth()
	queue_redraw()


func _draw():
	if selected:
		draw_arc(Vector2.ZERO, 110.0, 0.0, TAU, 40, Color.GOLD, 4.0, true)
	if commander:
		var star: PackedVector2Array = _star_points(Vector2(0, -130), 16.0, 8.0)
		draw_colored_polygon(star, Color.GOLD)
	# ombra ellittica della formazione
	draw_ellipse(Vector2(0, 46), 190.0, 20.0, Color(0, 0, 0, 0.22))
	var ratio := float(count) / float(max_count) if max_count > 0 else 1.0
	draw_rect(Rect2(Vector2(-34, 58), Vector2(68 * ratio, 7)), Color.DARK_RED)
	draw_rect(Rect2(Vector2(-34, 58), Vector2(68, 7)), Color.WHITE, false, 1.0)


func _star_points(center: Vector2, outer: float, inner: float) -> PackedVector2Array:
	var pts: PackedVector2Array = PackedVector2Array()
	for i in range(10):
		var r: float = outer if i % 2 == 0 else inner
		var a: float = -PI / 2.0 + i * TAU / 10.0
		pts.append(center + Vector2(cos(a), sin(a)) * r)
	return pts
