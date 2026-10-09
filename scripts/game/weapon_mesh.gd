extends Node3D
# Generatore di mesh per armi e equipaggiamenti
# Forme stilizzate low-poly che occupano il volume corretto
# Dark Corporation / Stev

# Spada: lama + elsa + pomolo
static func create_sword() -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	var verts: PackedVector3Array = []
	var normals: PackedVector3Array = []
	var indices: PackedInt32Array = []
	# Lama: cilindro sottile verticale (lungo 0.8m)
	_add_cyl(verts, normals, indices, Vector3(0, 0.4, 0), 0.03, 0.8, 4)
	# Elsa: scatola orizzontale
	_add_box(verts, normals, indices, Vector3(0, 0.0, 0), Vector3(0.2, 0.04, 0.04))
	# Pomolo: sfera
	_add_sph(verts, normals, indices, Vector3(0, -0.08, 0), 0.05, 4, 3)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.7, 0.7, 0.75)
	mat.roughness = 0.3
	mat.metallic = 0.8
	mesh.surface_set_material(0, mat)
	return mesh

# Scudo: scatola sottile curva (rettangolare)
static func create_shield() -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	var verts: PackedVector3Array = []
	var normals: PackedVector3Array = []
	var indices: PackedInt32Array = []
	# Scudo: 0.5x0.7x0.05 (largo, alto, sottile)
	_add_box(verts, normals, indices, Vector3(0, 0, 0), Vector3(0.5, 0.7, 0.05))
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.5, 0.3, 0.15)
	mat.roughness = 0.8
	mesh.surface_set_material(0, mat)
	return mesh

# Arco: cilindro curvo (semicerchio)
static func create_bow() -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	var verts: PackedVector3Array = []
	var normals: PackedVector3Array = []
	var indices: PackedInt32Array = []
	# Arco: arco verticale, altezza 1.2m
	var seg := 12
	var radius := 0.6
	for i in range(seg + 1):
		var angle := PI * float(i) / seg  # da 0 a PI (semicerchio)
		var x := cos(angle) * radius
		var y := sin(angle) * radius
		verts.append(Vector3(x, y - radius, 0))
		normals.append(Vector3(cos(angle), sin(angle), 0))
		verts.append(Vector3(x, y - radius, 0.02))
		normals.append(Vector3(cos(angle), sin(angle), 0))
	for i in range(seg):
		var a := i * 2
		var b := (i + 1) * 2
		indices.append(a); indices.append(b); indices.append(a + 1)
		indices.append(b); indices.append(b + 1); indices.append(a + 1)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.4, 0.25, 0.1)
	mat.roughness = 0.8
	mesh.surface_set_material(0, mat)
	return mesh

# Faretra: cilindro verticale sulla schiena/coscia
static func create_quiver() -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	var verts: PackedVector3Array = []
	var normals: PackedVector3Array = []
	var indices: PackedInt32Array = []
	_add_cyl(verts, normals, indices, Vector3(0, 0, 0), 0.06, 0.4, 6)
	# Frecce dentro la faretra (3 frecce che sporgono)
	for i in range(3):
		var offset_x := (i - 1) * 0.03
		_add_cyl(verts, normals, indices, Vector3(offset_x, 0.35, 0), 0.008, 0.3, 3)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.3, 0.2, 0.1)
	mat.roughness = 0.85
	mesh.surface_set_material(0, mat)
	return mesh

# Lancia: cilindro lungo verticale (2.5m)
static func create_spear() -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	var verts: PackedVector3Array = []
	var normals: PackedVector3Array = []
	var indices: PackedInt32Array = []
	# Asta: cilindro lungo
	_add_cyl(verts, normals, indices, Vector3(0, 0, 0), 0.025, 2.5, 4)
	# Punta: cono
	_add_cone(verts, normals, indices, Vector3(0, 1.35, 0), 0.06, 0.2, 6)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.5, 0.35, 0.15)
	mat.roughness = 0.7
	mesh.surface_set_material(0, mat)
	return mesh

