extends Node3D
# Scena di rendering per verificare edifici e unita' con texture
# Permette di navigare, selezionare e ispezionare ogni oggetto
# Dark Corporation / Stev

@onready var _camera: Camera3D = $CameraPivot/Camera3D
@onready var _camera_pivot: Node3D = $CameraPivot

var _editor_panel: Control = null

var _unit_types := ["spadaccini", "lancieri", "asceri", "arciere", "cavalleria", "artiglieria"]
var _building_icons := [
	"res://risorse/icone/1000/european/buildings/centro_cittadino.png",
	"res://risorse/icone/1000/european/buildings/caserma_i.png",
	"res://risorse/icone/1000/european/buildings/caserma_ii.png",
	"res://risorse/icone/1000/european/buildings/caserma_iii.png",
	"res://risorse/icone/1000/european/buildings/mercato.png",
	"res://risorse/icone/1000/european/buildings/mulino.png",
	"res://risorse/icone/1000/european/buildings/fucina.png",
	"res://risorse/icone/1000/european/buildings/miniera.png",
	"res://risorse/icone/1000/european/buildings/monastero.png",
	"res://risorse/icone/1000/european/buildings/fortezza_frontiera.png",
]
var _faction_color := Color(0.8, 0.2, 0.2)
var _selected_node: Node3D = null
var _selection_box: MeshInstance3D = null

# Camera orbitale
var _orbit_angle: float = 0.0
var _pitch_angle: float = -0.35
var _camera_distance: float = 18.0
var _dragging: bool = false
var _last_mouse: Vector2 = Vector2.ZERO

func _ready():
	_setup_environment()
	_setup_hud()
	_setup_buildings()
	_setup_units()
	_update_camera()
	print("Scena di rendering edifici e unita' pronta.")

func _setup_environment():
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.15, 0.18, 0.22)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_color = Color(0.7, 0.7, 0.75)
	env.ambient_light_energy = 0.5
	var world_env := WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)
	var sun := DirectionalLight3D.new()
	sun.light_energy = 1.5
	sun.position = Vector3(10, 20, 10)
	sun.rotation = Vector3(deg_to_rad(-45), deg_to_rad(30), 0)
	add_child(sun)
	# Pavimento griglia grande
	var floor := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(60, 30)
	floor.mesh = plane
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.3, 0.35, 0.25)
	mat.roughness = 0.9
	floor.material_override = mat
	floor.position = Vector3(0, 0, 0)
	add_child(floor)

func _setup_hud():
	var canvas := CanvasLayer.new()
	canvas.name = "HUD"
	add_child(canvas)
	# Pulsante torna indietro
	var back_btn := Button.new()
	back_btn.text = "Torna indietro"
	back_btn.position = Vector2(20, 20)
	back_btn.size = Vector2(140, 40)
	back_btn.pressed.connect(_on_back)
	canvas.add_child(back_btn)
	# Info selezione
	var info := Label.new()
	info.name = "InfoLabel"
	info.position = Vector2(20, 70)
	info.size = Vector2(400, 60)
	info.text = "Click su un oggetto per selezionarlo"
	canvas.add_child(info)
	# Istruzioni
	var help := Label.new()
	help.position = Vector2(20, 140)
	help.size = Vector2(400, 100)
	help.text = "Mouse: trascina per ruotare/inclinare\nRotellina: zoom\nClick sinistro: seleziona"
	canvas.add_child(help)
	# Pannello modifica
	var panel_scene := load("res://scenes/render_editor_panel.tscn")
	if panel_scene:
		_editor_panel = panel_scene.instantiate()
		_editor_panel.name = "EditorPanel"
		_editor_panel.setup(_building_icons)
		_editor_panel.apply_texture.connect(_on_apply_texture)
		_editor_panel.apply_color.connect(_on_apply_color)
		_editor_panel.apply_scale.connect(_on_apply_scale)
		_editor_panel.apply_rotation.connect(_on_apply_rotation)
		canvas.add_child(_editor_panel)
		_editor_panel.visible = false

