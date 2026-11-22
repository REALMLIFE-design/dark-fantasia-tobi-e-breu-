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
	_build_swamp_witch_cauldron(parent, Vector3(9, 0, -94))
	_build_drowned_bell_marker(parent, Vector3(61, 0, -132))
	_build_golden_plain_windmill(parent, Vector3(18, 0, 238))
	_build_whispercap_grove(parent, Vector3(105, 0, -151))
	_build_echo_cave_crystals(parent, Vector3(-228, 0, -248))
	_build_tobi_cat(parent, Vector3(4.0, 0.0, 3.5))
	_build_waystone_shrine(parent, Vector3(-92, 0, 130))
	_build_hunters_camp(parent, Vector3(-142, 0, 62))
	_build_river_bridge(parent, Vector3(61, 0, -156))
	_build_watchtower(parent, Vector3(200, 0, 68))
	_build_blacksmith_forge(parent, Vector3(-121, 0, 96))
	_build_alchemist_workshop(parent, Vector3(188, 0, 100))

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
	mesh.radial_segments = 24
	mesh.rings = 16
	var instance := _mesh(parent, node_name, mesh, pos, color, mode, glow)
	instance.scale = scale
	return instance

static func _cylinder(parent: Node3D, node_name: String, pos: Vector3, radius: float, height: float, color: Color, mode := 8, sides := 8) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = maxi(sides, 18)
	return _mesh(parent, node_name, mesh, pos, color, mode)

static func _cone(parent: Node3D, node_name: String, pos: Vector3, radius: float, height: float, color: Color, mode := 8) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.0
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 16
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
	var frost_ring := _cylinder(root, "FrostRing", Vector3(0, 0.62, 0), 2.55, 0.16, Color("9bbec8"), 8, 13)
	frost_ring.material_override = _material(Color("9bbec8"), 13, true)
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


static func _build_swamp_witch_cauldron(parent: Node3D, position: Vector3) -> void:
	var root := _root(parent, "SwampWitchCauldron", position)
	_cylinder(root, "CauldronBody", Vector3(0, 1.05, 0), 1.0, 1.15, Color("303b36"), 10, 9)
	_cylinder(root, "CauldronRim", Vector3(0, 1.68, 0), 1.12, 0.18, Color("68766a"), 10, 9)
	_cylinder(root, "BubblingToxicBrew", Vector3(0, 1.76, 0), 0.88, 0.08, Color("83b85b"), 13, 12)
	for i in range(3):
		var angle := TAU * float(i) / 3.0
		var leg := _box(root, "CauldronLeg_%d" % i, Vector3(cos(angle) * 0.82, 0.42, sin(angle) * 0.82), Vector3(0.18, 0.9, 0.18), Color("51463a"), 4)
		leg.rotation.z = cos(angle) * 0.16
	for i in range(4):
		_sphere(root, "BrewBubble_%d" % i, Vector3(-0.48 + float(i) * 0.32, 1.98 + float(i % 2) * 0.12, 0.12), 0.13, Color("b4e47a"), Vector3.ONE, 13, true)
	for side in [-1.0, 1.0]:
		_box(root, "CauldronHandleMount", Vector3(side * 1.02, 1.48, 0), Vector3(0.16, 0.42, 0.16), Color("79674c"), 4)


static func _build_drowned_bell_marker(parent: Node3D, position: Vector3) -> void:
	var root := _root(parent, "DrownedBellMarker", position)
	_cylinder(root, "BellStoneBase", Vector3(0, 0.22, 0), 2.2, 0.44, Color("56615e"), 10, 10)
	for side in [-1.0, 1.0]:
		var pillar := _box(root, "BellPillar", Vector3(side * 1.35, 2.0, 0), Vector3(0.42, 3.6, 0.48), Color("68736d"), 10)
		pillar.rotation.z = side * -0.06
	_box(root, "BellCrossbeam", Vector3(0, 3.82, 0), Vector3(3.2, 0.42, 0.56), Color("737d74"), 10)
	_cylinder(root, "BellHanger", Vector3(0, 3.28, 0), 0.09, 0.72, Color("8d8067"), 4, 8)
	var bell := _sphere(root, "DrownedBell", Vector3(0, 2.76, 0), 0.52, Color("a18a61"), Vector3(1.0, 1.1, 0.85), 12)
	var clapper := _cylinder(root, "BellClapper", Vector3(0, 2.2, 0), 0.12, 0.38, Color("c5b18a"), 4, 7)
	clapper.rotation.z = PI
	_sphere(root, "BellRune", Vector3(0, 2.8, 0.46), 0.13, Color("79c9bb"), Vector3.ONE, 13, true)


