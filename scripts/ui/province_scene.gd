# Dark Corporation / Stev
# Scena provincia dedicata - render territorio con zoom, agglomerati e strade
extends Control

@onready var title_label: Label = $Panel/Title
@onready var territory_view: Node2D = $TerritoryView
@onready var settlements_list: ItemList = $Panel/SettlementsList
@onready var info_label: Label = $Panel/Info
@onready var back_button: Button = $Panel/BackButton
@onready var enter_button: Button = $Panel/EnterButton

var current_province: String = ""
var settlement_markers: Dictionary = {}
var _dragging := false
var _min_zoom := 0.3
var _max_zoom := 5.0


func _ready():
	back_button.pressed.connect(_on_back)
	enter_button.pressed.connect(_on_enter_settlement)
	settlements_list.item_selected.connect(_on_settlement_selected)
	var prov = GameState.state.get("last_province", "")
	if not prov.is_empty():
		_open_province(prov)


func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_on_back()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_territory(1)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_territory(-1)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			_dragging = event.pressed
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_dragging = event.pressed
	elif event is InputEventMouseMotion and _dragging:
		var factor: float = 1.0 / territory_view.scale.x
		territory_view.position += event.relative * factor


func _zoom_territory(direction: int):
	var old_scale: float = territory_view.scale.x
	var new_scale: float = clampf(old_scale * (1.0 + 0.15 * direction), _min_zoom, _max_zoom)
	territory_view.scale = Vector2(new_scale, new_scale)


func _open_province(province_name: String):
	current_province = province_name
	title_label.text = province_name
	_draw_territory()
	_update_settlements()


func _draw_territory():
	for child in territory_view.get_children():
		child.queue_free()
	settlement_markers.clear()

	var data = WorldData.get_province(current_province)
	var geometry = data.get("geometry", {})

	# Sfondo terreno con colori variabili in base al terrain type
	var terrain: String = data.get("terrain", "generic")
	var bg_color: Color = _terrain_color(terrain)
	var bg := ColorRect.new()
	bg.color = bg_color
	bg.size = Vector2(3000, 3000)
	bg.position = Vector2(-1500, -1500)
	bg.z_index = -10
	territory_view.add_child(bg)

	# Aggiungi texture di vegetazione con pattern
	_terrain_pattern(terrain)

	if not geometry.has("coordinates"):
		return

	# Raccogli tutti i poligoni
	var all_polys: Array = []
	var geom_type: String = geometry.get("type", "Polygon")
	var coords = geometry["coordinates"]

	if geom_type == "MultiPolygon":
		for poly in coords:
			if poly.size() > 0:
				var ring: Array = poly[0]
				var pts := PackedVector2Array()
				for coord in ring:
					if coord.size() >= 2:
						pts.append(Vector2(float(coord[0]), -float(coord[1])))
				if pts.size() >= 3:
					all_polys.append(pts)
	else:
		if coords.size() > 0:
			var ring: Array = coords[0]
			var pts := PackedVector2Array()
			for coord in ring:
				if coord.size() >= 2:
					pts.append(Vector2(float(coord[0]), -float(coord[1])))
			if pts.size() >= 3:
				all_polys.append(pts)

	if all_polys.is_empty():
		return

	# Calcola bounds e centra
	var min_x := INF
	var max_x := -INF
	var min_y := INF
	var max_y := -INF
	for poly in all_polys:
		for pt in poly:
			min_x = min(min_x, pt.x)
			max_x = max(max_x, pt.x)
			min_y = min(min_y, pt.y)
			max_y = max(max_y, pt.y)

	var center := Vector2((min_x + max_x) / 2, (min_y + max_y) / 2)
	var ext_x: float = max_x - min_x
	var ext_y: float = max_y - min_y
	var scale_factor: float = 600.0 / max(ext_x, ext_y)
	var screen_center := Vector2(0, 0)

	# Scala e centra
	var scaled_polys: Array = []
	for poly in all_polys:
		var sp := PackedVector2Array()
		for i in range(poly.size()):
			sp.append((poly[i] - center) * scale_factor + screen_center)
		scaled_polys.append(sp)

	# Disegna tutti i poligoni del territorio
	for poly in scaled_polys:
		var polygon := Polygon2D.new()
		polygon.polygon = poly
		polygon.color = Color(0.30, 0.42, 0.25, 0.9)
		polygon.antialiased = true
		territory_view.add_child(polygon)

		# Bordo
		var border := Line2D.new()
		border.points = poly
		border.closed = true
		border.antialiased = true
		border.width = 2.0
		border.default_color = Color(0.2, 0.15, 0.1, 1.0)
		border.joint_mode = Line2D.LINE_JOINT_ROUND
		territory_view.add_child(border)

	# Calcola centro del territorio
	var poly_center := _polygon_center(scaled_polys[0])

	# Disegna agglomerati urbani
	var prov = GameState.state.provinces.get(current_province, {})
	var settlements = prov.get("settlements", {})
	var settlement_names = settlements.keys() if settlements is Dictionary else []
	var count: int = settlement_names.size()

	if count == 0:
		# Se non ci sono agglomerati, genera un agglomerato principale
		# basato sul nome della provincia
		var marker_pos := poly_center
		_draw_settlement_marker(marker_pos, current_province, "civil", 0)
		settlement_markers[current_province] = marker_pos
	else:
		var radius: float = 100.0
		var idx: int = 0
		var positions: Array[Vector2] = []

		for s_name in settlement_names:
			var s = settlements[s_name]
			var angle: float = idx * TAU / count - PI / 2
			var pos: Vector2 = poly_center + Vector2(cos(angle), sin(angle)) * radius
			positions.append(pos)

			_draw_settlement_marker(pos, s_name, s.get("type", "civil"), idx)
			settlement_markers[s_name] = pos
			idx += 1

		# Strade tra agglomerati
		for i in range(positions.size()):
			for j in range(i + 1, positions.size()):
				var road := Line2D.new()
				road.add_point(positions[i])
				road.add_point(positions[j])
				road.width = 1.5
				road.default_color = Color(0.5, 0.4, 0.25, 0.6)
				road.antialiased = true
				territory_view.add_child(road)


