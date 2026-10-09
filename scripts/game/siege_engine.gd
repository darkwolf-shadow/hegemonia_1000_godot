extends Node3D
# Generatore di macchine d'assedio anno 1000: onagro e balista
# Ogni macchina ha 6 serventi (soldati senza armi)
# Dark Corporation / Stev

# Crea un onagro completo con serventi
# Dimensioni storiche: 2.5m lungo, 1.5m largo, 1.5m alto, braccio 1.5m
# Peso: 500kg - 6 tonnellate
static func create_onagro() -> Node3D:
	var machine := Node3D.new()
	machine.name = "Onagro"
	# Base: telaio di legno massiccio (2.5m x 1.5m x 0.8m)
	var base := MeshInstance3D.new()
	base.mesh = _box_mesh(Vector3(2.5, 0.8, 1.5), Color(0.35, 0.22, 0.1))
	base.position = Vector3(0, 0.5, 0)
	base.name = "Base"
	machine.add_child(base)
	# 4 travi verticali angolari (rinforzo telaio)
	for pos in [Vector3(-1.1, 1.1, -0.6), Vector3(1.1, 1.1, -0.6),
			Vector3(-1.1, 1.1, 0.6), Vector3(1.1, 1.1, 0.6)]:
		var post := MeshInstance3D.new()
		post.mesh = _box_mesh(Vector3(0.2, 1.2, 0.2), Color(0.3, 0.18, 0.08))
		post.position = pos
		post.name = "Montante"
		machine.add_child(post)
	# 4 ruote grandi (diametro 0.7m)
	for pos in [Vector3(-1.3, 0.45, -0.7), Vector3(1.3, 0.45, -0.7),
			Vector3(-1.3, 0.45, 0.7), Vector3(1.3, 0.45, 0.7)]:
		var wheel := MeshInstance3D.new()
		wheel.mesh = _cyl_mesh(0.35, 0.12, Color(0.15, 0.1, 0.05))
		wheel.position = pos
		wheel.rotation_degrees = Vector3(0, 0, 90)
		wheel.name = "Ruota"
		machine.add_child(wheel)
	# Braccio della catapulta: trave massiccio (0.25m x 2.5m x 0.25m)
	# Inclinato a -50 gradi, parte dal centro del telaio
	var arm := MeshInstance3D.new()
	arm.mesh = _box_mesh(Vector3(0.25, 2.5, 0.25), Color(0.4, 0.25, 0.1))
	arm.position = Vector3(0, 1.6, 0)
	arm.rotation_degrees = Vector3(-50, 0, 0)
	arm.name = "Braccio"
	machine.add_child(arm)
	# Cucchiaio all'estremita' del braccio (scodella per il proiettile)
	var spoon := MeshInstance3D.new()
	spoon.mesh = _sphere_mesh(0.25, Color(0.3, 0.2, 0.08))
	spoon.position = Vector3(0, 2.5, -0.9)
	spoon.name = "Cucchiaio"
	machine.add_child(spoon)
	# Torsione: due grandi matasse di corde laterali
	for x in [-0.4, 0.4]:
		var torsion := MeshInstance3D.new()
		torsion.mesh = _cyl_mesh(0.15, 0.8, Color(0.2, 0.15, 0.08))
		torsion.position = Vector3(x, 1.0, 0)
		torsion.name = "Torsione"
		machine.add_child(torsion)
	# Contrappeso: blocco di pietra sul retro
	var counter := MeshInstance3D.new()
	counter.mesh = _box_mesh(Vector3(0.8, 0.6, 0.8), Color(0.4, 0.38, 0.35))
	counter.position = Vector3(0, 0.8, 0.6)
	counter.name = "Contrappeso"
	machine.add_child(counter)
	# 6 serventi attorno alla macchina (senza armi)
	_add_servents(machine, "onagro")
	return machine


