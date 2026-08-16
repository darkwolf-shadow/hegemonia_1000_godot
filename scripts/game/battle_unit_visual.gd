class_name BattleUnitVisual
extends Node2D

# Modelli di unità per la scena di battaglia.
# Supporta due modalità:
# - "sprite_2d": usa l'icona dell'unità con animazione procedurale (bob/oscillazione)
# - "vector_3d": disegna una formazione di figurine stilizzate pseudo-tridimensionali

var unit_type: String = "fanteria"
var role: String = "infantry"
var side_color: Color = Color.WHITE
var count: int = 1
var max_count: int = 1
var selected: bool = false
var commander: bool = false
var facing_right: bool = true
var moving: bool = false
var visual_mode: String = "vector_3d"

var _anim_time: float = 0.0
var _sprite: Sprite2D = null

const _PI: float = 3.14159265358979

func setup(type_name: String, p_region: String, p_role: String, p_side_color: Color, p_count: int, p_max_count: int, p_mode: String = "vector_3d"):
	unit_type = type_name
	role = p_role
	side_color = p_side_color
	count = p_count
	max_count = p_max_count
	visual_mode = p_mode
	_tint_by_role()
	_init_sprite(p_region)
	_update_mode()

func _ready():
	set_process(true)
	_init_sprite("")

func _init_sprite(region: String):
	if _sprite != null:
		return
	_sprite = Sprite2D.new()
	_sprite.scale = Vector2(0.55, 0.55)
	add_child(_sprite)
	if region.is_empty():
		return
	var tex = IconManager.get_battle_sprite(unit_type, region)
	if tex == null:
		tex = IconManager.get_unit_icon(unit_type, region)
	if tex != null:
		_sprite.texture = tex

func _tint_by_role():
	# Colori distintivi per ruolo, ma mantenendo il colore di fazione per la tunica
	match role:
		"cavalry":
			side_color = side_color.lightened(0.1)
		"ranged":
			side_color = side_color.darkened(0.1)
		"artillery":
			side_color = Color(0.45, 0.42, 0.38)
		"elephant":
			side_color = Color(0.55, 0.52, 0.48)

func _update_mode():
	if _sprite != null:
		_sprite.visible = false
	z_index = 1
	queue_redraw()

func set_visual_mode(p_mode: String):
	if visual_mode == p_mode:
		return
	visual_mode = p_mode
	_update_mode()

func set_facing_right(p_right: bool):
	facing_right = p_right
	scale.x = 1.0 if facing_right else -1.0

func set_moving(p_moving: bool):
	moving = p_moving

func set_selected(p_selected: bool):
	selected = p_selected
	queue_redraw()

func set_commander(p_commander: bool):
	commander = p_commander
	queue_redraw()

func _process(delta: float):
	_anim_time += delta * (8.0 if moving else 1.0)
	queue_redraw()

func _animate_sprite():
	if _sprite == null:
		return
	var bob: float = -5.0 * abs(sin(_anim_time)) if moving else 0.0
	_sprite.position.y = bob
	_sprite.rotation = 0.05 * sin(_anim_time) if moving else 0.0

func _draw():
	if visual_mode == "sprite_2d":
		_draw_2d_formation()
	else:
		_draw_vector_formation()

func _draw_vector_formation():
	# Numero visivo di soldati (non 1:1, altrimenti le formazioni grandi diventano confusione)
	var vis_count: int = clampi(count, 1, 12)
	var cols: int = 3
	var rows: int = 3
	var spacing_x: float = 18.0
	var spacing_y: float = 14.0
	match role:
		"cavalry":
			cols = 2
			rows = 2
			spacing_x = 34.0
			spacing_y = 22.0
		"elephant":
			cols = 1
			rows = 1
			spacing_x = 60.0
			spacing_y = 60.0
		"artillery":
			cols = 1
			rows = 1
			spacing_x = 40.0
			spacing_y = 30.0
		_:
			cols = 3
			rows = 4
			spacing_x = 16.0
			spacing_y = 13.0

	var start_x: float = -(cols - 1) * spacing_x * 0.5
	var start_y: float = -(rows - 1) * spacing_y * 0.5

	# Riduci progressivamente le dimensioni con la perdita di truppe
	var ratio: float = clampf(float(count) / float(max_count), 0.25, 1.0)
	var formation_scale: float = 0.7 + 0.3 * ratio

	for i in range(vis_count):
		var col: int = i % cols
		var row: int = i / cols
		var pos: Vector2 = Vector2(start_x + col * spacing_x, start_y + row * spacing_y)
		var phase: float = _anim_time + i * 0.7
		_draw_soldier(pos, phase, formation_scale)

	if selected:
		draw_rect(Rect2(Vector2(-32, -40), Vector2(64, 56)), Color.YELLOW, false, 2.0)
	if commander:
		draw_circle(Vector2(0, -46), 6.0, Color.GOLD)

