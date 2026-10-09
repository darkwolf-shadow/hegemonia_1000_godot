extends Mesh
# Generatore di mesh soldato low-poly procedurale
# Crea un soldato semplice combinando primitive: corpo, testa, scudo, lancia
# Dark Corporation / Stev

static func create_soldier_mesh() -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	
	var verts: PackedVector3Array = []
	var normals: PackedVector3Array = []
	var uvs: PackedVector2Array = []
	var indices: PackedInt32Array = []
	
	# Corpo (cilindro schiacciato, tronco)
	_add_cylinder(verts, normals, uvs, indices, Vector3(0, 0.6, 0), 0.25, 0.6, 8)
	# Testa (sfera)
	_add_sphere(verts, normals, uvs, indices, Vector3(0, 1.2, 0), 0.18, 6, 4)
	# Gambe (due cilindri piccoli)
	_add_cylinder(verts, normals, uvs, indices, Vector3(-0.1, 0.2, 0), 0.08, 0.4, 6)
	_add_cylinder(verts, normals, uvs, indices, Vector3(0.1, 0.2, 0), 0.08, 0.4, 6)
	# Scudo (box sottile sul lato sinistro)
	_add_box(verts, normals, uvs, indices, Vector3(-0.35, 0.7, 0), Vector3(0.05, 0.4, 0.3))
	# Lancia (cilindro sottile verticale sul lato destro)
	_add_cylinder(verts, normals, uvs, indices, Vector3(0.3, 0.9, 0), 0.03, 1.5, 4)
	
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	# Crea un materiale PBR-like che usera' il colore del MultiMesh
	# metallico per armatura/lancia, cuoio per corpo
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color.WHITE
	mat.roughness = 0.6
	mat.metallic = 0.3
	mat.metallic_specular = 0.5
	mat.vertex_color_use_as_albedo = true
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	mesh.surface_set_material(0, mat)
	
	return mesh


static func _add_cylinder(verts: PackedVector3Array, normals: PackedVector3Array, 
		uvs: PackedVector2Array, indices: PackedInt32Array, 
		center: Vector3, radius: float, height: float, segments: int):
	var base_index := verts.size()
	var half_h := height / 2.0
	# Vertici laterali
	for i in range(segments):
		var angle := TAU * i / segments
		var x := cos(angle) * radius
		var z := sin(angle) * radius
		# Bottom
		verts.append(center + Vector3(x, -half_h, z))
		normals.append(Vector3(cos(angle), 0, sin(angle)))
		uvs.append(Vector2(float(i) / segments, 0))
		# Top
		verts.append(center + Vector3(x, half_h, z))
		normals.append(Vector3(cos(angle), 0, sin(angle)))
		uvs.append(Vector2(float(i) / segments, 1))
	# Indici laterali
	for i in range(segments):
		var a := base_index + i * 2
		var b := base_index + ((i + 1) % segments) * 2
		indices.append(a)
		indices.append(b)
		indices.append(a + 1)
		indices.append(b)
		indices.append(b + 1)
		indices.append(a + 1)


static func _add_sphere(verts: PackedVector3Array, normals: PackedVector3Array,
		uvs: PackedVector2Array, indices: PackedInt32Array,
		center: Vector3, radius: float, h_segments: int, v_segments: int):
	var base_index := verts.size()
	for i in range(v_segments + 1):
		var v := float(i) / v_segments
		var phi := v * PI
		for j in range(h_segments):
			var u := float(j) / h_segments
			var theta := u * TAU
			var x := sin(phi) * cos(theta) * radius
			var y := cos(phi) * radius
			var z := sin(phi) * sin(theta) * radius
			verts.append(center + Vector3(x, y, z))
			normals.append(Vector3(x, y, z).normalized())
			uvs.append(Vector2(u, v))
	for i in range(v_segments):
		for j in range(h_segments):
			var a := base_index + i * h_segments + j
			var b := base_index + i * h_segments + (j + 1) % h_segments
			var c := base_index + (i + 1) * h_segments + j
			var d := base_index + (i + 1) * h_segments + (j + 1) % h_segments
			indices.append(a)
			indices.append(c)
			indices.append(b)
			indices.append(b)
			indices.append(c)
			indices.append(d)


static func _add_box(verts: PackedVector3Array, normals: PackedVector3Array,
		uvs: PackedVector2Array, indices: PackedInt32Array,
		center: Vector3, size: Vector3):
	var base_index := verts.size()
	var hx := size.x / 2.0
	var hy := size.y / 2.0
	var hz := size.z / 2.0
	# 8 vertici del box
	var p := [
		center + Vector3(-hx, -hy, -hz),  # 0
		center + Vector3(hx, -hy, -hz),   # 1
		center + Vector3(hx, hy, -hz),    # 2
		center + Vector3(-hx, hy, -hz),   # 3
		center + Vector3(-hx, -hy, hz),   # 4
		center + Vector3(hx, -hy, hz),    # 5
		center + Vector3(hx, hy, hz),     # 6
		center + Vector3(-hx, hy, hz),    # 7
	]
	# 6 facce (2 triangoli ciascuna)
	var faces := [
		[0, 1, 2, 3, Vector3(0, 0, -1)],  # back
		[5, 4, 7, 6, Vector3(0, 0, 1)],   # front
		[4, 0, 3, 7, Vector3(-1, 0, 0)],  # left
		[1, 5, 6, 2, Vector3(1, 0, 0)],   # right
		[3, 2, 6, 7, Vector3(0, 1, 0)],   # top
		[4, 5, 1, 0, Vector3(0, -1, 0)],  # bottom
	]
	for f in faces:
		var vi := verts.size()
		for i in range(4):
			verts.append(p[f[i]])
			normals.append(f[4])
			uvs.append(Vector2(i % 2, i / 2))
		indices.append(vi)
		indices.append(vi + 1)
		indices.append(vi + 2)
		indices.append(vi)
		indices.append(vi + 2)
		indices.append(vi + 3)