# Crea una balista completa con serventi
static func create_balista() -> Node3D:
	var machine := Node3D.new()
	machine.name = "Balista"
	# Base: scatola di legno (2m x 0.8m x 1.2m)
	var base := MeshInstance3D.new()
	base.mesh = _box_mesh(Vector3(2.0, 0.5, 1.2), Color(0.35, 0.22, 0.1))
	base.position = Vector3(0, 0.25, 0)
	base.name = "Base"
	machine.add_child(base)
	# 4 ruote
	for pos in [Vector3(-1.0, 0.2, -0.5), Vector3(1.0, 0.2, -0.5),
			Vector3(-1.0, 0.2, 0.5), Vector3(1.0, 0.2, 0.5)]:
		var wheel := MeshInstance3D.new()
		wheel.mesh = _cyl_mesh(0.2, 0.1, Color(0.15, 0.1, 0.05))
		wheel.position = pos
		wheel.rotation_degrees = Vector3(0, 0, 90)
		wheel.name = "Ruota"
		machine.add_child(wheel)
	# Guide orizzontali per il dardo (due travi parallele)
	for z in [-0.15, 0.15]:
		var guide := MeshInstance3D.new()
		guide.mesh = _box_mesh(Vector3(1.8, 0.1, 0.08), Color(0.4, 0.25, 0.1))
		guide.position = Vector3(0, 0.6, z)
		guide.name = "Guida"
		machine.add_child(guide)
	# Dardo caricato (cilindro lungo orizzontale)
	var bolt := MeshInstance3D.new()
	bolt.mesh = _cyl_mesh(0.04, 1.5, Color(0.3, 0.2, 0.1))
	bolt.position = Vector3(0, 0.65, 0)
	bolt.rotation_degrees = Vector3(0, 0, 90)
	bolt.name = "Dardo"
	machine.add_child(bolt)
	# Punta del dardo (cono)
	var tip := MeshInstance3D.new()
	tip.mesh = _cone_mesh(0.05, 0.15, Color(0.6, 0.6, 0.6))
	tip.position = Vector3(0.8, 0.65, 0)
	tip.rotation_degrees = Vector3(0, 0, -90)
	tip.name = "Punta"
	machine.add_child(tip)
	# Bracci della torsione (due cilindri verticali con corde)
	for x in [-0.4, 0.4]:
		var torsion_arm := MeshInstance3D.new()
		torsion_arm.mesh = _cyl_mesh(0.08, 0.8, Color(0.4, 0.25, 0.1))
		torsion_arm.position = Vector3(x, 0.9, 0)
		torsion_arm.name = "BraccioTorsione"
		machine.add_child(torsion_arm)
		# Corda della torsione
		var rope := MeshInstance3D.new()
		rope.mesh = _cyl_mesh(0.05, 0.6, Color(0.2, 0.15, 0.08))
		rope.position = Vector3(x, 0.6, 0)
		rope.name = "Corda"
		machine.add_child(rope)
	# 6 serventi attorno alla macchina (senza armi)
	_add_servents(machine, "balista")
	return machine


# Aggiunge 6 serventi attorno alla macchina (soldati senza armi)
static func _add_servents(machine: Node3D, machine_type: String):
	# Posizioni dei 6 serventi attorno alla macchina
	# Piu' distanti per l'onagro (piu' grande)
	var spread: float = 2.5
	if machine_type == "onagro":
		spread = 3.5
	var positions := [
		Vector3(-spread, 0, 0),
		Vector3(spread, 0, 0),
		Vector3(0, 0, -spread),
		Vector3(0, 0, spread),
		Vector3(-spread * 0.7, 0, spread * 0.7),
		Vector3(spread * 0.7, 0, spread * 0.7),
	]
	var colors := [Color(0.4, 0.3, 0.2), Color(0.35, 0.25, 0.15)]
	for i in range(positions.size()):
		var servant_data := preload("res://scripts/game/soldier_skeleton.gd").create_soldier_skeleton()
		var skeleton: Skeleton3D = servant_data["skeleton"]
		skeleton.position = positions[i]
		# Rotazione verso la macchina
		var angle := atan2(-positions[i].x, -positions[i].z)
		skeleton.rotation.y = angle
		# Colore neutro (serventi non hanno colore di fazione marcato)
		_apply_neutral_color(skeleton, colors[i % colors.size()])
		skeleton.name = "Servente_%d" % i
		machine.add_child(skeleton)


# Applica colore neutro ai serventi (busto e braccia)
static func _apply_neutral_color(skeleton: Skeleton3D, color: Color):
	for bone_name in ["Busto", "BraccioSx", "BraccioDx", "CosciaSx", "CosciaDx"]:
		var attach_name: String = "Attach_" + bone_name
		var attach: Node = skeleton.get_node_or_null(NodePath(attach_name))
		if attach == null:
			continue
		for child in attach.get_children():
			if child is MeshInstance3D:
				var mat := StandardMaterial3D.new()
				mat.albedo_color = color
				mat.roughness = 0.7
				(child as MeshInstance3D).material_override = mat


# === PRIMITIVE ===

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

static func _sphere_mesh(radius: float, color: Color) -> ArrayMesh:
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
	mat.roughness = 0.8
	mesh.surface_set_material(0, mat)
	return mesh

static func _cone_mesh(radius: float, height: float, color: Color) -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	var verts: PackedVector3Array = []
	var normals: PackedVector3Array = []
	var indices: PackedInt32Array = []
	var seg := 6
	var half_h := height / 2.0
	for i in range(seg):
		var angle := TAU * i / seg
		var x := cos(angle) * radius
		var z := sin(angle) * radius
		verts.append(Vector3(x, -half_h, z))
		normals.append(Vector3(cos(angle), 0, sin(angle)))
	var apex := verts.size()
	verts.append(Vector3(0, half_h, 0))
	normals.append(Vector3(0, 1, 0))
	for i in range(seg):
		indices.append(i)
		indices.append((i + 1) % seg)
		indices.append(apex)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.4
	mat.metallic = 0.6
	mesh.surface_set_material(0, mat)
	return mesh
