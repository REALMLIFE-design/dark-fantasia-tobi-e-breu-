extends RefCounted
class_name PluginAssetLoader

const AQUEDUCT_SHADER := preload("res://scripts/aqueduct_stone.gdshader")
const PROCEDURAL_FORGE = preload("res://scripts/procedural_asset_forge.gd")
const BASE_COLOR_PATH := "res://assets/plugin_imports/aqueduct/base_color.png"
const NORMAL_PATH := "res://assets/plugin_imports/aqueduct/normal.png"
const ROUGHNESS_PATH := "res://assets/plugin_imports/aqueduct/roughness.png"
const AO_PATH := "res://assets/plugin_imports/aqueduct/ao.png"
const MESHY_GATE_PATH := "res://assets/plugin_imports/meshy/gothic_gate.glb"


static func apply_aqueduct_stone(target: MeshInstance3D) -> bool:
	if target == null or target.mesh == null:
		return false
	var source_material := target.material_override as StandardMaterial3D
	if source_material == null and target.mesh.get_surface_count() > 0:
		source_material = target.get_active_material(0) as StandardMaterial3D
	var has_aqueduct_maps := true
	for texture_path in [BASE_COLOR_PATH, NORMAL_PATH, ROUGHNESS_PATH, AO_PATH]:
		if not FileAccess.file_exists(texture_path):
			has_aqueduct_maps = false
	var material := _make_aqueduct_material(source_material, 0.22)
	if has_aqueduct_maps:
		material.set_shader_parameter("has_base_color_texture", true)
		material.set_shader_parameter("has_normal_texture", true)
		material.set_shader_parameter("has_roughness_texture", true)
		material.set_shader_parameter("has_ao_texture", true)
		material.set_shader_parameter("base_color_texture", load(BASE_COLOR_PATH))
		material.set_shader_parameter("normal_texture", load(NORMAL_PATH))
		material.set_shader_parameter("roughness_texture", load(ROUGHNESS_PATH))
		material.set_shader_parameter("ao_texture", load(AO_PATH))
	target.material_override = material
	return true


static func apply_biome_moss_filter(root: Node, moss_strength: float = 0.14) -> int:
	if root == null:
		return 0
	var mesh_nodes := root.find_children("*", "MeshInstance3D", true, false)
	if root is MeshInstance3D:
		mesh_nodes.push_front(root)
	var material_cache: Dictionary = {}
	var applied := 0
	for mesh_node in mesh_nodes:
		var mesh_instance := mesh_node as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue
		for surface_index in range(mesh_instance.mesh.get_surface_count()):
			var source_material := mesh_instance.get_active_material(surface_index) as StandardMaterial3D
			if source_material == null or source_material.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
				continue
			var material_key := source_material.get_instance_id()
			var tuned_material := material_cache.get(material_key) as ShaderMaterial
			if tuned_material == null:
				tuned_material = _make_aqueduct_material(source_material, moss_strength)
				material_cache[material_key] = tuned_material
			mesh_instance.set_surface_override_material(surface_index, tuned_material)
			applied += 1
	return applied


static func _make_aqueduct_material(source_material: StandardMaterial3D, moss_strength: float) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = AQUEDUCT_SHADER
	material.set_shader_parameter("base_color", source_material.albedo_color if source_material != null else Color("46564a"))
	material.set_shader_parameter("base_roughness", source_material.roughness if source_material != null else 0.90)
	material.set_shader_parameter("base_metallic", source_material.metallic if source_material != null else 0.0)
	material.set_shader_parameter("base_ao", 1.0)
	material.set_shader_parameter("base_emission", Vector3.ZERO)
	material.set_shader_parameter("moss_color", Vector3(0.18, 0.28, 0.20))
	material.set_shader_parameter("cold_tint", Vector3(0.94, 0.98, 0.96))
	material.set_shader_parameter("moss_strength", clampf(moss_strength, 0.0, 0.4))
	material.set_shader_parameter("moss_scale", 4.0)
	if source_material == null:
		return material
	if source_material.albedo_texture != null:
		material.set_shader_parameter("has_base_color_texture", true)
		material.set_shader_parameter("base_color_texture", source_material.albedo_texture)
	if source_material.normal_enabled and source_material.normal_texture != null:
		material.set_shader_parameter("has_normal_texture", true)
		material.set_shader_parameter("normal_texture", source_material.normal_texture)
		material.set_shader_parameter("normal_strength", source_material.normal_scale)
	if source_material.roughness_texture != null:
		material.set_shader_parameter("has_roughness_texture", true)
		material.set_shader_parameter("roughness_texture", source_material.roughness_texture)
	if source_material.metallic_texture != null:
		material.set_shader_parameter("has_metallic_texture", true)
		material.set_shader_parameter("metallic_texture", source_material.metallic_texture)
	if source_material.ao_enabled and source_material.ao_texture != null:
		material.set_shader_parameter("has_ao_texture", true)
		material.set_shader_parameter("ao_texture", source_material.ao_texture)
	if source_material.emission_enabled:
		var emission := source_material.emission
		var energy := source_material.emission_energy_multiplier
		material.set_shader_parameter("base_emission", Vector3(emission.r * energy, emission.g * energy, emission.b * energy))
		if source_material.emission_texture != null:
			material.set_shader_parameter("has_emission_texture", true)
			material.set_shader_parameter("emission_texture", source_material.emission_texture)
	return material


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


static func load_or_create_asset(parent: Node3D, asset_key: String, position: Vector3, scale: Vector3 = Vector3.ONE) -> Node3D:
	if parent == null:
		return null
	var packed_scene := load_optional_scene(asset_key)
	var loaded_from_plugin := packed_scene != null
	var instance: Node3D
	if packed_scene != null:
		instance = packed_scene.instantiate() as Node3D
	else:
		instance = PROCEDURAL_FORGE.create_asset(asset_key)
	if instance == null:
		push_warning("Não foi possível criar asset local: " + asset_key)
		return null
	instance.name = asset_key
	instance.set_meta("plugin_asset_loaded", loaded_from_plugin)
	instance.position = position
	instance.scale = scale
	parent.add_child(instance)
	return instance
