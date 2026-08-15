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

	# Sfondo terreno con gradiente colorato in base al terrain type
	var terrain: String = data.get("terrain", "generic")
	var terrain_lower: String = terrain.to_lower()
	var bg_dark: Color = _terrain_color(terrain).darkened(0.3)
	var bg_light: Color = _terrain_color(terrain).lightened(0.1)
	for i in range(6):
		var layer := ColorRect.new()
		var t: float = float(i) / 6.0
		layer.color = bg_dark.lerp(bg_light, t)
		layer.size = Vector2(3000, 500)
		layer.position = Vector2(-1500, -1500 + i * 500)
		layer.z_index = -10
		territory_view.add_child(layer)

	# Aggiungi vegetazione e elementi del terreno
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
	var ground_color: Color = _terrain_ground_color(terrain_lower)
	for poly in scaled_polys:
		var polygon := Polygon2D.new()
		polygon.polygon = poly
		polygon.color = ground_color
		polygon.antialiased = true
		territory_view.add_child(polygon)

		# Bordo esterno spesso stile medievale
		var border_outer := Line2D.new()
		border_outer.points = poly
		border_outer.closed = true
		border_outer.antialiased = true
		border_outer.width = 4.0
		border_outer.default_color = Color(0.15, 0.10, 0.05, 0.9)
		border_outer.joint_mode = Line2D.LINE_JOINT_ROUND
		territory_view.add_child(border_outer)

		# Bordo interno dorato sottile
		var border_inner := Line2D.new()
		border_inner.points = poly
		border_inner.closed = true
		border_inner.antialiased = true
		border_inner.width = 1.5
		border_inner.default_color = Color(0.55, 0.42, 0.20, 0.8)
		border_inner.joint_mode = Line2D.LINE_JOINT_ROUND
		territory_view.add_child(border_inner)

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

		# Strade tra agglomerati - stile medievale sterrate
		for i in range(positions.size()):
			for j in range(i + 1, positions.size()):
				# Strada base larga color terra
				var road_base := Line2D.new()
				road_base.add_point(positions[i])
				road_base.add_point(positions[j])
				road_base.width = 5.0
				road_base.default_color = Color(0.35, 0.28, 0.18, 0.7)
				road_base.antialiased = true
				road_base.joint_mode = Line2D.LINE_JOINT_ROUND
				territory_view.add_child(road_base)

				# Strada interna piu' chiara
				var road_inner := Line2D.new()
				road_inner.add_point(positions[i])
				road_inner.add_point(positions[j])
				road_inner.width = 2.5
				road_inner.default_color = Color(0.55, 0.45, 0.28, 0.8)
				road_inner.antialiased = true
				road_inner.joint_mode = Line2D.LINE_JOINT_ROUND
				territory_view.add_child(road_inner)


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


func _terrain_ground_color(terrain_lower: String) -> Color:
	# Colori del terreno piu' naturali e ricchi per il suolo della provincia
	match terrain_lower:
		"forest", "foresta":
			return Color(0.22, 0.33, 0.18, 0.92)
		"mountain", "montagna":
			return Color(0.32, 0.28, 0.22, 0.92)
		"desert", "deserto":
			return Color(0.50, 0.42, 0.25, 0.92)
		"plains", "pianura":
			return Color(0.28, 0.38, 0.20, 0.92)
		"coastal", "costiera":
			return Color(0.22, 0.32, 0.25, 0.92)
		"tundra", "tundra":
			return Color(0.35, 0.37, 0.33, 0.92)
		"hills", "colline":
			return Color(0.25, 0.35, 0.18, 0.92)
		"swamp", "palude":
			return Color(0.18, 0.25, 0.18, 0.92)
		"jungle", "giungla":
			return Color(0.14, 0.28, 0.12, 0.92)
		"steppe", "steppa":
			return Color(0.32, 0.35, 0.18, 0.92)
		"savannah", "savana":
			return Color(0.40, 0.38, 0.20, 0.92)
		"river", "fiume":
			return Color(0.20, 0.28, 0.20, 0.92)
		_:
			return Color(0.24, 0.32, 0.18, 0.92)


func _terrain_pattern(terrain: String):
	# Disegna vegetazione e elementi del terreno in modo realistico
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(current_province)
	var terrain_lower = terrain.to_lower()

	# Macchie di erba/terreno con variazioni di colore
	var base_color: Color = _terrain_color(terrain)
	for i in range(40):
		var x: float = rng.randf_range(-800, 800)
		var y: float = rng.randf_range(-800, 800)
		var patch := Polygon2D.new()
		var pts := PackedVector2Array()
		var radius: float = rng.randf_range(30, 70)
		var sides: int = 8
		for s in range(sides):
			var angle: float = s * TAU / sides + rng.randf_range(-0.3, 0.3)
			var r: float = radius * rng.randf_range(0.7, 1.3)
			pts.append(Vector2(x + cos(angle) * r, y + sin(angle) * r))
		patch.polygon = pts
		var variant: float = rng.randf_range(-0.08, 0.08)
		patch.color = Color(
			clamp(base_color.r + variant, 0, 1),
			clamp(base_color.g + variant, 0, 1),
			clamp(base_color.b + variant * 0.5, 0, 1),
			0.6
		)
		patch.z_index = -5
		territory_view.add_child(patch)

	# Alberi per foresta, pianura, costiera, generico
	if terrain_lower in ["forest", "foresta", "plains", "pianura", "coastal", "costiera", "generic", ""]:
		var tree_count: int = 30 if terrain_lower in ["forest", "foresta"] else 15
		for i in range(tree_count):
			var x: float = rng.randf_range(-700, 700)
			var y: float = rng.randf_range(-700, 700)
			_draw_tree(Vector2(x, y), rng.randf_range(0.7, 1.4))

	# Colline per montagna, colline, tundra
	if terrain_lower in ["mountain", "montagna", "hills", "colline", "tundra"]:
		for i in range(12):
			var x: float = rng.randf_range(-600, 600)
			var y: float = rng.randf_range(-600, 600)
			_draw_hill(Vector2(x, y), rng.randf_range(40, 80), terrain_lower)

	# Dune per deserto
	if terrain_lower in ["desert", "deserto"]:
		for i in range(15):
			var x: float = rng.randf_range(-700, 700)
			var y: float = rng.randf_range(-700, 700)
			_draw_dune(Vector2(x, y), rng)

	# Roccce per montagna
	if terrain_lower in ["mountain", "montagna"]:
		for i in range(8):
			var x: float = rng.randf_range(-600, 600)
			var y: float = rng.randf_range(-600, 600)
			_draw_rock(Vector2(x, y), rng.randf_range(15, 35))


