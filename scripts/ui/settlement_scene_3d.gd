extends Node3D
# Agglomerato 3D interattivo: griglia, edifici, cantieri ed espansione
# Dark Corporation / Stev

@onready var _pivot: Node3D = $CameraPivot
@onready var _camera: Camera3D = $CameraPivot/Camera3D
@onready var _root: Node3D = $SettlementRoot

const BUILDING_TYPES := ["mercato", "mulino", "caserma_i", "campo_tiro_i", "scuderia_i", "fucina", "monastero", "miniera", "molo_i"]
var _province_name := ""
var _settlement_name := ""
var _province: Dictionary = {}
var _settlement: Dictionary = {}
var _grid_level := 1
var _grid_size := 5
var _cell_size := 2.5
var _selected_slot := -1
var _selected_building := "mercato"
var _slot_nodes: Dictionary = {}
var _slot_buttons: Dictionary = {}
var _status: Label
var _fence_root: Node3D
var _is_panning := false
var _is_rotating := false
var _last_mouse := Vector2.ZERO
var _target_fov: float = 50.0

func _ready() -> void:
	_load_data()
	_setup_environment()
	_setup_ui()
	_rebuild_scene()

func _load_data() -> void:
	_province_name = str(GameState.state.get("last_province", ""))
	_settlement_name = str(GameState.state.get("last_settlement", ""))
	_province = GameState.state.get("provinces", {}).get(_province_name, {})
	if _province.is_empty():
		_province = WorldData.get_province(_province_name)
	var settlements: Dictionary = _province.get("settlements", {})
	_settlement = settlements.get(_settlement_name, {})
	if _settlement.is_empty() and not settlements.is_empty():
		_settlement_name = str(settlements.keys()[0])
		_settlement = settlements[_settlement_name]
	if _settlement.is_empty():
		_settlement = {"name": "Agglomerato", "buildings": ["centro_cittadino"], "building_levels": {"centro_cittadino": 1}}
	_grid_level = clampi(int(_settlement.get("expansion_level", 1)), 1, 5)
	_grid_size = 3 + _grid_level * 2
	_settlement["grid_size"] = _grid_size
	_settlement["max_building_slots"] = _grid_size * _grid_size
	if not _settlement.has("building_slots"):
		_settlement["building_slots"] = {}
	if not _settlement.has("construction_queue"):
		_settlement["construction_queue"] = []

func _setup_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.25, 0.55, 0.85)
	sky_mat.sky_horizon_color = Color(0.75, 0.8, 0.9)
	sky_mat.ground_bottom_color = Color(0.2, 0.25, 0.15)
	sky_mat.ground_horizon_color = Color(0.5, 0.55, 0.4)
	sky.sky_material = sky_mat
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_color = Color(0.6, 0.7, 0.8)
	env.ambient_light_energy = 0.6
	env.ssao_enabled = true
	env.ssao_radius = 1.5
	env.ssao_intensity = 1.5
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	var world := WorldEnvironment.new()
	world.environment = env
	add_child(world)
	var sun := $Sun
	sun.light_energy = 2.5
	sun.shadow_enabled = true
	_camera.current = true

func _setup_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "HUD"
	add_child(canvas)
	var panel := Panel.new()
	panel.position = Vector2(16, 16)
	panel.size = Vector2(310, 520)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.07, 0.04, 0.92)
	style.border_color = Color(0.55, 0.38, 0.16)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", style)
	canvas.add_child(panel)
	var title := Label.new()
	title.position = Vector2(32, 28)
	title.text = "Agglomerato 3D"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.95, 0.82, 0.55))
	canvas.add_child(title)
	_status = Label.new()
	_status.position = Vector2(32, 65)
	_status.size = Vector2(270, 90)
	_status.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
	canvas.add_child(_status)
	var back := Button.new()
	back.text = "Torna alla provincia"
	back.position = Vector2(32, 165)
	back.size = Vector2(250, 36)
	back.pressed.connect(_on_back)
	canvas.add_child(back)
	var select := OptionButton.new()
	select.name = "BuildingChoice"
	select.position = Vector2(32, 215)
	select.size = Vector2(250, 36)
	var region := IconManager.region_for_faction(str(_province.get("owner", "")))
	for building in BUILDING_TYPES:
		var icon := IconManager.get_building_icon_masked(building, region)
		select.add_icon_item(icon, building)
	select.item_selected.connect(func(index: int): _selected_building = BUILDING_TYPES[index])
	canvas.add_child(select)
	var build := Button.new()
	build.text = "Costruisci edificio nello slot"
	build.position = Vector2(32, 260)
	build.size = Vector2(250, 36)
	build.pressed.connect(_build_selected)
	canvas.add_child(build)
	var upgrade := Button.new()
	upgrade.text = "Migliora edificio selezionato"
	upgrade.position = Vector2(32, 305)
	upgrade.size = Vector2(250, 36)
	upgrade.pressed.connect(_upgrade_selected)
	canvas.add_child(upgrade)
	var expand := Button.new()
	expand.text = "Espandi mura e griglia"
	expand.position = Vector2(32, 350)
	expand.size = Vector2(250, 36)
	expand.pressed.connect(_expand_settlement)
	canvas.add_child(expand)
	var help := Label.new()
	help.text = "Click: seleziona slot\nSinistro trascinato: sposta visuale\nRotellina: zoom\nESC: menu"
	help.position = Vector2(32, 405)
	help.add_theme_color_override("font_color", Color(0.72, 0.68, 0.58))
	canvas.add_child(help)

