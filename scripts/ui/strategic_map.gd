extends Node2D

@onready var map_layer := $MapLayer
@onready var turn_label := $CanvasLayer/UI/TopBar/TurnLabel
@onready var end_turn_button := $CanvasLayer/UI/TopBar/EndTurnButton
@onready var info_label := $CanvasLayer/UI/SidePanel/InfoLabel
@onready var details_label := $CanvasLayer/UI/SidePanel/Details
@onready var open_province_button := $CanvasLayer/UI/SidePanel/OpenProvinceButton
@onready var province_view := $CanvasLayer/UI/ProvinceView
@onready var log_text := $CanvasLayer/UI/EventLog/LogText

var province_nodes := {}
var selected_province: String = ""


func _ready():
	end_turn_button.pressed.connect(_on_end_turn)
	open_province_button.pressed.connect(_on_open_province)
	_draw_map()
	_update_ui()


func _draw_map():
	for child in map_layer.get_children():
		child.queue_free()
	province_nodes.clear()

	var min_x := INF
	var max_x := -INF
	var min_y := INF
	var max_y := -INF

	for p in WorldData.provinces.keys():
		var poly = _get_polygon_points(p)
		for pt in poly:
			min_x = min(min_x, pt.x)
			max_x = max(max_x, pt.x)
			min_y = min(min_y, pt.y)
			max_y = max(max_y, pt.y)

	var offset := Vector2.ZERO
	if min_x != INF:
		offset = Vector2(960, 540) - Vector2((min_x + max_x) / 2, (min_y + max_y) / 2)

	var scale_factor := 15.0

	for p in WorldData.provinces.keys():
		var poly := _get_polygon_points(p)
		for i in range(poly.size()):
			poly[i] = (poly[i] + offset) * scale_factor

		var prov = GameState.state.provinces.get(p, {})
		var owner = prov.get("owner", "Terra di Nessuno")
		var color = _faction_color(owner)

		var polygon = Polygon2D.new()
		polygon.name = p
		polygon.polygon = poly
		polygon.color = color
		polygon.modulate = Color(1, 1, 1, 0.9 if prov.get("visible", true) else 0.3)

		var area = Area2D.new()
		var collision = CollisionPolygon2D.new()
		collision.polygon = poly
		area.add_child(collision)
		area.input_event.connect(_on_province_clicked.bind(p))
		polygon.add_child(area)

		map_layer.add_child(polygon)
		province_nodes[p] = polygon

		var label = Label.new()
		label.text = p
		label.position = _polygon_center(poly)
		label.modulate = Color(1, 1, 1, 1.0 if prov.get("visible", true) else 0.3)
		map_layer.add_child(label)


func _get_polygon_points(province_name: String) -> PackedVector2Array:
	var data = WorldData.get_province(province_name)
	var geometry = data.get("geometry", {})
	if not geometry.has("coordinates"):
		var center = _hash_position(province_name)
		var pts := PackedVector2Array()
		for i in range(6):
			var angle = i * TAU / 6
			pts.append(center + Vector2(cos(angle), sin(angle)) * 3.0)
		return pts

	var coords = geometry["coordinates"]
	var points := PackedVector2Array()
	for ring in coords:
		for coord in ring:
			points.append(Vector2(coord[0], -coord[1]))
		break
	return points


func _hash_position(name: String) -> Vector2:
	var h = hash(name)
	return Vector2((h % 1000) / 50.0, ((h >> 10) % 1000) / 50.0)


func _faction_color(owner: String) -> Color:
	var faction = WorldData.get_faction(owner)
	var hex = faction.get("color", "#AAAAAA")
	return Color(hex)


func _polygon_center(points: PackedVector2Array) -> Vector2:
	var c := Vector2.ZERO
	for pt in points:
		c += pt
	return c / max(1, points.size())


func _on_province_clicked(viewport, event, shape_idx, province_name):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_select_province(province_name)


func _select_province(province_name: String):
	selected_province = province_name
	var prov = GameState.state.provinces.get(province_name, {})
	var owner = prov.get("owner", "Terra di Nessuno")
	var data = WorldData.get_province(province_name)
	info_label.text = province_name
	var txt = "Proprietario: %s\nRegione: %s\nTerreno: %s\nPopolazione: %d\nRisorse: %s" % [
		owner,
		data.get("region", ""),
		data.get("terrain", ""),
		data.get("population", 0),
		JSON.stringify(data.get("resources", {}))
	]
	details_label.text = txt


func _on_open_province():
	if selected_province != "":
		province_view.open(selected_province)


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