func _draw_soldier(pos: Vector2, phase: float, p_scale: float):
	# Ombra
	draw_colored_polygon(_ellipse_points(pos + Vector2(0, 1), 7.0 * p_scale, 2.5 * p_scale, 8), Color(0, 0, 0, 0.35))

	match role:
		"cavalry":
			_draw_cavalry(pos, phase, p_scale)
		"elephant":
			_draw_elephant(pos, phase, p_scale)
		"artillery":
			_draw_artillery(pos, phase, p_scale)
		"ranged":
			_draw_archer(pos, phase, p_scale)
		_:
			_draw_infantry(pos, phase, p_scale)

func _draw_infantry(pos: Vector2, phase: float, p_scale: float):
	var tunic: Color = side_color
	var skin: Color = Color(0.82, 0.62, 0.45, 1.0)
	var dark: Color = tunic.darkened(0.3)
	var light: Color = tunic.lightened(0.2)

	var body_h: float = 22.0 * p_scale
	var hw: float = 5.0 * p_scale
	var body_top: float = pos.y - 30.0 * p_scale
	var body_bottom: float = pos.y - body_h

	# Corpo con shading laterale
	var body_points: PackedVector2Array = PackedVector2Array([
		Vector2(pos.x - hw, body_top),
		Vector2(pos.x + hw, body_top),
		Vector2(pos.x + hw, body_bottom),
		Vector2(pos.x - hw, body_bottom)
	])
	var body_colors: PackedColorArray = PackedColorArray([dark, light, light, dark])
	draw_polygon(body_points, body_colors)

	# Gambe
	var swing: float = 4.0 * p_scale * sin(phase)
	var hip: Vector2 = Vector2(pos.x, body_bottom)
	var left_foot: Vector2 = Vector2(pos.x - 4.0 * p_scale + swing, pos.y)
	var right_foot: Vector2 = Vector2(pos.x + 4.0 * p_scale - swing, pos.y)
	draw_line(hip, left_foot, skin, 2.0 * p_scale, true)
	draw_line(hip, right_foot, skin, 2.0 * p_scale, true)

	# Testa
	var head_y: float = body_top - 6.0 * p_scale
	_draw_sphere(Vector2(pos.x, head_y), 5.5 * p_scale, skin)

	# Braccia e arma
	var shoulder: Vector2 = Vector2(pos.x, body_top + 6.0 * p_scale)
	var arm_x: float = pos.x + 8.0 * p_scale + 3.0 * p_scale * cos(phase)
	var hand: Vector2 = Vector2(arm_x, body_top + 12.0 * p_scale)
	draw_line(shoulder, hand, skin, 2.0 * p_scale, true)
	# Lancia
	draw_line(hand, Vector2(hand.x + 14.0 * p_scale, hand.y - 10.0 * p_scale), Color(0.55, 0.45, 0.25, 1.0), 2.0 * p_scale, true)
	draw_circle(hand + Vector2(14.0 * p_scale, -10.0 * p_scale), 2.5 * p_scale, Color(0.75, 0.75, 0.8, 1.0))

	# Scudo
	var shield_points: PackedVector2Array = PackedVector2Array([
		Vector2(pos.x - 12.0 * p_scale, body_top + 4.0 * p_scale),
		Vector2(pos.x - 4.0 * p_scale, body_top + 4.0 * p_scale),
		Vector2(pos.x - 4.0 * p_scale, body_bottom - 2.0 * p_scale),
		Vector2(pos.x - 12.0 * p_scale, body_bottom - 2.0 * p_scale)
	])
	draw_colored_polygon(shield_points, Color(0.5, 0.35, 0.15, 1.0))