# Freccia: cilindro sottile con punta
static func create_arrow() -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	var verts: PackedVector3Array = []
	var normals: PackedVector3Array = []
	var indices: PackedInt32Array = []
	# Asta: cilindro sottile lungo 0.8m (verticale, lungo Y)
	_add_cyl(verts, normals, indices, Vector3(0, 0, 0), 0.015, 0.8, 6)
	# Punta: cono acuminato in cima (ferro)
	_add_cone(verts, normals, indices, Vector3(0, 0.45, 0), 0.04, 0.10, 6)
	# Impennatura: 3 alette alla base (piume)
	for i in range(3):
		var angle := TAU * i / 3.0
		var ax := cos(angle) * 0.05
		var az := sin(angle) * 0.05
		_add_box(verts, normals, indices, Vector3(ax, -0.35, az), Vector3(0.02, 0.12, 0.08))
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.5, 0.35, 0.15)
	mat.roughness = 0.7
	mesh.surface_set_material(0, mat)
	return mesh

# Ascia: manico + testa d'ascia
static func create_axe() -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	var verts: PackedVector3Array = []
	var normals: PackedVector3Array = []
	var indices: PackedInt32Array = []
	# Manico: cilindro verticale (0.6m)
	_add_cyl(verts, normals, indices, Vector3(0, 0, 0), 0.025, 0.6, 4)
	# Testa d'ascia: scatola larga in alto
	_add_box(verts, normals, indices, Vector3(0, 0.35, 0), Vector3(0.25, 0.08, 0.04))
	# Lama: cono piatto su un lato
	_add_cone(verts, normals, indices, Vector3(0.15, 0.35, 0), 0.06, 0.04, 4)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.4, 0.25, 0.1)
	mat.roughness = 0.6
	mat.metallic = 0.4
	mesh.surface_set_material(0, mat)
	return mesh

# Ascia a due mani: manico lungo + testa grande (1.4m totale)
static func create_battleaxe() -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	var verts: PackedVector3Array = []
	var normals: PackedVector3Array = []
	var indices: PackedInt32Array = []
	# Manico: cilindro lungo (1.4m)
	_add_cyl(verts, normals, indices, Vector3(0, 0, 0), 0.035, 1.4, 6)
	# Testa d'ascia: scatola grande in alto
	_add_box(verts, normals, indices, Vector3(0, 0.8, 0), Vector3(0.4, 0.12, 0.06))
	# Lama sinistra: cono
	_add_cone(verts, normals, indices, Vector3(-0.25, 0.8, 0), 0.08, 0.06, 5)
	# Lama destra: cono
	_add_cone(verts, normals, indices, Vector3(0.25, 0.8, 0), 0.08, 0.06, 5)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.4, 0.25, 0.1)
	mat.roughness = 0.5
	mat.metallic = 0.5
	mesh.surface_set_material(0, mat)
	return mesh

# Alabarda: manico lungo + punta + lama laterale (1.6m)
static func create_halberd() -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	var verts: PackedVector3Array = []
	var normals: PackedVector3Array = []
	var indices: PackedInt32Array = []
	# Manico: cilindro lungo (1.6m)
	_add_cyl(verts, normals, indices, Vector3(0, 0, 0), 0.03, 1.6, 6)
	# Punta in alto: cono lungo
	_add_cone(verts, normals, indices, Vector3(0, 0.9, 0), 0.05, 0.25, 6)
	# Lama laterale: scatola inclinata
	_add_box(verts, normals, indices, Vector3(0.15, 0.75, 0), Vector3(0.25, 0.15, 0.04))
	# Gancio opposto: piccolo cono
	_add_cone(verts, normals, indices, Vector3(-0.12, 0.75, 0), 0.04, 0.08, 4)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.4, 0.25, 0.1)
	mat.roughness = 0.5
	mat.metallic = 0.5
	mesh.surface_set_material(0, mat)
	return mesh

# Daikatana: spada lunga a due mani (1.2m)
static func create_daikatana() -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	var verts: PackedVector3Array = []
	var normals: PackedVector3Array = []
	var indices: PackedInt32Array = []
	# Lama: cilindro lungo curvo (1.0m)
	_add_cyl(verts, normals, indices, Vector3(0, 0.5, 0), 0.025, 1.0, 4)
	# Elsa: scatola orizzontale lunga (per due mani)
	_add_box(verts, normals, indices, Vector3(0, 0.0, 0), Vector3(0.3, 0.05, 0.05))
	# Pomolo: sfera
	_add_sph(verts, normals, indices, Vector3(0, -0.08, 0), 0.05, 4, 3)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.6, 0.6, 0.65)
	mat.roughness = 0.2
	mat.metallic = 0.9
	mesh.surface_set_material(0, mat)
	return mesh

