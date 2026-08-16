extends Control

signal building_selected(building_id: String)
signal slot_selected(slot_index: int, building_id: String)

var _settlement: Dictionary = {}
var _region: String = "european"
var _province: String = ""
var _settlement_name: String = ""

var _zoom: float = 1.0
var _pan: Vector2 = Vector2.ZERO
var _dragging: bool = false
var _selected_slot: int = -1

const GRID_COLS := 5
const GRID_ROWS := 5
const CELL_SIZE := 80.0
const SPACING := 14.0
const CENTER_SLOT := 12

var _slot_building: Dictionary = {}
var _building_slot: Dictionary = {}

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
	_zoom = 1.0
	_pan = Vector2.ZERO
	_selected_slot = -1
	_rebuild_slot_mapping()
	queue_redraw()


func select_building(building_id: String):
	_selected_slot = _building_slot.get(building_id, -1)
	queue_redraw()


func _rebuild_slot_mapping():
	_slot_building.clear()
	_building_slot.clear()
	var peripheral := _peripheral_slots()
	var peripheral_idx := 0
	var center_used := false
	var buildings: Array = _settlement.get("buildings", [])
	for b in buildings:
		var id: String = str(b)
		if id == "centro_cittadino" and not center_used:
			_slot_building[CENTER_SLOT] = id
			_building_slot[id] = CENTER_SLOT
			center_used = true
		elif peripheral_idx < peripheral.size():
			var slot: int = peripheral[peripheral_idx]
			peripheral_idx += 1
			_slot_building[slot] = id
			_building_slot[id] = slot


func _peripheral_slots() -> Array:
	var center := Vector2(CENTER_SLOT % GRID_COLS, CENTER_SLOT / GRID_COLS)
	var slots := []
	for i in range(GRID_COLS * GRID_ROWS):
		if i == CENTER_SLOT:
			continue
		var p := Vector2(i % GRID_COLS, i / GRID_COLS)
		slots.append({"slot": i, "dist": center.distance_squared_to(p)})
	slots.sort_custom(func(a, b): return a["dist"] < b["dist"])
	return slots.map(func(x): return x["slot"])


func _draw():
	_draw_ground()
	_draw_roads()
	_draw_slots()


func _grid_origin() -> Vector2:
	var grid_w := GRID_COLS * CELL_SIZE + (GRID_COLS - 1) * SPACING
	var grid_h := GRID_ROWS * CELL_SIZE + (GRID_ROWS - 1) * SPACING
	return -Vector2(grid_w, grid_h) * 0.5


func _slot_position(slot_index: int) -> Vector2:
	var origin := _grid_origin()
	var col := slot_index % GRID_COLS
	var row := slot_index / GRID_COLS
	return origin + Vector2(col, row) * (CELL_SIZE + SPACING) + Vector2(CELL_SIZE, CELL_SIZE) * 0.5


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
		var grid_size := Vector2(
			GRID_COLS * CELL_SIZE + (GRID_COLS - 1) * SPACING,
			GRID_ROWS * CELL_SIZE + (GRID_ROWS - 1) * SPACING
		)
		var margin := 40.0
		var bg_size: Vector2 = (grid_size + Vector2(margin * 2, margin * 2)) * _zoom
		var bg_pos: Vector2 = _world_to_screen(-grid_size * 0.5 - Vector2(margin, margin))
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
	var center_pos := _slot_position(CENTER_SLOT)
	var buildings: Array = _settlement.get("buildings", [])
	var stone := buildings.has("strade")
	for slot_key in _slot_building.keys():
		var slot: int = slot_key
		if slot == CENTER_SLOT:
			continue
		var pos := _slot_position(slot)
		_draw_road(center_pos, pos, stone)


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


func _draw_slots():
	var total_slots := GRID_COLS * GRID_ROWS
	for slot in range(total_slots):
		var pos := _slot_position(slot)
		var screen_pos := _world_to_screen(pos)
		var is_empty := not _slot_building.has(slot)
		var selected := slot == _selected_slot
		if is_empty:
			_draw_empty_slot(screen_pos, selected)
		else:
			var b: String = str(_slot_building[slot])
			_draw_building_slot(screen_pos, b, selected)


