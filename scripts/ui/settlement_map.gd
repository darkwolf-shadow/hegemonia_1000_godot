extends Control

var _settlement: Dictionary = {}
var _region: String = "european"
var _province: String = ""
var _settlement_name: String = ""
var _building_positions: Dictionary = {}


func build_map(settlement: Dictionary, region: String, province: String, settlement_name: String):
	_settlement = settlement
	_region = region
	_province = province
	_settlement_name = settlement_name
	_building_positions.clear()
	queue_redraw()


func _draw():
	_draw_ground()
	_draw_roads()
	_draw_buildings()


func _draw_ground():
	var type_name := str(_settlement.get("type", "civil"))
	var png_path := "res://assets/backgrounds/1000/png/settlements/" + type_name + ".png"
	if FileAccess.file_exists(png_path):
		var tex = load(png_path) as Texture2D
		if tex:
			draw_texture_rect(tex, Rect2(Vector2.ZERO, size), false)
			return
	# Fallback SVG del terreno/insediamento
	var svg_path := "res://assets/backgrounds/1000/" + type_name + ".svg"
	if FileAccess.file_exists(svg_path):
		var tex = load(svg_path) as Texture2D
		if tex:
			draw_texture_rect(tex, Rect2(Vector2.ZERO, size), false)
			return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.12, 0.10, 0.08, 1.0))


func _draw_roads():
	var center := size * 0.5
	var buildings: Array = _settlement.get("buildings", [])
	var stone := "strade" in buildings
	for i in range(buildings.size()):
		var pos := _building_position(i)
		_draw_road(center, pos, stone)


func _building_position(index: int) -> Vector2:
	var buildings: Array = _settlement.get("buildings", [])
	if index >= buildings.size():
		return size * 0.5
	var b := str(buildings[index])
	var key := _settlement_name + "_" + b + "_" + str(index)
	if _building_positions.has(key):
		return _building_positions[key]
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(key)
	var center := size * 0.5
	var angle := rng.randf() * TAU
	var radius := 80.0 + (index % 3) * 45.0 + rng.randf_range(-15.0, 15.0)
	var pos := center + Vector2(cos(angle), sin(angle)) * radius
	# Mantiene l'edificio dentro la mappa
	pos.x = clampf(pos.x, 48.0, size.x - 48.0)
	pos.y = clampf(pos.y, 48.0, size.y - 48.0)
	_building_positions[key] = pos
	return pos


func _draw_road(a: Vector2, b: Vector2, stone: bool):
	var base_color := Color(0.35, 0.28, 0.18, 0.8)
	var inner_color := Color(0.55, 0.45, 0.28, 0.9)
	var width := 8.0
	if stone:
		base_color = Color(0.42, 0.42, 0.46, 0.9)
		inner_color = Color(0.72, 0.72, 0.76, 0.95)
		width = 9.0
	draw_line(a, b, base_color, width, true)
	draw_line(a, b, inner_color, width * 0.45, true)


func _draw_buildings():
	var buildings: Array = _settlement.get("buildings", [])
	for i in range(buildings.size()):
		var b := str(buildings[i])
		var pos := _building_position(i)
		var tex = IconManager.get_building_icon(b, _region)
		if tex == null:
			continue
		var icon_size := tex.get_size() * 0.55
		draw_texture_rect(tex, Rect2(pos - icon_size * 0.5, icon_size), false)