static func _build_golden_plain_windmill(parent: Node3D, position: Vector3) -> void:
	var root := _root(parent, "GoldenPlainWindmill", position)
	var tower := _cone(root, "WindmillStoneTower", Vector3(0, 3.0, 0), 1.65, 6.0, Color("9a8b70"), 10)
	tower.scale = Vector3(1.0, 1.0, 0.82)
	_cylinder(root, "WindmillRoof", Vector3(0, 6.1, 0), 1.8, 0.55, Color("51463c"), 4, 8)
	_box(root, "WindmillDoor", Vector3(0, 1.0, 1.34), Vector3(0.8, 1.8, 0.12), Color("44372e"), 4)
	_sphere(root, "WindmillHub", Vector3(0, 4.55, 1.52), 0.32, Color("b18b55"), Vector3.ONE, 10)
	for i in range(4):
		var blade := _box(root, "WindmillBlade_%d" % i, Vector3(0, 4.55, 1.55), Vector3(0.28, 3.0, 0.16), Color("c8b995"), 10)
		blade.rotation.z = float(i) * PI * 0.5
	_box(root, "WindmillTail", Vector3(0, 6.0, -1.3), Vector3(0.22, 0.22, 2.5), Color("75634c"), 4)


static func _build_whispercap_grove(parent: Node3D, position: Vector3) -> void:
	var root := _root(parent, "WhispercapGrove", position)
	for i in range(5):
		var angle := TAU * float(i) / 5.0
		var radius := 1.8 + float(i % 2) * 1.0
		var x := cos(angle) * radius
		var z := sin(angle) * radius
		var stem_height := 0.9 + float(i % 3) * 0.28
		_cylinder(root, "WhispercapStem_%d" % i, Vector3(x, stem_height * 0.5, z), 0.18, stem_height, Color("d0c5a9"), 10, 7)
		var cap := _sphere(root, "WhispercapTop_%d" % i, Vector3(x, stem_height + 0.12, z), 0.62 + float(i % 2) * 0.12, Color("70536e"), Vector3(1.0, 0.52, 1.0), 11)
		cap.rotation.y = angle
		_sphere(root, "WhispercapGlow_%d" % i, Vector3(x, stem_height + 0.08, z + 0.34), 0.12, Color("b8e7bb"), Vector3.ONE, 13, true)
	for i in range(3):
		_sphere(root, "ForestGlowMote_%d" % i, Vector3(-2.0 + float(i) * 2.0, 2.2 + float(i % 2) * 0.45, -1.0), 0.1, Color("9de6c4"), Vector3.ONE, 13, true)


static func _build_echo_cave_crystals(parent: Node3D, position: Vector3) -> void:
	var root := _root(parent, "EchoCaveCrystalCluster", position)
	for i in range(7):
		var angle := TAU * float(i) / 7.0
		var radius := 1.1 + float(i % 3) * 0.55
		var height := 1.7 + float(i % 4) * 0.65
		var crystal := _cone(root, "EchoCrystal_%d" % i, Vector3(cos(angle) * radius, height * 0.5, sin(angle) * radius), 0.42 + float(i % 2) * 0.12, height, Color("7a9db4"), 13)
		crystal.rotation.z = -0.12 if i % 2 == 0 else 0.12
		crystal.rotation.x = angle * 0.08
		_box(root, "CrystalLight_%d" % i, Vector3(cos(angle) * radius, height * 0.45, sin(angle) * radius + 0.28), Vector3(0.09, height * 0.48, 0.08), Color("a9e4ee"), 13, true)
	_sphere(root, "EchoCore", Vector3(0, 0.6, 0), 0.32, Color("b8f0ef"), Vector3.ONE, 13, true)