func _draw_archer(pos: Vector2, phase: float, p_scale: float):
	var tunic: Color = side_color.darkened(0.05)
	var skin: Color = Color(0.82, 0.62, 0.45, 1.0)
	var dark: Color = tunic.darkened(0.3)
	var light: Color = tunic.lightened(0.2)

	var body_h: float = 20.0 * p_scale
	var hw: float = 4.5 * p_scale
	var body_top: float = pos.y - 28.0 * p_scale
	var body_bottom: float = pos.y - body_h

	var body_points: PackedVector2Array = PackedVector2Array([
		Vector2(pos.x - hw, body_top),
		Vector2(pos.x + hw, body_top),
		Vector2(pos.x + hw, body_bottom),
		Vector2(pos.x - hw, body_bottom)
	])
	draw_polygon(body_points, PackedColorArray([dark, light, light, dark]))

	var swing: float = 3.0 * p_scale * sin(phase)
	var hip: Vector2 = Vector2(pos.x, body_bottom)
	draw_line(hip, Vector2(pos.x - 3.5 * p_scale + swing, pos.y), skin, 2.0 * p_scale, true)
	draw_line(hip, Vector2(pos.x + 3.5 * p_scale - swing, pos.y), skin, 2.0 * p_scale, true)

	var head_y: float = body_top - 5.5 * p_scale
	_draw_sphere(Vector2(pos.x, head_y), 5.0 * p_scale, skin)

	# Arco
	var bow_center: Vector2 = Vector2(pos.x - 10.0 * p_scale, body_top + 8.0 * p_scale)
	draw_arc(bow_center, 10.0 * p_scale, -_PI * 0.6, _PI * 0.6, 12, Color(0.55, 0.35, 0.15, 1.0), 2.0 * p_scale, true)
	draw_line(bow_center + Vector2(0, -10.0 * p_scale), bow_center + Vector2(0, 10.0 * p_scale), Color(0.9, 0.9, 0.85, 1.0), 1.0 * p_scale, true)

	# Freccia
	var arrow_start: Vector2 = bow_center + Vector2(0, 0)
	var arrow_end: Vector2 = arrow_start + Vector2(18.0 * p_scale, 0)
	draw_line(arrow_start, arrow_end, Color(0.75, 0.55, 0.25, 1.0), 2.0 * p_scale, true)
	draw_colored_polygon(PackedVector2Array([
		arrow_end,
		arrow_end + Vector2(-5.0 * p_scale, -2.5 * p_scale),
		arrow_end + Vector2(-5.0 * p_scale, 2.5 * p_scale)
	]), Color(0.75, 0.75, 0.8, 1.0))

func _draw_cavalry(pos: Vector2, phase: float, p_scale: float):
	var horse: Color = Color(0.55, 0.38, 0.22, 1.0)
	var horse_dark: Color = horse.darkened(0.25)
	var horse_light: Color = horse.lightened(0.15)

	# Cavallo: corpo ellittico con shading
	var body_c: Vector2 = Vector2(pos.x + 4.0 * p_scale, pos.y - 16.0 * p_scale)
	var body_pts: PackedVector2Array = _ellipse_points(body_c, 22.0 * p_scale, 10.0 * p_scale, 16)
	var body_cols: PackedColorArray = PackedColorArray()
	for i in range(body_pts.size()):
		body_cols.append(horse_dark if body_pts[i].x < body_c.x else horse_light)
	draw_polygon(body_pts, body_cols)

	# Testa del cavallo
	_draw_sphere(Vector2(pos.x + 20.0 * p_scale, pos.y - 32.0 * p_scale), 6.0 * p_scale, horse_light)
	# Collo
	draw_line(Vector2(pos.x + 12.0 * p_scale, pos.y - 22.0 * p_scale), Vector2(pos.x + 20.0 * p_scale, pos.y - 30.0 * p_scale), horse, 5.0 * p_scale, true)

	# Zampe
	var z: float = 8.0 * p_scale * sin(phase)
	var z2: float = 8.0 * p_scale * sin(phase + _PI)
	var front_leg: Vector2 = Vector2(pos.x + 12.0 * p_scale, pos.y - 10.0 * p_scale)
	var back_leg: Vector2 = Vector2(pos.x - 10.0 * p_scale, pos.y - 10.0 * p_scale)
	draw_line(front_leg, Vector2(front_leg.x + z, pos.y), horse_light, 3.0 * p_scale, true)
	draw_line(front_leg, Vector2(front_leg.x + z2, pos.y), horse_dark, 3.0 * p_scale, true)
	draw_line(back_leg, Vector2(back_leg.x + z2, pos.y), horse_light, 3.0 * p_scale, true)
	draw_line(back_leg, Vector2(back_leg.x + z, pos.y), horse_dark, 3.0 * p_scale, true)

	# Cavaliere
	var rider: Vector2 = Vector2(pos.x + 4.0 * p_scale, pos.y - 30.0 * p_scale)
	var tunic: Color = side_color
	_draw_infantry(rider + Vector2(0, 6.0 * p_scale), phase, p_scale * 0.7)

