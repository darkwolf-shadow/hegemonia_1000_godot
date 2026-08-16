extends Control

signal building_selected(building_id: String)

var _settlement: Dictionary = {}
var _region: String = "european"
var _province: String = ""
var _settlement_name: String = ""
var _building_positions: Dictionary = {}

var _zoom: float = 1.0
var _pan: Vector2 = Vector2.ZERO
var _dragging: bool = false
var _selected_building: String = ""

var _building_colors: Dictionary = {
	"centro_cittadino": Color(0.55, 0.40, 0.22),
	"mercato": Color(0.30, 0.48, 0.28),
	"mercato_marittimo": Color(0.25, 0.42, 0.50),
	"caserma_i": Color(0.55, 0.20, 0.18),
	"caserma_ii": Color(0.60, 0.22, 0.18),
	"caserma_iii": Color(0.65, 0.24, 0.18),
	"scuderia_i": Color(0.50, 0.35, 0.18),
	"scuderia_ii": Color(0.53, 0.36, 0.18),
	"scuderia_iii": Color(0.56, 0.37, 0.18),
	"officina_armi": Color(0.42, 0.40, 0.38),
	"fucina": Color(0.35, 0.35, 0.35),
	"miniera": Color(0.30, 0.28, 0.25),
	"capanna_boscaioli": Color(0.45, 0.38, 0.28),
	"segheria": Color(0.50, 0.40, 0.28),
	"mulino": Color(0.55, 0.45, 0.30),
	"molo_i": Color(0.30, 0.35, 0.45),
	"molo_ii": Color(0.32, 0.37, 0.48),
	"monastero": Color(0.45, 0.42, 0.38),
	"fortezza_frontiera": Color(0.48, 0.48, 0.52),
	"cortile_cavaliere": Color(0.55, 0.35, 0.20),
	"magazzino": Color(0.40, 0.35, 0.25),
	"strade": Color(0.38, 0.33, 0.25),
	"campo_tiro_i": Color(0.40, 0.45, 0.30),
	"campo_tiro_ii": Color(0.42, 0.47, 0.30),
	"campo_tiro_iii": Color(0.45, 0.50, 0.30),
	"officina_assedio_i": Color(0.45, 0.42, 0.35),
	"officina_assedio_ii": Color(0.48, 0.45, 0.36),
	"officina_assedio_iii": Color(0.52, 0.48, 0.38),
	"arsenale_i": Color(0.35, 0.35, 0.40),
	"arsenale_ii": Color(0.38, 0.38, 0.43)
}


func build_map(settlement: Dictionary, region: String, province: String, settlement_name: String):
	_settlement = settlement
	_region = region
	_province = province
	_settlement_name = settlement_name
	_building_positions.clear()
	_zoom = 1.0
	_pan = Vector2.ZERO
	_selected_building = ""
	queue_redraw()


func select_building(building_id: String):
	_selected_building = building_id
	queue_redraw()


func _draw():
	_draw_ground()
	_draw_roads()
	_draw_buildings()


func _world_to_screen(v: Vector2) -> Vector2:
	return size * 0.5 + (v + _pan) * _zoom


func _screen_to_world(v: Vector2) -> Vector2:
	return (v - size * 0.5) / _zoom - _pan


func _draw_ground():
	# Colore di base che copre tutto il canvas
	draw_rect(Rect2(Vector2(-2000, -2000), Vector2(4000, 4000)), Color(0.10, 0.09, 0.07, 1.0))

	var type_name := str(_settlement.get("type", "civil"))
	var tex: Texture2D = _load_background_texture(type_name)
	if tex != null:
		var bg_size: Vector2 = size * _zoom
		var bg_pos: Vector2 = _world_to_screen(-size * 0.5)
		draw_texture_rect(tex, Rect2(bg_pos, bg_size), false)
	else:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.12, 0.10, 0.08, 1.0))


func _load_background_texture(type_name: String) -> Texture2D:
	var svg_path := "res://assets/backgrounds/1000/" + type_name + ".svg"
	if FileAccess.file_exists(svg_path):
		return load(svg_path) as Texture2D
	var png_path := "res://assets/backgrounds/1000/png/settlements/" + type_name + ".png"
	if FileAccess.file_exists(png_path):
		return load(png_path) as Texture2D
	var generic_paths := [
		"res://assets/backgrounds/1000/generic.svg",
		"res://assets/backgrounds/1000/png/generic.png"
	]
	for p in generic_paths:
		if FileAccess.file_exists(p):
			return load(p) as Texture2D
	return null


func _draw_roads():
	var center := Vector2.ZERO
	var buildings: Array = _settlement.get("buildings", [])
	var stone := buildings.has("strade")
	for i in range(buildings.size()):
		var pos := _building_position(i)
		_draw_road(center, pos, stone)


