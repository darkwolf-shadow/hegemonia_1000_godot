# Dark Corporation / Stev
# Mappa strategica anno 1000 - stile Leaflet con nebbia di guerra a raggio
extends Node2D

@onready var map_layer := $MapLayer
@onready var camera := $Camera2D
@onready var turn_label := $CanvasLayer/UI/TopBar/TurnLabel
@onready var end_turn_button := $CanvasLayer/UI/TopBar/EndTurnButton
@onready var province_popup = $CanvasLayer/UI/ProvincePopup
@onready var province_view := $CanvasLayer/UI/ProvinceView
@onready var log_text := $CanvasLayer/UI/EventLog/LogText

var province_nodes := {}
var province_centers := {}
var province_all_polygons := {}
var province_bounds := {}
var selected_province: String = ""
var _dragging := false
var _min_zoom := 0.15
var _max_zoom := 8.0
var _zoom_speed := 0.12
var _selected_border: Line2D = null

# Colori stile Leaflet - Dark Corporation / Stev
const COL_SEA := Color(0.16, 0.50, 0.73, 0.45)
const COL_SEA_BORDER := Color(0.12, 0.38, 0.55, 0.5)
const COL_FOG_BLACK := Color(0.0, 0.0, 0.0, 1.0)
const COL_FOG_HALF := Color(0.02, 0.02, 0.02, 1.0)
const COL_LAND_BORDER := Color(0.10, 0.10, 0.12, 0.9)
const COL_SELECTED := Color(1.0, 1.0, 0.3, 1.0)


func _ready():
	end_turn_button.pressed.connect(_on_end_turn)
	province_popup.enter_province.connect(_on_enter_province)
	_draw_map()
	_update_ui()


func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_camera(1)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_camera(-1)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			_dragging = event.pressed
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_dragging = event.pressed
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not _dragging:
			# Verifica che il click non sia su un elemento UI
			var ui = $CanvasLayer/UI
			var mouse_pos = ui.get_global_mouse_position()
			var on_ui = false
			for child in ui.get_children():
				if child is Control and child.visible and child.get_global_rect().has_point(mouse_pos):
					if child.mouse_filter != Control.MOUSE_FILTER_IGNORE:
						on_ui = true
						break
			if not on_ui:
				_check_province_click()
	elif event is InputEventMouseMotion and _dragging:
		var factor: float = 1.0 / camera.zoom.x
		camera.position -= event.relative * factor


func _zoom_camera(direction: int):
	var old_zoom: float = camera.zoom.x
	var new_zoom: float = clampf(old_zoom * (1.0 + _zoom_speed * direction), _min_zoom, _max_zoom)
	var world_pos = camera.get_global_mouse_position()
	camera.zoom = Vector2(new_zoom, new_zoom)
	var new_world_pos = camera.get_global_mouse_position()
	camera.position += world_pos - new_world_pos


func _is_sea(data: Dictionary) -> bool:
	var featurecla: String = data.get("properties", {}).get("featurecla", "")
	if featurecla in ["sea", "ocean", "gulf", "bay", "strait", "sound", "channel", "lagoon", "fjord", "river", "reef", "inlet"]:
		return true
	var tipo: String = data.get("properties", {}).get("tipo", "")
	if tipo == "mare":
		return true
	var name: String = data.get("name", "")
	if "OCEAN" in name.to_upper() or " SEA" in name.to_upper() or "SEA " in name.to_upper():
		return true
	return false


func _check_province_click():
	var world_pos: Vector2 = camera.get_global_mouse_position()
	var best: String = ""
	var best_area: float = INF
	# Pre-filtro con bounding box per velocizzare
	for p in province_all_polygons.keys():
		var bounds: Rect2 = province_bounds.get(p, Rect2())
		if bounds.size == Vector2.ZERO:
			continue
		if not bounds.has_point(world_pos):
			continue
		var all_polys: Array = province_all_polygons[p]
		for poly in all_polys:
			if _point_in_polygon(world_pos, poly):
				var area: float = _polygon_area(poly)
				if area < best_area:
					best_area = area
					best = p
				break
	if best != "":
		_select_province(best)


