extends RefCounted
class_name DarkFantasyPropPack
## Cenografia procedural gratuita usando os atlases PBR ja existentes.

const PAINTER_SHADER = preload("res://scripts/painter_material.gdshader")
const ALBEDO_ATLAS = preload("res://assets/textures/surface_albedo_atlas.png")
const ROUGHNESS_ATLAS = preload("res://assets/textures/surface_roughness_atlas.png")
static var _materials: Dictionary = {}

static func build_all(parent: Node3D) -> void:
	if parent == null:
		return
	_build_village(parent, Vector3(-112, 0, 92))
	_build_city(parent, Vector3(174, 0, 88))
	_build_forest(parent, Vector3(-158, 0, -104))
	_build_cave(parent, Vector3(-220, 0, -255))
	_build_dungeon(parent, Vector3(226, 0, 94))
	_build_castle(parent, Vector3(250, 0, -300))
	_build_ruins(parent, Vector3(164, 0, -65))
	_build_bone_cart(parent, Vector3(-130, 0, 112))
	_build_rune_circle(parent, Vector3(-177, 0, -119))
	_build_cursed_well(parent, Vector3(145, 0, -72))
	_build_fallen_guardian(parent, Vector3(246, 0, -315))
	_build_glacial_altar(parent, Vector3(-166, 0, -260))
	_build_crimson_rift_gate(parent, Vector3(165, 0, -330))

static func _root(parent: Node3D, node_name: String, position: Vector3) -> Node3D:
	var root := Node3D.new()
	root.name = node_name
	root.position = position
	parent.add_child(root)
	return root

static func _material(color: Color, mode: int, glow := false) -> Material:
	if glow:
		var emissive := StandardMaterial3D.new()
		emissive.albedo_color = color
		emissive.emission_enabled = true
		emissive.emission = color
		emissive.emission_energy_multiplier = 1.5
		return emissive
	var key := "%s:%d" % [color.to_html(false), mode]
	if _materials.has(key):
		return _materials[key]
	var mat := ShaderMaterial.new()
	mat.shader = PAINTER_SHADER
	mat.set_shader_parameter("surface_albedo_atlas", ALBEDO_ATLAS)
	mat.set_shader_parameter("surface_roughness_atlas", ROUGHNESS_ATLAS)
	mat.set_shader_parameter("base_tint", color)
	mat.set_shader_parameter("accent_tint", color.darkened(0.28))
	mat.set_shader_parameter("brush_scale", 3.4)
	mat.set_shader_parameter("brush_strength", 0.12)
	mat.set_shader_parameter("pattern_mode", mode)
	mat.set_shader_parameter("detail_scale", 1.0)
	mat.set_shader_parameter("triplanar_sharpness", 4.3)
	mat.set_shader_parameter("bump_strength", 0.16)
	_materials[key] = mat
	return mat

static func _mesh(parent: Node3D, node_name: String, mesh: Mesh, pos: Vector3, color: Color, mode: int, glow := false) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = pos
	instance.material_override = _material(color, mode, glow)
	parent.add_child(instance)
	return instance

static func _box(parent: Node3D, node_name: String, pos: Vector3, size: Vector3, color: Color, mode := 8, glow := false) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return _mesh(parent, node_name, mesh, pos, color, mode, glow)

static func _sphere(parent: Node3D, node_name: String, pos: Vector3, radius: float, color: Color, scale := Vector3.ONE, mode := 8, glow := false) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 10
	mesh.rings = 6
	var instance := _mesh(parent, node_name, mesh, pos, color, mode, glow)
	instance.scale = scale
	return instance

static func _cylinder(parent: Node3D, node_name: String, pos: Vector3, radius: float, height: float, color: Color, mode := 8, sides := 8) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = sides
	return _mesh(parent, node_name, mesh, pos, color, mode)

static func _cone(parent: Node3D, node_name: String, pos: Vector3, radius: float, height: float, color: Color, mode := 8) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.0
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 7
	return _mesh(parent, node_name, mesh, pos, color, mode)

