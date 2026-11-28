extends Node3D
class_name TobiQuaterniusCandidate

## Personagem candidato montado com peças Quaternius CC0.
## Não substitui o personagem ativo: esta cena é isolada para revisão visual e retarget.

const BASE_HEAD := "res://assets/models/tobi_quaternius/base/Regular_Male_OnlyHead.gltf"

const PIECES := [
	{
		"path": "res://assets/models/tobi_quaternius/ranger/Male_Ranger_Body.gltf",
		"name": "RangerBody",
		"tint": Color(0.66, 0.78, 1.0)
	},
	{
		"path": "res://assets/models/tobi_quaternius/ranger/Male_Ranger_Arms.gltf",
		"name": "RangerArms",
		"tint": Color(0.82, 0.88, 1.0)
	},
	{
		"path": "res://assets/models/tobi_quaternius/ranger/Male_Ranger_Legs.gltf",
		"name": "RangerLegs",
		"tint": Color(0.58, 0.68, 0.92)
	},
	{
		"path": "res://assets/models/tobi_quaternius/ranger/Male_Ranger_Feet_Boots.gltf",
		"name": "RangerBoots",
		"tint": Color(0.78, 0.72, 0.66)
	},
	{
		"path": "res://assets/models/tobi_quaternius/ranger/Male_Ranger_Head_Hood.gltf",
		"name": "RangerHood",
		"tint": Color(0.52, 0.54, 0.62)
	}
]

var _base_skeleton: Skeleton3D


func _ready() -> void:
	_build_candidate()


func _build_candidate() -> void:
	var base_packed := load(BASE_HEAD) as PackedScene
	if base_packed == null:
		push_error("Tobi Quaternius: cabeça base não importada: " + BASE_HEAD)
		return

	var base_instance := base_packed.instantiate()
	base_instance.name = "TobiHeadAndSkeleton"
	add_child(base_instance)

	_base_skeleton = _find_skeleton(base_instance)
	if _base_skeleton == null:
		push_error("Tobi Quaternius: o arquivo base não contém Skeleton3D.")
		return

	for piece_data: Dictionary in PIECES:
		_attach_piece(piece_data)
	set_meta("tobi_quaternius_ready", true)
	print("TOBI_QUATERNIUS_SCENE_READY")


func _attach_piece(piece_data: Dictionary) -> void:
	var path: String = piece_data["path"]
	var packed := load(path) as PackedScene
	if packed == null:
		push_error("Tobi Quaternius: peça não importada: " + path)
		return

	var instance := packed.instantiate()
	instance.name = String(piece_data["name"])
	add_child(instance)

	var meshes: Array[MeshInstance3D] = []
	_collect_meshes(instance, meshes)
	if meshes.is_empty():
		push_warning("Tobi Quaternius: nenhuma malha encontrada em " + path)
		return

	for mesh_instance: MeshInstance3D in meshes:
		# Todas as peças Quaternius do kit usam o mesmo rig humanoide.
		# Cada malha passa a seguir o esqueleto único da cabeça/base.
		mesh_instance.skeleton = mesh_instance.get_path_to(_base_skeleton)
		_tint_ranger_surfaces(mesh_instance, piece_data["tint"])


func _find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node as Skeleton3D
	for child: Node in node.get_children():
		var found := _find_skeleton(child)
		if found != null:
			return found
	return null


func _collect_meshes(node: Node, output: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D:
		output.append(node as MeshInstance3D)
	for child: Node in node.get_children():
		_collect_meshes(child, output)


func _tint_ranger_surfaces(mesh_instance: MeshInstance3D, tint: Color) -> void:
	if mesh_instance.mesh == null:
		return
	for surface_index in range(mesh_instance.mesh.get_surface_count()):
		var source_material := mesh_instance.get_active_material(surface_index)
		if source_material is StandardMaterial3D:
			var source_texture := (source_material as StandardMaterial3D).albedo_texture
			if source_texture != null and source_texture.resource_path.contains("T_Ranger_BaseColor"):
				var tinted := (source_material as StandardMaterial3D).duplicate() as StandardMaterial3D
				tinted.albedo_color = tinted.albedo_color * tint
				mesh_instance.set_surface_override_material(surface_index, tinted)