func _building_position(index: int) -> Vector2:
	var buildings: Array = _settlement.get("buildings", [])
	if index >= buildings.size():
		return Vector2.ZERO
	var b := str(buildings[index])
	var key := _settlement_name + "_" + b + "_" + str(index)
	if _building_positions.has(key):
		return _building_positions[key]

	var rng := RandomNumberGenerator.new()
	rng.seed = hash(key)
	# Spirale dorata per evitare sovrapposizioni
	var golden_angle := 2.399963229728653
	var ring := index / 6
	var idx_in_ring := index % 6
	var angle := ring * golden_angle + idx_in_ring * (TAU / 6.0) + rng.randf_range(-0.15, 0.15)
	var radius := 90.0 + ring * 55.0 + rng.randf_range(-12.0, 12.0)
	var pos := Vector2(cos(angle), sin(angle)) * radius
	_building_positions[key] = pos
	return pos


func _draw_road(a: Vector2, b: Vector2, stone: bool):
	var screen_a := _world_to_screen(a)
	var screen_b := _world_to_screen(b)
	var base_color := Color(0.35, 0.28, 0.18, 0.8)
	var inner_color := Color(0.55, 0.45, 0.28, 0.9)
	var width := 8.0 * _zoom
	if stone:
		base_color = Color(0.42, 0.42, 0.46, 0.9)
		inner_color = Color(0.72, 0.72, 0.76, 0.95)
		width = 9.0 * _zoom
	draw_line(screen_a, screen_b, base_color, width, true)
	draw_line(screen_a, screen_b, inner_color, width * 0.45, true)


func _draw_buildings():
	var buildings: Array = _settlement.get("buildings", [])
	for i in range(buildings.size()):
		var b := str(buildings[i])
		var pos := _building_position(i)
		var screen_pos := _world_to_screen(pos)
		_draw_vector_building(screen_pos, b, b == _selected_building)
		_draw_building_icon(screen_pos, b)


func _draw_vector_building(screen_pos: Vector2, building_id: String, selected: bool):
	var color: Color = _building_colors.get(building_id, Color(0.45, 0.38, 0.30))
	var base := 24.0 * _zoom
	var body := PackedVector2Array([
		screen_pos + Vector2(-base, base * 0.4),
		screen_pos + Vector2(base, base * 0.4),
		screen_pos + Vector2(base, -base * 0.6),
		screen_pos + Vector2(-base, -base * 0.6)
	])
	var roof := PackedVector2Array([
		screen_pos + Vector2(-base * 1.15, -base * 0.6),
		screen_pos + Vector2(0.0, -base * 1.1),
		screen_pos + Vector2(base * 1.15, -base * 0.6),
		screen_pos + Vector2(-base * 1.15, -base * 0.6)
	])
	var dark: Color = color.darkened(0.3)
	var light1: Color = color.lightened(0.2)
	var light2: Color = color.lightened(0.4)
	draw_polygon(body, PackedColorArray([dark, color, color, dark]))
	draw_polygon(roof, PackedColorArray([light1, light2, light1, light1]))
	if selected:
		draw_circle(screen_pos, base * 1.25, Color(0.95, 0.80, 0.45, 0.35))


func _draw_building_icon(screen_pos: Vector2, building_id: String):
	var tex := IconManager.get_building_icon_masked(building_id, _region)
	if tex == null:
		return
	var icon_size: Vector2 = tex.get_size() * 0.45 * _zoom
	draw_texture_rect(tex, Rect2(screen_pos - icon_size * 0.5 - Vector2(0.0, 8.0 * _zoom), icon_size), false)


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_at(event.position, 1.1)
			accept_event()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_at(event.position, 1.0 / 1.1)
			accept_event()
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_select_building_at(event.position)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_dragging = true
			accept_event()
		elif event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
			_dragging = false
			accept_event()
	elif event is InputEventMouseMotion:
		if _dragging:
			_pan += event.relative / _zoom
			queue_redraw()
			accept_event()


func _zoom_at(screen_pos: Vector2, factor: float):
	var world_before := _screen_to_world(screen_pos)
	_zoom = clampf(_zoom * factor, 0.25, 4.0)
	var world_after := _screen_to_world(screen_pos)
	_pan += world_before - world_after
	queue_redraw()


func _select_building_at(screen_pos: Vector2):
	var world_pos := _screen_to_world(screen_pos)
	var buildings: Array = _settlement.get("buildings", [])
	var best := ""
	var best_dist := INF
	for i in range(buildings.size()):
		var b := str(buildings[i])
		var pos := _building_position(i)
		var dist := world_pos.distance_to(pos)
		if dist < best_dist:
			best_dist = dist
			best = b
	if best_dist <= 30.0:
		_selected_building = best
		queue_redraw()
		building_selected.emit(best)