func _draw_elephant(pos: Vector2, phase: float, p_scale: float):
	var gray: Color = Color(0.52, 0.50, 0.47, 1.0)
	var dark: Color = gray.darkened(0.3)
	var light: Color = gray.lightened(0.15)

	var body_c: Vector2 = Vector2(pos.x, pos.y - 24.0 * p_scale)
	var body_pts: PackedVector2Array = _rounded_rect_points(body_c, 30.0 * p_scale, 20.0 * p_scale)
	var body_cols: PackedColorArray = PackedColorArray()
	for i in range(body_pts.size()):
		body_cols.append(dark if body_pts[i].x < body_c.x else light)
	draw_polygon(body_pts, body_cols)

	# Testa e proboscide
	var head: Vector2 = Vector2(pos.x + 28.0 * p_scale, pos.y - 38.0 * p_scale)
	_draw_sphere(head, 9.0 * p_scale, gray.lightened(0.1))
	draw_line(head, Vector2(head.x + 16.0 * p_scale + 4.0 * p_scale * sin(phase), head.y + 8.0 * p_scale), gray.lightened(0.05), 5.0 * p_scale, true)

	# Zampe
	for ox in [-18.0, 18.0]:
		draw_line(Vector2(pos.x + ox * p_scale, pos.y - 14.0 * p_scale), Vector2(pos.x + ox * p_scale, pos.y), gray, 6.0 * p_scale, true)

	# Howdah con arcieri
	var howdah: PackedVector2Array = PackedVector2Array([
		Vector2(pos.x - 14.0 * p_scale, pos.y - 44.0 * p_scale),
		Vector2(pos.x + 14.0 * p_scale, pos.y - 44.0 * p_scale),
		Vector2(pos.x + 12.0 * p_scale, pos.y - 34.0 * p_scale),
		Vector2(pos.x - 12.0 * p_scale, pos.y - 34.0 * p_scale)
	])
	draw_colored_polygon(howdah, Color(0.55, 0.35, 0.15, 1.0))

func _draw_artillery(pos: Vector2, phase: float, p_scale: float):
	# Carro con due ruote e un trabucco
	var wood: Color = Color(0.55, 0.40, 0.25, 1.0)
	var metal: Color = Color(0.45, 0.45, 0.48, 1.0)

	# Ruote
	draw_circle(Vector2(pos.x - 16.0 * p_scale, pos.y), 8.0 * p_scale, Color(0.3, 0.2, 0.1, 1.0))
	draw_circle(Vector2(pos.x + 16.0 * p_scale, pos.y), 8.0 * p_scale, Color(0.3, 0.2, 0.1, 1.0))
	draw_circle(Vector2(pos.x - 16.0 * p_scale, pos.y), 3.0 * p_scale, Color(0.6, 0.5, 0.35, 1.0))
	draw_circle(Vector2(pos.x + 16.0 * p_scale, pos.y), 3.0 * p_scale, Color(0.6, 0.5, 0.35, 1.0))

	# Carro
	draw_colored_polygon(PackedVector2Array([
		Vector2(pos.x - 18.0 * p_scale, pos.y - 10.0 * p_scale),
		Vector2(pos.x + 18.0 * p_scale, pos.y - 10.0 * p_scale),
		Vector2(pos.x + 18.0 * p_scale, pos.y - 4.0 * p_scale),
		Vector2(pos.x - 18.0 * p_scale, pos.y - 4.0 * p_scale)
	]), wood)

	# Braccio del trabucco
	var arm_angle: float = -0.4 + 0.3 * sin(phase)
	var arm_len: float = 28.0 * p_scale
	var tip: Vector2 = Vector2(pos.x, pos.y - 10.0 * p_scale) + Vector2(cos(arm_angle), sin(arm_angle)) * arm_len
	draw_line(Vector2(pos.x, pos.y - 10.0 * p_scale), tip, metal, 4.0 * p_scale, true)
	draw_circle(tip, 4.0 * p_scale, Color(0.2, 0.2, 0.2, 1.0))

	# Operai
	_draw_infantry(Vector2(pos.x - 24.0 * p_scale, pos.y - 6.0 * p_scale), phase, p_scale * 0.65)

