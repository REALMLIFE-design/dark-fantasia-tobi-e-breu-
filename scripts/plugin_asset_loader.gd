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


static func load_meshy_gate(parent: Node3D, position: Vector3, scale: Vector3 = Vector3.ONE) -> Node3D:
	if parent == null or not ResourceLoader.exists(MESHY_GATE_PATH):
		return null
	var packed_scene := load(MESHY_GATE_PATH) as PackedScene
	if packed_scene == null:
		push_warning("O GLB do portão Meshy não pôde ser carregado como PackedScene.")
		return null
	var instance := packed_scene.instantiate() as Node3D
	if instance == null:
		push_warning("A raiz do GLB do portão Meshy não é Node3D.")
		return null
	instance.name = "MeshyGothicGate"
	instance.position = position
	instance.scale = scale
	parent.add_child(instance)
	return instance
