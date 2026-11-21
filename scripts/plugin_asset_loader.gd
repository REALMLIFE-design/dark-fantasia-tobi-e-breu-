extends RefCounted
class_name PluginAssetLoader

const AQUEDUCT_SHADER := preload("res://scripts/aqueduct_stone.gdshader")
const BASE_COLOR_PATH := "res://assets/plugin_imports/aqueduct/base_color.png"
const NORMAL_PATH := "res://assets/plugin_imports/aqueduct/normal.png"
const ROUGHNESS_PATH := "res://assets/plugin_imports/aqueduct/roughness.png"
const AO_PATH := "res://assets/plugin_imports/aqueduct/ao.png"
const MESHY_GATE_PATH := "res://assets/plugin_imports/meshy/gothic_gate.glb"


static func apply_aqueduct_stone(target: MeshInstance3D) -> bool:
	if target == null or target.mesh == null:
		return false
	for texture_path in [BASE_COLOR_PATH, NORMAL_PATH, ROUGHNESS_PATH, AO_PATH]:
		if not FileAccess.file_exists(texture_path):
			return false
	var material := ShaderMaterial.new()
	material.shader = AQUEDUCT_SHADER
	material.set_shader_parameter("base_color_texture", load(BASE_COLOR_PATH))
	material.set_shader_parameter("normal_texture", load(NORMAL_PATH))
	material.set_shader_parameter("roughness_texture", load(ROUGHNESS_PATH))
	material.set_shader_parameter("ao_texture", load(AO_PATH))
	target.material_override = material
	return true


static func load_optional_scene(asset_key: String) -> PackedScene:
	if not PluginAssetCatalog.ASSETS.has(asset_key):
		return null
	var asset_path: String = PluginAssetCatalog.ASSETS[asset_key]
	if not ResourceLoader.exists(asset_path):
		return null
	var packed_scene := load(asset_path) as PackedScene
	if packed_scene == null:
		push_warning("O asset opcional não pôde ser carregado: " + asset_key)
	return packed_scene


static func load_meshy_asset(parent: Node3D, asset_key: String, position: Vector3, scale: Vector3 = Vector3.ONE) -> Node3D:
	if parent == null or not asset_key.begins_with("meshy_"):
		return null
	var packed_scene := load_optional_scene(asset_key)
	if packed_scene == null:
		return null
	var instance := packed_scene.instantiate() as Node3D
	if instance == null:
		push_warning("A raiz do asset Meshy não é Node3D: " + asset_key)
		return null
	instance.name = asset_key
	instance.position = position
	instance.scale = scale
	parent.add_child(instance)
	return instance


static func load_pinoc_motion(asset_key: String) -> PackedScene:
	if not asset_key.begins_with("pinoc_") or asset_key == "pinoc_forest_splat":
		return null
	return load_optional_scene(asset_key)


static func load_meshy_gate(parent: Node3D, position: Vector3, scale: Vector3 = Vector3.ONE) -> Node3D:
	return load_meshy_asset(parent, "meshy_gate", position, scale)
