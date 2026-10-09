extends Node3D
# Generatore di soldato con scheletro (Skeleton3D) e giunture
# Struttura: testa, busto, addome, bacino
# Braccia: spalla -> braccio -> avambraccio -> mano (pendenti verso il basso)
# Gambe: anca -> coscia -> gamba -> piede (pendenti verso il basso)
# Dark Corporation / Stev

static func create_soldier_skeleton() -> Dictionary:
	var skeleton := Skeleton3D.new()
	skeleton.name = "Skeleton3D"
	
	# Altezza totale circa 1.7m, piedi a terra (y=0)
	# Bacino a y=0.90, gambe lunghe 0.85m totali, piedi a y=0
	# Dark Corporation / Stev
	var bones := [
		# Colonna vertebrale: bacino -> addome -> busto -> collo -> testa
		[0, "Bacino", -1, Vector3(0, 0.90, 0)],
		[1, "Addome", 0, Vector3(0, 0.15, 0)],
		[2, "Busto", 1, Vector3(0, 0.20, 0)],
		[3, "Testa", 2, Vector3(0, 0.35, 0)],
		# Braccio sinistro: spalla -> braccio -> avambraccio -> mano
		[4, "SpallaSx", 2, Vector3(-0.25, 0.15, 0)],
		[5, "BraccioSx", 4, Vector3(0, -0.25, 0)],
		[6, "AvambraccioSx", 5, Vector3(0, -0.25, 0)],
		[7, "ManoSx", 6, Vector3(0, -0.2, 0)],
		# Braccio destro (simmetrico)
		[8, "SpallaDx", 2, Vector3(0.25, 0.15, 0)],
		[9, "BraccioDx", 8, Vector3(0, -0.25, 0)],
		[10, "AvambraccioDx", 9, Vector3(0, -0.25, 0)],
		[11, "ManoDx", 10, Vector3(0, -0.2, 0)],
		# Gamba sinistra: anca -> coscia -> gamba -> piede
		# Anca vicino al bacino, coscia subito sotto
		# Davanti del soldato = -Z (standard Godot), piedi puntano a -Z
		[12, "AncaSx", 0, Vector3(-0.12, -0.05, 0)],
		[13, "CosciaSx", 12, Vector3(0, -0.05, 0)],
		[14, "GambaSx", 13, Vector3(0, -0.40, 0)],
		[15, "PiedeSx", 14, Vector3(0, -0.35, -0.08)],
		# Gamba destra (simmetrica)
		[16, "AncaDx", 0, Vector3(0.12, -0.05, 0)],
		[17, "CosciaDx", 16, Vector3(0, -0.05, 0)],
		[18, "GambaDx", 17, Vector3(0, -0.40, 0)],
		[19, "PiedeDx", 18, Vector3(0, -0.35, -0.08)],
	]
	
	for b in bones:
		skeleton.add_bone(b[1])
		skeleton.set_bone_parent(b[0], b[2])
		skeleton.set_bone_rest(b[0], Transform3D(Basis(), b[3]))
		skeleton.set_bone_pose(b[0], Transform3D(Basis(), b[3]))
	
	# Crea BoneAttachment3D per ogni osso che ha una mesh
	var mesh_data := _create_body_meshes()
	for bone_name in mesh_data.keys():
		var bone_idx := skeleton.find_bone(bone_name)
		if bone_idx < 0:
			continue
		var attachment := BoneAttachment3D.new()
		attachment.name = "Attach_" + bone_name
		attachment.bone_name = bone_name
		attachment.bone_idx = bone_idx
		skeleton.add_child(attachment)
		var mi := MeshInstance3D.new()
		var entry: Dictionary = mesh_data[bone_name]
		mi.mesh = entry["mesh"]
		mi.name = "Mesh_" + bone_name
		mi.position = entry.get("offset", Vector3.ZERO)
		attachment.add_child(mi)
	
	return {"skeleton": skeleton, "bone_count": bones.size()}


# Applica la posa seduta del cavaliere
# Cosce orizzontali in avanti (sul dorso del cavallo)
# Stinchi pendenti verticali lungo i fianchi
# Dark Corporation / Stev
static func apply_rider_pose(skeleton: Skeleton3D):
	# Cosce orizzontali: ruotate 80 gradi in avanti (asse X)
	for bone_name in ["CosciaSx", "CosciaDx"]:
		var idx := skeleton.find_bone(bone_name)
		if idx >= 0:
			var rest := skeleton.get_bone_rest(idx)
			skeleton.set_bone_pose(idx, Transform3D(
				Basis().rotated(Vector3.RIGHT, deg_to_rad(80)), rest.origin))
	# Stinchi pendenti verticali: ruotati -80 gradi (asse X)
	for bone_name in ["GambaSx", "GambaDx"]:
		var idx := skeleton.find_bone(bone_name)
		if idx >= 0:
			var rest := skeleton.get_bone_rest(idx)
			skeleton.set_bone_pose(idx, Transform3D(
				Basis().rotated(Vector3.RIGHT, deg_to_rad(-80)), rest.origin))