func _draw_empty_slot(screen_pos: Vector2, selected: bool):
	var half := CELL_SIZE * 0.5 * _zoom
	var rect := Rect2(screen_pos - Vector2(half, half), Vector2(half * 2, half * 2))
	var fill := Color(0.18, 0.15, 0.12, 0.65)
	var border := Color(0.45, 0.38, 0.28, 0.35)
	if selected:
		fill = Color(0.28, 0.22, 0.15, 0.75)
		border = Color(0.85, 0.70, 0.40, 0.85)
	draw_rect(rect, fill, true)
	draw_rect(rect, border, false, 2.0 * _zoom)


func _draw_building_slot(screen_pos: Vector2, building_id: String, selected: bool):
	var half := CELL_SIZE * 0.5 * _zoom
	var rect := Rect2(screen_pos - Vector2(half, half), Vector2(half * 2, half * 2))
	draw_rect(rect, Color(0.08, 0.07, 0.06, 0.4), true)
	if selected:
		draw_rect(rect, Color(0.95, 0.80, 0.45, 0.85), false, 3.0 * _zoom)
	else:
		draw_rect(rect, Color(0.45, 0.38, 0.28, 0.45), false, 2.0 * _zoom)

	_draw_vector_building(screen_pos, building_id)
	_draw_building_icon(screen_pos, building_id)

	var level := _get_building_level(building_id)
	if level > 1:
		_draw_level_pips(screen_pos, level)


func _get_building_level(building_id: String) -> int:
	return _settlement.get("building_levels", {}).get(building_id, 1)


func _draw_level_pips(screen_pos: Vector2, level: int):
	var radius := 3.5 * _zoom
	var offset := CELL_SIZE * 0.35 * _zoom
	var color := Color(0.95, 0.80, 0.45, 0.95)
	for i in range(level - 1):
		draw_circle(screen_pos + Vector2(offset - i * (radius * 2.8), -offset), radius, color)


func _draw_vector_building(screen_pos: Vector2, building_id: String):
	var color: Color = _building_colors.get(building_id, Color(0.45, 0.38, 0.30))
	var base := (CELL_SIZE * 0.30) * _zoom
	var body := PackedVector2Array([
		screen_pos + Vector2(-base, base * 0.4),
		screen_pos + Vector2(base, base * 0.4),
		screen_pos + Vector2(base * 0.7, -base * 0.6),
		screen_pos + Vector2(-base * 0.7, -base * 0.6)
	])
	var roof := PackedVector2Array([
		screen_pos + Vector2(-base * 0.85, -base * 0.6),
		screen_pos + Vector2(0.0, -base * 1.1),
		screen_pos + Vector2(base * 0.85, -base * 0.6),
		screen_pos + Vector2(-base * 0.85, -base * 0.6)
	])
	var dark: Color = color.darkened(0.3)
	var light1: Color = color.lightened(0.2)
	var light2: Color = color.lightened(0.4)
	draw_polygon(body, PackedColorArray([dark, color, color, dark]))
	draw_polygon(roof, PackedColorArray([light1, light2, light1, light1]))


func _draw_building_icon(screen_pos: Vector2, building_id: String):
	var tex := IconManager.get_building_icon_masked(building_id, _region)
	if tex == null:
		return
	var icon_size: Vector2 = tex.get_size() * 0.35 * _zoom
	draw_texture_rect(tex, Rect2(screen_pos - icon_size * 0.5 - Vector2(0.0, 6.0 * _zoom), icon_size), false)


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_at(event.position, 1.1)
			accept_event()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_at(event.position, 1.0 / 1.1)
			accept_event()
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_select_slot_at(event.position)
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


func _select_slot_at(screen_pos: Vector2):
	var world_pos := _screen_to_world(screen_pos)
	var total_slots := GRID_COLS * GRID_ROWS
	var best := -1
	var best_dist := INF
	for slot in range(total_slots):
		var pos := _slot_position(slot)
		var dist := world_pos.distance_to(pos)
		if dist < best_dist:
			best_dist = dist
			best = slot
	if best_dist <= CELL_SIZE * 0.6:
		_selected_slot = best
		queue_redraw()
		var building_id := ""
		if _slot_building.has(best):
			building_id = str(_slot_building[best])
			building_selected.emit(building_id)
		slot_selected.emit(best, building_id)