# Edifici su due file distanziate, con etichette ben visibili
func _setup_buildings():
	var start_x := -12.0
	var step_x := 5.0
	var z_row_1 := -5.0
	var z_row_2 := -9.0
	for i in range(_building_icons.size()):
		var icon_path: String = _building_icons[i]
		var tex := load(icon_path)
		if tex == null:
			continue
		var col := i % 5
		var row := i / 5
		var x := start_x + col * step_x
		var z := z_row_1 if row == 0 else z_row_2
		# Sprite 3D con pixel size piu' piccolo per non sovrapporsi
		var sprite := Sprite3D.new()
		sprite.texture = tex
		sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		sprite.pixel_size = 0.008
		sprite.position = Vector3(x, 1.3, z)
		sprite.name = "Building_%s" % icon_path.get_file().get_basename()
		add_child(sprite)
		# Etichetta sotto
		var label := Label3D.new()
		label.text = icon_path.get_file().get_basename().replace("_", " ")
		label.position = Vector3(x, 0.2, z + 1.0)
		label.font_size = 30
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		add_child(label)

# Unita' su una fila larga
func _setup_units():
	var start_x := -10.0
	var step_x := 4.0
	var z := 3.0
	for i in range(_unit_types.size()):
		var unit_type: String = _unit_types[i]
		var unit: Node3D = preload("res://scripts/game/unit_factory.gd").create_unit(unit_type, _faction_color)
		unit.position = Vector3(start_x + i * step_x, 0, z)
		unit.rotation.y = -PI / 2.0
		unit.name = "Unit_%s" % unit_type
		add_child(unit)
		# Etichetta
		var label := Label3D.new()
		label.text = unit_type.capitalize()
		label.position = Vector3(start_x + i * step_x, 0.2, z + 1.8)
		label.font_size = 40
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		add_child(label)
		# Animazione di camminata
		var skeleton := unit.get_node_or_null("Skeleton3D")
		if skeleton:
			var anim := Node.new()
			anim.set_script(preload("res://scripts/game/soldier_animation.gd"))
			anim.setup(skeleton)
			anim.set_walking(true)
			add_child(anim)
		elif unit_type == "cavalleria":
			var horse := unit.get_node_or_null("Horse")
			if horse:
				var horse_anim := Node.new()
				horse_anim.set_script(preload("res://scripts/game/horse_animation.gd"))
				horse_anim.setup(horse.get_node_or_null("HorseSkeleton"))
				horse_anim.set_walking(true)
				add_child(horse_anim)

func _update_camera():
	_camera_pivot.rotation = Vector3(_pitch_angle, _orbit_angle, 0.0)
	_camera.position = Vector3(0, 0, _camera_distance)

func _input(event: InputEvent):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file("res://scenes/prova_egemonia_1000.tscn")
	# Trascinamento: ruota e inclina
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			# Click rilasciato senza trascinamento: seleziona
			if _last_mouse.distance_to(event.position) < 5.0:
				_select_at(event.position)
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_dragging = event.pressed
			_last_mouse = event.position
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_camera_distance = max(_camera_distance - 1.0, 6.0)
			_update_camera()
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_camera_distance = min(_camera_distance + 1.0, 40.0)
			_update_camera()
	if event is InputEventMouseMotion:
		if _dragging:
			var delta_pos: Vector2 = event.position - _last_mouse
			_orbit_angle += delta_pos.x * 0.005
			_pitch_angle = clamp(_pitch_angle + delta_pos.y * 0.005, -1.2, -0.1)
			_update_camera()
		_last_mouse = event.position

func _select_at(screen_pos: Vector2):
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	var from: Vector3 = camera.project_ray_origin(screen_pos)
	var to: Vector3 = from + camera.project_ray_normal(screen_pos) * 100.0
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_bodies = true
	var result: Dictionary = space_state.intersect_ray(query)
	if result.is_empty():
		_clear_selection()
		return
	var node: Node = result.get("collider", null)
	if node == null:
		return
	# Seleziona il nodo genitore di livello superiore (unit o building)
	var selected := _find_selectable_parent(node)
	if selected:
		_select_node(selected)

