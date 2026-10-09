extends Node3D
# Generatore di cavallo con scheletro per animazione delle zampe
# Cavallo orientato: testa a -Z (avanti), coda a +Z (dietro)
# Corpo da z=+0.3 (dietro) a z=-1.3 (davanti)
# Dark Corporation / Stev

static func create_horse() -> Node3D:
	var horse := Node3D.new()
	horse.name = "Horse"
	
	var skeleton := Skeleton3D.new()
	skeleton.name = "HorseSkeleton"
	horse.add_child(skeleton)
	
	# Scheletro con posizioni calcolate:
	# Bacino al posteriore (z=+0.3), Dorso al centro (z=-0.5)
	# Collo lungo in avanti (z=-1.0), Testa davanti (z=-1.45)
	# Coda dietro (z=+0.8), incernierata sul bacino
	# Zampe anteriori sotto il davanti (z=-1.0)
	# Zampe posteriori sotto il posteriore (z=+0.3)
	var bones := [
		# Colonna vertebrale: bacino -> dorso -> collo -> testa
		[0, "Bacino", -1, Vector3(0, 1.5, 0.3)],
		[1, "Dorso", 0, Vector3(0, 0.0, -0.8)],
		[2, "Collo", 1, Vector3(0, 0.25, -0.5)],
		[3, "Testa", 2, Vector3(0, 0.10, -0.45)],
		# Coda: incernierata sul bacino, punta indietro (+Z)
		[4, "Coda", 0, Vector3(0, -0.10, 0.30)],
		# Zampe anteriori: incernierate sul dorso (parte anteriore)
		[5, "SpallaAntSx", 1, Vector3(-0.20, -0.2, -0.5)],
		[6, "CosciaAntSx", 5, Vector3(0, -0.35, 0)],
		[7, "GambaAntSx", 6, Vector3(0, -0.40, 0)],
		[8, "ZoccoloAntSx", 7, Vector3(0, -0.30, 0)],
		[9, "SpallaAntDx", 1, Vector3(0.20, -0.2, -0.5)],
		[10, "CosciaAntDx", 9, Vector3(0, -0.35, 0)],
		[11, "GambaAntDx", 10, Vector3(0, -0.40, 0)],
		[12, "ZoccoloAntDx", 11, Vector3(0, -0.30, 0)],
		# Zampe posteriori: incernierate sul bacino (parte posteriore)
		[13, "AncaPostSx", 0, Vector3(-0.20, -0.2, 0.0)],
		[14, "CosciaPostSx", 13, Vector3(0, -0.35, 0)],
		[15, "GambaPostSx", 14, Vector3(0, -0.40, 0)],
		[16, "ZoccoloPostSx", 15, Vector3(0, -0.30, 0)],
		[17, "AncaPostDx", 0, Vector3(0.20, -0.2, 0.0)],
		[18, "CosciaPostDx", 17, Vector3(0, -0.35, 0)],
		[19, "GambaPostDx", 18, Vector3(0, -0.40, 0)],
		[20, "ZoccoloPostDx", 19, Vector3(0, -0.30, 0)],
	]
	
	for b in bones:
		skeleton.add_bone(b[1])
		if b[2] >= 0:
			skeleton.set_bone_parent(b[0], b[2])
		skeleton.set_bone_rest(b[0], Transform3D(Basis(), b[3]))
		skeleton.set_bone_pose(b[0], Transform3D(Basis(), b[3]))
	
	# Corpo: scatola centrata sul dorso (z=-0.5), lunga 1.6m
	# Copre da z=+0.3 a z=-1.3
	_attach_box(skeleton, "Dorso", Vector3(0.45, 0.50, 1.6), Color(0.35, 0.2, 0.1), Vector3(0, 0, 0))
	# Collo: scatola lunga che collega dorso a testa (inclinata in avanti)
	_attach_box(skeleton, "Collo", Vector3(0.22, 0.40, 0.50), Color(0.35, 0.2, 0.1), Vector3(0, 0.05, -0.20))
	# Testa: scatola del muso, spostata in avanti per non sovrapporsi al collo
	_attach_box(skeleton, "Testa", Vector3(0.22, 0.28, 0.45), Color(0.35, 0.2, 0.1), Vector3(0, -0.02, -0.25))
	# Orecchie
	for x in [-0.07, 0.07]:
		_attach_cyl(skeleton, "Testa", 0.03, 0.08, Color(0.3, 0.18, 0.08), Vector3(x, 0.16, 0.15))
	# Criniera sul collo
	for i in range(4):
		_attach_cyl(skeleton, "Collo", 0.04, 0.08, Color(0.15, 0.08, 0.05), Vector3(0, 0.15 - i*0.02, -0.05 - i*0.06))
	# Coda: mesh attaccata all'osso Coda (incernierata sul bacino)
	_attach_cyl(skeleton, "Coda", 0.05, 0.50, Color(0.15, 0.08, 0.05), Vector3(0, -0.25, 0.10))
	# Sella sul dorso (z=-0.5)
	_attach_box(skeleton, "Dorso", Vector3(0.30, 0.10, 0.45), Color(0.3, 0.15, 0.08), Vector3(0, 0.28, 0.0))
	# Staffe ai lati della sella
	_attach_box(skeleton, "Dorso", Vector3(0.04, 0.10, 0.10), Color(0.4, 0.4, 0.4), Vector3(-0.22, 0.08, 0.0))
	_attach_box(skeleton, "Dorso", Vector3(0.04, 0.10, 0.10), Color(0.4, 0.4, 0.4), Vector3(0.22, 0.08, 0.0))
	# Zampe
	for suffix in ["AntSx", "AntDx", "PostSx", "PostDx"]:
		_attach_cyl(skeleton, "Coscia" + suffix, 0.08, 0.35, Color(0.3, 0.18, 0.08), Vector3(0, -0.18, 0))
		_attach_cyl(skeleton, "Gamba" + suffix, 0.06, 0.40, Color(0.3, 0.18, 0.08), Vector3(0, -0.20, 0))
		_attach_box(skeleton, "Zoccolo" + suffix, Vector3(0.09, 0.06, 0.14), Color(0.1, 0.08, 0.05), Vector3(0, -0.03, 0.03))
	
	return horse