static func _build_tobi_cat(parent: Node3D, position: Vector3) -> void:
	# Gato companheiro de Tobi: pose sentada, silhueta legivel e poucas pecas para mobile.
	var root := _root(parent, "TobiCatCompanion", position)
	root.rotation.y = -0.35
	# Corpo e peito
	_sphere(root, "CatBody", Vector3(0, 0.78, -0.28), 0.62, Color("343b3c"), Vector3(0.88, 0.82, 1.18), 10)
	_sphere(root, "CatChest", Vector3(0, 0.78, 0.24), 0.43, Color("b7ad98"), Vector3(0.78, 1.05, 0.62), 8)
	# Cabeca, bochechas e focinho
	_sphere(root, "CatHead", Vector3(0, 1.48, 0.48), 0.53, Color("42494a"), Vector3(1.0, 0.94, 0.9), 10)
	_sphere(root, "CatMuzzleLeft", Vector3(-0.16, 1.32, 0.88), 0.19, Color("d0c5ad"), Vector3(1.0, 0.72, 0.72), 8)
	_sphere(root, "CatMuzzleRight", Vector3(0.16, 1.32, 0.88), 0.19, Color("d0c5ad"), Vector3(1.0, 0.72, 0.72), 8)
	_sphere(root, "CatNose", Vector3(0, 1.39, 1.04), 0.075, Color("9c6665"), Vector3(1.0, 0.75, 0.7), 8)
	# Orelhas triangulares
	for side in [-1.0, 1.0]:
		var ear := _cone(root, "CatEar", Vector3(side * 0.36, 1.99, 0.42), 0.22, 0.62, Color("42494a"), 8)
		ear.rotation.z = side * -0.18
		_cone(root, "CatInnerEar", Vector3(side * 0.36, 1.98, 0.56), 0.105, 0.38, Color("a97878"), 8)
		_sphere(root, "CatEye", Vector3(side * 0.22, 1.54, 0.91), 0.085, Color("e8c66f"), Vector3(0.82, 1.0, 0.48), 13, true)
		_sphere(root, "CatPupil", Vector3(side * 0.22, 1.54, 0.96), 0.035, Color("171b1b"), Vector3(0.7, 1.2, 0.45), 8)
		# Bigodes discretos
		for whisker in range(2):
			var line := _box(root, "CatWhisker", Vector3(side * 0.36, 1.31 - float(whisker) * 0.09, 0.91), Vector3(0.34, 0.018, 0.018), Color("d6d0bd"), 8)
			line.rotation.y = side * 0.12
	# Patas dianteiras e traseiras em pose sentada
	for side in [-1.0, 1.0]:
		_cylinder(root, "CatFrontLeg", Vector3(side * 0.27, 0.39, 0.36), 0.14, 0.62, Color("343b3c"), 8, 7)
		_sphere(root, "CatFrontPaw", Vector3(side * 0.27, 0.12, 0.48), 0.19, Color("b7ad98"), Vector3(1.0, 0.58, 1.25), 8)
		_sphere(root, "CatHindLeg", Vector3(side * 0.38, 0.34, -0.55), 0.31, Color("343b3c"), Vector3(1.0, 0.86, 1.1), 8)
		_sphere(root, "CatHindPaw", Vector3(side * 0.38, 0.12, -0.38), 0.2, Color("b7ad98"), Vector3(1.0, 0.55, 1.2), 8)
	# Cauda curva, feita de segmentos leves
	for i in range(5):
		var tail_pos := Vector3(0.0 + sin(float(i) * 0.48) * 0.38, 0.72 + float(i) * 0.19, -0.82 - float(i) * 0.22)
		_sphere(root, "CatTailSegment_%d" % i, tail_pos, 0.19 - float(i) * 0.018, Color("343b3c"), Vector3(0.92, 1.0, 1.0), 8)
	# Pelagem em tufos discretos, sobrancelhas, dedos e detalhes da coleira
	for side in [-1.0, 1.0]:
		_sphere(root, "CatCheekFur", Vector3(side * 0.42, 1.34, 0.57), 0.19, Color("4c5554"), Vector3(0.75, 0.8, 0.75), 8)
		var brow := _box(root, "CatBrow", Vector3(side * 0.22, 1.68, 0.88), Vector3(0.22, 0.045, 0.055), Color("272e30"), 8)
		brow.rotation.z = side * -0.12
		for toe in range(3):
			_sphere(root, "CatToe", Vector3(side * 0.27 + (float(toe) - 1.0) * 0.085, 0.105, 0.59), 0.055, Color("c7baa2"), Vector3(0.72, 0.65, 1.0), 8)
	# Tufo de peito e pequenas mechas da silhueta
	for i in range(5):
		var tuft := _cone(root, "ChestFurTuft_%d" % i, Vector3(-0.28 + float(i) * 0.14, 0.58, 0.48), 0.10, 0.30, Color("c4baa7"), 8)
		tuft.rotation.z = PI
	# Coleira vinho com rebites e medalhão em camadas
	_cylinder(root, "CatCrimsonCollar", Vector3(0, 1.08, 0.55), 0.34, 0.11, Color("7e3945"), 11, 18)
	for side in [-1.0, 1.0]:
		_sphere(root, "CollarGoldStud", Vector3(side * 0.25, 1.08, 0.79), 0.045, Color("e1c17b"), Vector3.ONE, 13, true)
	_sphere(root, "CatGoldenCharm", Vector3(0, 0.98, 0.88), 0.105, Color("d2ad69"), Vector3(0.85, 1.1, 0.55), 13, true)
	_sphere(root, "CatCharmInset", Vector3(0, 0.98, 0.94), 0.045, Color("7ac9bd"), Vector3(0.8, 1.0, 0.4), 13, true)


