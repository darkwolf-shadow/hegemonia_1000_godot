extends Node3D
# Caricatore di texture PBR per la scena di battaglia 3D
# Applica texture reali (albedo, normal, roughness) a terreno, alberi e rocce
# Dark Corporation / Stev

static func create_terrain_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	# Albedo (colore base)
	var tex := load("res://risorse/textures/terreno/terreno_colore.png")
	if tex:
		mat.albedo_texture = tex
	# Normal map (rilievo superficiale senza poligoni extra)
	var normal := load("res://risorse/textures/terreno/terreno_normale.png")
	if normal:
		mat.normal_texture = normal
		mat.normal_enabled = true
	# Roughness map (dove e' lucido vs opaco)
	var rough := load("res://risorse/textures/terreno/terreno_rugosita.png")
	if rough:
		mat.roughness_texture = rough
		mat.roughness_texture_channel = StandardMaterial3D.TEXTURE_CHANNEL_GREEN
	mat.uv1_scale = Vector3(20, 20, 1)
	mat.roughness = 0.8  # erba: opaco
	mat.metallic = 0.0
	return mat

static func create_grass_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	var tex := load("res://risorse/textures/terreno/erba.jpg")
	if tex:
		mat.albedo_texture = tex
	mat.uv1_scale = Vector3(5, 5, 1)
	mat.roughness = 0.8
	return mat

static func create_rock_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	var tex := load("res://risorse/textures/rocce/roccia_colore.png")
	if tex:
		mat.albedo_texture = tex
	var normal := load("res://risorse/textures/rocce/roccia_normale.png")
	if normal:
		mat.normal_texture = normal
		mat.normal_enabled = true
	var rough := load("res://risorse/textures/rocce/roccia_ao.png")
	if rough:
		mat.roughness_texture = rough
		mat.roughness_texture_channel = StandardMaterial3D.TEXTURE_CHANNEL_RED
	mat.uv1_scale = Vector3(2, 2, 1)
	mat.roughness = 0.7  # roccia: semi-lucido
	mat.metallic = 0.0
	return mat

static func create_stone_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	var tex := load("res://risorse/textures/rocce/pietra_colore.png")
	if tex:
		mat.albedo_texture = tex
	var normal := load("res://risorse/textures/rocce/pietra_normale.png")
	if normal:
		mat.normal_texture = normal
		mat.normal_enabled = true
	var rough := load("res://risorse/textures/rocce/pietra_ao.png")
	if rough:
		mat.roughness_texture = rough
		mat.roughness_texture_channel = StandardMaterial3D.TEXTURE_CHANNEL_RED
	mat.uv1_scale = Vector3(2, 2, 1)
	mat.roughness = 0.7  # pietra castello: semi-lucido
	mat.metallic = 0.0
	return mat

static func create_tree_trunk_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.35, 0.22, 0.1)
	mat.roughness = 0.9  # legno: opaco
	return mat

static func create_tree_leaves_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.4, 0.15)
	mat.roughness = 0.85
	return mat

static func create_wood_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.4, 0.25, 0.12)
	mat.roughness = 0.85
	return mat