func _find_selectable_parent(node: Node) -> Node3D:
	var current: Node = node
	while current != null:
		if current is Node3D and (current.name.begins_with("Building_") or current.name.begins_with("Unit_")):
			return current as Node3D
		current = current.get_parent()
	return null

func _select_node(node: Node3D):
	_selected_node = node
	_show_selection_box(node)
	var info := get_node_or_null("HUD/InfoLabel") as Label
	if info:
		info.text = "Selezionato: %s" % node.name
	print("Selezionato: %s" % node.name)
	if _editor_panel:
		_editor_panel.open_for(node)

func _clear_selection():
	_selected_node = null
	if _selection_box != null:
		_selection_box.queue_free()
		_selection_box = null
	var info := get_node_or_null("HUD/InfoLabel") as Label
	if info:
		info.text = "Click su un oggetto per selezionarlo"
	if _editor_panel:
		_editor_panel._on_close()

func _on_apply_texture(path: String):
	if _selected_node == null or not _selected_node is Sprite3D:
		return
	var sprite: Sprite3D = _selected_node as Sprite3D
	var tex := load(path)
	if tex:
		sprite.texture = tex
		print("Texture applicata: %s" % path)

func _on_apply_color(color: Color):
	if _selected_node == null or not _selected_node.name.begins_with("Unit_"):
		return
	# Ricrea l'unita' con il nuovo colore, mantenendo posizione/rotazione/scala
	var unit_type := _selected_node.name.replace("Unit_", "")
	var old_pos := _selected_node.position
	var old_rot := _selected_node.rotation
	var old_scale := _selected_node.scale
	_selected_node.queue_free()
	if _selection_box:
		_selection_box.queue_free()
		_selection_box = null
	var new_unit: Node3D = preload("res://scripts/game/unit_factory.gd").create_unit(unit_type, color)
	new_unit.position = old_pos
	new_unit.rotation = old_rot
	new_unit.scale = old_scale
	new_unit.name = "Unit_%s" % unit_type
	add_child(new_unit)
	_selected_node = new_unit
	_show_selection_box(new_unit)
	print("Colore applicato a %s" % new_unit.name)

func _on_apply_scale(scale: Vector3):
	if _selected_node == null:
		return
	_selected_node.scale = scale
	_show_selection_box(_selected_node)

func _on_apply_rotation(rotation_y: float):
	if _selected_node == null:
		return
	_selected_node.rotation.y = rotation_y
	_show_selection_box(_selected_node)

func _show_selection_box(node: Node3D):
	if _selection_box != null:
		_selection_box.queue_free()
	# Crea una scatola wireframe attorno all'oggetto
	var aabb := _get_aabb(node)
	var size: Vector3 = aabb.size
	var box := BoxMesh.new()
	box.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.8, 0.0, 0.5)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.no_depth_test = true
	box.material = mat
	_selection_box = MeshInstance3D.new()
	_selection_box.mesh = box
	_selection_box.position = aabb.position + size / 2.0
	add_child(_selection_box)

func _get_aabb(node: Node3D) -> AABB:
	var aabb := AABB()
	if node is MeshInstance3D:
		aabb = (node as MeshInstance3D).get_aabb()
	# Per Sprite3D e scheletri, stima dimensioni
	elif node is Sprite3D:
		var s := node as Sprite3D
		aabb = AABB(Vector3(-0.5, 0, -0.5), Vector3(1.0, s.pixel_size * s.texture.get_height(), 1.0))
	else:
		aabb = AABB(Vector3(-0.5, 0, -0.5), Vector3(1.0, 1.8, 1.0))
	return aabb

func _on_back():
	get_tree().change_scene_to_file("res://scenes/prova_egemonia_1000.tscn")

