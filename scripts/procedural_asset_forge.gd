extends RefCounted
class_name ProceduralAssetForge

# Forge de modelos 3D locais: geometria criada pelo Godot, sem IA, tokens ou downloads.
const STONE := Color("555b58")
const DARK := Color("20272a")
const METAL := Color("8c9691")
const RUNE := Color("70d8c6")
const GOLD := Color("c39a5d")
const WOOD := Color("49372f")

static func create_asset(asset_key: String) -> Node3D:
	var root := Node3D.new()
	root.name = "Local_" + asset_key
	match asset_key:
		"thrixel_stag_guardian":
			_build_stag(root)
		"thrixel_river_crab":
			_build_crab(root)
		"thrixel_drowned_wraith":
			_build_wraith(root)
		"thrixel_ancient_tree":
			_build_tree(root)
		"thrixel_rune_obelisk", "meshy_rune_obelisk":
			_build_obelisk(root)
		"thrixel_way_shrine", "meshy_way_shrine":
			_build_shrine(root)
		"meshy_gate":
			_build_gate(root)
		_:
			root.queue_free()
			return null
	return root


static func _mat(color: Color, glow := false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
	if glow:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = 1.25
	return material


static func _part(parent: Node3D, mesh: Mesh, part_name: String, pos: Vector3, color: Color, scale := Vector3.ONE, glow := false) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = part_name
	instance.mesh = mesh
	instance.position = pos
	instance.scale = scale
	instance.material_override = _mat(color, glow)
	parent.add_child(instance)
	return instance


static func _box(parent: Node3D, part_name: String, pos: Vector3, size: Vector3, color: Color, glow := false) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return _part(parent, mesh, part_name, pos, color, Vector3.ONE, glow)


static func _sphere(parent: Node3D, part_name: String, pos: Vector3, radius: float, color: Color, scale := Vector3.ONE, glow := false) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 12
	mesh.rings = 8
	return _part(parent, mesh, part_name, pos, color, scale, glow)


static func _cylinder(parent: Node3D, part_name: String, pos: Vector3, radius: float, height: float, color: Color, sides := 8) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = sides
	return _part(parent, mesh, part_name, pos, color)


static func _build_stag(root: Node3D) -> void:
	_sphere(root, "StagBody", Vector3(0, 1.35, 0), 0.68, Color("59665d"), Vector3(1.35, 0.78, 0.82))
	_sphere(root, "StagChest", Vector3(0, 1.55, 0.42), 0.48, Color("6d786a"), Vector3(0.9, 1.05, 0.72))
	_cylinder(root, "StagNeck", Vector3(0, 2.05, 0.45), 0.25, 0.95, Color("59665d"))
	_sphere(root, "StagHead", Vector3(0, 2.62, 0.55), 0.38, Color("737b6c"), Vector3(0.9, 1.0, 1.0))
	_sphere(root, "StagMuzzle", Vector3(0, 2.48, 0.88), 0.18, Color("a19a82"))
	for side in [-1.0, 1.0]:
		_cylinder(root, "StagLeg", Vector3(side * 0.38, 0.55, 0.10), 0.105, 1.05, Color("454f49"), 6)
		_cylinder(root, "StagAntlerStem", Vector3(side * 0.23, 3.10, 0.48), 0.065, 0.82, GOLD, 6)
		_cylinder(root, "StagAntlerBranch", Vector3(side * 0.47, 3.32, 0.48), 0.045, 0.48, GOLD, 6).rotation.z = side * -0.7
		_sphere(root, "StagRuneEye", Vector3(side * 0.22, 2.68, 0.88), 0.055, RUNE, Vector3.ONE, true)
	for i in range(5):
		_box(root, "StagRune_%d" % i, Vector3(-0.28 + i * 0.14, 1.48 + (i % 2) * 0.12, 0.81), Vector3(0.045, 0.22, 0.035), RUNE, true)


static func _build_crab(root: Node3D) -> void:
	_sphere(root, "CrabShell", Vector3(0, 0.62, 0), 0.72, Color("9c6752"), Vector3(1.45, 0.68, 1.0))
	_sphere(root, "CrabShellTop", Vector3(0, 0.91, -0.02), 0.48, Color("bd8462"), Vector3(1.3, 0.42, 1.0))
	for side in [-1.0, 1.0]:
		for i in range(3):
			var leg := _cylinder(root, "CrabLeg_%s_%d" % [str(side), i], Vector3(side * (0.62 + i * 0.10), 0.28, -0.42 + i * 0.42), 0.075, 0.72, Color("765044"), 6)
			leg.rotation.z = side * 0.85
		var claw := _sphere(root, "CrabClaw", Vector3(side * 1.12, 0.46, 0.42), 0.24, Color("bd8462"), Vector3(1.2, 0.75, 1.0))
		var pincer := _cone(root, "CrabPincer", Vector3(side * 1.29, 0.43, 0.52), 0.12, 0.34, Color("d4a17a"))
		pincer.rotation.z = side * 1.1
		_cylinder(root, "CrabEyeStem", Vector3(side * 0.24, 1.10, 0.30), 0.045, 0.32, DARK, 6)
		_sphere(root, "CrabEye", Vector3(side * 0.24, 1.28, 0.30), 0.09, RUNE, Vector3.ONE, true)


static func _build_wraith(root: Node3D) -> void:
	_sphere(root, "WraithCowl", Vector3(0, 2.12, 0), 0.62, Color("29363a"), Vector3(0.9, 1.0, 0.72))
	_sphere(root, "WraithFaceVoid", Vector3(0, 2.12, 0.48), 0.34, DARK, Vector3(0.85, 1.0, 0.35))
	for side in [-1.0, 1.0]:
		_sphere(root, "WraithEye", Vector3(side * 0.15, 2.20, 0.72), 0.075, Color("76e5d3"), Vector3.ONE, true)
		var arm := _box(root, "WraithSleeve", Vector3(side * 0.62, 1.62, 0.02), Vector3(0.32, 1.05, 0.34), Color("34474a"))
		arm.rotation.z = side * -0.38
		_sphere(root, "WraithHand", Vector3(side * 0.90, 1.05, 0.08), 0.18, Color("263438"))
	for i in range(5):
		var rag := _box(root, "WraithRag_%d" % i, Vector3(-0.42 + i * 0.21, 0.72 - (i % 2) * 0.18, -0.02), Vector3(0.20, 1.25 + (i % 3) * 0.16, 0.10), Color("273438"))
		rag.rotation.z = (i - 2) * 0.10
	_sphere(root, "WraithCore", Vector3(0, 1.35, 0.32), 0.16, RUNE, Vector3.ONE, true)


static func _build_tree(root: Node3D) -> void:
	_cylinder(root, "AncientTrunk", Vector3(0, 2.4, 0), 0.58, 4.8, Color("514238"), 9)
	for i in range(7):
		var angle := TAU * float(i) / 7.0
		var branch := _cylinder(root, "AncientBranch_%d" % i, Vector3(cos(angle) * 0.72, 3.8 + (i % 3) * 0.25, sin(angle) * 0.72), 0.17, 2.0, Color("5b4839"), 7)
		branch.rotation.z = cos(angle) * -0.65
		branch.rotation.x = sin(angle) * 0.65
		_sphere(root, "Canopy_%d" % i, Vector3(cos(angle) * 1.35, 5.1 + (i % 2) * 0.55, sin(angle) * 1.35), 1.42, Color("344f43"), Vector3(1.1, 0.88, 1.0))
	_sphere(root, "CanopyCrown", Vector3(0, 6.25, 0), 1.6, Color("405c49"), Vector3(1.15, 0.9, 1.0))
	for i in range(8):
		_sphere(root, "Firefly_%d" % i, Vector3(cos(i * TAU / 8.0) * 1.6, 4.2 + (i % 3) * 0.55, sin(i * TAU / 8.0) * 1.6), 0.055, RUNE, Vector3.ONE, true)


static func _build_obelisk(root: Node3D) -> void:
	_box(root, "ObeliskBase", Vector3(0, 0.25, 0), Vector3(2.3, 0.5, 2.0), STONE)
	_box(root, "ObeliskFoot", Vector3(0, 0.62, 0), Vector3(1.65, 0.28, 1.45), Color("74766a"))
	_cylinder(root, "ObeliskShaft", Vector3(0, 2.15, 0), 0.62, 3.0, Color("626c65"), 6)
	_cylinder(root, "ObeliskCap", Vector3(0, 3.72, 0), 0.84, 0.28, Color("858778"), 6)
	var tip := _cone(root, "ObeliskTip", Vector3(0, 4.28, 0), 0.62, 0.9, Color("777e70"))
	for i in range(4):
		var rune := _box(root, "ObeliskRune_%d" % i, Vector3(0, 1.35 + i * 0.48, 0.64), Vector3(0.20, 0.12, 0.06), RUNE, true)
		rune.rotation.z = 0.4 if i % 2 == 0 else -0.4
	_cylinder(root, "ObeliskRing", Vector3(0, 2.15, 0), 0.95, 0.06, GOLD, 12)


static func _build_shrine(root: Node3D) -> void:
	_box(root, "ShrineFoundation", Vector3(0, 0.18, 0), Vector3(4.2, 0.36, 3.4), STONE)
	for side in [-1.0, 1.0]:
		_box(root, "ShrinePillar", Vector3(side * 1.45, 1.35, -0.25), Vector3(0.48, 2.35, 0.48), Color("777b70"))
		_box(root, "ShrinePillarFoot", Vector3(side * 1.45, 0.35, -0.25), Vector3(0.72, 0.28, 0.72), Color("929182"))
	_box(root, "ShrineLintel", Vector3(0, 2.65, -0.25), Vector3(3.55, 0.42, 0.62), Color("858778"))
	_box(root, "ShrineAltar", Vector3(0, 0.72, 0.55), Vector3(1.25, 0.62, 0.85), Color("626b62"))
	_sphere(root, "ShrineHeart", Vector3(0, 1.35, 0.55), 0.25, RUNE, Vector3.ONE, true)
	for i in range(5):
		_box(root, "ShrineGlyph_%d" % i, Vector3(-0.72 + i * 0.36, 2.65, 0.09), Vector3(0.12, 0.20, 0.05), GOLD)


static func _build_gate(root: Node3D) -> void:
	_box(root, "GateThreshold", Vector3(0, 0.16, 0), Vector3(7.0, 0.32, 1.5), STONE)
	for side in [-1.0, 1.0]:
		_box(root, "GatePier", Vector3(side * 2.65, 2.4, 0), Vector3(0.9, 4.8, 0.9), Color("555b58"))
		_box(root, "GateBase", Vector3(side * 2.65, 0.42, 0), Vector3(1.25, 0.72, 1.25), Color("777b70"))
		_box(root, "GateCap", Vector3(side * 2.65, 4.9, 0), Vector3(1.35, 0.42, 1.35), Color("858778"))
		var finial := _cone(root, "GateFinial", Vector3(side * 2.65, 5.42, 0), 0.42, 0.75, GOLD)
	_box(root, "GateArchTop", Vector3(0, 4.85, 0), Vector3(4.8, 0.55, 0.82), Color("626b62"))
	_box(root, "GateSeal", Vector3(0, 3.95, 0.48), Vector3(0.68, 0.88, 0.10), Color("843f45"), true)


static func _cone(parent: Node3D, part_name: String, pos: Vector3, radius: float, height: float, color: Color) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.0
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 8
	return _part(parent, mesh, part_name, pos, color)