static func _barrel(parent: Node3D, pos: Vector3) -> void:
	var root := Node3D.new()
	root.name = "OldBarrel"
	root.position = pos
	parent.add_child(root)
	_cylinder(root, "BarrelBody", Vector3(0, 0.62, 0), 0.48, 1.24, Color("5a4030"), 4, 9)
	for y in [0.18, 0.55, 1.05]:
		_cylinder(root, "IronHoop", Vector3(0, y, 0), 0.50, 0.075, Color("555d60"), 12, 9)

static func _crate(parent: Node3D, pos: Vector3) -> void:
	_box(parent, "WoodSupplyCrate", pos + Vector3(0, 0.48, 0), Vector3(0.95, 0.95, 0.95), Color("604633"), 4)
	_box(parent, "CrateCross", pos + Vector3(0, 0.48, 0.49), Vector3(0.12, 0.94, 0.04), Color("98734b"), 4)

static func _lamp(parent: Node3D, pos: Vector3, flame_color := Color("e9b36b")) -> void:
	_cylinder(parent, "WroughtIronLampPost", pos + Vector3(0, 1.45, 0), 0.075, 2.9, Color("414749"), 12, 7)
	_box(parent, "LanternFrame", pos + Vector3(0, 2.85, 0), Vector3(0.52, 0.58, 0.52), Color("30393a"), 12)
	_sphere(parent, "LanternFlame", pos + Vector3(0, 2.85, 0), 0.18, flame_color, Vector3(0.72, 1.2, 0.72), 13, true)

static func _market_stall(parent: Node3D, pos: Vector3, canopy: Color) -> void:
	var root := Node3D.new()
	root.name = "MedievalMarketStall"
	root.position = pos
	parent.add_child(root)
	for x in [-1.35, 1.35]:
		_cylinder(root, "StallPost", Vector3(x, 1.45, 0), 0.09, 2.9, Color("49382d"), 4, 7)
	_box(root, "StallCounter", Vector3(0, 0.9, 0), Vector3(3.1, 0.22, 1.35), Color("674b35"), 4)
	_box(root, "StallCanopy", Vector3(0, 2.9, 0), Vector3(3.3, 0.22, 1.55), canopy, 7)

static func _build_village(parent: Node3D, center: Vector3) -> void:
	var root := _root(parent, "VillagePropCollection", center)
	_market_stall(root, Vector3(-7, 0, 5), Color("784a42"))
	_market_stall(root, Vector3(6, 0, 5), Color("556c63"))
	_barrel(root, Vector3(-10, 0, -3))
	_barrel(root, Vector3(-8.8, 0, -3))
	_crate(root, Vector3(9, 0, -3))
	_lamp(root, Vector3(-13, 0, 10))
	_lamp(root, Vector3(13, 0, 10), Color("d8a16d"))
	_box(root, "TavernSignBoard", Vector3(0, 3.1, 11), Vector3(2.2, 0.8, 0.16), Color("6a4b33"), 4)
	_cylinder(root, "VillageAnvil", Vector3(4, 0.7, -10), 0.48, 0.5, Color("6e7475"), 12, 8)
	_box(root, "VillageBench", Vector3(-4, 0.55, -10), Vector3(2.1, 0.18, 0.55), Color("604633"), 4)

static func _build_city(parent: Node3D, center: Vector3) -> void:
	var root := _root(parent, "StoneCityPropCollection", center)
	_market_stall(root, Vector3(-8, 0, -4), Color("5b6262"))
	_market_stall(root, Vector3(7, 0, -4), Color("6e4b48"))
	_barrel(root, Vector3(-11, 0, 5))
	_crate(root, Vector3(-9.5, 0, 5))
	_lamp(root, Vector3(12, 0, 9))
	_lamp(root, Vector3(-12, 0, 9), Color("e2c18a"))
	_box(root, "CityNoticeBoard", Vector3(0, 1.7, 11), Vector3(2.8, 2.4, 0.22), Color("503c32"), 4)

