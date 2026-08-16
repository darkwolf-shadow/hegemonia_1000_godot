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
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not _dragging:
			# Verifica se il click e' su un agglomerato
			_check_settlement_click()
	elif event is InputEventMouseMotion and _dragging:
		var factor: float = 1.0 / territory_view.scale.x
		territory_view.position += event.relative * factor


func _check_settlement_click():
	# Converti posizione mouse in coordinate del territory_view
	# TerritoryView e' un Node2D a position (480, 350) con scale variabile
	var mouse_screen = get_viewport().get_mouse_position()
	var tv_pos = territory_view.global_position
	var tv_scale = territory_view.scale.x
	var local_pos = (mouse_screen - tv_pos) / tv_scale
	# Raggio piu' grande per facilitare il click
	var best_name: String = ""
	var best_dist: float = 80.0
	for s_name in settlement_markers.keys():
		var marker_pos: Vector2 = settlement_markers[s_name]
		var dist: float = local_pos.distance_to(marker_pos)
		if dist < best_dist:
			best_dist = dist
			best_name = s_name
	print("Settlement click @ screen %s | local %s | markers: %d | best: %s (dist %.1f)" % [str(mouse_screen), str(local_pos), settlement_markers.size(), best_name, best_dist])
	if best_name != "":
		GameState.state["last_settlement"] = best_name
		get_tree().change_scene_to_file("res://scenes/settlement_scene.tscn")


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
	var terrain: String = data.get("terrain", "generic")
	var terrain_lower: String = terrain.to_lower()

	# Sfondo del terreno (PNG realistico se disponibile, altrimenti SVG)
	var bg_path := _get_background_path(terrain_lower)
	if ResourceLoader.exists(bg_path):
		var bg_tex = load(bg_path)
		if bg_tex:
			var bg_rect := TextureRect.new()
			bg_rect.texture = bg_tex
			bg_rect.size = Vector2(2400, 1800)
			bg_rect.position = Vector2(-1200, -1100)
			bg_rect.z_index = -10
			bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			bg_rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
			bg_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			territory_view.add_child(bg_rect)

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

	# Vegetazione e dettagli SOLO dentro il poligono della provincia
	_terrain_pattern(terrain, scaled_polys)

	# Disegna agglomerati urbani
	var prov = GameState.state.provinces.get(current_province, {})
	var settlements = prov.get("settlements", {})
	var settlement_names = settlements.keys() if settlements is Dictionary else []
	var count: int = settlement_names.size()
	var owner: String = prov.get("owner", "")
	var region: String = IconManager.region_for_faction(owner)

	if count == 0:
		# Se non ci sono agglomerati, genera un agglomerato principale
		# basato sul nome della provincia
		var marker_pos := poly_center
		_draw_settlement_marker(marker_pos, current_province, "civil", 0, region)
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

			_draw_settlement_marker(pos, s_name, s.get("type", "civil"), idx, region)
			settlement_markers[s_name] = pos
			idx += 1

		# Strade tra agglomerati - sterrate o in pietra in base all'evoluzione
		for i in range(positions.size()):
			for j in range(i + 1, positions.size()):
				var s_i = settlements[settlement_names[i]] if settlement_names.size() > i else {}
				var s_j = settlements[settlement_names[j]] if settlement_names.size() > j else {}
				var stone := _has_strade(s_i) or _has_strade(s_j)
				_draw_road(positions[i], positions[j], stone)


func _draw_settlement_marker(pos: Vector2, name: String, type_name: String, idx: int, region: String = "european"):
	# Icona della settlement senza sfondo bianco e con dimensioni moderate
	if type_name == "capital":
		type_name = "civil"
	var tex = IconManager.get_settlement_icon_masked(type_name, region)
	if tex == null:
		tex = IconManager.get_settlement_icon(type_name, region)
	var sprite := Sprite2D.new()
	sprite.texture = tex
	sprite.position = pos
	sprite.scale = Vector2(1.2, 1.2)
	sprite.z_index = 5
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	territory_view.add_child(sprite)

	# Ombra sotto l'icona per profondita
	var shadow := ColorRect.new()
	shadow.color = Color(0, 0, 0, 0.3)
	shadow.size = Vector2(60, 12)
	shadow.position = pos + Vector2(-30, 25)
	shadow.z_index = 4
	territory_view.add_child(shadow)

	# Etichetta con sfondo semitrasparente
	var label_bg := ColorRect.new()
	label_bg.color = Color(0, 0, 0, 0.6)
	label_bg.size = Vector2(120, 22)
	label_bg.position = pos + Vector2(-60, -55)
	label_bg.z_index = 6
	territory_view.add_child(label_bg)

	var label := Label.new()
	label.text = name
	label.position = pos + Vector2(-55, -53)
	label.size = Vector2(110, 18)
	label.add_theme_color_override("font_color", Color(1, 0.95, 0.7, 1.0))
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.horizontal_alignment = 1
	label.z_index = 7
	territory_view.add_child(label)


func _has_strade(settlement: Dictionary) -> bool:
	if settlement is Dictionary:
		return "strade" in settlement.get("buildings", [])
	return false