func _draw_settlement_marker(pos: Vector2, name: String, type_name: String, idx: int):
	# Icona reale di Medieval 2 in base al tipo
	var icon_path := _settlement_icon(type_name)
	var sprite := Sprite2D.new()
	sprite.texture = load(icon_path)
	sprite.position = pos
	sprite.scale = Vector2(1.5, 1.5)
	sprite.z_index = 5
	territory_view.add_child(sprite)

	# Etichetta
	var label := Label.new()
	label.text = name
	label.position = pos + Vector2(-40, -45)
	label.add_theme_color_override("font_color", Color(1, 1, 0.8, 1.0))
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.z_index = 6
	territory_view.add_child(label)


func _settlement_icon(type_name: String) -> String:
	# Icone originali di Medieval 2 Total War
	match type_name:
		"capital":
			return "res://assets/ui_textures/settlements/city.png"
		"military":
			return "res://assets/ui_textures/settlements/castle.png"
		"port":
			return "res://assets/ui_textures/settlements/port.png"
		"industrial":
			return "res://assets/ui_textures/settlements/mines.png"
		_:
			return "res://assets/ui_textures/settlements/village.png"


func _terrain_color(terrain: String) -> Color:
	match terrain:
		"forest", "foresta":
			return Color(0.12, 0.20, 0.10, 1.0)
		"mountain", "montagna":
			return Color(0.25, 0.22, 0.18, 1.0)
		"desert", "deserto":
			return Color(0.45, 0.38, 0.22, 1.0)
		"plains", "pianura":
			return Color(0.18, 0.28, 0.15, 1.0)
		"coastal", "costiera":
			return Color(0.15, 0.25, 0.22, 1.0)
		"tundra", "tundra":
			return Color(0.30, 0.32, 0.28, 1.0)
		_:
			return Color(0.15, 0.22, 0.15, 1.0)


func _terrain_pattern(terrain: String):
	# Aggiunge punti di vegetazione/terreno per dare profondita'
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(current_province)
	var pattern_color: Color = _terrain_color(terrain).lightened(0.15)
	for i in range(80):
		var x: float = rng.randf_range(-1000, 1000)
		var y: float = rng.randf_range(-1000, 1000)
		var dot := ColorRect.new()
		dot.color = pattern_color
		dot.size = Vector2(rng.randf_range(8, 20), rng.randf_range(8, 20))
		dot.position = Vector2(x, y)
		dot.z_index = -5
		territory_view.add_child(dot)


func _settlement_color(type_name: String) -> Color:
	match type_name:
		"capital":
			return Color(1.0, 0.84, 0.0, 1.0)
		"military":
			return Color(0.8, 0.2, 0.2, 1.0)
		"port":
			return Color(0.2, 0.6, 0.9, 1.0)
		"industrial":
			return Color(0.5, 0.5, 0.5, 1.0)
		_:
			return Color(0.7, 0.7, 0.5, 1.0)


func _polygon_center(points: PackedVector2Array) -> Vector2:
	var c := Vector2.ZERO
	for pt in points:
		c += pt
	return c / max(1, points.size())


func _update_settlements():
	settlements_list.clear()
	var prov = GameState.state.provinces.get(current_province, {})
	var settlements = prov.get("settlements", {})
	var data = WorldData.get_province(current_province)

	for s_name in settlements.keys():
		var s = settlements[s_name]
		var tipo = s.get("type", "civil")
		var pop = s.get("population", 0)
		settlements_list.add_item("%s (%s, pop. %d)" % [s_name, tipo, pop])

	var owner = prov.get("owner", "Terra di Nessuno")
	info_label.text = "Proprietario: %s\nRegione: %s\nTerreno: %s\nPopolazione: %d" % [
		owner,
		data.get("region", "N/D"),
		data.get("terrain", "N/D"),
		int(data.get("population", 0))
	]


func _on_settlement_selected(index: int):
	var prov = GameState.state.provinces.get(current_province, {})
	var settlements = prov.get("settlements", {})
	var keys = settlements.keys()
	if index >= 0 and index < keys.size():
		var s_name = keys[index]
		var s = settlements[s_name]
		var buildings = s.get("buildings", [])
		info_label.text = "%s\nTipo: %s\nPopolazione: %d\nEdifici: %s" % [
			s_name,
			s.get("type", "civil"),
			int(s.get("population", 0)),
			", ".join(buildings) if buildings is Array else "Nessuno"
		]


func _on_enter_settlement():
	var idx = settlements_list.get_selected_items()
	if idx.size() == 0:
		return
	var prov = GameState.state.provinces.get(current_province, {})
	var settlements = prov.get("settlements", {})
	var keys = settlements.keys()
	if idx[0] < keys.size():
		var s_name = keys[idx[0]]
		GameState.state["last_settlement"] = s_name
		get_tree().change_scene_to_file("res://scenes/settlement_scene.tscn")


func _on_back():
	get_tree().change_scene_to_file("res://scenes/strategic_map.tscn")