func _point_in_polygon(point: Vector2, poly: PackedVector2Array) -> bool:
	if poly.size() < 3:
		return false
	var inside := false
	var j: int = poly.size() - 1
	for i in range(poly.size()):
		var pi: Vector2 = poly[i]
		var pj: Vector2 = poly[j]
		if ((pi.y > point.y) != (pj.y > point.y)) and \
		   (point.x < (pj.x - pi.x) * (point.y - pi.y) / (pj.y - pi.y) + pi.x):
			inside = not inside
		j = i
	return inside


func _polygon_area(poly: PackedVector2Array) -> float:
	if poly.size() < 3:
		return 0.0
	var area: float = 0.0
	var j: int = poly.size() - 1
	for i in range(poly.size()):
		area += (poly[j].x + poly[i].x) * (poly[j].y - poly[i].y)
		j = i
	return abs(area) * 0.5


func _draw_map():
	for child in map_layer.get_children():
		child.queue_free()
	province_nodes.clear()
	province_centers.clear()
	province_all_polygons.clear()
	province_bounds.clear()

	# Calcola bounds
	var min_x := INF
	var max_x := -INF
	var min_y := INF
	var max_y := -INF

	for p in WorldData.provinces.keys():
		var all_polys = _get_all_polygons(p)
		for poly in all_polys:
			for pt in poly:
				min_x = min(min_x, pt.x)
				max_x = max(max_x, pt.x)
				min_y = min(min_y, pt.y)
				max_y = max(max_y, pt.y)

	var center := Vector2.ZERO
	if min_x != INF:
		center = Vector2((min_x + max_x) / 2, (min_y + max_y) / 2)

	var scale_factor := 25.0
	var screen_center := Vector2(960, 540)

	# Sfondo oceano profondo
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.09, 0.18, 1.0)
	bg.size = Vector2(8000, 6000)
	bg.position = Vector2(-3000, -2000)
	bg.z_index = -10
	map_layer.add_child(bg)

	for p in WorldData.provinces.keys():
		var all_polys = _get_all_polygons(p)
		if all_polys.is_empty():
			continue

		# Scala e centra tutti i poligoni
		var scaled_polys: Array = []
		for poly in all_polys:
			var sp := PackedVector2Array()
			for i in range(poly.size()):
				sp.append((poly[i] - center) * scale_factor + screen_center)
			scaled_polys.append(sp)

		# Memorizza per click detection
		province_all_polygons[p] = scaled_polys
		# Calcola bounding box per pre-filtro click
		var b_min_x := INF
		var b_max_x := -INF
		var b_min_y := INF
		var b_max_y := -INF
		for sp in scaled_polys:
			for pt in sp:
				b_min_x = min(b_min_x, pt.x)
				b_max_x = max(b_max_x, pt.x)
				b_min_y = min(b_min_y, pt.y)
				b_max_y = max(b_max_y, pt.y)
		province_bounds[p] = Rect2(Vector2(b_min_x, b_min_y), Vector2(b_max_x - b_min_x, b_max_y - b_min_y))

		var data = WorldData.get_province(p)
		var prov = GameState.state.provinces.get(p, {})
		var owner = prov.get("owner", "Terra di Nessuno")
		var fog: String = GameState.get_fog(p)
		var is_sea: bool = _is_sea(data)

		# Usa il poligono piu' grande come nodo principale
		var biggest: PackedVector2Array = scaled_polys[0]
		for sp in scaled_polys:
			if sp.size() > biggest.size():
				biggest = sp

		var polygon = Polygon2D.new()
		polygon.name = p
		polygon.polygon = biggest
		polygon.antialiased = true

		# Colore in base a nebbia/mare/fazione
		if fog == "nebbia":
			polygon.color = Color(0.02, 0.02, 0.04, 0.92)
		elif fog == "mezza":
			polygon.color = COL_FOG_HALF
		else:
			if is_sea:
				polygon.color = COL_SEA
			else:
				var faction = WorldData.get_faction(owner)
				var hex = faction.get("color", "#888888")
				var base_color: Color = Color(hex)
				polygon.color = Color(base_color.r, base_color.g, base_color.b, 0.85)

		# Disegna anche i poligoni secondari (isole)
		for i in range(1, scaled_polys.size()):
			var extra = Polygon2D.new()
			extra.polygon = scaled_polys[i]
			extra.antialiased = true
			extra.color = polygon.color
			extra.visible = polygon.visible
			polygon.add_child(extra)

		# Bordo
		var border := Line2D.new()
		border.points = biggest
		border.closed = true
		border.antialiased = true
		border.joint_mode = Line2D.LINE_JOINT_ROUND
		if fog == "nebbia":
			border.width = 0.3
			border.default_color = Color(0.05, 0.05, 0.08, 0.8)
		elif fog == "mezza":
			border.width = 0.3
			border.default_color = Color(0.08, 0.08, 0.10, 0.8)
		elif is_sea:
			border.width = 0.3
			border.default_color = COL_SEA_BORDER
		else:
			border.width = 0.4
			border.default_color = COL_LAND_BORDER
		border.z_index = 1
		polygon.add_child(border)

		map_layer.add_child(polygon)
		province_nodes[p] = polygon
		province_centers[p] = _polygon_center(biggest)

	# Centra camera sulle province del giocatore
	var player_provs = GameState.get_player_provinces()
	if player_provs.size() > 0:
		var first = player_provs[0]
		if province_centers.has(first):
			camera.position = province_centers[first]
			camera.zoom = Vector2(1.5, 1.5)


