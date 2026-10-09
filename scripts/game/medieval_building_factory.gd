extends Node
# Factory per modelli 3D medievali modulari con icone applicate sulle facciate
# Dark Corporation / Stev

static func create_building(building_id: String, icon: Texture2D) -> Node3D:
	var root := Node3D.new()
	root.name = "Modello3D_" + building_id
	var imported_path := "res://risorse/modelli/edifici_glb/%s.glb" % building_id
	var imported = load(imported_path) if ResourceLoader.exists(imported_path) else null
	if imported is PackedScene:
		var imported_node: Node3D = imported.instantiate()
		imported_node.name = "ModelloGLB"
		imported_node.scale = Vector3.ONE * 0.55
		root.add_child(imported_node)
		# Applica sempre l'icona corretta del catalogo anche al modello GLB
		if icon:
			_add_facade_texture(root, icon)
		return root
	var color := _building_color(building_id)
	_add_body(root, Vector3(1.4, 1.4, 1.3), Vector3(0, 0.7, 0), color)
	_add_roof(root, building_id, color.darkened(0.25))
	if building_id in ["centro_cittadino", "monastero", "fortezza_frontiera"]:
		_add_tower(root, Vector3(-0.45, 1.25, 0), color.darkened(0.15))
	if building_id in ["caserma_i", "caserma_ii", "caserma_iii", "molo_i", "molo_ii"]:
		_add_banner(root, color)
	if icon:
		_add_facade_texture(root, icon)
	return root

static func _add_body(root: Node3D, size: Vector3, position: Vector3, color: Color) -> void:
	var part := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.86
	mesh.material = material
	part.mesh = mesh
	part.position = position
	root.add_child(part)

static func _add_roof(root: Node3D, building_id: String, color: Color) -> void:
	var roof := MeshInstance3D.new()
	var mesh := PrismMesh.new()
	mesh.size = Vector3(1.65, 0.65, 1.5)
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	mesh.material = material
	roof.mesh = mesh
	roof.position = Vector3(0, 1.7, 0)
	root.add_child(roof)

static func _add_tower(root: Node3D, position: Vector3, color: Color) -> void:
	var tower := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.28
	mesh.bottom_radius = 0.34
	mesh.height = 2.0
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.88
	mesh.material = material
	tower.mesh = mesh
	tower.position = position + Vector3.UP * 1.0
	root.add_child(tower)
	var cap := MeshInstance3D.new()
	var cap_mesh := CylinderMesh.new()
	cap_mesh.top_radius = 0.0
	cap_mesh.bottom_radius = 0.42
	cap_mesh.height = 0.5
	cap_mesh.material = material
	cap.mesh = cap_mesh
	cap.position = position + Vector3.UP * 2.25
	root.add_child(cap)

static func _add_banner(root: Node3D, color: Color) -> void:
	var pole := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.025
	mesh.bottom_radius = 0.025
	mesh.height = 1.2
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.18, 0.1, 0.04)
	mesh.material = material
	pole.mesh = mesh
	pole.position = Vector3(0.0, 2.1, 0.0)
	root.add_child(pole)
	var flag := MeshInstance3D.new()
	var flag_mesh := QuadMesh.new()
	flag_mesh.size = Vector2(0.38, 0.24)
	var flag_mat := StandardMaterial3D.new()
	flag_mat.albedo_color = color
	flag_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	flag_mesh.material = flag_mat
	flag.mesh = flag_mesh
	flag.position = Vector3(0.2, 2.48, 0.0)
	root.add_child(flag)

static func _add_facade_texture(root: Node3D, icon: Texture2D) -> void:
	var facade := Sprite3D.new()
	facade.name = "TextureFacciata"
	facade.texture = icon
	facade.pixel_size = 0.004
	facade.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	facade.position = Vector3(0, 0.85, -0.67)
	facade.rotation_degrees = Vector3(0, 180, 0)
	root.add_child(facade)

static func _building_color(building_id: String) -> Color:
	if building_id.begins_with("caserma"): return Color(0.48, 0.25, 0.14)
	if building_id in ["mercato", "mulino"]: return Color(0.52, 0.38, 0.20)
	if building_id in ["monastero", "fortezza_frontiera"]: return Color(0.48, 0.47, 0.43)
	if building_id in ["molo_i", "molo_ii"]: return Color(0.34, 0.27, 0.19)
	if building_id == "miniera": return Color(0.30, 0.28, 0.25)
	return Color(0.46, 0.32, 0.19)