static func _build_forest(parent: Node3D, center: Vector3) -> void:
	var root := _root(parent, "AncientForestPropCollection", center)
	_cylinder(root, "FallenMossyLog", Vector3(7, 0.48, 8), 0.55, 5.5, Color("49382e"), 4, 9).rotation.z = PI * 0.5
	_sphere(root, "MossyStump", Vector3(-8, 0.48, 7), 0.65, Color("5a4938"), Vector3(1, 0.75, 1), 4)
	for i in range(8):
		var x := -6.0 + float(i) * 1.7
		_sphere(root, "MushroomCap", Vector3(x, 0.42, -8 + sin(float(i)) * 1.2), 0.28, Color("9b5d50"), Vector3(1.3, 0.55, 1), 3)
		_cylinder(root, "MushroomStem", Vector3(x, 0.22, -8 + sin(float(i)) * 1.2), 0.10, 0.38, Color("c7b99a"), 8, 7)
	for i in range(4):
		_box(root, "MossyGravestone", Vector3(-10 + i * 6.5, 0.95, 15), Vector3(1, 1.9, 0.32), Color("6d7568"), 10)

static func _build_cave(parent: Node3D, center: Vector3) -> void:
	var root := _root(parent, "EchoCavePropCollection", center)
	for i in range(9):
		var angle := TAU * float(i) / 9.0
		var pos := Vector3(cos(angle) * 7, 1, sin(angle) * 6)
		var crystal := _cone(root, "EchoCrystal", pos, 0.7 + float(i % 3) * 0.15, 2.8 + float(i % 3), Color("5b9d9e"), 13)
		crystal.rotation.z = -0.12 + float(i % 3) * 0.12
	for side in [-1.0, 1.0]:
		_lamp(root, Vector3(side * 8, 0, 0), Color("b5a078"))
		_box(root, "CaveObsidianPillar", Vector3(side * 5.5, 2.2, -7), Vector3(1, 4.4, 1), Color("30393b"), 9)

static func _build_dungeon(parent: Node3D, center: Vector3) -> void:
	var root := _root(parent, "AshDungeonPropCollection", center)
	for i in range(6):
		var x := -8.0 + float(i) * 3.2
		_cylinder(root, "IronBrazierBase", Vector3(x, 0.4, -9), 0.55, 0.8, Color("41484a"), 12, 8)
		_sphere(root, "BrazierFlame", Vector3(x, 1.35, -9), 0.32, Color("e78b50"), Vector3(0.8, 1.4, 0.8), 13, true)
	_box(root, "ObsidianAltar", Vector3(0, 0.8, 8), Vector3(5, 1.6, 3.4), Color("343638"), 9)
	_box(root, "BloodRunicSlab", Vector3(0, 1.68, 8), Vector3(3, 0.16, 2.1), Color("79343e"), 11)
	for side in [-1.0, 1.0]:
		_box(root, "CrimsonBanner", Vector3(side * 10, 4, 0.12), Vector3(2.2, 2.8, 0.10), Color("6f3039"), 11)

static func _build_castle(parent: Node3D, center: Vector3) -> void:
	var root := _root(parent, "SilentCastlePropCollection", center)
	for x in [-9.0, 9.0]:
		_box(root, "CastleBannerPole", Vector3(x, 5, 9), Vector3(0.18, 10, 0.18), Color("42494b"), 12)
		_box(root, "CastleCrimsonBanner", Vector3(x, 6.2, 9), Vector3(2.8, 3.2, 0.12), Color("71323c"), 11)
		_cylinder(root, "CastleBrazier", Vector3(x, 1, -8), 0.65, 1.8, Color("434a4c"), 12, 8)
		_sphere(root, "CastleFire", Vector3(x, 2.1, -8), 0.28, Color("e9a35d"), Vector3(0.8, 1.3, 0.8), 13, true)

static func _build_ruins(parent: Node3D, center: Vector3) -> void:
	var root := _root(parent, "ForgottenRuinsPropCollection", center)
	for i in range(5):
		var angle := TAU * float(i) / 5.0
		var pos := Vector3(cos(angle) * 10, 1.8, sin(angle) * 10)
		var column := _box(root, "MossyBrokenColumn", pos, Vector3(1.2, 3.6, 1.2), Color("74756a"), 10)
		column.rotation.z = -0.18 + float(i) * 0.07
	for i in range(3):
		_cone(root, "RunicMarker", Vector3(-4 + i * 4, 1.2, -12), 0.8, 2.4, Color("6a4245"), 11)