# Expansao de pontos de interesse: marcos de viagem e estruturas exploraveis.
static func _build_waystone_shrine(parent: Node3D, position: Vector3) -> void:
	var root := _root(parent, "WaystoneShrine", position)
	_cylinder(root, "ShrineFoundation", Vector3(0, 0.18, 0), 2.6, 0.36, Color("555d58"), 10, 24)
	_box(root, "ShrineStep", Vector3(0, 0.42, 0.35), Vector3(2.8, 0.28, 1.6), Color("777a6d"), 10)
	for side in [-1.0, 1.0]:
		var pillar := _box(root, "ShrinePillar", Vector3(side * 1.45, 2.0, -0.15), Vector3(0.42, 3.2, 0.48), Color("77796e"), 10)
		pillar.rotation.z = side * -0.035
		_box(root, "PillarCapital", Vector3(side * 1.45, 3.72, -0.15), Vector3(0.72, 0.28, 0.76), Color("9a927d"), 10)
	_box(root, "ShrineLintel", Vector3(0, 3.78, -0.15), Vector3(3.35, 0.42, 0.65), Color("77796e"), 10)
	_cylinder(root, "WaystonePedestal", Vector3(0, 0.95, 0.65), 0.72, 0.8, Color("4c5754"), 10, 20)
	_cone(root, "WaystoneCrystal", Vector3(0, 2.05, 0.65), 0.42, 1.55, Color("8bc8b7"), 13)
	_sphere(root, "WaystoneCore", Vector3(0, 2.15, 0.65), 0.16, Color("b5f4dc"), Vector3.ONE, 13, true)
	for i in range(5):
		_box(root, "ShrineGlyph_%d" % i, Vector3(-0.8 + float(i) * 0.4, 1.35, 1.38), Vector3(0.09, 0.32, 0.05), Color("82c9b4"), 13, true)


