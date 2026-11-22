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



static func download_and_load_plugin_asset(parent: Node3D, asset_key: String, position: Vector3, scale: Vector3 = Vector3.ONE) -> void:
	if parent == null or not PluginAssetCatalog.DOWNLOAD_URLS.has(asset_key):
		return
	var target_path: String = PluginAssetCatalog.ASSETS.get(asset_key, "")
	if target_path.is_empty():
		return
	if FileAccess.file_exists(target_path):
		_load_downloaded_glb(parent, asset_key, target_path, position, scale)
		return
	var directory := target_path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	var request := HTTPRequest.new()
	request.timeout = 120.0
	parent.add_child(request)
	request.request_completed.connect(func(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
		request.queue_free()
		if result != HTTPRequest.RESULT_SUCCESS or response_code != 200 or body.is_empty():
			push_warning("Falha ao baixar asset do plugin: " + asset_key)
			return
		var file := FileAccess.open(target_path, FileAccess.WRITE)
		if file == null:
			push_warning("Não foi possível salvar asset: " + target_path)
			return
		file.store_buffer(body)
		file.close()
		_load_downloaded_glb(parent, asset_key, target_path, position, scale)
	)
	var error := request.request(PluginAssetCatalog.get_download_url(asset_key))
	if error != OK:
		request.queue_free()
		push_warning("Não foi possível iniciar download do asset: " + asset_key)


static func _load_downloaded_glb(parent: Node3D, asset_key: String, path: String, position: Vector3, scale: Vector3) -> void:
	var document := GLTFDocument.new()
	var state := GLTFState.new()
	var error := document.append_from_file(path, state)
	if error != OK:
		push_warning("GLB inválido para asset: " + asset_key)
		return
	var instance := document.generate_scene(state)
	if instance == null:
		push_warning("Não foi possível montar a cena GLB: " + asset_key)
		return
	instance.name = asset_key
	instance.position = position
	instance.scale = scale
	parent.add_child(instance)


static func load_meshy_gate(parent: Node3D, position: Vector3, scale: Vector3 = Vector3.ONE) -> Node3D:
	return load_meshy_asset(parent, "meshy_gate", position, scale)
