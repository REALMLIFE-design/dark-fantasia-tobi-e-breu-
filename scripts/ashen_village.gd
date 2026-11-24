extends RefCounted
class_name AshenVillageBuilder

const MAX_GRAVESTONES := 12
const MAX_DEAD_TREES := 5
const VILLAGE_CENTER := Vector3(275.0, 0.0, 175.0)

static func build(world: Node3D) -> void:
	var village := Node3D.new()
	village.name = "AldeiaDasCinzas"
	village.position = VILLAGE_CENTER
	world.add_child(village)
	_box(village, "AshenVillageGround", Vector3.ZERO, Vector3(58.0, 0.18, 52.0), Color("514d46"))
	_box(village, "AshenMainSquare", Vector3(0.0, 0.12, 3.0), Vector3(24.0, 0.12, 18.0), Color("777064"))
	var road := _box(world, "AshenRoad", Vector3(224.0, 0.08, 131.0), Vector3(6.0, 0.16, 130.0), Color("665947"))
	road.rotation.y = 0.85
	_box(village, "AshenSquareWell", Vector3(0.0, 0.85, 3.0), Vector3(2.8, 1.7, 2.8), Color("66645d"))
	_box(village, "AshenWellRim", Vector3(0.0, 1.75, 3.0), Vector3(3.2, 0.22, 3.2), Color("9a9281"))
	_build_house(village, "AshenHouse_01", Vector3(-20.0, 0.0, -13.0), 5.0, 4.6)
	_build_house(village, "AshenHouse_02", Vector3(19.0, 0.0, -15.0), 4.4, 4.2)
	_build_house(village, "AshenHouse_03", Vector3(-21.0, 0.0, 3.0), 4.8, 4.5)
	_build_house(village, "AshenHouse_04", Vector3(20.0, 0.0, 1.0), 5.2, 4.6)
	_build_chapel(village)
	_build_crypt(village)
	_build_graveyard(village)
	_build_dead_trees(village)
	_build_lanterns(village)
	for i in range(8):
		var x := -25.0 + float(i) * 7.0
		if absf(x) < 5.0:
			continue
		_box(village, "BrokenBoundaryStone_%02d" % i, Vector3(x, 0.75, 24.0), Vector3(2.4, 1.5 + float(i % 3) * 0.35, 0.8), Color("575650"))
	_box(village, "AbandonedCartBed", Vector3(-9.0, 0.65, 14.0), Vector3(2.8, 0.28, 1.6), Color("57402f"))
	_title(world, "ALDEIA DAS CINZAS", VILLAGE_CENTER + Vector3(0.0, 13.0, 0.0), Color("d8bda5"))

static func _build_house(parent: Node3D, house_name: String, position: Vector3, width: float, depth: float) -> void:
	var house := Node3D.new()
	house.name = house_name
	house.position = position
	parent.add_child(house)
	_box(house, "StoneFoundation", Vector3(0.0, 0.35, 0.0), Vector3(width + 0.5, 0.7, depth + 0.5), Color("55534d"))
	_box(house, "WeatheredTimberWalls", Vector3(0.0, 1.85, 0.0), Vector3(width, 3.0, depth), Color("665344"))
	_collision(house, "HouseCollision", Vector3(0.0, 1.85, 0.0), Vector3(width, 3.0, depth))
	_box(house, "DarkDoor", Vector3(0.0, 1.0, depth * 0.51), Vector3(0.95, 2.0, 0.12), Color("302b28"))
	_box(house, "RoofSlab", Vector3(0.0, 3.55, 0.0), Vector3(width + 1.0, 0.45, depth + 1.0), Color("49413b"))
	_box(house, "RoofRidge", Vector3(0.0, 3.9, 0.0), Vector3(width + 1.1, 0.22, 0.42), Color("332f2d"))
	for side in [-1.0, 1.0]:
		_box(house, "TimberCornerPost", Vector3(side * width * 0.43, 1.85, depth * 0.52), Vector3(0.18, 3.05, 0.18), Color("382f29"))
	_box(house, "BrokenWindow", Vector3(width * 0.28, 2.1, depth * 0.52), Vector3(0.7, 0.8, 0.12), Color("242a2a"))

