extends Node3D
# Generatore di unita' complete: soldato + equipaggiamento
# Tipi: fanteria, arciere, cavalleria, artiglieria
# Ogni tipo ha arma e scudo/attrezzatura attaccati alle mani
# Dark Corporation / Stev

# Crea un'unita' completa del tipo specificato
# Tipi: spadaccini, lancieri, asceri, arciere, cavalleria, artiglieria
# Restituisce Node3D con tutto dentro
static func create_unit(unit_type: String, faction_color: Color) -> Node3D:
	var unit := Node3D.new()
	unit.name = "Unit_" + unit_type
	
	match unit_type:
		"spadaccini":
			_create_spadaccini(unit, faction_color)
		"lancieri":
			_create_lancieri(unit, faction_color)
		"asceri":
			_create_asceri(unit, faction_color)
		"arciere":
			_create_arciere(unit, faction_color)
		"cavalleria":
			_create_cavalleria(unit, faction_color)
		"artiglieria":
			_create_artiglieria(unit, faction_color)
		"fanteria":
			_create_spadaccini(unit, faction_color)
		_:
			_create_spadaccini(unit, faction_color)
	
	return unit


# Spadaccini: spada nella mano destra, scudo nella mano sinistra
static func _create_spadaccini(unit: Node3D, color: Color):
	var data := preload("res://scripts/game/soldier_skeleton.gd").create_soldier_skeleton()
	var skeleton: Skeleton3D = data["skeleton"]
	unit.add_child(skeleton)
	_apply_color(skeleton, color, ["Busto", "BraccioSx", "BraccioDx", "CosciaSx", "CosciaDx"])
	# Spada nella mano destra
	var sword := MeshInstance3D.new()
	sword.mesh = preload("res://scripts/game/weapon_mesh.gd").create_sword()
	sword.name = "Spada"
	_attach_to_bone(skeleton, "ManoDx", sword, Vector3(0, -0.1, 0.05))
	# Scudo nella mano sinistra
	var shield := MeshInstance3D.new()
	shield.mesh = preload("res://scripts/game/weapon_mesh.gd").create_shield()
	shield.name = "Scudo"
	_attach_to_bone(skeleton, "ManoSx", shield, Vector3(-0.1, 0.1, 0))


# Lancieri: lancia corta nella mano destra, scudo nella mano sinistra
static func _create_lancieri(unit: Node3D, color: Color):
	var data := preload("res://scripts/game/soldier_skeleton.gd").create_soldier_skeleton()
	var skeleton: Skeleton3D = data["skeleton"]
	unit.add_child(skeleton)
	_apply_color(skeleton, color, ["Busto", "BraccioSx", "BraccioDx", "CosciaSx", "CosciaDx"])
	# Lancia corta nella mano destra (1.8m, verticale)
	var pike := MeshInstance3D.new()
	pike.mesh = preload("res://scripts/game/weapon_mesh.gd").create_pike()
	pike.name = "Lancia"
	_attach_to_bone(skeleton, "ManoDx", pike, Vector3(0, 0.3, 0.05))
	# Scudo nella mano sinistra
	var shield := MeshInstance3D.new()
	shield.mesh = preload("res://scripts/game/weapon_mesh.gd").create_shield()
	shield.name = "Scudo"
	_attach_to_bone(skeleton, "ManoSx", shield, Vector3(-0.1, 0.1, 0))


# Asceri: arma a due mani (ascia, alabarda o daikatana), niente scudo
static func _create_asceri(unit: Node3D, color: Color):
	var data := preload("res://scripts/game/soldier_skeleton.gd").create_soldier_skeleton()
	var skeleton: Skeleton3D = data["skeleton"]
	unit.add_child(skeleton)
	_apply_color(skeleton, color, ["Busto", "BraccioSx", "BraccioDx", "CosciaSx", "CosciaDx"])
	# Sceglie casualmente arma a due mani: ascia, alabarda o daikatana
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(unit.name)
	var weapon_type := rng.randi() % 3
	var weapon := MeshInstance3D.new()
	match weapon_type:
		0: weapon.mesh = preload("res://scripts/game/weapon_mesh.gd").create_battleaxe()
		1: weapon.mesh = preload("res://scripts/game/weapon_mesh.gd").create_halberd()
		2: weapon.mesh = preload("res://scripts/game/weapon_mesh.gd").create_daikatana()
	weapon.name = "ArmaDueMani"
	# Arma attaccata alla mano destra, la mano sinistra la impugna piu' in basso
	_attach_to_bone(skeleton, "ManoDx", weapon, Vector3(0, 0.2, 0.05))
	# Niente scudo: arma a due mani