func _get_all_polygons(province_name: String) -> Array:
	# Restituisce tutti i poligoni di una provincia (gestisce MultiPolygon)
	var data = WorldData.get_province(province_name)
	var geometry = data.get("geometry", {})
	if not geometry.has("coordinates"):
		var center = _hash_position(province_name)
		var pts := PackedVector2Array()
		for i in range(6):
			var angle = i * TAU / 6
			pts.append(center + Vector2(cos(angle), sin(angle)) * 3.0)
		return [pts]

	var geom_type: String = geometry.get("type", "Polygon")
	var coords = geometry["coordinates"]
	var result: Array = []

	if geom_type == "MultiPolygon":
		for poly in coords:
			if poly.size() > 0:
				var ring: Array = poly[0]
				var pts := PackedVector2Array()
				for coord in ring:
					if coord.size() >= 2:
						pts.append(Vector2(float(coord[0]), -float(coord[1])))
				if pts.size() >= 3:
					result.append(pts)
	else:
		if coords.size() > 0:
			var ring: Array = coords[0]
			var pts := PackedVector2Array()
			for coord in ring:
				if coord.size() >= 2:
					pts.append(Vector2(float(coord[0]), -float(coord[1])))
			if pts.size() >= 3:
				result.append(pts)

	return result


func _get_polygon_points(province_name: String) -> PackedVector2Array:
	var all = _get_all_polygons(province_name)
	if all.is_empty():
		return PackedVector2Array()
	return all[0]


func _hash_position(name: String) -> Vector2:
	var h = hash(name)
	return Vector2((h % 1000) / 50.0, ((h >> 10) % 1000) / 50.0)


func _faction_color(owner: String) -> Color:
	var faction = WorldData.get_faction(owner)
	var hex = faction.get("color", "#888888")
	return Color(hex)


func _polygon_center(points: PackedVector2Array) -> Vector2:
	var c := Vector2.ZERO
	for pt in points:
		c += pt
	return c / max(1, points.size())


func _select_province(province_name: String):
	# Rimuovi evidenza precedente
	if _selected_border:
		_selected_border.width = 0.4
		_selected_border.default_color = COL_LAND_BORDER
	_selected_border = null

	selected_province = province_name

	# Evidenzia bordo provincia selezionata
	if province_nodes.has(province_name):
		var poly_node: Polygon2D = province_nodes[province_name]
		if poly_node:
			# Cerca il Line2D tra i figli (non e' sempre il primo)
			for child in poly_node.get_children():
				if child is Line2D:
					child.width = 1.0
					child.default_color = COL_SELECTED
					_selected_border = child
					break

	# Mostra popup
	province_popup.show_province(province_name)


func _on_enter_province(province_name: String):
	# Cambia scena alla vista provincia dedicata
	var tree = get_tree()
	# Salva la provincia selezionata per la scena provincia
	GameState.state["last_province"] = province_name
	tree.change_scene_to_file("res://scenes/province_scene.tscn")


func _on_end_turn():
	GameState.advance_turn()
	_draw_map()
	_update_ui()


func _update_ui():
	turn_label.text = "Turno %d - %d/%d" % [GameState.state.turn, GameState.state.year, GameState.state.month]
	var lines := []
	for ev in GameState.state.events:
		lines.append("Turno %d: %s" % [ev.turn, ev.text])
	log_text.text = "[b]Cronaca[/b]\n" + "\n".join(lines.slice(-20))
