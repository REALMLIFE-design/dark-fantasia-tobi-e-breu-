extends RefCounted
class_name PluginAssetCatalog

const ASSETS := {
	"aqueduct_base_color": "res://assets/plugin_imports/aqueduct/base_color.png",
	"aqueduct_normal": "res://assets/plugin_imports/aqueduct/normal.png",
	"aqueduct_roughness": "res://assets/plugin_imports/aqueduct/roughness.png",
	"aqueduct_ao": "res://assets/plugin_imports/aqueduct/ao.png",
	"meshy_gate": "res://assets/plugin_imports/meshy/gothic_gate.glb",
	"pinoc_walking": "res://assets/plugin_imports/pinoc/walking.glb",
	"pinoc_running": "res://assets/plugin_imports/pinoc/running.glb",
	"pinoc_dodge_roll": "res://assets/plugin_imports/pinoc/dodge_roll.glb",
	"pinoc_cast_spell": "res://assets/plugin_imports/pinoc/cast_spell.glb",
	"pinoc_hit_reaction": "res://assets/plugin_imports/pinoc/hit_reaction.glb",
	"pinoc_forest_splat": "res://assets/plugin_imports/pinoc/forest_scarlet.spz",
}


static func is_available(asset_key: String) -> bool:
	if not ASSETS.has(asset_key):
		return false
	return FileAccess.file_exists(ASSETS[asset_key])


static func get_missing_assets() -> PackedStringArray:
	var missing := PackedStringArray()
	for asset_key in ASSETS:
		if not FileAccess.file_exists(ASSETS[asset_key]):
			missing.append(asset_key)
	return missing


static func get_available_count() -> int:
	return ASSETS.size() - get_missing_assets().size()