func _draw_road(a: Vector2, b: Vector2, stone: bool):
	var base_color := Color(0.35, 0.28, 0.18, 0.7)
	var inner_color := Color(0.55, 0.45, 0.28, 0.8)
	var width := 5.0
	var inner_width := 2.5
	if stone:
		base_color = Color(0.45, 0.45, 0.48, 0.8)
		inner_color = Color(0.70, 0.70, 0.74, 0.85)
		width = 6.0
		inner_width = 3.0
	var road_base := Line2D.new()
	road_base.add_point(a)
	road_base.add_point(b)
	road_base.width = width
	road_base.default_color = base_color
	road_base.antialiased = true
	road_base.joint_mode = Line2D.LINE_JOINT_ROUND
	territory_view.add_child(road_base)

	var road_inner := Line2D.new()
	road_inner.add_point(a)
	road_inner.add_point(b)
	road_inner.width = inner_width
	road_inner.default_color = inner_color
	road_inner.antialiased = true
	road_inner.joint_mode = Line2D.LINE_JOINT_ROUND
	territory_view.add_child(road_inner)


func _settlement_icon(type_name: String) -> String:
	# Usa le icone SVG base del progetto (non quelle originali di Medieval 2)
	if type_name == "capital":
		type_name = "civil"
	var path := "res://assets/icons/1000/settlements/" + type_name + ".svg"
	if not ResourceLoader.exists(path):
		path = "res://assets/icons/1000/settlements/civil.svg"
	return path


func _get_background_path(terrain_lower: String) -> String:
	# Usa subito lo SVG vettoriale ad alta risoluzione; il PNG a 256x256 appare pixelato
	var svg_path := _terrain_svg_path(terrain_lower)
	if FileAccess.file_exists(svg_path):
		return svg_path
	var png_name := _png_background_name(terrain_lower)
	var png_path := "res://assets/backgrounds/1000/png/" + png_name + ".png"
	if FileAccess.file_exists(png_path):
		return png_path
	return "res://assets/backgrounds/1000/generic.svg"


func _png_background_name(terrain_lower: String) -> String:
	if terrain_lower in ["forest", "foresta", "jungle", "giungla", "swamp", "palude"]:
		return "forest"
	if terrain_lower in ["mountain", "montagna", "mountains", "hills", "colline", "tundra"]:
		return "mountains"
	if terrain_lower in ["desert", "deserto", "savannah", "savana", "steppe", "steppa"]:
		return "desert"
	return "plains"


func _terrain_svg_path(terrain_lower: String) -> String:
	# Path allo SVG di sfondo per ogni tipo di terreno
	match terrain_lower:
		"forest", "foresta":
			return "res://assets/backgrounds/1000/forest.svg"
		"mountain", "montagna", "mountains":
			return "res://assets/backgrounds/1000/mountains.svg"
		"desert", "deserto":
			return "res://assets/backgrounds/1000/desert.svg"
		"plains", "pianura":
			return "res://assets/backgrounds/1000/plains.svg"
		"coastal", "costiera", "coast":
			return "res://assets/backgrounds/1000/coast.svg"
		"tundra":
			return "res://assets/backgrounds/1000/tundra.svg"
		"hills", "colline":
			return "res://assets/backgrounds/1000/hills.svg"
		"swamp", "palude":
			return "res://assets/backgrounds/1000/swamp.svg"
		"jungle", "giungla":
			return "res://assets/backgrounds/1000/jungle.svg"
		"steppe", "steppa":
			return "res://assets/backgrounds/1000/steppe.svg"
		"savannah", "savana":
			return "res://assets/backgrounds/1000/savannah.svg"
		"river", "fiume":
			return "res://assets/backgrounds/1000/river.svg"
		"industrial", "industriale":
			return "res://assets/backgrounds/1000/industrial.svg"
		"military", "militare":
			return "res://assets/backgrounds/1000/military.svg"
		"port", "porto":
			return "res://assets/backgrounds/1000/port.svg"
		_:
			return "res://assets/backgrounds/1000/generic.svg"


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


