extends Mesh
# Generatore di mesh albero low-poly procedurale
# Tronco cilindro + chioma conica/sferica
# Dark Corporation / Stev

static func create_tree_mesh() -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	var verts: PackedVector3Array = []
	var normals: PackedVector3Array = []
	var uvs: PackedVector2Array = []
	var indices: PackedInt32Array = []
	# Tronco (cilindro marrone)
	_add_cylinder(verts, normals, uvs, indices, Vector3(0, 1.0, 0), 0.15, 2.0, 6)
	# Chioma (cono verde, 3 livelli)
	_add_cone(verts, normals, uvs, indices, Vector3(0, 2.5, 0), 0.8, 1.5, 8)
	_add_cone(verts, normals, uvs, indices, Vector3(0, 3.2, 0), 0.6, 1.2, 8)
	_add_cone(verts, normals, uvs, indices, Vector3(0, 3.8, 0), 0.4, 0.9, 8)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	# Materiale albero: tronco marrone + chioma verde
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.4, 0.15)
	mat.roughness = 0.9
	mesh.surface_set_material(0, mat)
	return mesh


static func _add_cylinder(verts: PackedVector3Array, normals: PackedVector3Array,
		uvs: PackedVector2Array, indices: PackedInt32Array,
		center: Vector3, radius: float, height: float, segments: int):
	var base_index := verts.size()
	var half_h := height / 2.0
	for i in range(segments):
		var angle := TAU * i / segments
		var x := cos(angle) * radius
		var z := sin(angle) * radius
		verts.append(center + Vector3(x, -half_h, z))
		normals.append(Vector3(cos(angle), 0, sin(angle)))
		uvs.append(Vector2(float(i) / segments, 0))
		verts.append(center + Vector3(x, half_h, z))
		normals.append(Vector3(cos(angle), 0, sin(angle)))
		uvs.append(Vector2(float(i) / segments, 1))
	for i in range(segments):
		var a := base_index + i * 2
		var b := base_index + ((i + 1) % segments) * 2
		indices.append(a)
		indices.append(b)
		indices.append(a + 1)
		indices.append(b)
		indices.append(b + 1)
		indices.append(a + 1)


static func _add_cone(verts: PackedVector3Array, normals: PackedVector3Array,
		uvs: PackedVector2Array, indices: PackedInt32Array,
		center: Vector3, radius: float, height: float, segments: int):
	var base_index := verts.size()
	var half_h := height / 2.0
	# Vertici base
	for i in range(segments):
		var angle := TAU * i / segments
		var x := cos(angle) * radius
		var z := sin(angle) * radius
		verts.append(center + Vector3(x, -half_h, z))
		normals.append(Vector3(cos(angle), 0, sin(angle)))
		uvs.append(Vector2(float(i) / segments, 0))
	# Apice
	var apex_idx := verts.size()
	verts.append(center + Vector3(0, half_h, 0))
	normals.append(Vector3(0, 1, 0))
	uvs.append(Vector2(0.5, 1))
	# Indici
	for i in range(segments):
		indices.append(base_index + i)
		indices.append(base_index + ((i + 1) % segments))
		indices.append(apex_idx)