func _rebuild_scene() -> void:
	for child in _root.get_children():
		child.queue_free()
	_slot_nodes.clear()
	_slot_buttons.clear()
	_create_ground()
	_create_fence()
	var total := _grid_size * _grid_size
	for index in range(total):
		var x := float(index % _grid_size) - float(_grid_size - 1) / 2.0
		var z := float(index / _grid_size) - float(_grid_size - 1) / 2.0
		_create_slot(index, Vector3(x * _cell_size, 0.12, z * _cell_size))
	_update_status()

func _create_ground() -> void:
	var ground := MeshInstance3D.new()
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(_grid_size * _cell_size + 4.0, _grid_size * _cell_size + 4.0)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.28, 0.22, 0.14)
	material.roughness = 0.95
	mesh.material = material
	ground.mesh = mesh
	_root.add_child(ground)

func _create_slot(index: int, position: Vector3) -> void:
	var slot := MeshInstance3D.new()
	slot.name = "Slot_%d" % index
	var mesh := BoxMesh.new()
	mesh.size = Vector3(_cell_size - 0.12, 0.08, _cell_size - 0.12)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.38, 0.30, 0.18, 0.35)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material = material
	slot.mesh = mesh
	slot.position = position
	# Slot logico: il quadrato non viene mostrato sul terreno
	slot.visible = false
	_root.add_child(slot)
	_slot_nodes[index] = slot
	var building_slots: Dictionary = _settlement.get("building_slots", {})
	var building: String = str(building_slots.get(str(index), ""))
	if building.is_empty() and index == 12 and "centro_cittadino" in _settlement.get("buildings", []):
		building = "centro_cittadino"
	if not building.is_empty():
		_create_building(index, building, position)

func _create_building(index: int, building: String, position: Vector3) -> void:
	var owner := str(_province.get("owner", ""))
	var region := IconManager.region_for_faction(owner)
	var icon := IconManager.get_building_icon_masked(building, region)
	var model: Node3D = preload("res://scripts/game/medieval_building_factory.gd").create_building(building, icon)
	model.name = "Edificio_%d_%s" % [index, building]
	model.position = position
	_root.add_child(model)
	var label := Label3D.new()
	label.text = building
	label.position = position + Vector3.UP * 2.2
	label.font_size = 28
	label.outline_size = 5
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_root.add_child(label)

func _create_fence() -> void:
	_fence_root = Node3D.new()
	_fence_root.name = "ConfineAgglomerato"
	_root.add_child(_fence_root)
	var half := (_grid_size * _cell_size + 1.5) / 2.0
	for side in range(4):
		var fence := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.18, 1.5, _grid_size * _cell_size + 1.5) if side < 2 else Vector3(_grid_size * _cell_size + 1.5, 1.5, 0.18)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.28, 0.16, 0.08) if int(_settlement.get("walls_level", 0)) == 0 else Color(0.42, 0.42, 0.45)
		mat.roughness = 0.95
		mesh.material = mat
		fence.mesh = mesh
		if side == 0: fence.position = Vector3(-half, 0.75, 0)
		elif side == 1: fence.position = Vector3(half, 0.75, 0)
		elif side == 2: fence.position = Vector3(0, 0.75, -half)
		else: fence.position = Vector3(0, 0.75, half)
		_fence_root.add_child(fence)

