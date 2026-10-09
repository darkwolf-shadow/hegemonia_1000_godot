extends Node3D
# Generatore di insediamento 3D con atmosfera medievale
# Usa billboard per gli edifici (icone esistenti) e mesh 3D per mura, torri, terreno
# Dark Corporation / Stev

static func create_settlement(settlement_data: Dictionary, region: String) -> Node3D:
	var settlement := Node3D.new()
	settlement.name = "Settlement3D"

	# Terreno base (piano verde-marrone)
	var terrain := _create_terrain()
	settlement.add_child(terrain)

	# Mura di cinta (palizzata di legno o mura di pietra)
	var has_fortress := false
	var buildings: Array = settlement_data.get("buildings", [])
	for b in buildings:
		if b in ["fortezza_frontiera", "caserma_iii"]:
			has_fortress = true
	if has_fortress:
		settlement.add_child(_create_stone_walls())
	else:
		settlement.add_child(_create_wooden_palisade())

	# Porta d'ingresso
	settlement.add_child(_create_gate())

	# Edifici come billboard (icone esistenti)
	var positions := _calculate_positions(buildings.size())
	for i in range(buildings.size()):
		var building_id: String = buildings[i]
		var billboard := _create_building_billboard(building_id, region)
		billboard.position = positions[i]
		settlement.add_child(billboard)

	# Alberi decorativi
	settlement.add_child(_create_trees())

	# Fuoco da campo (atmosfera)
	settlement.add_child(_create_campfire())

	return settlement

# Terreno base
static func _create_terrain() -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = "TerrenoInsediamento"
	var plane := PlaneMesh.new()
	plane.size = Vector2(60, 60)
	mi.mesh = plane
	mi.position = Vector3(0, 0, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.35, 0.28, 0.18)
	mat.roughness = 0.9
	mi.material_override = mat
	return mi

# Palizzata di legno (anno 1000)
static func _create_wooden_palisade() -> Node3D:
	var palisade := Node3D.new()
	palisade.name = "Palizzata"
	var wood_mat := StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.35, 0.22, 0.12)
	wood_mat.roughness = 0.95
	# Anello di tronchi verticali
	var radius := 25.0
	var seg_count := 40
	for i in range(seg_count):
		var angle := TAU * i / seg_count
		var x := cos(angle) * radius
		var z := sin(angle) * radius
		var log := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.3, 4.0, 0.3)
		log.mesh = box
		log.material_override = wood_mat
		log.position = Vector3(x, 2.0, z)
		log.cast_shadow = 1
		palisade.add_child(log)
	return palisade

# Mura di pietra (per fortezze)
static func _create_stone_walls() -> Node3D:
	var walls := Node3D.new()
	walls.name = "MuraPietra"
	var stone_mat := StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.52, 0.48)
	stone_mat.roughness = 0.9
	# Quattro muri perimetrali
	var radius := 25.0
	var wall_height := 6.0
	var wall_thickness := 1.5
	for angle in [0, PI / 2, PI, 3 * PI / 2]:
		var wall := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(radius * 2, wall_height, wall_thickness)
		wall.mesh = box
		wall.material_override = stone_mat
		wall.position = Vector3(cos(angle) * radius, wall_height / 2, sin(angle) * radius)
		wall.rotation.y = angle
		wall.cast_shadow = 1
		walls.add_child(wall)
	# Torri agli angoli
	for tx in [-radius, radius]:
		for tz in [-radius, radius]:
			var tower := MeshInstance3D.new()
			var cyl := CylinderMesh.new()
			cyl.top_radius = 2.0
			cyl.bottom_radius = 2.5
			cyl.height = wall_height + 3.0
			tower.mesh = cyl
			tower.material_override = stone_mat
			tower.position = Vector3(tx, (wall_height + 3.0) / 2, tz)
			tower.cast_shadow = 1
			walls.add_child(tower)
	return walls