static func _build_hunters_camp(parent: Node3D, position: Vector3) -> void:
	var root := _root(parent, "HuntersRestCamp", position)
	for side in [-1.0, 1.0]:
		var pole := _cylinder(root, "TentPole", Vector3(side * 1.35, 1.25, -0.25), 0.075, 2.5, Color("5b4433"), 4, 16)
		pole.rotation.z = side * 0.18
	var canopy := _cone(root, "WeatheredCanvasTent", Vector3(0, 2.1, -0.25), 1.85, 2.1, Color("77705c"), 7)
	canopy.rotation.z = PI
	_box(root, "TentGroundCloth", Vector3(0, 0.08, -0.25), Vector3(2.7, 0.08, 2.3), Color("554d40"), 4)
	_cylinder(root, "CampfireStoneRing", Vector3(2.8, 0.22, 1.25), 0.72, 0.34, Color("77746a"), 10, 18)
	_sphere(root, "CampfireEmbers", Vector3(2.8, 0.48, 1.25), 0.35, Color("e58a4e"), Vector3(1.0, 0.35, 1.0), 13, true)
	for i in range(3):
		var log := _cylinder(root, "CampfireLog", Vector3(2.8, 0.42, 1.25), 0.12, 1.1, Color("49362b"), 4, 12)
		log.rotation.y = float(i) * PI / 3.0
		log.rotation.z = PI * 0.5
	_box(root, "SupplyChest", Vector3(-2.35, 0.52, 0.7), Vector3(1.0, 0.82, 0.85), Color("604631"), 4)
	_box(root, "ChestIronBand", Vector3(-2.35, 0.58, 1.14), Vector3(1.02, 0.12, 0.08), Color("777e7c"), 12)
	for side in [-1.0, 1.0]:
		_cylinder(root, "CampTorchPost", Vector3(side * 3.5, 1.0, -1.8), 0.07, 2.0, Color("49382f"), 4, 12)
		_sphere(root, "CampTorchFlame", Vector3(side * 3.5, 2.08, -1.8), 0.17, Color("e8a15e"), Vector3(0.8, 1.2, 0.8), 13, true)


static func _build_river_bridge(parent: Node3D, position: Vector3) -> void:
	var root := _root(parent, "SilverRiverStoneBridge", position)
	_box(root, "BridgeDeck", Vector3(0, 0.55, 0), Vector3(10.0, 0.42, 4.2), Color("77796f"), 10)
	for i in range(9):
		var x := -4.4 + float(i) * 1.1
		_box(root, "BridgePaving_%d" % i, Vector3(x, 0.79, 0), Vector3(0.98, 0.08, 3.95), Color("989486"), 10)
	for side in [-1.0, 1.0]:
		_box(root, "BridgeRailingBase", Vector3(0, 1.05, side * 1.92), Vector3(10.0, 0.28, 0.28), Color("555e59"), 10)
		for i in range(6):
			_box(root, "BridgeBaluster", Vector3(-4.2 + float(i) * 1.68, 1.48, side * 1.92), Vector3(0.2, 0.9, 0.22), Color("77796f"), 10)
		_box(root, "BridgeHandrail", Vector3(0, 1.98, side * 1.92), Vector3(10.2, 0.2, 0.34), Color("696e66"), 10)
	for side in [-1.0, 1.0]:
		_box(root, "BridgeEndPost", Vector3(side * 4.75, 1.1, 0), Vector3(0.55, 1.1, 4.4), Color("666e67"), 10)
	for i in range(3):
		var keystone := _box(root, "BridgeRunestone_%d" % i, Vector3(-2.4 + float(i) * 2.4, 0.91, 0), Vector3(0.16, 0.12, 2.8), Color("86b8aa"), 13, true)
		keystone.rotation.y = 0.0


static func _build_watchtower(parent: Node3D, position: Vector3) -> void:
	var root := _root(parent, "FallenWatchWatchtower", position)
	_cylinder(root, "TowerStoneFoot", Vector3(0, 0.3, 0), 2.0, 0.6, Color("5b625d"), 10, 24)
	for side in [-1.0, 1.0]:
		for depth in [-1.0, 1.0]:
			_box(root, "TowerTimber", Vector3(side * 1.1, 4.1, depth * 1.1), Vector3(0.22, 7.6, 0.22), Color("49372c"), 4)
			_box(root, "TowerBrace", Vector3(side * 0.72, 2.2, depth * 1.1), Vector3(1.0, 0.18, 0.18), Color("5c4433"), 4)
	_box(root, "TowerPlatform", Vector3(0, 4.3, 0), Vector3(3.1, 0.32, 3.1), Color("70553b"), 4)
	_box(root, "TowerParapetNorth", Vector3(0, 5.0, -1.42), Vector3(3.1, 1.1, 0.22), Color("686d66"), 10)
	_box(root, "TowerParapetSouth", Vector3(0, 5.0, 1.42), Vector3(3.1, 1.1, 0.22), Color("686d66"), 10)
	for side in [-1.0, 1.0]:
		_box(root, "TowerParapetSide", Vector3(side * 1.42, 5.0, 0), Vector3(0.22, 1.1, 2.8), Color("686d66"), 10)
	_cylinder(root, "TowerRoofSupport", Vector3(0, 6.1, 0), 1.75, 0.22, Color("49382f"), 4, 16)
	_cone(root, "TowerRoof", Vector3(0, 7.15, 0), 1.8, 2.0, Color("554b43"), 4)
	_box(root, "TowerBannerPole", Vector3(0, 8.5, 0), Vector3(0.12, 2.0, 0.12), Color("4c5050"), 12)
	_box(root, "TowerBanner", Vector3(0.65, 8.25, 0), Vector3(1.2, 1.25, 0.08), Color("733b43"), 11)