func _draw_sphere(center: Vector2, radius: float, color: Color):
	var segs: int = 14
	var points: PackedVector2Array = PackedVector2Array()
	for i in range(segs + 1):
		var ang: float = i * _PI * 2.0 / segs
		points.append(center + Vector2(cos(ang), sin(ang)) * radius)
	var cols: PackedColorArray = PackedColorArray()
	for i in range(points.size()):
		var ratio: float = (points[i].x - center.x + radius) / (2.0 * radius)
		cols.append(color.darkened(0.25).lerp(color.lightened(0.25), ratio))
	draw_polygon(points, cols)

func _ellipse_points(center: Vector2, rx: float, ry: float, segs: int) -> PackedVector2Array:
	var pts: PackedVector2Array = PackedVector2Array()
	for i in range(segs + 1):
		var ang: float = i * _PI * 2.0 / segs
		pts.append(center + Vector2(cos(ang) * rx, sin(ang) * ry))
	return pts

func _rounded_rect_points(center: Vector2, hw: float, hh: float, segs: int = 16) -> PackedVector2Array:
	var pts: PackedVector2Array = PackedVector2Array()
	# Semplicemente un rettangolo con angoli arrotondati
	for i in range(segs + 1):
		var t: float = i / float(segs)
		var x: float
		var y: float
		if t < 0.25:
			x = -hw + t / 0.25 * hw * 2.0
			y = -hh
		elif t < 0.5:
			x = hw
			y = -hh + (t - 0.25) / 0.25 * hh * 2.0
		elif t < 0.75:
			x = hw - (t - 0.5) / 0.25 * hw * 2.0
			y = hh
		else:
			x = -hw
			y = hh - (t - 0.75) / 0.25 * hh * 2.0
		pts.append(center + Vector2(x, y))
	return pts

# --- Modalità 2D stile Age of Empires (figure vettoriali animate, non icone statiche) ---

func _draw_2d_formation():
	var vis_count: int = clampi(count, 1, 10)
	var cols: int = 3
	var rows: int = 3
	var spacing_x: float = 18.0
	var spacing_y: float = 14.0
	match role:
		"cavalry":
			cols = 2
			rows = 2
			spacing_x = 34.0
			spacing_y = 22.0
		"elephant":
			cols = 1
			rows = 1
			spacing_x = 60.0
			spacing_y = 60.0
		"artillery":
			cols = 1
			rows = 1
			spacing_x = 40.0
			spacing_y = 30.0
		"ranged":
			cols = 3
			rows = 3
			spacing_x = 16.0
			spacing_y = 13.0
		_:
			cols = 3
			rows = 4
			spacing_x = 16.0
			spacing_y = 13.0

	var start_x: float = -(cols - 1) * spacing_x * 0.5
	var start_y: float = -(rows - 1) * spacing_y * 0.5
	var ratio: float = clampf(float(count) / float(max_count), 0.25, 1.0)
	var formation_scale: float = 0.7 + 0.3 * ratio

	for i in range(vis_count):
		var col: int = i % cols
		var row: int = i / cols
		var pos: Vector2 = Vector2(start_x + col * spacing_x, start_y + row * spacing_y)
		var phase: float = _anim_time + i * 0.7
		_draw_2d_soldier(pos, phase, formation_scale)

	if selected:
		draw_rect(Rect2(Vector2(-32, -40), Vector2(64, 56)), Color.YELLOW, false, 2.0)
	if commander:
		draw_circle(Vector2(0, -46), 6.0, Color.GOLD)