func _build_selected() -> void:
	if _selected_slot < 0:
		_status.text = "\nSeleziona prima uno slot libero."
		return
	var slots: Dictionary = _settlement.get("building_slots", {})
	if slots.has(str(_selected_slot)):
		_status.text = "\nLo slot e' gia' occupato."
		return
	if not _pay({"oro": 50, "legname": 10, "pietra": 10}):
		_status.text = "\nRisorse insufficienti."
		return
	slots[str(_selected_slot)] = _selected_building
	_settlement["building_slots"] = slots
	_settlement.get("buildings", []).append(_selected_building)
	_settlement["construction_queue"].append({"building": _selected_building, "slot": _selected_slot, "turns": 2, "is_under_construction": true})
	_persist()
	_rebuild_scene()

func _upgrade_selected() -> void:
	if _selected_slot < 0:
		_status.text = "\nSeleziona un edificio."
		return
	var slots: Dictionary = _settlement.get("building_slots", {})
	var building: String = str(slots.get(str(_selected_slot), ""))
	if building.is_empty():
		_status.text = "\nLo slot e' vuoto."
		return
	var levels: Dictionary = _settlement.get("building_levels", {})
	var level: int = int(levels.get(building, 1))
	if level >= 4:
		_status.text = "\nLivello massimo raggiunto."
		return
	levels[building] = level + 1
	_settlement["building_levels"] = levels
	_settlement["construction_queue"].append({"building": building, "slot": _selected_slot, "from_level": level, "to_level": level + 1, "turns": 2, "is_under_construction": true})
	_persist()
	_status.text = "\nMiglioramento avviato: edificio precedente resta attivo."

func _expand_settlement() -> void:
	if _grid_level >= 5:
		_status.text = "\nEspansione massima raggiunta."
		return
	if not _pay({"oro": 200 * _grid_level, "legname": 40 * _grid_level, "pietra": 60 * _grid_level}):
		_status.text = "\nRisorse insufficienti per espandere le mura."
		return
	_grid_level += 1
	_grid_size = 3 + _grid_level * 2
	_settlement["expansion_level"] = _grid_level
	_settlement["grid_size"] = _grid_size
	_settlement["max_building_slots"] = _grid_size * _grid_size
	_settlement["construction_queue"].append({"type": "expansion", "turns": 3, "is_under_construction": true})
	_persist()
	_rebuild_scene()

func _pay(cost: Dictionary) -> bool:
	if bool(GameState.state.get("render_test_mode", false)):
		return true
	var owner := str(_province.get("owner", ""))
	var factions: Dictionary = GameState.state.get("factions", {})
	var faction: Dictionary = factions.get(owner, {})
	var resources: Dictionary = faction.get("resources", {})
	for key in cost:
		if int(resources.get(key, 0)) < int(cost[key]): return false
	for key in cost: resources[key] = int(resources.get(key, 0)) - int(cost[key])
	faction["resources"] = resources
	factions[owner] = faction
	GameState.state["factions"] = factions
	return true

func _persist() -> void:
	_province["settlements"][_settlement_name] = _settlement
	GameState.state.provinces[_province_name] = _province

func _update_status() -> void:
	if _status:
		_status.text = "Provincia: %s\nAgglomerato: %s\nEspansione: %d/5\nGriglia: %dx%d\nSlot: %d" % [_province_name, _settlement_name, _grid_level, _grid_size, _grid_size, _grid_size * _grid_size]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_on_back()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_is_panning = event.pressed
			_last_mouse = event.position
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_is_rotating = event.pressed
			_last_mouse = event.position
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_target_fov = maxf(_target_fov - 4.0, 25.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_target_fov = minf(_target_fov + 4.0, 75.0)
	if event is InputEventMouseMotion:
		var delta: Vector2 = event.position - _last_mouse
		_last_mouse = event.position
		if _is_panning:
			global_position += Vector3(-delta.x, 0.0, -delta.y) * 0.01
		if _is_rotating:
			_pivot.rotation.y -= delta.x * 0.005
			_pivot.rotation.x = clampf(_pivot.rotation.x - delta.y * 0.005, -1.2, -0.1)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		var camera := get_viewport().get_camera_3d()
		var from := camera.project_ray_origin(event.position)
		var direction := camera.project_ray_normal(event.position)
		var t := -from.y / direction.y if abs(direction.y) > 0.001 else 0.0
		var point := from + direction * maxf(t, 0.0)
		var col := int(round(point.x / _cell_size + float(_grid_size - 1) / 2.0))
		var row := int(round(point.z / _cell_size + float(_grid_size - 1) / 2.0))
		if col >= 0 and col < _grid_size and row >= 0 and row < _grid_size:
			_selected_slot = row * _grid_size + col
			_status.text = "\nSlot selezionato: %d" % _selected_slot

func _process(delta: float) -> void:
	_camera.fov = lerpf(_camera.fov, _target_fov, delta * 10.0)

func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/prova_egemonia_1000.tscn")