# Oficinas regionais: cenografia detalhada, sem alterar economia ou interacoes.
static func _build_blacksmith_forge(parent: Node3D, position: Vector3) -> void:
	var root := _root(parent, "OakVillageBlacksmithForge", position)
	# Base de pedra e lareira de forja
	_box(root, "ForgeStoneFoundation", Vector3(0, 0.22, 0), Vector3(5.2, 0.44, 3.8), Color("555a54"), 10)
	_box(root, "ForgeHearthBody", Vector3(0, 1.15, -0.75), Vector3(2.8, 1.9, 1.45), Color("4a4842"), 10)
	_box(root, "ForgeMouthDark", Vector3(0, 0.92, 0.02), Vector3(1.45, 1.05, 0.12), Color("171b1b"), 9)
	_box(root, "ForgeEmberBed", Vector3(0, 0.72, 0.12), Vector3(1.05, 0.18, 0.12), Color("d47743"), 13, true)
	for side in [-1.0, 1.0]:
		_box(root, "ForgeStonePier", Vector3(side * 1.18, 1.75, -0.7), Vector3(0.34, 2.9, 1.35), Color("686b61"), 10)
		_box(root, "ForgeIronBracket", Vector3(side * 1.0, 2.35, 0.08), Vector3(0.18, 0.12, 0.85), Color("353b3d"), 12)
	# Bigorna, martelo e tenazes
	_box(root, "AnvilFoot", Vector3(1.45, 0.48, 0.78), Vector3(0.75, 0.42, 0.7), Color("493d32"), 4)
	_cylinder(root, "AnvilWaist", Vector3(1.45, 0.88, 0.78), 0.25, 0.55, Color("51595b"), 12, 24)
	_box(root, "AnvilFace", Vector3(1.45, 1.22, 0.78), Vector3(1.25, 0.22, 0.62), Color("788184"), 12)
	_cone(root, "AnvilHorn", Vector3(2.12, 1.22, 0.78), 0.22, 0.72, Color("899294"), 12)
	var hammer := _box(root, "SmithHammerHead", Vector3(-1.45, 1.28, 0.7), Vector3(0.72, 0.22, 0.25), Color("717a7b"), 12)
	hammer.rotation.z = -0.12
	_cylinder(root, "SmithHammerHandle", Vector3(-1.45, 0.78, 0.7), 0.07, 0.9, Color("76553a"), 4, 16)
	# Suportes de armas e placas de metal
	for i in range(3):
		var blade := _box(root, "DisplayBlade_%d" % i, Vector3(-2.05 + float(i) * 0.42, 1.28, -1.45), Vector3(0.08, 1.35, 0.12), Color("9aa4a2"), 12)
		blade.rotation.z = -0.12 + float(i) * 0.12
		_box(root, "BladeGrip_%d" % i, Vector3(-2.05 + float(i) * 0.42, 0.58, -1.45), Vector3(0.14, 0.32, 0.16), Color("674631"), 4)
	# Chaminé e faíscas decorativas
	_box(root, "ForgeChimney", Vector3(0, 3.25, -1.18), Vector3(1.2, 2.2, 1.1), Color("555750"), 10)
	_box(root, "ChimneyCap", Vector3(0, 4.42, -1.18), Vector3(1.5, 0.22, 1.4), Color("393d3b"), 10)
	for i in range(4):
		_sphere(root, "ForgeSpark_%d" % i, Vector3(-0.32 + float(i) * 0.2, 1.05 + float(i % 2) * 0.3, 0.24), 0.045, Color("ffb56d"), Vector3.ONE, 13, true)
	_box(root, "CoalSack", Vector3(2.0, 0.52, -0.9), Vector3(0.72, 0.72, 0.62), Color("51463b"), 4)
	_box(root, "CoalSackTie", Vector3(2.0, 0.88, -0.9), Vector3(0.32, 0.12, 0.34), Color("8a765c"), 4)