func _draw_2d_soldier(pos: Vector2, phase: float, p_scale: float):
	# Ombra piatta
	draw_colored_polygon(_ellipse_points(pos + Vector2(0, 2), 7.0 * p_scale, 2.5 * p_scale, 8), Color(0, 0, 0, 0.35))
	match role:
		"cavalry":
			_draw_2d_cavalry(pos, phase, p_scale)
		"elephant":
			_draw_2d_elephant(pos, phase, p_scale)
		"artillery":
			_draw_2d_artillery(pos, phase, p_scale)
		"ranged":
			_draw_2d_archer(pos, phase, p_scale)
		_:
			_draw_2d_infantry(pos, phase, p_scale)

func _draw_2d_infantry(pos: Vector2, phase: float, p_scale: float):
	var tunic: Color = side_color
	var skin: Color = Color(0.82, 0.62, 0.45, 1.0)
	var dark: Color = tunic.darkened(0.35)
	var outline: Color = Color(0.05, 0.05, 0.05, 1.0)
	var body_h: float = 18.0 * p_scale
	var hw: float = 5.0 * p_scale
	var body_top: float = pos.y - 26.0 * p_scale
	var body_bottom: float = body_top + body_h

	var body_points: PackedVector2Array = PackedVector2Array([
		Vector2(pos.x - hw, body_top),
		Vector2(pos.x + hw, body_top),
		Vector2(pos.x + hw, body_bottom),
		Vector2(pos.x - hw, body_bottom)
	])
	draw_polygon(body_points, PackedColorArray([tunic, tunic, dark, dark]))
	draw_polyline(body_points, outline, 1.0, true)

	var swing: float = 5.0 * p_scale * sin(phase)
	var hip: Vector2 = Vector2(pos.x, body_bottom)
	draw_line(hip, Vector2(pos.x - 4.0 * p_scale + swing, pos.y), skin, 2.5 * p_scale, true)
	draw_line(hip, Vector2(pos.x + 4.0 * p_scale - swing, pos.y), skin, 2.5 * p_scale, true)

	var head_y: float = body_top - 6.0 * p_scale
	draw_circle(Vector2(pos.x, head_y), 5.5 * p_scale, skin)
	draw_circle(Vector2(pos.x, head_y), 5.5 * p_scale, outline, false, 1.0)

	var shoulder: Vector2 = Vector2(pos.x, body_top + 6.0 * p_scale)
	var arm_x: float = pos.x + 8.0 * p_scale + 3.0 * p_scale * cos(phase)
	var hand: Vector2 = Vector2(arm_x, body_top + 12.0 * p_scale)
	draw_line(shoulder, hand, skin, 2.0 * p_scale, true)

	# Lancia
	draw_line(hand, Vector2(hand.x + 14.0 * p_scale, hand.y - 10.0 * p_scale), Color(0.55, 0.45, 0.25, 1.0), 2.5 * p_scale, true)
	draw_circle(hand + Vector2(14.0 * p_scale, -10.0 * p_scale), 2.5 * p_scale, Color(0.75, 0.75, 0.8, 1.0))

	# Scudo
	var shield_points: PackedVector2Array = PackedVector2Array([
		Vector2(pos.x - 12.0 * p_scale, body_top + 4.0 * p_scale),
		Vector2(pos.x - 4.0 * p_scale, body_top + 4.0 * p_scale),
		Vector2(pos.x - 4.0 * p_scale, body_bottom - 2.0 * p_scale),
		Vector2(pos.x - 12.0 * p_scale, body_bottom - 2.0 * p_scale)
	])
	draw_colored_polygon(shield_points, Color(0.5, 0.35, 0.15, 1.0))
	draw_polyline(shield_points, outline, 1.0, true)

