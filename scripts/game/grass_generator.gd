extends Node3D
# Generatore di erba 3D con MultiMeshInstance3D
# Distribuisce ciuffi d'erba casualmente sul terreno
# Dark Corporation / Stev

@export var grass_count: int = 2000
@export var area_size: float = 180.0
@export var blade_height: float = 0.4

var _multimesh_node: MultiMeshInstance3D

func _ready():
	_multimesh_node = MultiMeshInstance3D.new()
	add_child(_multimesh_node)
	_generate_grass()

func _generate_grass():
	# Mesh del filo d'erba: piccolo piano verticale
	var blade := PlaneMesh.new()
	blade.size = Vector2(0.05, blade_height)
	blade.material = _grass_material()
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.mesh = blade
	mm.instance_count = grass_count
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("grass_seed_1000")
	for i in range(grass_count):
		var x := rng.randf_range(-area_size / 2.0, area_size / 2.0)
		var z := rng.randf_range(-area_size / 2.0, area_size / 2.0)
		# Evita il centro (campo di battaglia)
		if abs(x) < 20 and abs(z) < 20:
			continue
		var y := 0.0
		var rot_y := rng.randf_range(0, TAU)
		var xform := Transform3D(
			Basis(Vector3.UP, rot_y),
			Vector3(x, y + blade_height / 2.0, z)
		)
		mm.set_instance_transform(i, xform)
		# Variazione colore verde
		var g := rng.randf_range(0.3, 0.6)
		mm.set_instance_color(i, Color(0.2, g, 0.1, 1.0))
	_multimesh_node.multimesh = mm
	_multimesh_node.cast_shadow = 0  # SHADOW_OFF

func _grass_material() -> Material:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.3, 0.5, 0.2)
	mat.roughness = 0.9
	mat.vertex_color_use_as_albedo = true
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return mat
