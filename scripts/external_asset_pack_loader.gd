extends RefCounted
class_name ExternalAssetPackLoader
## Loader for third-party GLB/GLTF packs copied into res://assets/external_packs/.

const PACK_ROOT := "res://assets/external_packs"


static func list_models(pack_id: String) -> PackedStringArray:
	var paths := PackedStringArray()
	if not _is_safe_pack_id(pack_id):
		return paths
	_collect_models(PACK_ROOT.path_join(pack_id), paths)
	paths.sort()
	return paths


static func get_model_count(pack_id: String) -> int:
	return list_models(pack_id).size()


static func instantiate_model(parent: Node3D, model_path: String, position: Vector3, scale: Vector3 = Vector3.ONE) -> Node3D:
	if parent == null or not model_path.begins_with(PACK_ROOT + "/"):
		return null
	var extension := model_path.get_extension().to_lower()
	if extension != "glb" and extension != "gltf" and extension != "fbx":
		return null
	if not ResourceLoader.exists(model_path):
		return null
	var packed_scene := load(model_path) as PackedScene
	if packed_scene == null:
		push_warning("Modelo GLB/GLTF não importado como PackedScene: " + model_path)
		return null
	var instance := packed_scene.instantiate() as Node3D
	if instance == null:
		push_warning("A raiz do modelo externo não é Node3D: " + model_path)
		return null
	instance.name = model_path.get_file().get_basename().to_pascal_case()
	instance.position = position
	instance.scale = scale
	parent.add_child(instance)
	return instance


static func instantiate_by_name(parent: Node3D, pack_id: String, name_fragment: String, position: Vector3, scale: Vector3 = Vector3.ONE) -> Node3D:
	var needle := name_fragment.to_lower()
	if needle.is_empty():
		return null
	for model_path in list_models(pack_id):
		if model_path.get_file().get_basename().to_lower().contains(needle):
			return instantiate_model(parent, model_path, position, scale)
	return null


static func _collect_models(folder_path: String, output: PackedStringArray) -> void:
	var directory := DirAccess.open(folder_path)
	if directory == null:
		return
	for file_name in directory.get_files():
		var extension := file_name.get_extension().to_lower()
		if extension == "glb" or extension == "gltf" or extension == "fbx":
			output.append(folder_path.path_join(file_name))
	for child_folder in directory.get_directories():
		_collect_models(folder_path.path_join(child_folder), output)


static func _is_safe_pack_id(pack_id: String) -> bool:
	if pack_id.is_empty() or pack_id.contains("..") or pack_id.contains("/") or pack_id.contains("\\"):
		return false
	for character in pack_id:
		if not (character.is_valid_identifier() or character == "-"):
			return false
	return true