func _draw_tree(pos: Vector2, scale_factor: float):
	# Albero con tronco e chioma
	var s: float = scale_factor
	# Tronco
	var trunk := Polygon2D.new()
	var trunk_pts := PackedVector2Array()
	trunk_pts.append(pos + Vector2(-2 * s, 0))
	trunk_pts.append(pos + Vector2(2 * s, 0))
	trunk_pts.append(pos + Vector2(2 * s, -12 * s))
	trunk_pts.append(pos + Vector2(-2 * s, -12 * s))
	trunk.polygon = trunk_pts
	trunk.color = Color(0.25, 0.15, 0.08, 1.0)
	trunk.z_index = -3
	territory_view.add_child(trunk)

	# Chioma - triangoli sovrapposti per effetto fogliame
	var crown_colors := [Color(0.15, 0.35, 0.12, 0.95), Color(0.18, 0.40, 0.15, 0.95), Color(0.12, 0.30, 0.10, 0.95)]
	for layer in range(3):
		var crown := Polygon2D.new()
		var pts := PackedVector2Array()
		var offset_y: float = -12 * s - layer * 6 * s
		var width: float = 14 * s * (1.0 - layer * 0.2)
		pts.append(pos + Vector2(-width, offset_y))
		pts.append(pos + Vector2(width, offset_y))
		pts.append(pos + Vector2(0, offset_y - 16 * s))
		crown.polygon = pts
		crown.color = crown_colors[layer]
		crown.z_index = -2 + layer
		territory_view.add_child(crown)


func _draw_hill(pos: Vector2, radius: float, terrain_type: String):
	# Collina con curva e ombra
	var hill := Polygon2D.new()
	var pts := PackedVector2Array()
	var sides: int = 12
	for s in range(sides):
		var angle: float = s * TAU / sides
		var r: float = radius * (0.8 + 0.2 * sin(angle * 2))
		pts.append(pos + Vector2(cos(angle) * r, sin(angle) * r * 0.5))
	hill.polygon = pts
	var hill_color: Color = Color(0.30, 0.28, 0.22, 0.85) if terrain_type in ["mountain", "montagna"] else Color(0.25, 0.32, 0.18, 0.85)
	hill.color = hill_color
	hill.z_index = -4
	territory_view.add_child(hill)

	# Ombra della collina
	var shadow := Polygon2D.new()
	var shadow_pts := PackedVector2Array()
	for s in range(sides):
		var angle: float = s * TAU / sides
		var r: float = radius * 0.7
		shadow_pts.append(pos + Vector2(cos(angle) * r + 5, sin(angle) * r * 0.4 + 5))
	shadow.polygon = shadow_pts
	shadow.color = Color(0.0, 0.0, 0.0, 0.2)
	shadow.z_index = -5
	territory_view.add_child(shadow)


func _draw_dune(pos: Vector2, rng: RandomNumberGenerator):
	# Duna di sabbia
	var dune := Polygon2D.new()
	var pts := PackedVector2Array()
	var sides: int = 10
	var radius: float = rng.randf_range(40, 80)
	for s in range(sides):
		var angle: float = s * TAU / sides
		var r: float = radius * (0.6 + 0.4 * abs(sin(angle)))
		pts.append(pos + Vector2(cos(angle) * r, sin(angle) * r * 0.3))
	dune.polygon = pts
	var shade: float = rng.randf_range(0.35, 0.50)
	dune.color = Color(shade, shade * 0.85, shade * 0.55, 0.7)
	dune.z_index = -4
	territory_view.add_child(dune)


func _draw_rock(pos: Vector2, size: float):
	# Roccia con facce poligonali
	var rock := Polygon2D.new()
	var pts := PackedVector2Array()
	pts.append(pos + Vector2(-size, size * 0.3))
	pts.append(pos + Vector2(-size * 0.5, -size))
	pts.append(pos + Vector2(size * 0.3, -size * 0.8))
	pts.append(pos + Vector2(size, size * 0.5))
	rock.polygon = pts
	rock.color = Color(0.35, 0.32, 0.28, 0.9)
	rock.z_index = -3
	territory_view.add_child(rock)

	# Faccia in ombra
	var face := Polygon2D.new()
	var face_pts := PackedVector2Array()
	face_pts.append(pos + Vector2(-size, size * 0.3))
	face_pts.append(pos + Vector2(-size * 0.5, -size))
	face_pts.append(pos + Vector2(-size * 0.2, 0))
	face.polygon = face_pts
	face.color = Color(0.20, 0.18, 0.15, 0.9)
	face.z_index = -2
	territory_view.add_child(face)


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
