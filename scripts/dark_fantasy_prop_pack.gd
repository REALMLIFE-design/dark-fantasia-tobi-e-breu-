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