static func _attach_box(skeleton: Skeleton3D, bone_name: String, size: Vector3, color: Color, offset: Vector3):
	var idx := skeleton.find_bone(bone_name)
	if idx < 0:
		return
	var attach := BoneAttachment3D.new()
	attach.bone_name = bone_name
	attach.bone_idx = idx
	skeleton.add_child(attach)
	var mi := MeshInstance3D.new()
	mi.mesh = _box_mesh(size, color)
	mi.position = offset
	attach.add_child(mi)

static func _attach_cyl(skeleton: Skeleton3D, bone_name: String, radius: float, height: float, color: Color, offset: Vector3):
	var idx := skeleton.find_bone(bone_name)
	if idx < 0:
		return
	var attach := BoneAttachment3D.new()
	attach.bone_name = bone_name
	attach.bone_idx = idx
	skeleton.add_child(attach)
	var mi := MeshInstance3D.new()
	mi.mesh = _cyl_mesh(radius, height, color)
	mi.position = offset
	attach.add_child(mi)

static func _box_mesh(size: Vector3, color: Color) -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	var verts: PackedVector3Array = []
	var normals: PackedVector3Array = []
	var indices: PackedInt32Array = []
	var hx := size.x / 2.0
	var hy := size.y / 2.0
	var hz := size.z / 2.0
	var p := [
		Vector3(-hx, -hy, -hz), Vector3(hx, -hy, -hz),
		Vector3(hx, hy, -hz), Vector3(-hx, hy, -hz),
		Vector3(-hx, -hy, hz), Vector3(hx, -hy, hz),
		Vector3(hx, hy, hz), Vector3(-hx, hy, hz),
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
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.85
	mesh.surface_set_material(0, mat)
	return mesh

static func _cyl_mesh(radius: float, height: float, color: Color) -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	var verts: PackedVector3Array = []
	var normals: PackedVector3Array = []
	var indices: PackedInt32Array = []
	var seg := 8
	var half_h := height / 2.0
	for i in range(seg):
		var angle := TAU * i / seg
		var x := cos(angle) * radius
		var z := sin(angle) * radius
		verts.append(Vector3(x, -half_h, z))
		normals.append(Vector3(cos(angle), 0, sin(angle)))
		verts.append(Vector3(x, half_h, z))
		normals.append(Vector3(cos(angle), 0, sin(angle)))
	for i in range(seg):
		var a := i * 2
		var b := ((i + 1) % seg) * 2
		indices.append(a); indices.append(b); indices.append(a + 1)
		indices.append(b); indices.append(b + 1); indices.append(a + 1)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.85
	mesh.surface_set_material(0, mat)
	return mesh