# Lancia corta per fanteria (1.8m, piu' corta della lancia da cavalleria)
static func create_pike() -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	var verts: PackedVector3Array = []
	var normals: PackedVector3Array = []
	var indices: PackedInt32Array = []
	# Asta: cilindro (1.8m)
	_add_cyl(verts, normals, indices, Vector3(0, 0, 0), 0.02, 1.8, 4)
	# Punta: cono
	_add_cone(verts, normals, indices, Vector3(0, 1.0, 0), 0.04, 0.15, 6)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.5, 0.35, 0.15)
	mat.roughness = 0.7
	mesh.surface_set_material(0, mat)
	return mesh


# === PRIMITIVE HELPER ===

static func _add_cyl(verts: PackedVector3Array, normals: PackedVector3Array,
		indices: PackedInt32Array, center: Vector3, radius: float, height: float, seg: int):
	var base := verts.size()
	var half_h := height / 2.0
	for i in range(seg):
		var angle := TAU * i / seg
		var x := cos(angle) * radius
		var z := sin(angle) * radius
		verts.append(center + Vector3(x, -half_h, z))
		normals.append(Vector3(cos(angle), 0, sin(angle)))
		verts.append(center + Vector3(x, half_h, z))
		normals.append(Vector3(cos(angle), 0, sin(angle)))
	for i in range(seg):
		var a := base + i * 2
		var b := base + ((i + 1) % seg) * 2
		indices.append(a); indices.append(b); indices.append(a + 1)
		indices.append(b); indices.append(b + 1); indices.append(a + 1)

static func _add_box(verts: PackedVector3Array, normals: PackedVector3Array,
		indices: PackedInt32Array, center: Vector3, size: Vector3):
	var hx := size.x / 2.0
	var hy := size.y / 2.0
	var hz := size.z / 2.0
	var p := [
		center + Vector3(-hx, -hy, -hz), center + Vector3(hx, -hy, -hz),
		center + Vector3(hx, hy, -hz), center + Vector3(-hx, hy, -hz),
		center + Vector3(-hx, -hy, hz), center + Vector3(hx, -hy, hz),
		center + Vector3(hx, hy, hz), center + Vector3(-hx, hy, hz),
	]
	var faces := [[0,1,2,3,Vector3(0,0,-1)],[5,4,7,6,Vector3(0,0,1)],
		[4,0,3,7,Vector3(-1,0,0)],[1,5,6,2,Vector3(1,0,0)],
		[3,2,6,7,Vector3(0,1,0)],[4,5,1,0,Vector3(0,-1,0)]]
	for f in faces:
		var i := verts.size()
		for idx in range(4):
			verts.append(p[f[idx]])
			normals.append(f[4])
		indices.append(i); indices.append(i+1); indices.append(i+2)
		indices.append(i); indices.append(i+2); indices.append(i+3)

static func _add_sph(verts: PackedVector3Array, normals: PackedVector3Array,
		indices: PackedInt32Array, center: Vector3, radius: float, h_seg: int, v_seg: int):
	var base := verts.size()
	for i in range(v_seg + 1):
		var v: float = float(i) / v_seg
		var phi := v * PI
		for j in range(h_seg):
			var u: float = float(j) / h_seg
			var theta := u * TAU
			var x := sin(phi) * cos(theta) * radius
			var y := cos(phi) * radius
			var z := sin(phi) * sin(theta) * radius
			verts.append(center + Vector3(x, y, z))
			normals.append(Vector3(x, y, z).normalized())
	for i in range(v_seg):
		for j in range(h_seg):
			var a := base + i * h_seg + j
			var b := base + i * h_seg + (j + 1) % h_seg
			var c := base + (i + 1) * h_seg + j
			var d := base + (i + 1) * h_seg + (j + 1) % h_seg
			indices.append(a); indices.append(c); indices.append(b)
			indices.append(b); indices.append(c); indices.append(d)

static func _add_cone(verts: PackedVector3Array, normals: PackedVector3Array,
		indices: PackedInt32Array, center: Vector3, radius: float, height: float, seg: int):
	var base := verts.size()
	var half_h := height / 2.0
	for i in range(seg):
		var angle := TAU * i / seg
		var x := cos(angle) * radius
		var z := sin(angle) * radius
		verts.append(center + Vector3(x, -half_h, z))
		normals.append(Vector3(cos(angle), 0, sin(angle)))
	var apex := verts.size()
	verts.append(center + Vector3(0, half_h, 0))
	normals.append(Vector3(0, 1, 0))
	for i in range(seg):
		indices.append(base + i)
		indices.append(base + ((i + 1) % seg))
		indices.append(apex)