func _draw_2d_archer(pos: Vector2, phase: float, p_scale: float):
	var tunic: Color = side_color.darkened(0.05)
	var skin: Color = Color(0.82, 0.62, 0.45, 1.0)
	var dark: Color = tunic.darkened(0.35)
	var outline: Color = Color(0.05, 0.05, 0.05, 1.0)
	var body_h: float = 17.0 * p_scale
	var hw: float = 4.5 * p_scale
	var body_top: float = pos.y - 25.0 * p_scale
	var body_bottom: float = body_top + body_h

	var body_points: PackedVector2Array = PackedVector2Array([
		Vector2(pos.x - hw, body_top),
		Vector2(pos.x + hw, body_top),
		Vector2(pos.x + hw, body_bottom),
		Vector2(pos.x - hw, body_bottom)
	])
	draw_polygon(body_points, PackedColorArray([tunic, tunic, dark, dark]))
	draw_polyline(body_points, outline, 1.0, true)

	var swing: float = 4.0 * p_scale * sin(phase)
	var hip: Vector2 = Vector2(pos.x, body_bottom)
	draw_line(hip, Vector2(pos.x - 3.5 * p_scale + swing, pos.y), skin, 2.0 * p_scale, true)
	draw_line(hip, Vector2(pos.x + 3.5 * p_scale - swing, pos.y), skin, 2.0 * p_scale, true)

	var head_y: float = body_top - 5.5 * p_scale
	draw_circle(Vector2(pos.x, head_y), 5.0 * p_scale, skin)
	draw_circle(Vector2(pos.x, head_y), 5.0 * p_scale, outline, false, 1.0)

	var bow_center: Vector2 = Vector2(pos.x - 10.0 * p_scale, body_top + 8.0 * p_scale)
	draw_arc(bow_center, 10.0 * p_scale, -_PI * 0.6, _PI * 0.6, 12, Color(0.55, 0.35, 0.15, 1.0), 2.0 * p_scale, true)
	draw_line(bow_center + Vector2(0, -10.0 * p_scale), bow_center + Vector2(0, 10.0 * p_scale), Color(0.9, 0.9, 0.85, 1.0), 1.0 * p_scale, true)

	var arrow_start: Vector2 = bow_center + Vector2(0, 0)
	var arrow_end: Vector2 = arrow_start + Vector2(18.0 * p_scale, 0)
	draw_line(arrow_start, arrow_end, Color(0.75, 0.55, 0.25, 1.0), 2.0 * p_scale, true)
	var head_points: PackedVector2Array = PackedVector2Array([
		arrow_end,
		arrow_end + Vector2(-5.0 * p_scale, -2.5 * p_scale),
		arrow_end + Vector2(-5.0 * p_scale, 2.5 * p_scale)
	])
	draw_colored_polygon(head_points, Color(0.75, 0.75, 0.8, 1.0))

func _draw_2d_cavalry(pos: Vector2, phase: float, p_scale: float):
	var horse: Color = Color(0.55, 0.38, 0.22, 1.0)
	var horse_dark: Color = horse.darkened(0.3)
	var outline: Color = Color(0.05, 0.05, 0.05, 1.0)

	# Cavallo (corpo ellittico)
	var body_c: Vector2 = Vector2(pos.x + 4.0 * p_scale, pos.y - 16.0 * p_scale)
	var body_pts: PackedVector2Array = _ellipse_points(body_c, 22.0 * p_scale, 10.0 * p_scale, 16)
	draw_colored_polygon(body_pts, horse)
	draw_polyline(body_pts, outline, 1.0, true)

	# Testa
	draw_circle(Vector2(pos.x + 20.0 * p_scale, pos.y - 32.0 * p_scale), 6.0 * p_scale, horse_dark)
	draw_circle(Vector2(pos.x + 20.0 * p_scale, pos.y - 32.0 * p_scale), 6.0 * p_scale, outline, false, 1.0)

	# Zampe animate
	var z: float = 8.0 * p_scale * sin(phase)
	var z2: float = 8.0 * p_scale * sin(phase + _PI)
	var front_leg: Vector2 = Vector2(pos.x + 12.0 * p_scale, pos.y - 10.0 * p_scale)
	var back_leg: Vector2 = Vector2(pos.x - 10.0 * p_scale, pos.y - 10.0 * p_scale)
	draw_line(front_leg, Vector2(front_leg.x + z, pos.y), horse, 3.0 * p_scale, true)
	draw_line(front_leg, Vector2(front_leg.x + z2, pos.y), horse_dark, 3.0 * p_scale, true)
	draw_line(back_leg, Vector2(back_leg.x + z2, pos.y), horse, 3.0 * p_scale, true)
	draw_line(back_leg, Vector2(back_leg.x + z, pos.y), horse_dark, 3.0 * p_scale, true)

	# Cavaliere
	var rider: Vector2 = Vector2(pos.x + 4.0 * p_scale, pos.y - 30.0 * p_scale)
	_draw_2d_infantry(rider + Vector2(0, 6.0 * p_scale), phase, p_scale * 0.7)