# Novos modelos 3D locais: malhas low-poly compostas, sem downloads ou créditos.
static func _build_bone_cart(parent: Node3D, position: Vector3) -> void:
	var root := _root(parent, "BoneCollectorCart", position)
	_box(root, "CartBed", Vector3(0, 0.95, 0), Vector3(2.7, 0.24, 1.65), Color("49382f"), 4)
	for x in [-1.05, 1.05]:
		var wheel := _cylinder(root, "IronBoundWheel", Vector3(x, 0.78, 0), 0.72, 0.16, Color("30383a"), 12, 10)
		wheel.rotation.z = PI * 0.5
		var hub := _cylinder(root, "WheelHub", Vector3(x * 1.08, 0.78, 0), 0.22, 0.2, Color("8b7658"), 4, 8)
		hub.rotation.z = PI * 0.5
	for z in [-0.72, 0.72]:
		_box(root, "CartSideRail", Vector3(0, 1.45, z), Vector3(2.8, 0.9, 0.16), Color("5a4030"), 4)
	for i in range(4):
		var bone := _cylinder(root, "CargoBone_%d" % i, Vector3(-0.75 + i * 0.5, 1.9 + (i % 2) * 0.12, 0), 0.12, 1.45, Color("c5b99d"), 8, 7)
		bone.rotation.z = 0.3 if i % 2 == 0 else -0.3
	_box(root, "CartHandleLeft", Vector3(1.65, 0.7, -0.42), Vector3(1.8, 0.12, 0.12), Color("49382f"), 4)
	_box(root, "CartHandleRight", Vector3(1.65, 0.7, 0.42), Vector3(1.8, 0.12, 0.12), Color("49382f"), 4)


static func _build_rune_circle(parent: Node3D, position: Vector3) -> void:
	var root := _root(parent, "WhisperingRuneCircle", position)
	for i in range(7):
		var angle := TAU * float(i) / 7.0
		var stone := _box(root, "StandingRuneStone_%d" % i, Vector3(cos(angle) * 3.2, 1.25, sin(angle) * 3.2), Vector3(0.85, 2.5 + float(i % 3) * 0.35, 0.42), Color("626d66"), 10)
		stone.rotation.y = -angle
		stone.rotation.z = -0.08 if i % 2 == 0 else 0.08
		_box(root, "StoneGlyph_%d" % i, Vector3(cos(angle) * 3.2, 1.35, sin(angle) * 3.2 + 0.24), Vector3(0.12, 0.65, 0.06), Color("75c9bb"), 13, true)
	_cylinder(root, "CircleFoundation", Vector3(0, 0.12, 0), 2.35, 0.22, Color("454e49"), 10, 12)
	_cone(root, "HeartCrystal", Vector3(0, 1.35, 0), 0.52, 2.2, Color("70cbbd"), 13)
	_sphere(root, "CrystalCore", Vector3(0, 2.15, 0), 0.22, Color("a1f2df"), Vector3.ONE, 13, true)


static func _build_cursed_well(parent: Node3D, position: Vector3) -> void:
	var root := _root(parent, "CursedStoneWell", position)
	_cylinder(root, "WellBase", Vector3(0, 0.25, 0), 2.0, 0.5, Color("505a56"), 10, 12)
	_cylinder(root, "WellWall", Vector3(0, 0.95, 0), 1.65, 1.0, Color("74786c"), 10, 12)
	_cylinder(root, "WellDarkOpening", Vector3(0, 1.48, 0), 1.18, 0.08, Color("171e20"), 9, 12)
	for x in [-1.72, 1.72]:
		_cylinder(root, "WellSupport", Vector3(x, 2.15, 0), 0.13, 2.2, Color("49382f"), 4, 7)
	_box(root, "WellCrossBeam", Vector3(0, 3.15, 0), Vector3(3.8, 0.18, 0.18), Color("49382f"), 4)
	_cylinder(root, "WellWinch", Vector3(0, 2.65, 0), 0.18, 0.65, Color("7e8580"), 12, 8)
	_box(root, "WellBucket", Vector3(0, 1.8, 0.55), Vector3(0.55, 0.62, 0.48), Color("5a4030"), 4)
	for i in range(5):
		_box(root, "WellRune_%d" % i, Vector3(-0.9 + i * 0.45, 0.98, 1.55), Vector3(0.12, 0.28, 0.05), Color("8b4b52"), 11, true)