# Porta d'ingresso
static func _create_gate() -> Node3D:
	var gate := Node3D.new()
	gate.name = "Porta"
	var wood_mat := StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.3, 0.18, 0.08)
	wood_mat.roughness = 0.95
	# Due pilastri
	for x in [-2.0, 2.0]:
		var pillar := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(1.0, 5.0, 1.0)
		pillar.mesh = box
		pillar.material_override = wood_mat
		pillar.position = Vector3(x, 2.5, 25.0)
		pillar.cast_shadow = 1
		gate.add_child(pillar)
	# Architrave
	var lintel := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(5.0, 1.0, 1.0)
	lintel.mesh = box
	lintel.material_override = wood_mat
	lintel.position = Vector3(0, 5.5, 25.0)
	lintel.cast_shadow = 1
	gate.add_child(lintel)
	return gate

# Billboard per edificio (usa icone esistenti)
static func _create_building_billboard(building_id: String, region: String) -> Sprite3D:
	var sprite := Sprite3D.new()
	sprite.name = "Edificio_" + building_id
	# Cerca l'icona nella regione
	var path := "res://risorse/icone/1000/" + region + "/buildings/" + building_id + ".png"
	if not ResourceLoader.exists(path):
		path = "res://risorse/icone/1000/european/buildings/" + building_id + ".png"
	if ResourceLoader.exists(path):
		sprite.texture = load(path)
	sprite.pixel_size = 0.15
	sprite.no_depth_test = false
	sprite.cast_shadow = 1
	return sprite

# Calcola posizioni degli edifici in cerchio
static func _calculate_positions(count: int) -> Array:
	var positions := []
	if count <= 0:
		return positions
	var radius := 12.0
	for i in range(count):
		var angle := TAU * i / count
		var x := cos(angle) * radius
		var z := sin(angle) * radius
		positions.append(Vector3(x, 0, z))
	return positions

# Alberi decorativi
static func _create_trees() -> Node3D:
	var trees := Node3D.new()
	trees.name = "Alberi"
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("settlement_trees")
	for i in range(15):
		var angle := rng.randf_range(0, TAU)
		var dist := rng.randf_range(28, 35)
		var x := cos(angle) * dist
		var z := sin(angle) * dist
		# Tronco
		var trunk := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.2
		cyl.bottom_radius = 0.3
		cyl.height = 2.0
		trunk.mesh = cyl
		var trunk_mat := StandardMaterial3D.new()
		trunk_mat.albedo_color = Color(0.25, 0.15, 0.08)
		trunk.material_override = trunk_mat
		trunk.position = Vector3(x, 1.0, z)
		trunk.cast_shadow = 1
		trees.add_child(trunk)
		# Chioma
		var foliage := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 1.2
		sphere.height = 2.5
		foliage.mesh = sphere
		var fol_mat := StandardMaterial3D.new()
		fol_mat.albedo_color = Color(0.15, 0.3, 0.12)
		foliage.material_override = fol_mat
		foliage.position = Vector3(x, 3.0, z)
		foliage.cast_shadow = 1
		trees.add_child(foliage)
	return trees

# Fuoco da campo
static func _create_campfire() -> Node3D:
	var fire := Node3D.new()
	fire.name = "Fuoco"
	# Base pietre
	var base := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.5
	cyl.bottom_radius = 0.6
	cyl.height = 0.2
	base.mesh = cyl
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.3, 0.3, 0.3)
	base.material_override = mat
	base.position = Vector3(0, 0.1, 0)
	fire.add_child(base)
	# Fiamma (cono arancione)
	var flame := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.05
	cone.bottom_radius = 0.4
	cone.height = 1.0
	flame.mesh = cone
	var flame_mat := StandardMaterial3D.new()
	flame_mat.albedo_color = Color(1.0, 0.5, 0.1)
	flame_mat.emission_energy_multiplier = 2.0
	flame_mat.emission = Color(1.0, 0.5, 0.1)
	flame.material_override = flame_mat
	flame.position = Vector3(0, 0.6, 0)
	fire.add_child(flame)
	# Luce
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.6, 0.2)
	light.light_energy = 3.0
	light.omni_range = 15.0
	light.position = Vector3(0, 1.5, 0)
	fire.add_child(light)
	return fire
