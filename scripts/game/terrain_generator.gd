extends MeshInstance3D
# Generatore di terreno 3D con colline e avvallamenti
# Usa FastNoiseLite per deformare i vertici di un PlaneMesh
# Il tipo di terreno determina altezza colline, colori, densita' vegetazione
# Dark Corporation / Stev

@export var map_size: Vector2 = Vector2(300, 300)
@export var subdivisions: Vector2i = Vector2i(150, 150)
@export var hill_height: float = 12.0
@export var noise_seed: int = 1000
@export var terrain_type: String = "plains"
@export var noise_freq: float = 0.012

var _noise: FastNoiseLite
var _config: Dictionary = {}

func _ready():
	_config = preload("res://scripts/game/battle_scenario.gd").get_config(terrain_type)
	hill_height = _config.get("hill_height", hill_height)
	noise_freq = _config.get("noise_freq", noise_freq)
	generate_terrain()

func generate_terrain():
	var plane_mesh := PlaneMesh.new()
	plane_mesh.size = map_size
	plane_mesh.subdivide_width = subdivisions.x
	plane_mesh.subdivide_depth = subdivisions.y
	
	var surface_tool := SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)
	var array_data := surface_tool.commit_to_arrays()
	var vertices: PackedVector3Array = array_data[Mesh.ARRAY_VERTEX]
	
	_noise = FastNoiseLite.new()
	_noise.seed = noise_seed
	_noise.frequency = noise_freq
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	_noise.fractal_octaves = 4
	_noise.fractal_lacunarity = 2.0
	_noise.fractal_gain = 0.5
	
	for i in range(vertices.size()):
		var v: Vector3 = vertices[i]
		var dist_from_center: float = sqrt(v.x * v.x + v.z * v.z)
		var base_noise: float = _noise.get_noise_2d(v.x, v.z)
		var center_factor: float = clamp((dist_from_center - 40.0) / 60.0, 0.0, 1.0)
		v.y = base_noise * hill_height * center_factor
		vertices[i] = v
	
	array_data[Mesh.ARRAY_VERTEX] = vertices
	
	var new_mesh := ArrayMesh.new()
	new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, array_data)
	
	surface_tool.clear()
	surface_tool.create_from(new_mesh, 0)
	surface_tool.generate_normals()
	
	self.mesh = surface_tool.commit()
	
	var mat := _create_terrain_material()
	material_override = mat

func _create_terrain_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	var grass_color: Color = _config.get("grass_color", Color(0.35, 0.55, 0.25))
	var tex := load("res://risorse/textures/terreno/terreno_colore.png")
	if tex and terrain_type in ["plains", "hills", "forest"]:
		mat.albedo_texture = tex
		var normal := load("res://risorse/textures/terreno/terreno_normale.png")
		if normal:
			mat.normal_texture = normal
			mat.normal_enabled = true
		mat.uv1_scale = Vector3(20, 20, 1)
	elif terrain_type == "desert":
		mat.albedo_color = grass_color
		mat.uv1_scale = Vector3(15, 15, 1)
	elif terrain_type == "snow":
		mat.albedo_color = grass_color
		mat.uv1_scale = Vector3(15, 15, 1)
	else:
		mat.albedo_color = grass_color
		mat.uv1_scale = Vector3(20, 20, 1)
	mat.roughness = 0.95
	mat.metallic = 0.0
	return mat

func get_height_at(x: float, z: float) -> float:
	if _noise == null:
		return 0.0
	var dist_from_center: float = sqrt(x * x + z * z)
	var base_noise: float = _noise.get_noise_2d(x, z)
	var center_factor: float = clamp((dist_from_center - 40.0) / 60.0, 0.0, 1.0)
	return base_noise * hill_height * center_factor

func get_config() -> Dictionary:
	return _config