static func _build_chapel(parent: Node3D) -> void:
	var chapel := Node3D.new()
	chapel.name = "AshenChapel"
	chapel.position = Vector3(0.0, 0.0, -16.0)
	parent.add_child(chapel)
	_box(chapel, "ChapelFloor", Vector3(0.0, 0.12, 0.0), Vector3(15.0, 0.24, 11.0), Color("69665e"))
	_box(chapel, "ChapelLeftWall", Vector3(-6.0, 2.2, 0.0), Vector3(2.0, 4.4, 10.0), Color("77736a"))
	_box(chapel, "ChapelRightWall", Vector3(6.0, 2.2, 0.0), Vector3(2.0, 4.4, 10.0), Color("77736a"))
	_box(chapel, "ChapelBackWall", Vector3(0.0, 2.2, -4.0), Vector3(10.0, 4.4, 2.0), Color("77736a"))
	_box(chapel, "ChapelFrontLintel", Vector3(0.0, 4.0, 4.0), Vector3(10.0, 0.8, 2.0), Color("77736a"))
	_box(chapel, "ChapelRoof", Vector3(0.0, 4.8, -0.2), Vector3(16.0, 0.65, 12.0), Color("403a38"))
	_box(chapel, "ChapelCrossStem", Vector3(0.0, 6.0, -0.2), Vector3(0.3, 2.0, 0.3), Color("393432"))
	_box(chapel, "ChapelCrossBar", Vector3(0.0, 6.35, -0.2), Vector3(1.4, 0.28, 0.28), Color("393432"))
	_box(chapel, "ChapelAltar", Vector3(0.0, 0.85, -2.4), Vector3(3.0, 1.4, 1.3), Color("8b8172"))
	_collision(chapel, "ChapelLeftCollision", Vector3(-6.0, 2.2, 0.0), Vector3(2.0, 4.4, 10.0))
	_collision(chapel, "ChapelRightCollision", Vector3(6.0, 2.2, 0.0), Vector3(2.0, 4.4, 10.0))

static func _build_crypt(parent: Node3D) -> void:
	var crypt := Node3D.new()
	crypt.name = "AshenCrypt"
	crypt.position = Vector3(-15.0, 0.0, 17.0)
	parent.add_child(crypt)
	_box(crypt, "CryptFloor", Vector3(0.0, -0.1, 0.0), Vector3(13.0, 0.2, 11.0), Color("454542"))
	_box(crypt, "CryptLeftWall", Vector3(-6.0, 2.0, 0.0), Vector3(1.6, 4.0, 11.0), Color("575650"))
	_box(crypt, "CryptRightWall", Vector3(6.0, 2.0, 0.0), Vector3(1.6, 4.0, 11.0), Color("575650"))
	_box(crypt, "CryptRearWall", Vector3(0.0, 2.0, -5.0), Vector3(13.0, 4.0, 1.6), Color("575650"))
	_box(crypt, "CryptLintel", Vector3(0.0, 3.8, 5.0), Vector3(13.0, 0.8, 1.6), Color("6d695f"))
	_box(crypt, "CryptRoof", Vector3(0.0, 4.2, 0.0), Vector3(14.0, 0.6, 12.0), Color("3e3c39"))
	for i in range(4):
		_box(crypt, "CryptSteps_%d" % i, Vector3(0.0, 0.08 + float(i) * 0.16, 6.0 + float(i) * 0.8), Vector3(5.0, 0.16, 1.0), Color("77746c"))
	var seal := _sphere(crypt, "CryptCrimsonSeal", Vector3(0.0, 2.0, 5.86), 0.32, Color("9c3946"))
	var seal_material := _material(Color("9c3946"))
	seal_material.emission_enabled = true
	seal_material.emission = Color("762431")
	seal_material.emission_energy_multiplier = 0.6
	seal.material_override = seal_material

