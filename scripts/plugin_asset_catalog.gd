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
	"meshy_tobi_hero": "res://assets/plugin_imports/meshy/tobi_hero.glb",
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
	"thrixel_stag_guardian": "user://plugin_assets/thrixel/ancient_stag_guardian.glb",
	"thrixel_river_crab": "user://plugin_assets/thrixel/silver_river_crab.glb",
	"thrixel_drowned_wraith": "user://plugin_assets/thrixel/drowned_wraith.glb",
	"thrixel_ancient_tree": "user://plugin_assets/thrixel/ancient_tree.glb",
	"thrixel_rune_obelisk": "user://plugin_assets/thrixel/rune_obelisk.glb",
	"thrixel_way_shrine": "user://plugin_assets/thrixel/stone_way_shrine.glb",

}


const DOWNLOAD_URLS := {
	"thrixel_stag_guardian": "https://api.thrixel.com/api/v1/10f1f722-53d8-4ca0-b99b-e0e687bc8fec/download?format=glb&quality=full&texture_size=1024",
	"thrixel_river_crab": "https://api.thrixel.com/api/v1/4592675e-0e7e-491d-9d1e-a4a15eee7304/download?format=glb&quality=full&texture_size=1024",
	"thrixel_drowned_wraith": "https://api.thrixel.com/api/v1/f4d8f433-7cd2-45b1-80dd-a157ba5ce26e/download?format=glb&quality=full&texture_size=1024",
	"thrixel_ancient_tree": "https://api.thrixel.com/api/v1/584d17cf-92ff-4fde-ba50-19037a88d832/download?format=glb&quality=full&texture_size=1024",
	"thrixel_rune_obelisk": "https://api.thrixel.com/api/v1/07af580b-8b0e-4511-b2bd-c0164d113fc9/download?format=glb&quality=full&texture_size=1024",
	"thrixel_way_shrine": "https://api.thrixel.com/api/v1/cc8391a0-5058-4279-b452-36749452ab08/download?format=glb&quality=full&texture_size=1024"
}


static func get_download_url(asset_key: String) -> String:
	return str(DOWNLOAD_URLS.get(asset_key, ""))


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