# Arciere: arco nella mano sinistra, faretra sulla coscia destra
static func _create_arciere(unit: Node3D, color: Color):
	var data := preload("res://scripts/game/soldier_skeleton.gd").create_soldier_skeleton()
	var skeleton: Skeleton3D = data["skeleton"]
	unit.add_child(skeleton)
	# Colore fazione: verde per arcieri
	var archer_color := Color(0.2, 0.5, 0.2)
	_apply_color(skeleton, archer_color, ["Busto", "BraccioSx", "BraccioDx"])
	# Arco nella mano sinistra
	var bow := MeshInstance3D.new()
	bow.mesh = preload("res://scripts/game/weapon_mesh.gd").create_bow()
	bow.name = "Arco"
	_attach_to_bone(skeleton, "ManoSx", bow, Vector3(0, 0.3, 0))
	# Faretra sulla coscia destra
	var quiver := MeshInstance3D.new()
	quiver.mesh = preload("res://scripts/game/weapon_mesh.gd").create_quiver()
	quiver.name = "Faretra"
	_attach_to_bone(skeleton, "CosciaDx", quiver, Vector3(0.12, -0.1, 0))


# Cavalleria: soldato seduto a cavallo con lancia nella mano destra
# Il cavaliere sta seduto sulla sella con le gambe penzoloni ai lati
# Le cosce sono orizzontali (sul dorso del cavallo), gli stinchi pendono
# verticalmente lungo i fianchi del cavallo, i piedi nelle staffe
# Dark Corporation / Stev
static func _create_cavalleria(unit: Node3D, color: Color):
	# Cavallo
	var horse := preload("res://scripts/game/horse_mesh.gd").create_horse()
	unit.add_child(horse)
	# Soldato seduto SOPRA la sella
	# Sella: Dorso a y=1.5 z=-0.5, sella offset y=+0.28, meta' altezza 0.05
	# => sella a y=1.83, z=-0.5
	# Bacino soldato a y=0.90 locale
	# RiderOffset = (0, 1.83 - 0.90, -0.5) = (0, 0.93, -0.5)
	var rider_offset := Node3D.new()
	rider_offset.position = Vector3(0, 0.93, -0.5)
	rider_offset.name = "RiderOffset"
	unit.add_child(rider_offset)
	var data := preload("res://scripts/game/soldier_skeleton.gd").create_soldier_skeleton()
	var skeleton: Skeleton3D = data["skeleton"]
	rider_offset.add_child(skeleton)
	# Colore fazione
	_apply_color(skeleton, color, ["Busto", "BraccioSx", "BraccioDx", "CosciaSx", "CosciaDx"])
	# Salva riferimento per applicare la posa seduta dopo l'aggiunta all'albero
	skeleton.set_meta("is_rider", true)
	# Lancia nella mano destra
	var spear := MeshInstance3D.new()
	spear.mesh = preload("res://scripts/game/weapon_mesh.gd").create_spear()
	spear.name = "Lancia"
	_attach_to_bone(skeleton, "ManoDx", spear, Vector3(0, 0.5, 0))
	# Scudo nella mano sinistra
	var shield := MeshInstance3D.new()
	shield.mesh = preload("res://scripts/game/weapon_mesh.gd").create_shield()
	shield.name = "Scudo"
	_attach_to_bone(skeleton, "ManoSx", shield, Vector3(-0.1, 0.1, 0))


# Artiglieria: onagro o balista con 6 serventi (anno 1000, niente cannoni)
static func _create_artiglieria(unit: Node3D, color: Color):
	# Sceglie casualmente onagro o balista
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(unit.name)
	var machine: Node3D
	if rng.randf() > 0.5:
		machine = preload("res://scripts/game/siege_engine.gd").create_onagro()
	else:
		machine = preload("res://scripts/game/siege_engine.gd").create_balista()
	unit.add_child(machine)


# === HELPER ===

# Attacca un MeshInstance3D a un osso tramite BoneAttachment3D
static func _attach_to_bone(skeleton: Skeleton3D, bone_name: String,
		mesh_inst: MeshInstance3D, offset: Vector3):
	var bone_idx := skeleton.find_bone(bone_name)
	if bone_idx < 0:
		skeleton.add_child(mesh_inst)
		return
	var attach := BoneAttachment3D.new()
	attach.name = "Attach_" + bone_name + "_" + mesh_inst.name
	attach.bone_name = bone_name
	attach.bone_idx = bone_idx
	skeleton.add_child(attach)
	mesh_inst.position = offset
	attach.add_child(mesh_inst)

# Applica il colore della fazione alle mesh degli ossi specificati
static func _apply_color(skeleton: Skeleton3D, color: Color, bone_names: Array):
	for bone_name in bone_names:
		var attach_name: String = "Attach_" + bone_name
		var attach: Node = skeleton.get_node_or_null(NodePath(attach_name))
		if attach == null:
			continue
		for child in attach.get_children():
			if child is MeshInstance3D:
				var mat := StandardMaterial3D.new()
				mat.albedo_color = color
				mat.roughness = 0.6
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
	mat.roughness = 0.8
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
	mat.roughness = 0.8
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
	mat.roughness = 0.7
	mesh.surface_set_material(0, mat)
	return mesh
