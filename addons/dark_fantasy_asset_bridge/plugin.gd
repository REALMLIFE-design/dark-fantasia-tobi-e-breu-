@tool
extends EditorPlugin

const ASSET_PATHS := {
	"Aqueduct · Base Color": "res://assets/plugin_imports/aqueduct/base_color.png",
	"Aqueduct · Normal": "res://assets/plugin_imports/aqueduct/normal.png",
	"Aqueduct · Roughness": "res://assets/plugin_imports/aqueduct/roughness.png",
	"Aqueduct · AO": "res://assets/plugin_imports/aqueduct/ao.png",
	"Meshy · Gothic Gate": "res://assets/plugin_imports/meshy/gothic_gate.glb",
	"Thrixel · Ancient Stag Guardian": "user://plugin_assets/thrixel/ancient_stag_guardian.glb",
	"Thrixel · Silver River Crab": "user://plugin_assets/thrixel/silver_river_crab.glb",
	"Thrixel · Drowned Wraith": "user://plugin_assets/thrixel/drowned_wraith.glb",
	"Thrixel · Ancient Tree": "user://plugin_assets/thrixel/ancient_tree.glb",
	"Thrixel · Rune Obelisk": "user://plugin_assets/thrixel/rune_obelisk.glb",
	"Thrixel · Way Shrine": "user://plugin_assets/thrixel/stone_way_shrine.glb",
	"PINOC · Walking": "res://assets/plugin_imports/pinoc/walking.glb",
	"PINOC · Running": "res://assets/plugin_imports/pinoc/running.glb",
	"PINOC · Dodge Roll": "res://assets/plugin_imports/pinoc/dodge_roll.glb",
	"PINOC · Cast Spell": "res://assets/plugin_imports/pinoc/cast_spell.glb",
	"PINOC · Hit Reaction": "res://assets/plugin_imports/pinoc/hit_reaction.glb",
	"PINOC · Forest Splat": "res://assets/plugin_imports/pinoc/forest_scarlet.spz",
}

var status_label: RichTextLabel
var summary_label: Label


func _enter_tree() -> void:
	var panel := VBoxContainer.new()
	panel.name = "AssetBridgePanel"
	panel.custom_minimum_size = Vector2(260, 240)

	var heading := Label.new()
	heading.text = "TOBI E BREU · ASSET BRIDGE"
	heading.add_theme_font_size_override("font_size", 15)
	panel.add_child(heading)

	summary_label = Label.new()
	panel.add_child(summary_label)

	status_label = RichTextLabel.new()
	status_label.bbcode_enabled = true
	status_label.fit_content = true
	status_label.scroll_active = true
	status_label.custom_minimum_size = Vector2(260, 300)
	panel.add_child(status_label)

	var refresh_button := Button.new()
	refresh_button.text = "Verificar arquivos"
	refresh_button.pressed.connect(_refresh_status)
	panel.add_child(refresh_button)

	add_control_to_dock(DOCK_SLOT_RIGHT_UL, panel)
	_refresh_status()


func _exit_tree() -> void:
	var panel := get_editor_interface().get_editor_main_screen()
	# The dock control is owned by the editor; remove it cleanly on plugin unload.
	for child in get_editor_interface().get_base_control().find_children("AssetBridgePanel", "VBoxContainer", true, false):
		remove_control_from_docks(child)
		child.queue_free()


func _refresh_status() -> void:
	if status_label == null:
		return
	var found := 0
	var lines := PackedStringArray()
	for asset_name in ASSET_PATHS:
		var asset_path: String = ASSET_PATHS[asset_name]
		var exists := FileAccess.file_exists(asset_path)
		if exists:
			found += 1
			lines.append("[color=#83d6a0]✓[/color] %s" % asset_name)
		else:
			lines.append("[color=#e6b36d]○[/color] %s [color=#999999](aguardando arquivo)[/color]" % asset_name)
	status_label.text = "\n".join(lines)
	summary_label.text = "%d / %d arquivos encontrados" % [found, ASSET_PATHS.size()]