static func _create_body_meshes() -> Dictionary:
	var meshes := {}
	# Bacino: scatola che riempie il bacino (collega addome e cosce)
	meshes["Bacino"] = _box_mesh(Vector3(0.42, 0.25, 0.28), Color(0.35, 0.22, 0.13), Vector3(0, -0.05, 0))
	# Addome: scatola sopra il bacino
	meshes["Addome"] = _box_mesh(Vector3(0.38, 0.20, 0.25), Color(0.4, 0.25, 0.15), Vector3(0, 0.07, 0))
	# Busto: scatola (petto/armatura)
	meshes["Busto"] = _box_mesh(Vector3(0.48, 0.30, 0.30), Color(0.5, 0.3, 0.2), Vector3(0, 0.10, 0))
	# Testa: sfera piu' alta per non sovrapporsi al busto
	meshes["Testa"] = _sphere_mesh(0.15, Color(0.8, 0.6, 0.4), Vector3(0, 0.15, 0))
	# Braccio (parte superiore): cilindro verticale
	meshes["BraccioSx"] = _cyl_mesh(0.07, 0.25, Color(0.5, 0.3, 0.2), Vector3(0, -0.12, 0))
	meshes["BraccioDx"] = _cyl_mesh(0.07, 0.25, Color(0.5, 0.3, 0.2), Vector3(0, -0.12, 0))
	# Avambraccio: cilindro piu' sottile
	meshes["AvambraccioSx"] = _cyl_mesh(0.06, 0.25, Color(0.8, 0.6, 0.4), Vector3(0, -0.12, 0))
	meshes["AvambraccioDx"] = _cyl_mesh(0.06, 0.25, Color(0.8, 0.6, 0.4), Vector3(0, -0.12, 0))
	# Mani: piccole scatole
	meshes["ManoSx"] = _box_mesh(Vector3(0.09, 0.10, 0.06), Color(0.8, 0.6, 0.4), Vector3(0, -0.05, 0))
	meshes["ManoDx"] = _box_mesh(Vector3(0.09, 0.10, 0.06), Color(0.8, 0.6, 0.4), Vector3(0, -0.05, 0))
	# Cosce: cilindri che coprono da anca a ginocchio (0.40m)
	meshes["CosciaSx"] = _cyl_mesh(0.12, 0.40, Color(0.3, 0.2, 0.15), Vector3(0, -0.20, 0))
	meshes["CosciaDx"] = _cyl_mesh(0.12, 0.40, Color(0.3, 0.2, 0.15), Vector3(0, -0.20, 0))
	# Gambe (stinco): cilindri che coprono da ginocchio a caviglia
	meshes["GambaSx"] = _cyl_mesh(0.08, 0.35, Color(0.25, 0.18, 0.12), Vector3(0, -0.17, 0))
	meshes["GambaDx"] = _cyl_mesh(0.08, 0.35, Color(0.25, 0.18, 0.12), Vector3(0, -0.17, 0))
	# Piedi: scatole piatte a livello terreno
	meshes["PiedeSx"] = _box_mesh(Vector3(0.10, 0.05, 0.20), Color(0.2, 0.15, 0.1), Vector3(0, -0.02, 0.04))
	meshes["PiedeDx"] = _box_mesh(Vector3(0.10, 0.05, 0.20), Color(0.2, 0.15, 0.1), Vector3(0, -0.02, 0.04))
	return meshes


static func _box_mesh(size: Vector3, color: Color, offset: Vector3) -> Dictionary:
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
	mat.roughness = 0.7
	mesh.surface_set_material(0, mat)
	return {"mesh": mesh, "offset": offset}


static func _sphere_mesh(radius: float, color: Color, offset: Vector3) -> Dictionary:
	var mesh := ArrayMesh.new()
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	var verts: PackedVector3Array = []
	var normals: PackedVector3Array = []
	var indices: PackedInt32Array = []
	var h_seg := 8
	var v_seg := 6
	for i in range(v_seg + 1):
		var v: float = float(i) / v_seg
		var phi := v * PI
		for j in range(h_seg):
			var u: float = float(j) / h_seg
			var theta := u * TAU
			var x := sin(phi) * cos(theta) * radius
			var y := cos(phi) * radius
			var z := sin(phi) * sin(theta) * radius
			verts.append(Vector3(x, y, z))
			normals.append(Vector3(x, y, z).normalized())
	for i in range(v_seg):
		for j in range(h_seg):
			var a := i * h_seg + j
			var b := i * h_seg + (j + 1) % h_seg
			var c := (i + 1) * h_seg + j
			var d := (i + 1) * h_seg + (j + 1) % h_seg
			indices.append(a); indices.append(c); indices.append(b)
			indices.append(b); indices.append(c); indices.append(d)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.6
	mesh.surface_set_material(0, mat)
	return {"mesh": mesh, "offset": offset}


static func _cyl_mesh(radius: float, height: float, color: Color, offset: Vector3) -> Dictionary:
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
	mat.roughness = 0.7
	mesh.surface_set_material(0, mat)
	return {"mesh": mesh, "offset": offset}
