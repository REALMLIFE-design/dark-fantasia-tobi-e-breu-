extends RefCounted
class_name PluginAssetCatalog

const ASSETS := {
	"aqueduct_base_color": "res://assets/plugin_imports/aqueduct/base_color.png",
	"aqueduct_normal": "res://assets/plugin_imports/aqueduct/normal.png",
	"aqueduct_roughness": "res://assets/plugin_imports/aqueduct/roughness.png",
	"aqueduct_ao": "res://assets/plugin_imports/aqueduct/ao.png",
	"aqueduct_height": "res://assets/plugin_imports/aqueduct/height.png",
	"meshy_gate": "res://assets/plugin_imports/meshy/gothic_gate.glb",
	"meshy_rune_obelisk": "res://assets/plugin_imports/meshy/rune_obelisk.glb",
	"meshy_way_shrine": "res://assets/plugin_imports/meshy/stone_way_shrine.glb",
	"pinoc_walking": "res://assets/plugin_imports/pinoc/animations/walking.glb",
	"pinoc_running": "res://assets/plugin_imports/pinoc/animations/running.glb",
	"pinoc_dodge_roll": "res://assets/plugin_imports/pinoc/animations/dodge_roll.glb",
	"pinoc_cast_spell": "res://assets/plugin_imports/pinoc/animations/cast_spell.glb",
	"pinoc_hit_reaction": "res://assets/plugin_imports/pinoc/animations/hit_reaction.glb",
	"pinoc_sword_idle": "res://assets/plugin_imports/pinoc/animations/sword_idle.glb",
	"pinoc_jump": "res://assets/plugin_imports/pinoc/animations/jump.glb",
	"pinoc_block": "res://assets/plugin_imports/pinoc/animations/block.glb",
	"pinoc_bow_draw": "res://assets/plugin_imports/pinoc/animations/bow_draw.glb",
	"pinoc_pick_up": "res://assets/plugin_imports/pinoc/animations/pick_up.glb",
	"pinoc_climb": "res://assets/plugin_imports/pinoc/animations/climb.glb",
	"pinoc_vault": "res://assets/plugin_imports/pinoc/animations/vault.glb",
	"pinoc_stand_up": "res://assets/plugin_imports/pinoc/animations/stand_up.glb",
	"pinoc_death": "res://assets/plugin_imports/pinoc/animations/death.glb",
	"pinoc_drawing_sword": "res://assets/plugin_imports/pinoc/animations/drawing_sword.glb",
	"pinoc_fighting_stance": "res://assets/plugin_imports/pinoc/animations/fighting_stance.glb",
	"pinoc_carry_walk": "res://assets/plugin_imports/pinoc/animations/carry_walk.glb",
	"pinoc_crawl": "res://assets/plugin_imports/pinoc/animations/crawl.glb",
	"pinoc_crouch_walk": "res://assets/plugin_imports/pinoc/animations/crouch_walk.glb",
	"pinoc_injured_walk": "res://assets/plugin_imports/pinoc/animations/injured_walk.glb",
	"pinoc_run_jump": "res://assets/plugin_imports/pinoc/animations/run_jump.glb",
	"pinoc_sprint": "res://assets/plugin_imports/pinoc/animations/sprint.glb",
	"pinoc_walk_backwards": "res://assets/plugin_imports/pinoc/animations/walk_backwards.glb",
	"pinoc_strafe_left": "res://assets/plugin_imports/pinoc/animations/strafe_left.glb",
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