static func _build_fallen_guardian(parent: Node3D, position: Vector3) -> void:
	var root := _root(parent, "FallenGuardianStatue", position)
	_box(root, "StatuePedestal", Vector3(0, 0.35, 0), Vector3(4.6, 0.7, 3.6), Color("555e59"), 10)
	_box(root, "GuardianTorso", Vector3(0, 2.25, 0), Vector3(1.45, 2.6, 0.9), Color("73786f"), 10)
	_sphere(root, "GuardianHelm", Vector3(0, 3.95, 0), 0.72, Color("858579"), Vector3(0.9, 1.1, 0.85), 10)
	_box(root, "GuardianShoulderLeft", Vector3(-1.05, 3.0, 0), Vector3(0.8, 0.75, 0.9), Color("626d66"), 10)
	_box(root, "GuardianShoulderRight", Vector3(1.05, 3.0, 0), Vector3(0.8, 0.75, 0.9), Color("626d66"), 10)
	var fallen_blade := _box(root, "FallenStoneBlade", Vector3(1.65, 1.0, 0.25), Vector3(0.34, 2.7, 0.18), Color("858d88"), 12)
	fallen_blade.rotation.z = -0.72
	_box(root, "BladeGuard", Vector3(1.35, 1.55, 0.25), Vector3(1.1, 0.16, 0.28), Color("a88a58"), 12)
	_sphere(root, "GuardianChestRune", Vector3(0, 2.45, 0.5), 0.2, Color("a04e55"), Vector3.ONE, 11, true)


static func _build_glacial_altar(parent: Node3D, position: Vector3) -> void:
	var root := _root(parent, "GlacialMemoryAltar", position)
	_cylinder(root, "IceAltarBase", Vector3(0, 0.28, 0), 3.2, 0.56, Color("596d76"), 8, 12)
	_cylinder(root, "FrostRing", Vector3(0, 0.62, 0), 2.55, 0.16, Color("9bbec8"), 8, 13, true)
	_box(root, "AltarPedestal", Vector3(0, 1.15, 0), Vector3(1.9, 1.1, 1.9), Color("718b94"), 10)
	_cone(root, "MemoryCrystal", Vector3(0, 2.55, 0), 0.82, 2.7, Color("a9e7f0"), 13)
	for i in range(6):
		var angle := TAU * float(i) / 6.0
		var shard := _cone(root, "FrostShard_%d" % i, Vector3(cos(angle) * 2.25, 1.35, sin(angle) * 2.25), 0.34, 1.55 + float(i % 2) * 0.45, Color("8bb7c3"), 13)
		shard.rotation.z = -0.12 if i % 2 == 0 else 0.12
		_box(root, "AltarGlyph_%d" % i, Vector3(cos(angle) * 2.62, 0.78, sin(angle) * 2.62), Vector3(0.16, 0.42, 0.08), Color("b8f0f2"), 13, true)


static func _build_crimson_rift_gate(parent: Node3D, position: Vector3) -> void:
	var root := _root(parent, "CrimsonRiftGate", position)
	for side in [-1.0, 1.0]:
		var pillar := _box(root, "RiftPillar", Vector3(side * 3.0, 3.0, 0), Vector3(0.9, 6.0, 1.0), Color("57454a"), 11)
		pillar.rotation.z = side * -0.08
		_cone(root, "PillarCap", Vector3(side * 3.0, 6.25, 0), 0.82, 1.0, Color("80616a"), 11)
	_box(root, "RiftLintel", Vector3(0, 6.1, 0), Vector3(6.8, 0.85, 1.15), Color("665057"), 11)
	_box(root, "RiftKeystone", Vector3(0, 6.15, 0.66), Vector3(0.8, 1.05, 0.18), Color("b34d58"), 11, true)
	_box(root, "RiftThreshold", Vector3(0, 0.16, 0), Vector3(7.2, 0.32, 2.0), Color("463b40"), 11)
	for i in range(5):
		var rune := _sphere(root, "RiftRune_%d" % i, Vector3(-1.6 + float(i) * 0.8, 3.0 + float(i % 2) * 0.8, 0.68), 0.16, Color("d56b70"), Vector3(1.0, 1.0, 0.55), 11, true)
		rune.scale = Vector3.ONE
