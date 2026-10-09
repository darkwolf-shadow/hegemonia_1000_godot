extends MeshInstance3D
# Generatore del terreno con unica PlaneMesh piatta
# L'altezza viene applicata ESCLUSIVAMENTE nello shader vertex()
# Dark Corporation / Stev

@export var map_width: float = 200.0
@export var map_height: float = 100.0
@export var subdivisions_x: int = 500
@export var subdivisions_y: int = 250
@export var heightmap_path: String = "res://risorse/terreno/heightmap_terra.png"
@export var province_id_path: String = "res://risorse/terreno/province_id_map.png"
@export var shader_path: String = "res://risorse/shader/terrain_political.gdshader"

func _ready() -> void:
	_genera_terreno_piatto()

func _genera_terreno_piatto() -> void:
	# 1. PlaneMesh unica e piatta, orizzontale su Y=0
	var plane_mesh := PlaneMesh.new()
	plane_mesh.size = Vector2(map_width, map_height)
	plane_mesh.subdivide_width = subdivisions_x
	plane_mesh.subdivide_depth = subdivisions_y
	self.mesh = plane_mesh
	
	# 2. Carica texture e applica shader
	var height_img := Image.load_from_file(ProjectSettings.globalize_path(heightmap_path))
	var prov_img := Image.load_from_file(ProjectSettings.globalize_path(province_id_path))
	var shader := load(shader_path)
	
	if shader and height_img and prov_img:
		var mat := ShaderMaterial.new()
		mat.shader = shader
		mat.set_shader_parameter("heightmap_tex", ImageTexture.create_from_image(height_img))
		mat.set_shader_parameter("province_id_tex", ImageTexture.create_from_image(prov_img))
		mat.set_shader_parameter("sea_level", 0.5)
		self.material_override = mat
	
	# 3. Collisione semplice per raycast del mouse
	create_trimesh_collision()