static func _build_graveyard(parent: Node3D) -> void:
	var graveyard := Node3D.new()
	graveyard.name = "RavenGraveyard"
	graveyard.position = Vector3(16.0, 0.0, 14.0)
	parent.add_child(graveyard)
	_box(graveyard, "GraveyardGround", Vector3.ZERO, Vector3(18.0, 0.12, 17.0), Color("4d5148"))
	for i in range(MAX_GRAVESTONES):
		var row := i / 4
		var column := i % 4
		var x := -6.0 + float(column) * 4.0
		var z := -5.0 + float(row) * 4.2
		var stone := _box(graveyard, "Gravestone_%02d" % i, Vector3(x, 0.72, z), Vector3(0.9, 1.45 + float(i % 3) * 0.15, 0.28), Color("77766f"))
		stone.rotation.z = -0.08 if i % 2 == 0 else 0.08
		_box(graveyard, "GraveBase_%02d" % i, Vector3(x, 0.16, z), Vector3(1.6, 0.28, 0.8), Color("575751"))

static func _build_dead_trees(parent: Node3D) -> void:
	var positions := [Vector3(-27.0, 0.0, -21.0), Vector3(27.0, 0.0, -22.0), Vector3(-27.0, 0.0, 20.0), Vector3(27.0, 0.0, 20.0), Vector3(0.0, 0.0, 27.0)]
	for i in range(mini(MAX_DEAD_TREES, positions.size())):
		var tree := Node3D.new()
		tree.name = "DeadTree_%02d" % i
		tree.position = positions[i]
		parent.add_child(tree)
		var trunk := MeshInstance3D.new()
		var trunk_mesh := CylinderMesh.new()
		trunk_mesh.top_radius = 0.12
		trunk_mesh.bottom_radius = 0.42
		trunk_mesh.height = 5.8
		trunk.mesh = trunk_mesh
		trunk.position.y = 2.9
		trunk.material_override = _material(Color("40372f"))
		tree.add_child(trunk)
		for branch_index in range(3):
			var branch := _box(tree, "DeadBranch_%d" % branch_index, Vector3(0.0, 3.3 + float(branch_index) * 0.65, 0.0), Vector3(0.16, 2.2, 0.16), Color("40372f"))
			branch.rotation.z = -0.7 if branch_index % 2 == 0 else 0.7

static func _build_lanterns(parent: Node3D) -> void:
	for i in range(4):
		var x := -18.0 + float(i) * 12.0
		_box(parent, "AshenLanternPost_%d" % i, Vector3(x, 1.5, 8.0), Vector3(0.18, 3.0, 0.18), Color("3c3029"))
		var glow := _sphere(parent, "AshenLanternGlow_%d" % i, Vector3(x, 3.0, 8.0), 0.22, Color("d5a16a"))
		var material := _material(Color("d5a16a"))
		material.emission_enabled = true
		material.emission = Color("a65e34")
		material.emission_energy_multiplier = 0.8
		glow.material_override = material
		if i % 2 == 0:
			var light := OmniLight3D.new()
			light.position = Vector3(x, 3.0, 8.0)
			light.light_color = Color("d5a16a")
			light.light_energy = 0.45
			light.omni_range = 5.0
			parent.add_child(light)

static func _box(parent: Node3D, node_name: String, position: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.position = position
	instance.material_override = _material(color)
	parent.add_child(instance)
	return instance

static func _sphere(parent: Node3D, node_name: String, position: Vector3, radius: float, color: Color) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 10
	mesh.rings = 6
	instance.mesh = mesh
	instance.position = position
	instance.material_override = _material(color)
	parent.add_child(instance)
	return instance

static func _collision(parent: Node3D, node_name: String, position: Vector3, size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.name = node_name
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = position
	body.add_child(shape)
	parent.add_child(body)

static func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.92
	return material

static func _title(parent: Node3D, title_text: String, position: Vector3, color: Color) -> void:
	var title := Label3D.new()
	title.name = "RegionTitle_Aldeia_das_Cinzas"
	title.text = title_text
	title.position = position
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	title.font_size = 36
	title.modulate = color
	parent.add_child(title)