static func _build_alchemist_workshop(parent: Node3D, position: Vector3) -> void:
	var root := _root(parent, "StoneCityAlchemistWorkshop", position)
	_box(root, "AlchemyFloor", Vector3(0, 0.16, 0), Vector3(5.6, 0.32, 4.2), Color("555e58"), 10)
	_box(root, "AlchemyWorkbench", Vector3(0, 1.05, 0.2), Vector3(3.8, 0.22, 1.25), Color("604833"), 4)
	for side in [-1.0, 1.0]:
		for depth in [-1.0, 1.0]:
			_box(root, "WorkbenchLeg", Vector3(side * 1.55, 0.58, 0.62 + depth * 0.22), Vector3(0.16, 1.05, 0.16), Color("49382f"), 4)
	# Frascos de vidro com líquidos de cores distintas
	var bottle_colors := [Color("6fc3a0"), Color("b86c91"), Color("76a9d6"), Color("d5a85f")]
	for i in range(4):
		var x := -1.25 + float(i) * 0.82
		_cylinder(root, "PotionBottleBody_%d" % i, Vector3(x, 1.48, 0.12), 0.22, 0.58, Color("a9b8ad"), 13, 20)
		_cylinder(root, "PotionLiquid_%d" % i, Vector3(x, 1.43, 0.12), 0.18, 0.34, bottle_colors[i], 13, 20)
		_cylinder(root, "PotionNeck_%d" % i, Vector3(x, 1.88, 0.12), 0.09, 0.24, Color("9ca99f"), 13, 16)
		_cylinder(root, "PotionCork_%d" % i, Vector3(x, 2.04, 0.12), 0.105, 0.12, Color("8a6240"), 4, 12)
	# Caldeirao de mistura e suporte de aquecimento
	_cylinder(root, "MixingCauldron", Vector3(1.2, 0.78, -1.25), 0.62, 0.78, Color("343d3b"), 10, 24)
	_cylinder(root, "CauldronRim", Vector3(1.2, 1.2, -1.25), 0.69, 0.14, Color("78817a"), 12, 24)
	_cylinder(root, "PotionSurface", Vector3(1.2, 1.27, -1.25), 0.54, 0.06, Color("74b98a"), 13, 24)
	for i in range(3):
		var leg := _box(root, "CauldronStandLeg_%d" % i, Vector3(1.2 + cos(TAU * float(i) / 3.0) * 0.5, 0.32, -1.25 + sin(TAU * float(i) / 3.0) * 0.5), Vector3(0.12, 0.62, 0.12), Color("51463b"), 4)
		leg.rotation.z = 0.08
	# Prateleira de ingredientes, livros e cristais
	_box(root, "IngredientShelf", Vector3(-1.55, 2.05, -1.35), Vector3(1.25, 0.16, 0.5), Color("674c35"), 4)
	for i in range(3):
		_sphere(root, "IngredientJar_%d" % i, Vector3(-1.92 + float(i) * 0.38, 2.42, -1.35), 0.15, bottle_colors[i], Vector3(0.9, 1.25, 0.9), 13, true)
	_box(root, "Spellbook", Vector3(-1.3, 1.28, 0.42), Vector3(0.72, 0.12, 0.55), Color("563b4b"), 11)
	_box(root, "SpellbookClasp", Vector3(-1.3, 1.36, 0.7), Vector3(0.08, 0.08, 0.05), Color("d3b16d"), 12, true)
	_cone(root, "FocusCrystal", Vector3(2.15, 1.72, 0.38), 0.28, 1.05, Color("8ac9c1"), 13)
	_sphere(root, "FocusCrystalGlow", Vector3(2.15, 2.15, 0.38), 0.12, Color("b4f4dc"), Vector3.ONE, 13, true)