func _terrain_pattern(terrain: String, scaled_polys: Array):
	# Disegna vegetazione e elementi del terreno SOLO dentro il poligono
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(current_province)
	var terrain_lower = terrain.to_lower()

	# Funzione helper: verifica se un punto e' dentro almeno un poligono
	var check_inside := func(pos: Vector2) -> bool:
		for poly in scaled_polys:
			if _point_in_polygon(pos, poly):
				return true
		return false

	# Macchie di erba/terreno con variazioni di colore
	var base_color: Color = _terrain_color(terrain)
	var attempts: int = 0
	var placed: int = 0
	while placed < 25 and attempts < 100:
		attempts += 1
		var x: float = rng.randf_range(-400, 400)
		var y: float = rng.randf_range(-400, 400)
		var pos := Vector2(x, y)
		if not check_inside.call(pos):
			continue
		var patch := Polygon2D.new()
		var pts := PackedVector2Array()
		var radius: float = rng.randf_range(25, 55)
		var sides: int = 8
		for s in range(sides):
			var angle: float = s * TAU / sides + rng.randf_range(-0.3, 0.3)
			var r: float = radius * rng.randf_range(0.7, 1.3)
			pts.append(pos + Vector2(cos(angle) * r, sin(angle) * r))
		patch.polygon = pts
		var variant: float = rng.randf_range(-0.08, 0.08)
		patch.color = Color(
			clamp(base_color.r + variant, 0, 1),
			clamp(base_color.g + variant, 0, 1),
			clamp(base_color.b + variant * 0.5, 0, 1),
			0.5
		)
		patch.z_index = -3
		territory_view.add_child(patch)
		placed += 1

	# Alberi per foresta, pianura, costiera, generico
	if terrain_lower in ["forest", "foresta", "plains", "pianura", "coastal", "costiera", "generic", ""]:
		var tree_target: int = 20 if terrain_lower in ["forest", "foresta"] else 10
		attempts = 0
		placed = 0
		while placed < tree_target and attempts < 80:
			attempts += 1
			var x: float = rng.randf_range(-350, 350)
			var y: float = rng.randf_range(-350, 350)
			var pos := Vector2(x, y)
			if not check_inside.call(pos):
				continue
			_draw_tree(pos, rng.randf_range(0.6, 1.2))
			placed += 1

	# Colline per montagna, colline, tundra
	if terrain_lower in ["mountain", "montagna", "hills", "colline", "tundra"]:
		attempts = 0
		placed = 0
		while placed < 8 and attempts < 60:
			attempts += 1
			var x: float = rng.randf_range(-350, 350)
			var y: float = rng.randf_range(-350, 350)
			var pos := Vector2(x, y)
			if not check_inside.call(pos):
				continue
			_draw_hill(pos, rng.randf_range(30, 60), terrain_lower)
			placed += 1

	# Dune per deserto
	if terrain_lower in ["desert", "deserto"]:
		attempts = 0
		placed = 0
		while placed < 10 and attempts < 60:
			attempts += 1
			var x: float = rng.randf_range(-350, 350)
			var y: float = rng.randf_range(-350, 350)
			var pos := Vector2(x, y)
			if not check_inside.call(pos):
				continue
			_draw_dune(pos, rng)
			placed += 1

	# Rocce per montagna
	if terrain_lower in ["mountain", "montagna"]:
		attempts = 0
		placed = 0
		while placed < 6 and attempts < 50:
			attempts += 1
			var x: float = rng.randf_range(-350, 350)
			var y: float = rng.randf_range(-350, 350)
			var pos := Vector2(x, y)
			if not check_inside.call(pos):
				continue
			_draw_rock(pos, rng.randf_range(12, 28))
			placed += 1


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


func _update_settlements():
	settlements_list.clear()
	var prov = GameState.state.provinces.get(current_province, {})
	var settlements = prov.get("settlements", {})
	var data = WorldData.get_province(current_province)

	for s_name in settlements.keys():
		var s = settlements[s_name]
		var tipo = _translate_settlement_type(s.get("type", "civil"))
		var pop = s.get("population", 0)
		settlements_list.add_item("%s (%s, pop. %d)" % [s_name, tipo, pop])

	var owner = prov.get("owner", "Terra di Nessuno")
	info_label.text = "Proprietario: %s\nRegione: %s\nTerreno: %s\nPopolazione: %d" % [
		owner,
		data.get("region", "N/D"),
		_translate_terrain(data.get("terrain", "N/D")),
		int(data.get("population", 0))
	]


func _translate_terrain(terrain: String) -> String:
	match terrain.to_lower():
		"forest":
			return "Foresta"
		"foresta":
			return "Foresta"
		"mountain":
			return "Montagna"
		"montagna":
			return "Montagna"
		"mountains":
			return "Montagne"
		"desert":
			return "Deserto"
		"deserto":
			return "Deserto"
		"plains":
			return "Pianura"
		"pianura":
			return "Pianura"
		"coastal":
			return "Costiera"
		"costiera":
			return "Costiera"
		"coast":
			return "Costa"
		"tundra":
			return "Tundra"
		"hills":
			return "Colline"
		"colline":
			return "Colline"
		"swamp":
			return "Palude"
		"palude":
			return "Palude"
		"jungle":
			return "Giungla"
		"giungla":
			return "Giungla"
		"steppe":
			return "Steppa"
		"steppa":
			return "Steppa"
		"savannah":
			return "Savana"
		"savana":
			return "Savana"
		"river":
			return "Fiume"
		"fiume":
			return "Fiume"
		"industrial":
			return "Industriale"
		"military":
			return "Militare"
		"port":
			return "Porto"
		"generic":
			return "Generico"
		_:
			return terrain


func _translate_settlement_type(type_name: String) -> String:
	match type_name.to_lower():
		"capital":
			return "Capitale"
		"military":
			return "Militare"
		"port":
			return "Porto"
		"industrial":
			return "Industriale"
		"civil":
			return "Civile"
		_:
			return type_name


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