func _draw_2d_elephant(pos: Vector2, phase: float, p_scale: float):
	var gray: Color = Color(0.52, 0.50, 0.47, 1.0)
	var dark: Color = gray.darkened(0.3)
	var outline: Color = Color(0.05, 0.05, 0.05, 1.0)

	var body_c: Vector2 = Vector2(pos.x, pos.y - 24.0 * p_scale)
	var body_pts: PackedVector2Array = _rounded_rect_points(body_c, 30.0 * p_scale, 20.0 * p_scale)
	draw_colored_polygon(body_pts, gray)
	draw_polyline(body_pts, outline, 1.0, true)

	var head: Vector2 = Vector2(pos.x + 28.0 * p_scale, pos.y - 38.0 * p_scale)
	draw_circle(head, 9.0 * p_scale, gray.lightened(0.1))
	draw_circle(head, 9.0 * p_scale, outline, false, 1.0)
	var trunk_end: Vector2 = Vector2(head.x + 16.0 * p_scale + 4.0 * p_scale * sin(phase), head.y + 8.0 * p_scale)
	draw_line(head, trunk_end, gray.lightened(0.05), 5.0 * p_scale, true)

	for ox in [-18.0, 18.0]:
		draw_line(Vector2(pos.x + ox * p_scale, pos.y - 14.0 * p_scale), Vector2(pos.x + ox * p_scale, pos.y), gray, 6.0 * p_scale, true)

	var howdah: PackedVector2Array = PackedVector2Array([
		Vector2(pos.x - 14.0 * p_scale, pos.y - 44.0 * p_scale),
		Vector2(pos.x + 14.0 * p_scale, pos.y - 44.0 * p_scale),
		Vector2(pos.x + 12.0 * p_scale, pos.y - 34.0 * p_scale),
		Vector2(pos.x - 12.0 * p_scale, pos.y - 34.0 * p_scale)
	])
	draw_colored_polygon(howdah, Color(0.55, 0.35, 0.15, 1.0))
	draw_polyline(howdah, outline, 1.0, true)

func _draw_2d_artillery(pos: Vector2, phase: float, p_scale: float):
	var wood: Color = Color(0.55, 0.40, 0.25, 1.0)
	var metal: Color = Color(0.45, 0.45, 0.48, 1.0)
	var outline: Color = Color(0.05, 0.05, 0.05, 1.0)

	draw_circle(Vector2(pos.x - 16.0 * p_scale, pos.y), 8.0 * p_scale, Color(0.3, 0.2, 0.1, 1.0))
	draw_circle(Vector2(pos.x - 16.0 * p_scale, pos.y), 3.0 * p_scale, Color(0.6, 0.5, 0.35, 1.0))
	draw_circle(Vector2(pos.x + 16.0 * p_scale, pos.y), 8.0 * p_scale, Color(0.3, 0.2, 0.1, 1.0))
	draw_circle(Vector2(pos.x + 16.0 * p_scale, pos.y), 3.0 * p_scale, Color(0.6, 0.5, 0.35, 1.0))

	var carro_points: PackedVector2Array = PackedVector2Array([
		Vector2(pos.x - 18.0 * p_scale, pos.y - 10.0 * p_scale),
		Vector2(pos.x + 18.0 * p_scale, pos.y - 10.0 * p_scale),
		Vector2(pos.x + 18.0 * p_scale, pos.y - 4.0 * p_scale),
		Vector2(pos.x - 18.0 * p_scale, pos.y - 4.0 * p_scale)
	])
	draw_colored_polygon(carro_points, wood)
	draw_polyline(carro_points, outline, 1.0, true)

	var arm_angle: float = -0.4 + 0.3 * sin(phase)
	var arm_len: float = 28.0 * p_scale
	var tip: Vector2 = Vector2(pos.x, pos.y - 10.0 * p_scale) + Vector2(cos(arm_angle), sin(arm_angle)) * arm_len
	draw_line(Vector2(pos.x, pos.y - 10.0 * p_scale), tip, metal, 4.0 * p_scale, true)
	draw_circle(tip, 4.0 * p_scale, Color(0.2, 0.2, 0.2, 1.0))

	_draw_2d_infantry(Vector2(pos.x - 24.0 * p_scale, pos.y - 6.0 * p_scale), phase, p_scale * 0.65)
