extends Node3D

const PLAYER_SCRIPT = preload("res://scripts/player.gd")
const ENEMY_SCRIPT = preload("res://scripts/enemy.gd")
const PAINTER_SHADER = preload("res://scripts/painter_material.gdshader")
const SURFACE_ALBEDO_ATLAS = preload("res://assets/textures/surface_albedo_atlas.png")
const SURFACE_ROUGHNESS_ATLAS = preload("res://assets/textures/surface_roughness_atlas.png")
const PLUGIN_ASSET_LOADER = preload("res://scripts/plugin_asset_loader.gd")
const DARK_FANTASY_PROP_PACK = preload("res://scripts/dark_fantasy_prop_pack.gd")
const EXTERNAL_ASSET_LOADER = preload("res://scripts/external_asset_pack_loader.gd")
const HUD_STYLE = preload("res://scripts/hud_style.gd")
const ASHEN_VILLAGE = preload("res://scripts/ashen_village.gd")
const STORY_CUTSCENES = preload("res://scripts/story_cutscenes.gd")
var player: CharacterBody3D
var quest_stage := 0
var quest_text := "Fale com Mestre Azulan"
var hud: CanvasLayer
var quest_label: Label
var prompt_label: Label
var toast_label: Label
var health_label: Label
var health_value_label: Label
var health_bar: ProgressBar
var combo_label: Label
var objective_label: Label
var defeated_count := 0
var enemies: Array[Node3D] = []
var xp := 0
var shards := 0
var potions := 3
var weapon_level := 0
const WEAPON_UPGRADE_COSTS := [3, 6, 10]
var save_path := "user://tobi_breu_save.cfg"
var settings_path := "user://tobi_breu_settings.cfg"
var camera_sensitivity_setting := 0.006
var menu_layer: CanvasLayer
var loading_layer: CanvasLayer
var loading_progress: ProgressBar
var loading_status: Label
var menu_panel: PanelContainer
var menu_body: VBoxContainer
var menu_feedback: Label
var menu_page := "main"
var game_started := false
var day_clock := 0.0
var sun_light: DirectionalLight3D
var world_environment: WorldEnvironment
var stamina_bar: ProgressBar
var xp_label: Label
var xp_bar: ProgressBar
var boss_health_bar: ProgressBar
var boss_health_label: Label
var boss_hud_panel: PanelContainer
var inventory_label: Label
var inventory_panel: PanelContainer
var inventory_details: Label
var goblin_ears := 0
var swamp_herbs := 0
var dark_essence := 0
var save_toast_timer := 0.0
var shadow_skill_label: Label
var whisper_grove_label: Label
var saved_shrine_used := false
var saved_player_hp := 100
var checkpoint_position := Vector3(0, 0, 15)
var swamp_totems := 0
var swamp_totem_ids: Array[int] = []
var swamp_boss_defeated := false
var river_knights_defeated := 0
var river_relic_ids: Array[int] = []
var river_chest_ids: Array[int] = []
var whisper_lantern_ids: Array[int] = []
var whisper_guardian_reward_claimed := false
var river_boss_hp := 680
var river_boss_saved_band := -1
var river_shrine_solved := false
var river_puzzle_ring_steps: Array[int] = [0, 0, 0]
var guild_relic_ids: Array[int] = []
var guild_contract_started := false
var guild_contract_claimed := false
var bell_tower_ring_count := 0
var ancient_waystone_ids: Array[int] = []
var ashen_relic_ids: Array[int] = []
var ashen_reward_claimed := false
var itch_dungeon_stream_requested := false
var itch_dungeon_assets_loaded := false
var nature_models_stream_requested := false
const ITCH_DUNGEON_MODEL_PATHS := [
	"res://assets/external_packs/itch_dark_dungeon/cracked-runic-circle.glb",
	"res://assets/external_packs/itch_dark_dungeon/crimson-obsidian-sentinel.glb",
	"res://assets/external_packs/itch_dark_dungeon/cursed-codex.glb"
]
const RIVER_PUZZLE_TARGETS := [1, 3, 2]

func _configure_adaptive_4k() -> void:
	# Render at native 4K only on a 4K desktop display. Mobile keeps its native
	# viewport resolution to avoid forcing 4K rendering on phone GPUs.
	if OS.has_feature("pc"):
		var screen_size := DisplayServer.screen_get_size()
		if screen_size.x >= 3840 and screen_size.y >= 2160:
			get_window().content_scale_size = Vector2i(3840, 2160)
			print("TOBI_BREU_4K_DESKTOP_ENABLED: 3840x2160")
		else:
			get_window().content_scale_size = Vector2i(1920, 1080)
			print("TOBI_BREU_HIGH_RES_DESKTOP_ENABLED: 1920x1080")
	else:
		print("TOBI_BREU_ADAPTIVE_MOBILE_RESOLUTION: native device resolution")


func _ready() -> void:
	_configure_adaptive_4k()
	_create_loading_screen()
	_set_loading_progress(4.0, "Acendendo as runas...")
	await get_tree().process_frame
	_load_save()
	_load_settings()
	river_boss_saved_band = floori(float(river_boss_hp) / 68.0)
	_set_loading_progress(10.0, "Moldando o mundo...")
	await get_tree().process_frame
	_build_environment()
	await get_tree().process_frame
	_build_landscape()
	await get_tree().process_frame
	_build_downloaded_pbr_surface_patches()
	await get_tree().process_frame
	_set_loading_progress(24.0, "Erguendo as terras esquecidas...")
	_build_open_world_expansion()
	await get_tree().process_frame
	_build_ruins_and_props()
	await get_tree().process_frame
	_build_region_landmarks()
	await get_tree().process_frame
	_build_plugin_world_expansion()
	await get_tree().process_frame
	await _build_imported_plugin_models()
	await get_tree().process_frame
	DARK_FANTASY_PROP_PACK.build_all(self)
	await get_tree().process_frame
	await _build_visible_3dassets_showcase()
	await get_tree().process_frame
	_set_loading_progress(40.0, "Despertando as regiões...")
	_build_swamp_region()
	await get_tree().process_frame
	_build_river_region()
	await get_tree().process_frame
	_build_whisper_grove()
	await get_tree().process_frame
	_build_outer_regions()
	_build_wandering_lighthouse()
	await get_tree().process_frame
	_build_ancient_waystones()
	await get_tree().process_frame
	_set_loading_progress(62.0, "Reacendendo as cidades...")
	_build_world_civilization()
	_build_imported_medieval_hamlet()
	ASHEN_VILLAGE.build(self, ashen_relic_ids)
	await get_tree().process_frame
	_build_npcs()
	await get_tree().process_frame
	_build_enemies()
	await get_tree().process_frame
	_set_loading_progress(78.0, "Preparando Tobi e Breu...")
	await get_tree().process_frame
	_build_player()
	player.camera_sensitivity = camera_sensitivity_setting
	player.hp = clampi(saved_player_hp, 1, player.max_hp)
	player.global_position = checkpoint_position
	_build_hud()
	if quest_stage == 12:
		boss_hud_panel.visible = true
		boss_health_changed(river_boss_hp, 680)
	_update_quest()
	if quest_stage == 0: objective_label.text = "Objetivo: encontre Mestre Azulan"
	elif quest_stage == 1: objective_label.text = "Objetivo: derrote 3 goblins corrompidos"
	elif quest_stage == 2: objective_label.text = "Objetivo: retorne ao Mestre Azulan"
	elif quest_stage == 3: objective_label.text = "Objetivo: derrote o Guardião do Silêncio ao norte"
	elif quest_stage == 4: objective_label.text = "Objetivo: volte ao Mestre Azulan"
	elif quest_stage == 5: objective_label.text = "Objetivo: purifique os 3 totens do Pântano dos Ratos (%d/3)" % swamp_totems
	elif quest_stage == 6: objective_label.text = "Objetivo: derrote a Bruxa do Pântano"
	elif quest_stage == 7: objective_label.text = "Objetivo: volte ao Mestre Azulan"
	elif quest_stage == 8: objective_label.text = "Objetivo: fale com Azulan sobre o Rio Prateado"
	elif quest_stage == 9: objective_label.text = "Objetivo: encontre o Guardião do Rio Prateado"
	elif quest_stage == 10: objective_label.text = "Objetivo: derrote 3 Cavaleiros Afogados (%d/3)" % river_knights_defeated
	elif quest_stage == 11: objective_label.text = "Objetivo: retorne ao Guardião do Rio"
	elif quest_stage == 12: objective_label.text = "Objetivo: derrote o Leviatã do Lodo no coração do rio"
	elif quest_stage == 13: objective_label.text = "Objetivo: retorne ao Guardião do Rio"
	else: objective_label.text = "CAPÍTULO II CONCLUÍDO — O rio voltou a cantar"
	_update_inventory()
	player_health_changed(player.hp, player.max_hp)
	_build_menus()
	_set_loading_progress(100.0, "A jornada aguarda...")
	await get_tree().create_timer(0.2, true).timeout
	await _hide_loading_screen()
	if quest_stage == 0 and not STORY_CUTSCENES.intro_was_seen():
		await STORY_CUTSCENES.play_intro(self)
	print("TOBI_BREU_BOOT_READY")




func _build_downloaded_pbr_surface_patches() -> void:
	# Mapas PBR CC0 em pequenas áreas de transição: o terreno painterly original permanece intacto.
	var patches := [
		{"folder": "lama", "position": Vector3(-27.0, 0.012, -111.0), "size": Vector2(9.0, 12.0)},
		{"folder": "lama", "position": Vector3(27.0, 0.012, -111.0), "size": Vector2(9.0, 12.0)},
		{"folder": "pedra_musgo", "position": Vector3(40.0, 0.012, -148.0), "size": Vector2(6.0, 8.0)},
		{"folder": "pedra_musgo", "position": Vector3(70.0, 0.012, -148.0), "size": Vector2(6.0, 8.0)},
		{"folder": "terra_pedras", "position": Vector3(40.0, 0.012, -108.0), "size": Vector2(6.0, 8.0)},
		{"folder": "terra_pedras", "position": Vector3(70.0, 0.012, -108.0), "size": Vector2(6.0, 8.0)}
	]
	for patch_data in patches:
		var folder: String = patch_data["folder"]
		var base_path := "res://assets/textures/polyhaven/" + folder + "/"
		var albedo := load(base_path + "albedo.jpg") as Texture2D
		if albedo == null:
			continue
		var material := StandardMaterial3D.new()
		material.albedo_texture = albedo
		material.roughness = 0.92
		material.uv1_scale = Vector3(2.5, 2.5, 1.0)
		var normal := load(base_path + "normal.jpg") as Texture2D
		if normal != null:
			material.normal_enabled = true
			material.normal_texture = normal
		var roughness_map := load(base_path + "roughness.jpg") as Texture2D
		if roughness_map != null:
			material.roughness_texture = roughness_map
		var patch_mesh := PlaneMesh.new()
		patch_mesh.size = patch_data["size"]
		var patch := MeshInstance3D.new()
		patch.name = "CC0_PBR_" + folder
		patch.mesh = patch_mesh
		patch.position = patch_data["position"]
		patch.material_override = material
		add_child(patch)


func _build_downloaded_nature_models() -> void:
	# Conteúdo opcional de regiões distantes é carregado em lotes, quando o jogador se aproxima.
	# Nenhum modelo é removido; cada lote cede um frame para evitar congelar a gameplay.
	var models := EXTERNAL_ASSET_LOADER.list_models("quaternius_stylized_nature")
	if not models.is_empty():
		var rng := RandomNumberGenerator.new()
		rng.seed = 20261121
		var placed := 0
		for model_path in models:
			var file_name := model_path.get_file().to_lower()
			# Apenas árvores, arbustos, plantas, flores e rochas combinam com esta área.
			if not ("tree" in file_name or "bush" in file_name or "plant" in file_name or "flower" in file_name or "rock" in file_name or "grass" in file_name):
				continue
			var row := placed / 6
			var column := placed % 6
			var x := -190.0 + float(column) * 18.0 + rng.randf_range(-5.0, 5.0)
			var z := -205.0 + float(row) * 18.0 + rng.randf_range(-5.0, 5.0)
			var scale_factor := rng.randf_range(0.85, 1.35)
			var instance := EXTERNAL_ASSET_LOADER.instantiate_model(self, model_path, Vector3(x, 0.0, z), Vector3.ONE * scale_factor)
			if instance != null:
				instance.rotation.y = rng.randf_range(0.0, TAU)
				placed += 1
				await get_tree().process_frame
			if placed >= 24:
				break

	# LazyTextures: selecionar apenas modelos de natureza/pedra e posicioná-los
	# como detalhes adicionais, sem tocar nos marcos, NPCs ou construções existentes.
	var community_models := EXTERNAL_ASSET_LOADER.list_models("lazytextures")
	var community_rng := RandomNumberGenerator.new()
	community_rng.seed = 20261122
	var community_placed := 0
	for model_path in community_models:
		if not "/models/" in model_path:
			continue
		var file_name := model_path.get_file().to_lower()
		if not ("tree" in file_name or "forest" in file_name or "bush" in file_name or "plant" in file_name or "flower" in file_name or "rock" in file_name or "mushroom" in file_name or "stone" in file_name or "ruin" in file_name):
			continue
		var x := -150.0 + float(community_placed % 4) * 13.0 + community_rng.randf_range(-2.0, 2.0)
		var z := -155.0 - float(community_placed / 4) * 13.0 + community_rng.randf_range(-2.0, 2.0)
		var instance := EXTERNAL_ASSET_LOADER.instantiate_model(self, model_path, Vector3(x, 0.0, z), Vector3.ONE * community_rng.randf_range(0.8, 1.2))
		if instance != null:
			instance.rotation.y = community_rng.randf_range(0.0, TAU)
			community_placed += 1
			await get_tree().process_frame
		if community_placed >= 12:
			break

	# 3DAssets.dev: GLBs CC0 autocontidos, filtrados por natureza e cenário medieval.
	var curated_models := EXTERNAL_ASSET_LOADER.list_models("3dassets_dev")
	var curated_rng := RandomNumberGenerator.new()
	curated_rng.seed = 20261123
	var nature_count := 0
	var ruin_count := 0
	for model_path in curated_models:
		var file_name := model_path.get_file().to_lower()
		var is_nature := "tree" in file_name or "forest" in file_name or "bush" in file_name or "plant" in file_name or "flower" in file_name or "rock" in file_name or "mushroom" in file_name or "crystal" in file_name
		# O pack inclui peças submersas; só usar estruturas e props que também funcionem no Rio Prateado.
		var is_ruin_prop := "doorway-frame" in file_name or "standing-column" in file_name or "fountain-basin" in file_name or "glowing-crystal-clust" in file_name or "cargo-crate" in file_name or "shipwreck-hull" in file_name or "wreck-on-the-sand" in file_name
		if not is_nature and not is_ruin_prop:
			continue
		var position := Vector3.ZERO
		var scale_factor := curated_rng.randf_range(0.8, 1.2)
		if is_nature and nature_count < 12:
			position = Vector3(-235.0 + float(nature_count % 4) * 12.0, 0.0, -225.0 + float(nature_count / 4) * 12.0)
		elif is_ruin_prop and ruin_count < 8:
			position = Vector3(72.0 + float(ruin_count % 4) * 9.0, 0.0, -142.0 - float(ruin_count / 4) * 9.0)
		else:
			continue
		var instance := EXTERNAL_ASSET_LOADER.instantiate_model(self, model_path, position, Vector3.ONE * scale_factor)
		if instance != null:
			instance.rotation.y = curated_rng.randf_range(0.0, TAU)
			if is_nature:
				nature_count += 1
			else:
				ruin_count += 1
			await get_tree().process_frame


func _build_visible_3dassets_showcase() -> void:
	# Mostra os GLBs CC0 perto do início da aventura; antes eles ficavam
	# apenas em regiões distantes e o jogador podia terminar o jogo sem vê-los.
	var showcase := [
		{"file": "low-poly-character-figures-knight-sword-raised-5e8b7e11.glb", "position": Vector3(-6.5, 0.0, -8.0), "scale": 1.25},
		{"file": "low-poly-character-figures-villager-man-bfcdf400.glb", "position": Vector3(7.0, 0.0, -8.5), "scale": 1.25},
		{"file": "sunken-city-and-underwater-ruins-doorway-frame-1292bfb7.glb", "position": Vector3(-10.0, 0.0, -18.0), "scale": 1.35},
		{"file": "sunken-city-and-underwater-ruins-standing-column-96caec95.glb", "position": Vector3(10.0, 0.0, -17.0), "scale": 1.8},
		{"file": "sunken-city-and-underwater-ruins-cargo-crate-waterlogg-8761132f.glb", "position": Vector3(5.5, 0.0, -13.0), "scale": 1.5},
		{"file": "sunken-city-and-underwater-ruins-glowing-crystal-clust-897febc9.glb", "position": Vector3(-5.5, 0.0, -14.0), "scale": 1.8},
		{"file": "sunken-city-and-underwater-ruins-fountain-basin-0149d19f.glb", "position": Vector3(0.0, 0.0, -23.0), "scale": 1.2}
	]
	var placed := 0
	for item in showcase:
		var model_path: String = "res://assets/external_packs/3dassets_dev/" + str(item.file)
		var instance := EXTERNAL_ASSET_LOADER.instantiate_model(self, model_path, item.position, Vector3.ONE * item.scale)
		if instance != null:
			instance.rotation.y = 0.35 if placed % 2 == 0 else -0.25
			placed += 1
			await get_tree().process_frame
	if placed == 0:
		push_warning("Nenhum GLB do pacote 3DAssets.dev foi carregado no cenário inicial.")
	print("3DASSETS_SHOWCASE_LOADED: ", placed, "/", showcase.size())

func _build_imported_plugin_models() -> void:
	# Modelos 3D ja existentes nos plugins; baixados uma vez e guardados em user://.
	# Os modelos mantem materiais/texturas PBR incorporados ao GLB.
	# GLBs de inimigos são anexados às instâncias reais em enemy.gd, nunca como decoração estática.
	PLUGIN_ASSET_LOADER.load_or_create_asset(self, "thrixel_ancient_tree", Vector3(-185.0, 0.0, -104.0), Vector3.ONE * 1.35)
	await get_tree().process_frame
	PLUGIN_ASSET_LOADER.load_or_create_asset(self, "thrixel_rune_obelisk", Vector3(27.0, 0.0, -55.0), Vector3.ONE * 1.2)
	await get_tree().process_frame
	PLUGIN_ASSET_LOADER.load_or_create_asset(self, "thrixel_way_shrine", Vector3(83.0, 0.0, -143.0), Vector3.ONE)
	await get_tree().process_frame
	# Assets Meshy ja existentes: carregam quando os GLBs forem importados em res://assets/plugin_imports/meshy/.
	var meshy_gate := PLUGIN_ASSET_LOADER.load_meshy_asset(self, "meshy_gate", Vector3(-18.0, 0.0, -42.0), Vector3.ONE * 1.35)
	if meshy_gate == null:
		PLUGIN_ASSET_LOADER.load_or_create_asset(self, "meshy_gate", Vector3(-18.0, 0.0, -42.0), Vector3.ONE * 1.35)
	var meshy_obelisk := PLUGIN_ASSET_LOADER.load_meshy_asset(self, "meshy_rune_obelisk", Vector3(36.0, 0.0, -58.0), Vector3.ONE * 1.2)
	if meshy_obelisk == null:
		PLUGIN_ASSET_LOADER.load_or_create_asset(self, "meshy_rune_obelisk", Vector3(36.0, 0.0, -58.0), Vector3.ONE * 1.2)
	var meshy_shrine := PLUGIN_ASSET_LOADER.load_meshy_asset(self, "meshy_way_shrine", Vector3(91.0, 0.0, -137.0), Vector3.ONE)
	if meshy_shrine == null:
		PLUGIN_ASSET_LOADER.load_or_create_asset(self, "meshy_way_shrine", Vector3(91.0, 0.0, -137.0), Vector3.ONE)


func _create_loading_screen() -> void:
	loading_layer = CanvasLayer.new()
	loading_layer.name = "DarkFantasyLoading"
	loading_layer.layer = 100
	loading_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(loading_layer)
	var loading_root := Control.new()
	loading_root.name = "LoadingRoot"
	loading_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	loading_layer.add_child(loading_root)
	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color("080b0d")
	loading_root.add_child(backdrop)
	var frame := PanelContainer.new()
	frame.set_anchors_preset(Control.PRESET_CENTER)
	frame.position = Vector2(-160.0, -112.0)
	frame.size = Vector2(320.0, 224.0)
	frame.add_theme_stylebox_override("panel", _hud_button_style(Color(0.025, 0.035, 0.035, 0.98), Color("9d7546"), 20))
	loading_root.add_child(frame)
	var stack := VBoxContainer.new()
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 12)
	frame.add_child(stack)
	var heading := Label.new()
	heading.text = "TOBI  &  BREU"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 26)
	heading.add_theme_color_override("font_color", Color("e5c58c"))
	stack.add_child(heading)
	loading_progress = ProgressBar.new()
	loading_progress.custom_minimum_size = Vector2(250.0, 15.0)
	loading_progress.min_value = 0.0
	loading_progress.max_value = 100.0
	loading_progress.value = 0.0
	loading_progress.show_percentage = false
	loading_progress.add_theme_stylebox_override("background", _hud_bar_style(Color("242a28")))
	loading_progress.add_theme_stylebox_override("fill", _hud_bar_style(Color("b18a52")))
	stack.add_child(loading_progress)
	loading_status = Label.new()
	loading_status.text = "Preparando a aventura..."
	loading_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_status.add_theme_font_size_override("font_size", 11)
	loading_status.add_theme_color_override("font_color", Color("c9c0aa"))
	stack.add_child(loading_status)



func _set_loading_progress(value: float, message: String) -> void:
	if is_instance_valid(loading_progress):
		loading_progress.value = clampf(value, 0.0, 100.0)
	if is_instance_valid(loading_status):
		loading_status.text = message


func _hide_loading_screen() -> void:
	if not is_instance_valid(loading_layer):
		return
	var layer_to_remove := loading_layer
	loading_layer = null
	var fade_target := layer_to_remove.get_node_or_null("LoadingRoot") as Control
	if is_instance_valid(fade_target):
		var fade := layer_to_remove.create_tween()
		fade.tween_property(fade_target, "modulate:a", 0.0, 0.28)
		await fade.finished
	layer_to_remove.queue_free()


func _mat(color: Color, roughness := 0.92) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = roughness
	m.metallic = 0.0
	return m


func _painter_mat(color: Color, brush_scale := 3.0, brush_strength := 0.08, pattern_mode := 0, accent := Color("202a24")) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = PAINTER_SHADER
	material.set_shader_parameter("surface_albedo_atlas", SURFACE_ALBEDO_ATLAS)
	material.set_shader_parameter("surface_roughness_atlas", SURFACE_ROUGHNESS_ATLAS)
	material.set_shader_parameter("base_tint", color)
	material.set_shader_parameter("accent_tint", accent)
	material.set_shader_parameter("brush_scale", brush_scale)
	material.set_shader_parameter("brush_strength", brush_strength)
	material.set_shader_parameter("pattern_mode", pattern_mode)
	var detail_scale := 1.0
	var triplanar_sharpness := 4.5
	match pattern_mode:
		1:
			detail_scale = 0.92
			triplanar_sharpness = 3.8
		2:
			detail_scale = 1.18
			triplanar_sharpness = 4.2
		3:
			detail_scale = 1.05
			triplanar_sharpness = 3.6
		4:
			detail_scale = 1.28
			triplanar_sharpness = 5.0
		5:
			detail_scale = 0.78
			triplanar_sharpness = 3.0
		6:
			detail_scale = 1.0
			triplanar_sharpness = 4.0
		7:
			detail_scale = 1.12
			triplanar_sharpness = 5.2
		8:
			detail_scale = 1.08
			triplanar_sharpness = 5.4
	material.set_shader_parameter("detail_scale", detail_scale)
	material.set_shader_parameter("triplanar_sharpness", triplanar_sharpness)
	# Relief is tuned by surface so stone and timber read clearly without
	# making grass noisy, snow jagged, or water look embossed.
	var bump_strength := 0.16
	match pattern_mode:
		1: bump_strength = 0.10 # grass
		2: bump_strength = 0.14 # dirt
		3: bump_strength = 0.20 # wet mud
		4: bump_strength = 0.24 # wood grain
		5: bump_strength = 0.035 # water
		6: bump_strength = 0.075 # snow and ice
		7: bump_strength = 0.18 # roof tiles
		8: bump_strength = 0.22 # cut stone
		9: bump_strength = 0.28 # obsidian
		10: bump_strength = 0.19 # mossy stone
		11: bump_strength = 0.16 # blood-stained stone
		12: bump_strength = 0.12 # worn metal
		13: bump_strength = 0.08 # magical crystal
	material.set_shader_parameter("bump_strength", bump_strength)
	return material


func _material_for_surface(surface_name: String, color: Color) -> ShaderMaterial:
	var key := surface_name.to_lower()
	if "obsidian" in key or "blackglass" in key:
		return _painter_mat(color, 3.8, 0.12, 9, Color("541f2a"))
	if "moss" in key or "lichen" in key:
		return _painter_mat(color, 3.2, 0.13, 10, Color("465d3b"))
	if "blood" in key or "crimson" in key:
		return _painter_mat(color, 3.6, 0.11, 11, Color("702b36"))
	if "metal" in key or "iron" in key or "steel" in key or "chain" in key:
		return _painter_mat(color, 4.2, 0.08, 12, Color("41494b"))
	if "crystal" in key or "rune" in key or "arcane" in key:
		return _painter_mat(color, 3.0, 0.08, 13, Color("397e82"))
	if "grass" in key or "forest" in key or "meadow" in key or "brush" in key or "canopy" in key:
		return _painter_mat(color, 2.8, 0.12, 1, color.darkened(0.28))
	if "road" in key or "trail" in key or "dirt" in key or "path" in key:
		return _painter_mat(color, 3.4, 0.12, 2, color.darkened(0.3))
	if "swamp" in key or "mire" in key or "mud" in key or "toxic" in key or "pool" in key:
		return _painter_mat(color, 3.0, 0.14, 3, Color("263c35"))
	if "wood" in key or "timber" in key or "bark" in key or "door" in key or "beam" in key:
		return _painter_mat(color, 4.0, 0.10, 4, color.darkened(0.3))
	if "water" in key or "river" in key:
		return _painter_mat(color, 2.2, 0.08, 5, color.lightened(0.15))
	if "snow" in key or "ice" in key or "frost" in key:
		return _painter_mat(color, 3.0, 0.08, 6, Color("d8e7e5"))
	if "roof" in key or "tile" in key or "brick" in key:
		return _painter_mat(color, 3.0, 0.10, 7, color.darkened(0.25))
	if "stone" in key or "rock" in key or "wall" in key or "castle" in key or "ruin" in key:
		return _painter_mat(color, 3.2, 0.10, 8, color.darkened(0.24))
	return _painter_mat(color, 4.2, 0.085, 0, color.darkened(0.2))

func _box(parent: Node3D, name: String, pos: Vector3, size: Vector3, color: Color, bevel := false) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var mi := MeshInstance3D.new()
	mi.name = name
	mi.mesh = mesh
	mi.position = pos
	mi.material_override = _material_for_surface(name, color)
	parent.add_child(mi)
	return mi

func _sphere(parent: Node3D, name: String, pos: Vector3, radius: float, color: Color, height := -1.0) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = height if height > 0.0 else radius * 2.0
	mesh.radial_segments = 12
	mesh.rings = 8
	var mi := MeshInstance3D.new()
	mi.name = name
	mi.mesh = mesh
	mi.position = pos
	mi.material_override = _material_for_surface(name, color)
	parent.add_child(mi)
	return mi


func _add_box_collision(parent: Node3D, collision_name: String, local_pos: Vector3, dimensions: Vector3) -> void:
	var body := StaticBody3D.new()
	body.name = collision_name
	body.position = local_pos
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = dimensions
	collision.shape = shape
	body.add_child(collision)
	parent.add_child(body)


func _build_environment() -> void:
	# Dreamlike fantasy grade: warm sunlight, cool magical shadows and a soft
	# lavender-teal horizon. Keep the effect in Environment so every existing
	# biome, imported model and quest area inherits the same visual identity.
	world_environment = WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("263b50")
	sky_mat.sky_horizon_color = Color("b99a9a")
	sky_mat.ground_bottom_color = Color("172321")
	sky_mat.ground_horizon_color = Color("64736b")
	sky_mat.sun_angle_max = 18.0
	sky_mat.sun_curve = 0.12
	sky.sky_material = sky_mat
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("9a9bb0")
	e.ambient_light_energy = 0.72
	e.reflected_light_source = Environment.REFLECTION_SOURCE_BG
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 1.04
	e.tonemap_white = 1.12
	e.adjustment_enabled = true
	e.adjustment_brightness = 1.025
	e.adjustment_contrast = 1.045
	e.adjustment_saturation = 1.10
	e.glow_enabled = true
	e.glow_intensity = 0.28
	e.glow_strength = 0.62
	e.glow_bloom = 0.08
	e.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
	e.glow_hdr_threshold = 1.35
	e.glow_hdr_scale = 1.35
	e.fog_enabled = true
	e.fog_light_color = Color("8c9b9b")
	e.fog_density = 0.009
	e.fog_sun_scatter = 0.18
	world_environment.environment = e
	add_child(world_environment)
	sun_light = DirectionalLight3D.new()
	sun_light.rotation_degrees = Vector3(-42, -28, 0)
	sun_light.light_color = Color("ffe0b5")
	sun_light.light_energy = 1.12
	sun_light.shadow_enabled = true
	add_child(sun_light)

func _build_landscape() -> void:
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(700, 700)
	ground.mesh = plane
	ground.position.y = -0.12
	ground.material_override = _painter_mat(Color("34483a"), 2.2, 0.10, 1, Color("263a2e"))
	add_child(ground)
	var static_body := StaticBody3D.new()
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(700, 1, 700)
	col.shape = shape
	col.position.y = -0.5
	static_body.add_child(col)
	add_child(static_body)
	# layered hills create a painterly silhouette while keeping draw calls modest
	for i in range(18):
		var angle := TAU * float(i) / 18.0
		var hill := _sphere(self, "DistantHill_%02d" % i, Vector3(cos(angle)*285, 5.5, sin(angle)*285), 13.0 + float(i%4)*2.0, Color("34433f"), 19.0 + float(i%4)*3.0)
		hill.scale = Vector3(1.5, 0.72, 1.0)
	# distant layered silhouettes and vegetation clusters frame the playable space
	for i in range(28):
		var side := -1.0 if i % 2 == 0 else 1.0
		var shrub := _sphere(self, "MossShrub", Vector3(side * randf_range(18.0, 38.0), 0.45, randf_range(-42.0, 42.0)), randf_range(0.8, 1.6), Color("3e5742"), 1.2)
		shrub.scale = Vector3(1.5, 0.8, 1.0)
	# path
	var path := _box(self, "OldTrail", Vector3(0, 0.015, 5), Vector3(8, 0.06, 500), Color("75634c"))
	path.material_override = _painter_mat(Color("75634c"), 5.0, 0.07, 2, Color("493f34"))
	path.rotation.y = -0.08
	# Low-cost rock clusters and painterly ground accents frame the playable trail.
	for i in range(22):
		var side := -1.0 if i % 2 == 0 else 1.0
		var z := -34.0 + float(i) * 3.1
		var rock := _sphere(self, "TrailStone", Vector3(side * randf_range(7.0, 13.0), 0.28, z), randf_range(0.35, 0.8), Color("625f55"), 0.75)
		rock.scale = Vector3(1.35,0.7,0.9)
	# Vegetação de primeiro plano em MultiMesh: muito mais cheia sem criar
	# centenas de nós individuais nem sacrificar o desempenho no Android.
	var grass_mesh := SphereMesh.new()
	grass_mesh.radius = 0.34
	grass_mesh.height = 0.62
	grass_mesh.radial_segments = 7
	grass_mesh.rings = 4
	var grass_batch := MultiMesh.new()
	grass_batch.transform_format = MultiMesh.TRANSFORM_3D
	grass_batch.mesh = grass_mesh
	grass_batch.instance_count = 132
	for i in range(grass_batch.instance_count):
		var side := -1.0 if i % 2 == 0 else 1.0
		var x := side * randf_range(6.5, 34.0)
		var z := randf_range(-54.0, 58.0)
		var scale := Vector3(randf_range(0.75, 1.8), randf_range(0.7, 1.5), randf_range(0.75, 1.45))
		var transform := Transform3D(Basis().scaled(scale), Vector3(x, 0.18, z))
		grass_batch.set_instance_transform(i, transform)
	var grass_field := MultiMeshInstance3D.new()
	grass_field.name = "PainterlyGrassField"
	grass_field.multimesh = grass_batch
	grass_field.material_override = _painter_mat(Color("526b46"), 3.2, 0.12, 1, Color("304b37"))
	add_child(grass_field)

	# Pequenas flores pálidas pontuam a borda da trilha e guiam o olhar do jogador.
	var flower_mesh := SphereMesh.new()
	flower_mesh.radius = 0.12
	flower_mesh.height = 0.16
	flower_mesh.radial_segments = 6
	flower_mesh.rings = 3
	var flower_batch := MultiMesh.new()
	flower_batch.transform_format = MultiMesh.TRANSFORM_3D
	flower_batch.mesh = flower_mesh
	flower_batch.instance_count = 38
	for i in range(flower_batch.instance_count):
		var side := -1.0 if i % 2 == 0 else 1.0
		var x := side * randf_range(7.0, 25.0)
		var z := randf_range(-48.0, 52.0)
		var flower_scale := randf_range(0.7, 1.35)
		flower_batch.set_instance_transform(i, Transform3D(Basis().scaled(Vector3.ONE * flower_scale), Vector3(x, 0.24, z)))
	var flowers := MultiMeshInstance3D.new()
	flowers.name = "MoonlitWildflowers"
	flowers.multimesh = flower_batch
	flowers.material_override = _mat(Color("b5aa83"))
	add_child(flowers)

func _build_open_world_expansion() -> void:
	# Expanded wilderness ring: gives the connected regions breathing room without
	# adding thousands of expensive individual meshes on mobile.
	var trail_specs := [
		[Vector3(0.0, 0.02, -170.0), Vector3(7.0, 0.05, 150.0), 0.0],
		[Vector3(125.0, 0.02, -110.0), Vector3(150.0, 0.05, 6.0), 0.12],
		[Vector3(-115.0, 0.02, -95.0), Vector3(135.0, 0.05, 6.0), -0.18],
		[Vector3(0.0, 0.02, 175.0), Vector3(7.0, 0.05, 130.0), 0.0]
	]
	for i in range(trail_specs.size()):
		var spec: Array = trail_specs[i]
		var branch := _box(self, "WildernessTrail_%02d" % i, spec[0], spec[1], Color("665a48"))
		branch.rotation.y = float(spec[2])
	# Four discoverable clearings at the edges of the current playable regions.
	var clearings := [Vector3(-145, 0, -145), Vector3(150, 0, -55), Vector3(-150, 0, 75), Vector3(135, 0, 165)]
	var clearing_colors := [Color("53664a"), Color("4d625e"), Color("665947"), Color("555d4b")]
	for i in range(clearings.size()):
		var clearing := _sphere(self, "WildernessClearing_%02d" % i, clearings[i], 1.0, clearing_colors[i], 0.12)
		clearing.scale = Vector3(18.0, 0.08, 15.0)
		for j in range(7):
			var angle := TAU * float(j) / 7.0
			var tree_pos: Vector3 = clearings[i] + Vector3(cos(angle) * 20.0, 0.0, sin(angle) * 17.0)
			_build_tree(tree_pos, randf_range(0.8, 1.25))
	# Distant mountain wall makes the larger map read as a continuous landmass.
	for i in range(32):
		var angle := TAU * float(i) / 32.0
		var peak := _sphere(self, "OuterMountain_%02d" % i, Vector3(cos(angle) * 320.0, 18.0, sin(angle) * 320.0), 1.0, Color("303e3d"), 42.0 + float(i % 5) * 5.0)
		peak.scale = Vector3(1.8, 1.0, 1.25)


func _build_outer_regions() -> void:
	# Outer world expansion: five large, named biomes linked by broad dirt roads.
	# Geometry is deliberately low-cost and deterministic for Android devices.
	var routes := [
		[Vector3(0.0, 0.025, -205.0), Vector3(12.0, 0.05, 115.0), 0.0],
		[Vector3(-82.0, 0.025, -238.0), Vector3(150.0, 0.05, 7.0), -0.12],
		[Vector3(92.0, 0.025, -238.0), Vector3(150.0, 0.05, 7.0), 0.12],
		[Vector3(-155.0, 0.025, -125.0), Vector3(8.0, 0.05, 170.0), 0.0],
		[Vector3(155.0, 0.025, -125.0), Vector3(8.0, 0.05, 170.0), 0.0],
		[Vector3(0.0, 0.025, 205.0), Vector3(12.0, 0.05, 90.0), 0.0]
	]
	for i in range(routes.size()):
		var route: Array = routes[i]
		var road := _box(self, "OuterWorldRoad_%02d" % i, route[0], route[1], Color("665844"))
		road.rotation.y = float(route[2])
	# Ancient Forest — western woodland with a monumental ring of old trees.
	_build_biome_patch("AncientForest", Vector3(-158.0, 0.0, -104.0), Vector2(92.0, 104.0), Color("354d3c"))
	for i in range(19):
		var a := TAU * float(i) / 19.0
		var r := 25.0 + float(i % 4) * 5.0
		_build_tree(Vector3(-158.0 + cos(a) * r, 0.0, -104.0 + sin(a) * r), randf_range(1.1, 1.8))
	var ancient_stone := Node3D.new()
	ancient_stone.name = "AncientForestStandingStone"
	ancient_stone.position = Vector3(-158.0, 0.0, -104.0)
	add_child(ancient_stone)
	_box(ancient_stone, "StandingStone", Vector3(0.0, 3.0, 0.0), Vector3(3.0, 6.0, 1.5), Color("777b67"))
	_box(ancient_stone, "StoneCap", Vector3(0.0, 6.1, 0.0), Vector3(4.4, 0.7, 1.9), Color("8a896f"))
	_add_region_title("FLORESTA ANCESTRAL", Vector3(-158.0, 9.0, -104.0), Color("b5d09a"))
	# Frozen Mountain — icy shelves, blue crystal outcrops and a summit marker.
	_build_biome_patch("FrozenMountain", Vector3(-166.0, 0.0, -260.0), Vector2(104.0, 88.0), Color("697d80"))
	for i in range(13):
		var a := TAU * float(i) / 13.0
		var xz := Vector3(-166.0 + cos(a) * randf_range(22.0, 45.0), 0.0, -260.0 + sin(a) * randf_range(18.0, 38.0))
		var peak := _sphere(self, "FrozenMountainPeak", xz + Vector3(0.0, 7.0, 0.0), randf_range(5.0, 9.0), Color("71878a"), randf_range(18.0, 29.0))
		peak.scale = Vector3(1.25, 1.0, 1.1)
	for i in range(8):
		var crystal := _sphere(self, "FrostCrystal", Vector3(-190.0 + float(i) * 6.0, 1.8 + float(i % 3), -252.0 + randf_range(-8.0, 8.0)), 0.8, Color("9bc6c9"), 3.8)
		crystal.scale = Vector3(0.5, 1.5, 0.55)
	_add_region_title("MONTANHA GELADA", Vector3(-166.0, 15.0, -260.0), Color("c4e5e7"))
	# Red Gorge — broken canyon walls and a crimson fissure landmark.
	_build_biome_patch("RedGorge", Vector3(166.0, 0.0, -260.0), Vector2(108.0, 94.0), Color("62413c"))
	for i in range(17):
		var side := -1.0 if i % 2 == 0 else 1.0
		var z := -300.0 + float(i) * 5.0
		var cliff := _box(self, "RedGorgeCliff", Vector3(166.0 + side * randf_range(24.0, 42.0), randf_range(4.0, 9.0), z), Vector3(randf_range(7.0, 13.0), randf_range(9.0, 18.0), randf_range(5.0, 11.0)), Color("765047"))
		cliff.rotation.z = randf_range(-0.12, 0.12)
	for i in range(6):
		var shard := _sphere(self, "GorgeCrimsonShard", Vector3(145.0 + float(i) * 8.0, 2.0, -260.0 + randf_range(-10.0, 10.0)), 0.75, Color("a83c43"), 4.5)
		shard.scale = Vector3(0.55, 1.7, 0.6)
	_add_region_title("DESFILADEIRO RUBRO", Vector3(166.0, 13.0, -260.0), Color("e4a29a"))
	# Forgotten Ruins — ruined plaza, fallen columns and a sealed gate.
	_build_biome_patch("ForgottenRuins", Vector3(164.0, 0.0, -65.0), Vector2(88.0, 82.0), Color("555750"))
	for i in range(8):
		var a := TAU * float(i) / 8.0
		var pos := Vector3(164.0 + cos(a) * 19.0, 0.0, -65.0 + sin(a) * 17.0)
		var column := _box(self, "ForgottenColumn", pos + Vector3(0.0, 2.1, 0.0), Vector3(1.5, 4.2, 1.5), Color("77766c"))
		column.rotation.z = randf_range(-0.15, 0.15)
	_box(self, "ForgottenGateLintel", Vector3(164.0, 5.0, -43.0), Vector3(14.0, 1.2, 2.0), Color("898579"))
	_add_region_title("RUÍNAS ANTIGAS", Vector3(164.0, 10.0, -65.0), Color("d0c8ae"))
	# Golden Plains — open southern grassland with scattered boulders and wind markers.
	_build_biome_patch("GoldenPlains", Vector3(0.0, 0.0, 246.0), Vector2(136.0, 82.0), Color("77704b"))
	for i in range(24):
		var x := randf_range(-62.0, 62.0)
		var z := randf_range(212.0, 278.0)
		var grass := _sphere(self, "GoldenGrassClump", Vector3(x, 0.22, z), randf_range(0.7, 1.4), Color("9b8b50"), 0.6)
		grass.scale = Vector3(1.8, 0.55, 1.0)
	for i in range(5):
		var marker := _box(self, "PlainsWaystone", Vector3(-38.0 + float(i) * 19.0, 1.3, 240.0 + sin(float(i)) * 8.0), Vector3(0.55, 2.6, 0.55), Color("8a8162"))
		marker.rotation.z = randf_range(-0.08, 0.08)
	_add_region_title("PLANÍCIE DOURADA", Vector3(0.0, 8.0, 246.0), Color("e4d39a"))
	# Heart Temple — the late-game destination on the far eastern ridge.
	_build_biome_patch("HeartTemplePlateau", Vector3(165.0, 0.0, -330.0), Vector2(76.0, 56.0), Color("51464a"))
	for x in [-9.0, 9.0]:
		_box(self, "HeartTemplePillar", Vector3(165.0 + x, 5.0, -332.0), Vector3(2.4, 10.0, 2.4), Color("77716e"))
	_box(self, "HeartTempleRoof", Vector3(165.0, 10.5, -332.0), Vector3(25.0, 2.0, 8.0), Color("494348"))
	var heart := _sphere(self, "CrimsonHeartBeacon", Vector3(165.0, 7.0, -327.0), 1.5, Color("b33e50"), 2.5)
	heart.material_override = _painter_mat(Color("b33e50"), 8.0, 0.24)
	_add_region_title("TEMPLO DO CORAÇÃO", Vector3(165.0, 16.0, -330.0), Color("e7a1aa"))
	# Cloud Summit — a remote highland shrine reached by the northern road.
	_build_biome_patch("CloudSummit", Vector3(0.0, 0.0, -325.0), Vector2(86.0, 54.0), Color("59666a"))
	for i in range(7):
		var rock := _sphere(self, "CloudSummitBoulder", Vector3(-28.0 + float(i) * 9.0, 2.2, -325.0 + randf_range(-12.0, 12.0)), randf_range(2.0, 3.5), Color("778084"), randf_range(3.0, 5.0))
		rock.scale = Vector3(1.4, 1.0, 1.2)
	_box(self, "CloudSummitAltar", Vector3(0.0, 1.0, -325.0), Vector3(5.0, 2.0, 4.0), Color("8d9188"))
	_add_region_title("CUME DAS NUVENS", Vector3(0.0, 8.0, -325.0), Color("d3dcde"))


func _build_world_civilization() -> void:
	# Three settlements, a guild hub, a mountain cave, a buried dungeon and a ruined royal keep.
	# Every structure uses low-cost meshes and keeps the established painterly palette.
	_build_settlement("VilaDoCarvalho", Vector3(-112.0, 0.0, 92.0), "VILA DO CARVALHO", 7, Color("6b5948"), Color("8c765a"))
	_build_settlement("CidadeDePedra", Vector3(174.0, 0.0, 88.0), "CIDADE DE PEDRA", 11, Color("62645f"), Color("827f72"))
	# Nova vila independente: arquitetura de madeira, canal, roda d'água e mercado.
	_build_mill_village()

	# Dirt roads connect the new civil hubs to the original trail and outer regions.
	for road_spec in [
		[Vector3(-42.0, 0.025, 42.0), Vector3(7.0, 0.05, 74.0), -0.22],
		[Vector3(-75.0, 0.025, 76.0), Vector3(85.0, 0.05, 7.0), -0.08],
		[Vector3(70.0, 0.025, 82.0), Vector3(120.0, 0.05, 7.0), 0.02],
		[Vector3(205.0, 0.025, 45.0), Vector3(7.0, 0.05, 90.0), 0.0]
	]:
		var civil_road := _box(self, "CivilizationRoad", road_spec[0], road_spec[1], Color("6a5b49"))
		civil_road.rotation.y = float(road_spec[2])
	_build_guild_hall(Vector3(-34.0, 0.0, 66.0))
	_build_cave_complex()
	_build_royal_castle()
	_build_ancient_dungeon()
	_build_guild_relics()


func _build_imported_medieval_hamlet() -> void:
	# Modelos convertidos do Drive: integração aditiva, preservando as vilas originais.
	# O LOD1 entra como uma construção menor ao fundo; o LOD0 fica na área principal.
	var hamlet := Node3D.new()
	hamlet.name = "BairroDosArtesaosImportado"
	hamlet.position = Vector3(-300.0, 0.0, 150.0)
	add_child(hamlet)

	var road := _box(self, "ArtisanQuarterRoad", Vector3(-270.0, 0.035, 132.0), Vector3(68.0, 0.07, 4.2), Color("6a5947"))
	road.rotation.y = -0.55

	var placements := [
		{"fragment": "p3d_medieval_enterable_bld_13", "position": Vector3(-15.0, 0.0, -8.0), "scale": 0.82},
		{"fragment": "house_1exportversion", "position": Vector3(12.0, 0.0, -10.0), "scale": 0.82},
		{"fragment": "medhouse_", "position": Vector3(-3.0, 0.0, 10.0), "scale": 0.82},
		{"fragment": "lod0_long_house", "position": Vector3(19.0, 0.0, 10.0), "scale": 0.72},
		{"fragment": "lod1_long_house", "position": Vector3(31.0, 0.0, -8.0), "scale": 0.62}
	]
	var placed := 0
	for item in placements:
		var instance := EXTERNAL_ASSET_LOADER.instantiate_by_name(
			hamlet, "user_submitted", str(item.fragment), item.position, Vector3.ONE * float(item.scale)
		)
		if instance != null:
			instance.rotation.y = -0.18 if placed % 2 == 0 else 0.22
			_apply_dream_biome_tint(instance)
			placed += 1
			await get_tree().process_frame

	# Água fria e ponte de madeira dão uma entrada visual ao bairro.
	var stream_mesh := PlaneMesh.new()
	stream_mesh.size = Vector2(13.0, 5.0)
	var stream := MeshInstance3D.new()
	stream.name = "ArtisanQuarterStream"
	stream.mesh = stream_mesh
	stream.position = Vector3(1.0, 0.035, 25.0)
	var stream_material := _mat(Color("416e70"), 0.22)
	stream_material.metallic = 0.12
	stream_material.emission_enabled = true
	stream_material.emission = Color("244b50")
	stream_material.emission_energy_multiplier = 0.16
	stream.material_override = stream_material
	hamlet.add_child(stream)

	var bridge := EXTERNAL_ASSET_LOADER.instantiate_by_name(
		hamlet, "user_submitted", "medieval_wood_bridge", Vector3(1.0, 0.08, 25.0), Vector3.ONE * 0.82
	)
	if bridge != null:
		bridge.rotation.y = PI * 0.5
		_apply_dream_biome_tint(bridge)
		placed += 1

	_build_chestnut_billboard_grove(hamlet)
	_add_region_title("BAIRRO DOS ARTESÃOS", hamlet.position + Vector3(0.0, 12.0, 0.0), Color("d9bd91"))
	print("USER_SUBMITTED_MEDIEVAL_MODELS_LOADED: ", placed, "/6")


func _build_chestnut_billboard_grove(parent: Node3D) -> void:
	# Billboards de castanheira: alternativa leve para os modelos Maya/Vue que ainda
	# precisam ser exportados para FBX/GLB. Só usa imagens com transparência real.
	const TEXTURE_ROOT := "res://assets/textures/user_submitted"
	var directory := DirAccess.open(TEXTURE_ROOT)
	if directory == null:
		return
	var files := directory.get_files()
	files.sort()
	var billboard_files: Array[String] = []
	for file_name in files:
		if file_name.begins_with("EU43_Billboard_") and file_name.to_lower().ends_with(".png"):
			billboard_files.append(file_name)
	if billboard_files.is_empty():
		return

	var spots := [
		Vector3(-27.0, 0.0, 24.0), Vector3(-20.0, 0.0, 32.0),
		Vector3(-8.0, 0.0, 35.0), Vector3(10.0, 0.0, 34.0),
		Vector3(25.0, 0.0, 29.0), Vector3(34.0, 0.0, 17.0),
		Vector3(-34.0, 0.0, 9.0), Vector3(-29.0, 0.0, -2.0),
		Vector3(31.0, 0.0, -20.0)
	]
	var grove := Node3D.new()
	grove.name = "BosqueDeCastanheiras"
	parent.add_child(grove)
	var placed := 0
	for index in range(mini(billboard_files.size(), spots.size())):
		var texture := load(TEXTURE_ROOT.path_join(billboard_files[index])) as Texture2D
		if texture == null:
			continue
		if not texture.has_alpha():
			continue
		var tree_mesh := QuadMesh.new()
		tree_mesh.size = Vector2(7.0, 10.0)
		var tree := MeshInstance3D.new()
		tree.name = "CastanheiraBillboard_%02d" % index
		tree.mesh = tree_mesh
		tree.position = spots[index] + Vector3(0.0, 5.0, 0.0)
		tree.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var tree_material := StandardMaterial3D.new()
		tree_material.albedo_texture = texture
		tree_material.albedo_color = Color(0.94, 0.99, 0.94, 1.0)
		tree_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		tree_material.alpha_scissor_threshold = 0.18
		tree_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		tree_material.cull_mode = BaseMaterial3D.CULL_DISABLED
		tree_material.roughness = 1.0
		tree.material_override = tree_material
		grove.add_child(tree)
		placed += 1
	if placed == 0:
		grove.queue_free()
	else:
		print("CHESTNUT_BILLBOARDS_PLACED: ", placed)


func _apply_dream_biome_tint(root: Node) -> void:
	# Filtro leve de pigmento frio-esmeralda/lavanda: mantém mapas albedo e detalhes originais.
	if root == null:
		return
	var mesh_nodes := root.find_children("*", "MeshInstance3D", true, false)
	for mesh_node in mesh_nodes:
		var mesh_instance := mesh_node as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue
		for surface_index in range(mesh_instance.mesh.get_surface_count()):
			var source_material := mesh_instance.get_active_material(surface_index)
			if source_material == null:
				continue
			var tuned_material := source_material.duplicate(true) as StandardMaterial3D
			if tuned_material == null:
				continue
			tuned_material.albedo_color = tuned_material.albedo_color * Color(0.95, 0.98, 1.0, 1.0)
			tuned_material.roughness = clampf(tuned_material.roughness + 0.035, 0.0, 1.0)
			mesh_instance.set_surface_override_material(surface_index, tuned_material)


func _build_mill_village() -> void:
	var village_road := _box(self, "RoadToMillVillage", Vector3(-176.0, 0.035, 103.0), Vector3(132.0, 0.07, 5.0), Color("665844"))
	village_road.rotation.y = -0.07
	var center := Vector3(-238.0, 0.0, 112.0)
	var village := Node3D.new()
	village.name = "VilaDoMoinho"
	village.position = center
	add_child(village)

	# Praça de madeira e pedra, com canal raso atravessando a vila.
	var plaza := _box(village, "MillVillagePlaza", Vector3(0.0, 0.06, 0.0), Vector3(30.0, 0.16, 25.0), Color("786b55"))
	plaza.material_override = _painter_mat(Color("786b55"), 3.0, 0.12, 0, Color("51483b"))
	var canal := _box(village, "MillVillageCanal", Vector3(0.0, 0.12, -13.0), Vector3(34.0, 0.12, 3.2), Color("426b70"))
	var water_material := _mat(Color("426b70"), 0.2)
	water_material.metallic = 0.18
	water_material.emission_enabled = true
	water_material.emission = Color("244d55")
	water_material.emission_energy_multiplier = 0.18
	canal.material_override = water_material

	# Casas assimétricas de madeira e pedra, diferentes das duas cidades existentes.
	var house_positions := [
		Vector3(-12.0, 0.0, 7.0), Vector3(-3.0, 0.0, 10.0),
		Vector3(10.0, 0.0, 7.0), Vector3(14.0, 0.0, -5.0),
		Vector3(-12.0, 0.0, -4.0), Vector3(3.0, 0.0, 2.0)
	]
	for i in range(house_positions.size()):
		var house := Node3D.new()
		house.name = "MillHouse_%02d" % i
		house.position = house_positions[i]
		village.add_child(house)
		var width := 4.2 + float(i % 3) * 0.45
		var depth := 4.0 + float(i % 2) * 0.55
		var wall_color := Color("75624b") if i % 2 == 0 else Color("625b4c")
		_box(house, "StoneFoundation", Vector3(0.0, 0.35, 0.0), Vector3(width + 0.35, 0.7, depth + 0.35), Color("575950"))
		var walls := _box(house, "TimberAndPlasterWalls", Vector3(0.0, 1.95, 0.0), Vector3(width, 3.2, depth), wall_color)
		_add_box_collision(house, "MillHouseCollision", Vector3(0.0, 1.95, 0.0), Vector3(width, 3.2, depth))
		_box(house, "FrontDoor", Vector3(0.0, 1.0, depth * 0.51), Vector3(0.95, 2.0, 0.12), Color("3f3027"))
		var roof := _box(house, "SteepRoof", Vector3(0.0, 3.75, 0.0), Vector3(width + 1.0, 0.55, depth + 1.0), Color("704b3e") if i % 2 == 0 else Color("665747"))
		roof.rotation.z = 0.08 if i % 2 == 0 else -0.08
		_box(house, "RoofRidge", Vector3(0.0, 4.08, 0.0), Vector3(width + 1.1, 0.25, 0.48), Color("493a32"))
		for side in [-1.0, 1.0]:
			_box(house, "TimberPost", Vector3(side * width * 0.43, 1.95, depth * 0.52), Vector3(0.18, 3.25, 0.18), Color("49372b"))
		if i % 2 == 0:
			_box(house, "Window", Vector3(width * 0.27, 2.25, depth * 0.515), Vector3(0.78, 0.82, 0.12), Color("d3ad70"))

	# Moinho: roda vertical, pás e edifício de moagem junto ao canal.
	var mill := Node3D.new()
	mill.name = "WaterMill"
	mill.position = Vector3(0.0, 0.0, -18.0)
	village.add_child(mill)
	_box(mill, "MillBuilding", Vector3(0.0, 2.1, -2.8), Vector3(8.0, 4.2, 6.0), Color("695844"))
	_box(mill, "MillBuildingRoof", Vector3(0.0, 4.45, -2.8), Vector3(9.0, 0.5, 7.0), Color("594238"))
	var wheel := MeshInstance3D.new()
	wheel.name = "WaterWheel"
	var wheel_mesh := TorusMesh.new()
	wheel_mesh.inner_radius = 1.45
	wheel_mesh.outer_radius = 1.72
	wheel_mesh.rings = 12
	wheel_mesh.ring_segments = 10
	wheel.mesh = wheel_mesh
	wheel.position = Vector3(0.0, 2.0, 0.35)
	wheel.rotation.x = PI * 0.5
	wheel.material_override = _mat(Color("79563a"))
	mill.add_child(wheel)
	for i in range(8):
		var angle := TAU * float(i) / 8.0
		var paddle := _box(mill, "WaterWheelPaddle_%02d" % i, Vector3(cos(angle) * 1.56, 2.0 + sin(angle) * 1.56, 0.35), Vector3(0.22, 0.82, 0.16), Color("8a6543"))
		paddle.rotation.z = -angle
	var axle := MeshInstance3D.new()
	var axle_mesh := CylinderMesh.new()
	axle_mesh.top_radius = 0.16
	axle_mesh.bottom_radius = 0.16
	axle_mesh.height = 1.2
	axle.mesh = axle_mesh
	axle.position = Vector3(0.0, 2.0, 0.35)
	axle.rotation.x = PI * 0.5
	axle.material_override = _mat(Color("49372b"))
	mill.add_child(axle)

	# Ponte, barracas e iluminação dão identidade própria ao povoado.
	var bridge := _box(village, "CanalBridge", Vector3(0.0, 0.55, -13.0), Vector3(5.5, 0.28, 4.2), Color("806044"))
	for side in [-1.0, 1.0]:
		_box(village, "BridgeRail", Vector3(side * 2.45, 1.05, -13.0), Vector3(0.18, 0.9, 4.0), Color("4b392d"))
	var market := Node3D.new()
	market.name = "MillVillageMarket"
	market.position = Vector3(8.0, 0.0, 14.0)
	village.add_child(market)
	_box(market, "MarketCounter", Vector3(0.0, 0.8, 0.0), Vector3(4.8, 1.6, 2.0), Color("654a35"))
	_box(market, "MarketCanopy", Vector3(0.0, 2.0, 0.0), Vector3(5.5, 0.22, 3.0), Color("9a6248"))
	for x in [-2.2, 2.2]:
		_box(market, "MarketPost", Vector3(x, 1.5, 0.0), Vector3(0.16, 3.0, 0.16), Color("49372b"))
	for i in range(4):
		var lamp_position := Vector3(-12.0 + float(i) * 8.0, 2.2, 15.0)
		_box(village, "LanternPost", lamp_position, Vector3(0.16, 3.2, 0.16), Color("44372d"))
		var lantern := _sphere(village, "LanternGlow", lamp_position + Vector3(0.0, 1.25, 0.0), 0.24, Color("e4b16b"), 0.38)
		lantern.material_override = _painter_mat(Color("e4b16b"), 7.0, 0.1)
	_add_region_title("VILA DO MOINHO", center + Vector3(0.0, 10.0, 0.0), Color("e8c99a"))


func _build_settlement(settlement_name: String, center: Vector3, title_text: String, house_count: int, wall_color: Color, roof_color: Color) -> void:
	var root := Node3D.new()
	root.name = settlement_name
	root.position = center
	add_child(root)
	var plaza := _box(root, "CentralPlaza", Vector3(0.0, 0.025, 0.0), Vector3(34.0, 0.08, 28.0), Color("766b59"))
	plaza.material_override = _painter_mat(Color("766b59"), 3.0, 0.1, 0, Color("514b41"))
	# A small well gives the plaza a readable focal point.
	_box(root, "VillageWellBase", Vector3(0.0, 0.55, 0.0), Vector3(3.0, 1.1, 2.6), Color("686b64"))
	_box(root, "VillageWellRim", Vector3(0.0, 1.18, 0.0), Vector3(3.5, 0.22, 3.0), Color("99917d"))
	for i in range(house_count):
		var angle := TAU * float(i) / float(house_count)
		var radius := 17.0 if i % 2 == 0 else 23.0
		var house_pos := Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
		var house := Node3D.new()
		house.name = "House_%02d" % i
		house.position = house_pos
		root.add_child(house)
		var w := 4.2 + float(i % 3) * 0.55
		var d := 4.0 + float(i % 2) * 0.6
		_box(house, "StoneAndTimberWalls", Vector3(0.0, 1.7, 0.0), Vector3(w, 3.4, d), wall_color)
		_add_box_collision(house, "HouseSolidWalls", Vector3(0.0, 1.7, 0.0), Vector3(w, 3.4, d))
		_box(house, "TimberFrontDoor", Vector3(0.0, 1.05, d * 0.51), Vector3(1.05, 2.1, 0.12), Color("49382e"))
		_box(house, "RoofFront", Vector3(0.0, 3.65, 0.0), Vector3(w + 1.0, 0.45, d + 1.0), roof_color).rotation.z = 0.06 if i % 2 == 0 else -0.06
		_box(house, "RoofRidge", Vector3(0.0, 4.0, 0.0), Vector3(w + 1.2, 0.28, 0.55), roof_color.darkened(0.18))
		for side in [-1.0, 1.0]:
			_box(house, "TimberBeam", Vector3(side * (w * 0.42), 1.7, d * 0.53), Vector3(0.18, 3.5, 0.18), Color("4a392e"))
		if i % 3 == 0:
			var chimney := _box(house, "Chimney", Vector3(w * 0.28, 4.0, -d * 0.18), Vector3(0.7, 1.5, 0.75), Color("62564b"))
			chimney.rotation.z = -0.08
	for i in range(5):
		var lamp_pos := Vector3(-13.0 + float(i) * 6.5, 1.7, 11.0)
		_box(root, "PlazaLanternPost", lamp_pos, Vector3(0.18, 3.4, 0.18), Color("44372e"))
		_sphere(root, "PlazaLantern", lamp_pos + Vector3(0.0, 1.45, 0.0), 0.28, Color("e6b36c"), 0.42)
	_add_region_title(title_text, center + Vector3(0.0, 11.0, 0.0), Color("e1d2b4"))

func _build_guild_hall(center: Vector3) -> void:
	var guild := Node3D.new()
	guild.name = "GuildaDosVigias"
	guild.position = center
	add_child(guild)
	_box(guild, "GuildStoneHall", Vector3(0.0, 3.0, 0.0), Vector3(18.0, 6.0, 13.0), Color("565b58"))
	_box(guild, "GuildRoof", Vector3(0.0, 6.5, 0.0), Vector3(20.0, 1.0, 15.0), Color("51433b"))
	for x in [-6.0, 6.0]:
		_box(guild, "GuildFrontPillar", Vector3(x, 3.0, 6.7), Vector3(1.2, 6.0, 1.2), Color("898477"))
	_box(guild, "GuildCrestShield", Vector3(0.0, 5.0, 7.0), Vector3(3.4, 3.4, 0.5), Color("9a7650"))
	var board := Node3D.new()
	board.name = "GuildContractBoard"
	board.position = Vector3(0.0, 0.0, 10.0)
	board.set_meta("interact_name", "Quadro da Guilda")
	guild.add_child(board)
	_box(board, "BoardLegs", Vector3(0.0, 1.25, 0.0), Vector3(2.6, 2.5, 0.28), Color("4a382d"))
	_box(board, "BoardFace", Vector3(0.0, 2.35, 0.2), Vector3(3.2, 1.7, 0.2), Color("b49a70"))
	for i in range(3):
		_box(board, "ContractPaper_%d" % i, Vector3(-0.85 + float(i) * 0.85, 2.35, 0.34), Vector3(0.55, 0.95, 0.06), Color("e0d2ad"))
	_add_region_title("GUILDA DOS VIGIAS", center + Vector3(0.0, 10.0, 0.0), Color("e8c88f"))

func _build_cave_complex() -> void:
	var cave := Node3D.new()
	cave.name = "CavernaDoEco"
	cave.position = Vector3(-220.0, 0.0, -255.0)
	add_child(cave)
	# Dark mountain mouth, jagged stone ribs and a traversable dark chamber.
	for i in range(9):
		var angle := PI * float(i) / 8.0
		var rock := _sphere(cave, "CaveMouthRock", Vector3(cos(angle) * 12.0, 3.0 + sin(angle) * 7.0, 0.0), 1.0, Color("3b4645"), 1.0)
		rock.scale = Vector3(3.0, 4.0, 3.5)
	var mouth := _box(cave, "CaveShadow", Vector3(0.0, 3.0, 1.0), Vector3(12.0, 7.0, 0.4), Color("171e21"))
	mouth.material_override = _mat(Color("171e21"))
	_box(cave, "CaveFloor", Vector3(0.0, 0.0, -17.0), Vector3(18.0, 0.3, 38.0), Color("454b47"))
	for side in [-1.0, 1.0]:
		for i in range(5):
			var wall := _sphere(cave, "CaveInteriorWall", Vector3(side * 9.0, 2.0, -5.0 - float(i) * 7.0), 1.0, Color("394341"), 1.0)
			wall.scale = Vector3(3.0, 5.0, 4.2)
	for i in range(6):
		var crystal := _sphere(cave, "EchoCrystal", Vector3(-5.0 + float(i) * 2.0, 1.3 + float(i % 2), -20.0 - float(i % 3) * 4.0), 0.7, Color("6b9c9b"), 2.8)
		crystal.scale = Vector3(0.55, 1.6, 0.6)
		crystal.material_override = _painter_mat(Color("6b9c9b"), 7.0, 0.22)
	_add_region_title("CAVERNA DO ECO", Vector3(-220.0, 12.0, -255.0), Color("a9c9c1"))

func _start_itch_dungeon_streaming() -> void:
	if itch_dungeon_stream_requested:
		return
	itch_dungeon_stream_requested = true
	for model_path in ITCH_DUNGEON_MODEL_PATHS:
		if not ResourceLoader.exists(model_path):
			push_warning("Asset do itch.io ausente no pacote exportado: " + model_path)
			continue
		var request_error := ResourceLoader.load_threaded_request(model_path, "PackedScene", true)
		if request_error != OK and request_error != ERR_BUSY:
			push_warning("Não foi possível iniciar carregamento do modelo: " + model_path)


func _poll_itch_dungeon_streaming() -> void:
	var all_finished := true
	for model_path in ITCH_DUNGEON_MODEL_PATHS:
		if not ResourceLoader.exists(model_path):
			continue
		var status := ResourceLoader.load_threaded_get_status(model_path)
		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			all_finished = false
		elif status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_warning("Falha ao importar modelo do itch.io: " + model_path)
	if not all_finished:
		return
	# Bloqueia reentrada do _process enquanto as três cenas são instanciadas.
	itch_dungeon_assets_loaded = true
	var dungeon := get_node_or_null("MasmorraDasCinzas") as Node3D
	if not is_instance_valid(dungeon):
		return
	var placements := [
		{"path": ITCH_DUNGEON_MODEL_PATHS[0], "name": "ItchRunicCircle", "position": Vector3(0.0, 0.18, -20.0), "scale": 0.72},
		{"path": ITCH_DUNGEON_MODEL_PATHS[1], "name": "ItchObsidianSentinel", "position": Vector3(0.0, 0.0, -39.0), "scale": 0.78},
		{"path": ITCH_DUNGEON_MODEL_PATHS[2], "name": "ItchCursedCodex", "position": Vector3(0.0, 1.8, -58.0), "scale": 0.62}
	]
	for placement in placements:
		var packed := ResourceLoader.load_threaded_get(placement.path) as PackedScene
		if packed == null:
			continue
		var instance := packed.instantiate() as Node3D
		if instance == null:
			continue
		instance.name = placement.name
		instance.position = placement.position
		instance.scale = Vector3.ONE * float(placement.scale)
		dungeon.add_child(instance)
	print("ITCH_DUNGEON_GAMEPLAY_ASSETS_LOADED: ", ITCH_DUNGEON_MODEL_PATHS.size())


func _build_ancient_dungeon() -> void:
	var dungeon := Node3D.new()
	dungeon.name = "MasmorraDasCinzas"
	dungeon.position = Vector3(226.0, 0.0, 94.0)
	add_child(dungeon)
	_box(dungeon, "DungeonApproach", Vector3(0.0, 0.03, 0.0), Vector3(34.0, 0.08, 24.0), Color("514d48"))
	for x in [-6.0, 6.0]:
		_box(dungeon, "DungeonGatePillar", Vector3(x, 3.5, -5.0), Vector3(2.0, 7.0, 2.2), Color("5e625f"))
	_box(dungeon, "DungeonGateLintel", Vector3(0.0, 7.0, -5.0), Vector3(15.0, 1.5, 2.4), Color("77746a"))
	_box(dungeon, "DungeonDarkDoor", Vector3(0.0, 3.0, -5.0), Vector3(9.0, 6.0, 0.3), Color("1c2527"))
	# Three connected chambers are represented as a sunken hall, side crypt and sealed altar room.
	for chamber in range(3):
		var z := -20.0 - float(chamber) * 19.0
		_box(dungeon, "DungeonChamberFloor_%d" % chamber, Vector3(0.0, -0.25, z), Vector3(22.0 - float(chamber) * 2.0, 0.5, 18.0), Color("4c4d49"))
		for side in [-1.0, 1.0]:
			_box(dungeon, "DungeonWall_%d" % chamber, Vector3(side * (11.0 - float(chamber)), 3.0, z), Vector3(1.4, 6.0, 18.0), Color("5e5b53"))
		for x in [-7.0, 7.0]:
			_box(dungeon, "DungeonPillar_%d" % chamber, Vector3(x, 2.6, z - 5.0), Vector3(1.3, 5.2, 1.3), Color("777164"))
	var altar := _box(dungeon, "AshenAltar", Vector3(0.0, 1.0, -60.0), Vector3(5.0, 2.0, 3.0), Color("71604f"))
	altar.material_override = _painter_mat(Color("71604f"), 5.0, 0.14)
	_add_region_title("MASMORRA DAS CINZAS", Vector3(226.0, 12.0, 94.0), Color("d1b99c"))
	# O pacote do itch.io é carregado sob demanda quando o jogador chega à masmorra.

func _build_royal_castle() -> void:
	var castle := Node3D.new()
	castle.name = "CasteloDoSilencio"
	castle.position = Vector3(250.0, 0.0, -300.0)
	add_child(castle)
	_build_biome_patch("CastleCourtyard", Vector3(250.0, 0.0, -300.0), Vector2(66.0, 54.0), Color("49494b"))
	_box(castle, "CastleKeep", Vector3(0.0, 8.0, 0.0), Vector3(26.0, 16.0, 20.0), Color("65615d"))
	_box(castle, "KeepRoof", Vector3(0.0, 16.5, 0.0), Vector3(29.0, 1.0, 23.0), Color("423d40"))
	for x in [-16.0, 16.0]:
		for z in [-11.0, 11.0]:
			_box(castle, "CastleTower", Vector3(x, 9.0, z), Vector3(6.0, 18.0, 6.0), Color("77716b"))
			var roof := _sphere(castle, "CastleTowerCap", Vector3(x, 19.0, z), 3.5, Color("4c4143"), 5.0)
			roof.scale = Vector3(1.0, 1.3, 1.0)
	_box(castle, "CastleGate", Vector3(0.0, 4.0, 10.4), Vector3(8.0, 8.0, 0.5), Color("29292d"))
	_box(castle, "CastleBridge", Vector3(0.0, 0.3, 20.0), Vector3(12.0, 0.6, 15.0), Color("77746c"))
	_add_region_title("CASTELO DO SILÊNCIO", Vector3(250.0, 25.0, -300.0), Color("d7b7b5"))

func _build_guild_relics() -> void:
	var relic_positions := [Vector3(-220.0, 0.0, -278.0), Vector3(226.0, 0.0, 34.0), Vector3(250.0, 0.0, -300.0)]
	var relic_names := ["Selo da Caverna", "Selo das Cinzas", "Selo do Castelo"]
	for i in range(3):
		var relic := Node3D.new()
		relic.name = "GuildRelic_%d" % i
		relic.position = relic_positions[i]
		relic.set_meta("relic_name", relic_names[i])
		relic.visible = not guild_relic_ids.has(i)
		add_child(relic)
		var stone := _sphere(relic, "GuildRelicStone", Vector3(0.0, 0.9, 0.0), 0.75, Color("9c7753"), 1.2)
		stone.material_override = _painter_mat(Color("b08b5e"), 7.0, 0.22)
		var glow := OmniLight3D.new()
		glow.position = Vector3(0.0, 1.5, 0.0)
		glow.light_color = Color("e0ae70")
		glow.light_energy = 0.65
		glow.omni_range = 5.0
		relic.add_child(glow)


func _build_biome_patch(region_name: String, center: Vector3, dimensions: Vector2, tint: Color) -> void:
	var patch := _box(self, region_name + "Ground", Vector3(center.x, -0.045, center.z), Vector3(dimensions.x, 0.09, dimensions.y), tint)
	var region_key := region_name.to_lower()
	var terrain_pattern := 1
	if "frozen" in region_key or "cloud" in region_key:
		terrain_pattern = 6
	elif "ruin" in region_key or "temple" in region_key or "castle" in region_key:
		terrain_pattern = 8
	elif "gorge" in region_key:
		terrain_pattern = 2
	patch.material_override = _painter_mat(tint, 2.5, 0.12, terrain_pattern, tint.darkened(0.28))
	var edge_material := _painter_mat(tint.darkened(0.25), 3.0, 0.1)
	for side in [-1.0, 1.0]:
		var ridge := _box(self, region_name + "BorderRidge", Vector3(center.x + side * dimensions.x * 0.5, 1.0, center.z), Vector3(2.0, 2.0, dimensions.y), tint.darkened(0.3))
		ridge.material_override = edge_material


func _add_region_title(text_value: String, world_pos: Vector3, tint: Color) -> void:
	var title := Label3D.new()
	title.name = "RegionTitle_" + text_value.replace(" ", "_")
	title.text = text_value
	title.position = world_pos
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	title.font_size = 36
	title.modulate = tint
	add_child(title)

func _build_tree(pos: Vector3, scale_factor := 1.0) -> void:
	# Silhueta de árvore pintada: raízes expostas, tronco afunilado,
	# galhos visíveis e copa em camadas. Mantém poucos nós por árvore no Android.
	var tree := Node3D.new()
	tree.name = "PainterlyAncientTree"
	tree.position = pos
	tree.scale = Vector3.ONE * scale_factor
	add_child(tree)

	var bark := _painter_mat(Color("49372d"), 4.6, 0.16, 4, Color("2d2925"))
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.20
	trunk_mesh.bottom_radius = 0.48
	trunk_mesh.height = 4.8
	trunk_mesh.radial_segments = 9
	var trunk := MeshInstance3D.new()
	trunk.name = "TaperedBark"
	trunk.mesh = trunk_mesh
	trunk.position = Vector3(0.0, 2.4, 0.0)
	trunk.material_override = bark
	tree.add_child(trunk)

	# Raízes largas quebram a aparência de cilindro plantado no chão.
	for i in range(4):
		var angle := TAU * float(i) / 4.0 + 0.35
		var root_mesh := CylinderMesh.new()
		root_mesh.top_radius = 0.08
		root_mesh.bottom_radius = 0.25
		root_mesh.height = 1.45
		root_mesh.radial_segments = 7
		var root := MeshInstance3D.new()
		root.name = "ExposedRoot_%02d" % i
		root.mesh = root_mesh
		root.position = Vector3(cos(angle) * 0.48, 0.48, sin(angle) * 0.48)
		root.rotation.z = cos(angle) * 0.52
		root.rotation.x = sin(angle) * 0.52
		root.material_override = bark
		tree.add_child(root)

	# Dois galhos principais aparecem por baixo da copa e dão leitura de árvore.
	for i in range(2):
		var side := -1.0 if i == 0 else 1.0
		var branch_mesh := CylinderMesh.new()
		branch_mesh.top_radius = 0.055
		branch_mesh.bottom_radius = 0.16
		branch_mesh.height = 2.0
		branch_mesh.radial_segments = 7
		var branch := MeshInstance3D.new()
		branch.name = "MainBranch_%d" % i
		branch.mesh = branch_mesh
		branch.position = Vector3(side * 0.58, 3.65, 0.0)
		branch.rotation.z = -side * 0.72
		branch.rotation.x = side * 0.16
		branch.material_override = bark
		tree.add_child(branch)

	# Copa irregular em camadas, com tons alternados para parecer pintada à mão.
	var leaf_colors := [
		Color("344d3d"), Color("405f48"), Color("526f50"),
		Color("3b5843"), Color("61784f"), Color("496447")
	]
	var crown_specs := [
		[Vector3(0.0, 5.35, 0.0), 2.05, Vector3(1.12, 0.88, 1.0)],
		[Vector3(-1.15, 4.75, 0.05), 1.48, Vector3(1.15, 0.88, 0.92)],
		[Vector3(1.12, 4.95, -0.12), 1.55, Vector3(1.08, 0.92, 1.0)],
		[Vector3(-0.62, 6.05, -0.1), 1.42, Vector3(1.0, 0.94, 0.92)],
		[Vector3(0.72, 6.25, 0.12), 1.38, Vector3(1.08, 0.9, 1.0)],
		[Vector3(0.0, 6.85, 0.0), 1.12, Vector3(1.0, 0.95, 0.9)]
	]
	for i in range(crown_specs.size()):
		var spec: Array = crown_specs[i]
		var crown := _sphere(tree, "LayeredCanopy_%02d" % i, spec[0], float(spec[1]), leaf_colors[i], float(spec[1]) * 1.42)
		crown.scale = spec[2]
		crown.material_override = _painter_mat(leaf_colors[i], 3.8, 0.15, 1, leaf_colors[i].darkened(0.28))

	# Pequenos planos de luz nas bordas da copa dão volume sem partículas.
	for i in range(3):
		var accent_pos := Vector3(-1.05 + float(i) * 1.05, 5.9 + float(i % 2) * 0.42, 0.92)
		var accent_color := Color("71875a") if i == 1 else Color("5d7952")
		var accent := _sphere(tree, "CanopyLightPatch_%d" % i, accent_pos, 0.48, accent_color, 0.72)
		accent.scale = Vector3(1.2, 0.58, 0.72)
		accent.material_override = _painter_mat(accent_color, 5.0, 0.12, 1, Color("3f5b43"))

func _build_ruins_and_props() -> void:
	for p in [Vector3(-16,0,-12),Vector3(17,0,-19),Vector3(-22,0,22),Vector3(23,0,28),Vector3(-34,0,2),Vector3(34,0,-2),Vector3(10,0,40),Vector3(-12,0,-42)]:
		_build_tree(p, randf_range(0.8,1.35))
	# broken stone gate, readable landmark
	for x in [-5.5,5.5]:
		_box(self,"GatePillar",Vector3(x,2.6,-27),Vector3(2.2,5.2,2.0),Color("77746a"))
	_box(self,"GateLintel",Vector3(0,5.0,-27),Vector3(13,1.6,2.4),Color("817c70"))
	_box(self,"BrokenLintel",Vector3(2.8,6.1,-27),Vector3(4.2,0.7,2.1),Color("6c6b63")).rotation.z = 0.22
	_build_gothic_gate_accents()
	# weathered trail lanterns help navigation in the dusk
	for z in [-15.0, 1.0, 18.0, 34.0]:
		var post := _box(self, "LanternPost", Vector3(5.6,1.25,z), Vector3(0.18,2.5,0.18), Color("49372d"))
		_box(self, "LanternHousing", Vector3(5.6,2.55,z), Vector3(0.62,0.72,0.62), Color("5a4939"))
		_sphere(self, "LanternGlow", Vector3(5.6,2.55,z), 0.22, Color("e5a45e"), 0.32)
	# village ruins and a warm camp
	_box(self,"RuinedWall",Vector3(-13,1.5,-4),Vector3(9,3,1),Color("777166"))
	_box(self,"RuinedWallSide",Vector3(-17,1.5,-8),Vector3(1,3,7),Color("777166"))
	_sphere(self,"CampFireGlow",Vector3(9,0.9,10),0.8,Color("ff9a46"),1.4)
	for i in range(4):
		var ember := _sphere(self, "FireEmber", Vector3(9 + randf_range(-0.35,0.35), 1.0 + i * 0.38, 10 + randf_range(-0.3,0.3)), 0.12, Color("ffc16c"), 0.24)
		ember.material_override = _painter_mat(Color("ffc16c"), 8.0, 0.05)
	var fire := OmniLight3D.new()
	fire.position = Vector3(9,2.0,10)
	fire.light_color = Color("ff8a45")
	fire.light_energy = 2.2
	fire.omni_range = 10
	add_child(fire)

func _build_gothic_gate_accents() -> void:
	# Carved caps, iron finials and crimson seals turn the entrance into a clear landmark.
	for side in [-1.0, 1.0]:
		var cap := _box(self, "GateCarvedCap", Vector3(side * 5.5, 5.35, -25.82), Vector3(2.55, 0.42, 2.28), Color("514d49"))
		PLUGIN_ASSET_LOADER.apply_aqueduct_stone(cap)
		cap.rotation.z = side * -0.035
		var footing := _box(self, "GateFooting", Vector3(side * 5.5, 0.32, -25.82), Vector3(2.55, 0.64, 2.28), Color("514d49"))
		PLUGIN_ASSET_LOADER.apply_aqueduct_stone(footing)
		footing.material_override = _material_for_surface("cut stone", Color("514d49"))
		for spike_index in range(2):
			var spike := _box(self, "GateIronFinial", Vector3(side * (4.65 + float(spike_index) * 1.25), 6.0, -26.0), Vector3(0.22, 1.25, 0.22), Color("343638"))
			spike.rotation.z = side * 0.18
	for i in range(3):
		var seal := _sphere(self, "GateCrimsonSeal", Vector3(-2.4 + float(i) * 2.4, 4.85, -25.55), 0.19, Color("a83d4b"), 0.42)
		seal.scale = Vector3(0.72, 1.0, 0.42)
		var seal_material := StandardMaterial3D.new()
		seal_material.albedo_color = Color("a83d4b")
		seal_material.emission_enabled = true
		seal_material.emission = Color("8f2638")
		seal_material.emission_energy_multiplier = 0.7
		seal.material_override = seal_material
	var gate_glow := OmniLight3D.new()
	gate_glow.name = "GateCrimsonGlow"
	gate_glow.position = Vector3(0.0, 5.0, -24.8)
	gate_glow.light_color = Color("a83d4b")
	gate_glow.light_energy = 0.42
	gate_glow.omni_range = 6.0
	add_child(gate_glow)


func _build_region_landmarks() -> void:
	# Broken watchtower and a red corruption scar give the clearing a memorable skyline.
	var tower := Node3D.new()
	tower.name = "OldWatchtower"
	tower.position = Vector3(-29.0, 0.0, -31.0)
	add_child(tower)
	_box(tower, "TowerBase", Vector3(0, 2.2, 0), Vector3(4.2, 4.4, 4.0), Color("625e55"))
	_box(tower, "TowerUpper", Vector3(0, 5.4, 0), Vector3(3.3, 2.0, 3.2), Color("777166"))
	_box(tower, "TowerRoof", Vector3(0, 6.7, 0), Vector3(4.5, 0.5, 4.3), Color("463c36"))
	for x in [-1.0, 1.0]:
		_box(tower, "WindowVoid", Vector3(x, 5.1, 1.64), Vector3(0.48, 1.0, 0.08), Color("20282a"))
	# Corrupted crystal cluster near the far edge, visible as a future objective.
	var crystal_root := Node3D.new()
	crystal_root.name = "CorruptionScar"
	crystal_root.position = Vector3(0, 0, -43)
	add_child(crystal_root)
	for i in range(5):
		var crystal := _sphere(crystal_root, "RubroShard", Vector3(-2.0 + i, 1.0 + (i % 3) * 0.45, randf_range(-0.7, 0.7)), 0.7, Color("8e303c"), 2.2)
		crystal.scale = Vector3(0.55, 1.8, 0.55)
		crystal.material_override = _painter_mat(Color("8e303c"), 7.0, 0.18)
	var glow := OmniLight3D.new()
	glow.position = Vector3(0, 2.0, -43)
	glow.light_color = Color("c33b4b")
	glow.light_energy = 1.1
	glow.omni_range = 8.0
	crystal_root.add_child(glow)
	# Shrine is an optional side objective and a clear landmark.
	var shrine := Node3D.new()
	shrine.name = "OldShrine"
	shrine.position = Vector3(15, 0, 25)
	shrine.set_meta("interact_name", "Santuário Esquecido")
	shrine.set_meta("used", saved_shrine_used)
	add_child(shrine)
	_box(shrine, "ShrinePlinth", Vector3(0, 0.6, 0), Vector3(2.6, 1.2, 2.2), Color("68665f"))
	_box(shrine, "ShrineStone", Vector3(0, 2.1, 0), Vector3(1.3, 2.2, 0.8), Color("858075"))
	var rune := _sphere(shrine, "RuneLight", Vector3(0, 2.1, 0.48), 0.25, Color("dfb96b"), 0.3)
	rune.material_override = _painter_mat(Color("dfb96b"), 8.0, 0.12)
	var shrine_light := OmniLight3D.new()
	shrine_light.position = Vector3(0, 2.4, 1.0)
	shrine_light.light_color = Color("d5a85c")
	shrine_light.light_energy = 0.8
	shrine_light.omni_range = 5.0
	shrine.add_child(shrine_light)

func _build_plugin_world_expansion() -> void:
	# Conteudo extra inspirado nos assets Meshy/Aqueduct: observatorio lunar,
	# trilha de monolitos e ruinas de vigia. Tudo e procedural e leve para mobile.
	var expansion := Node3D.new()
	expansion.name = "PluginInspiredWorldExpansion"
	add_child(expansion)

	# Moonwell: um pequeno ponto de descanso e orientacao no caminho norte.
	var moonwell := Node3D.new()
	moonwell.name = "MoonwellSanctuary"
	moonwell.position = Vector3(27.0, 0.0, -55.0)
	expansion.add_child(moonwell)
	var foundation := _box(moonwell, "MoonwellFoundation", Vector3.ZERO, Vector3(9.0, 0.42, 8.0), Color("555950"))
	foundation.material_override = _material_for_surface("cut stone", Color("555950"))
	var inner_ring := _box(moonwell, "MoonwellInnerStone", Vector3(0.0, 0.26, 0.0), Vector3(5.5, 0.22, 5.5), Color("74766a"))
	inner_ring.material_override = _material_for_surface("cut stone", Color("74766a"))
	var pool := _sphere(moonwell, "MoonwellWater", Vector3(0.0, 0.44, 0.0), 2.1, Color("527f83"), 0.18)
	pool.scale = Vector3(1.0, 0.12, 1.0)
	var water_material := _mat(Color("527f83"), 0.18)
	water_material.metallic = 0.28
	water_material.emission_enabled = true
	water_material.emission = Color("2c6970")
	water_material.emission_energy_multiplier = 0.45
	pool.material_override = water_material
	for i in range(4):
		var angle := TAU * float(i) / 4.0
		var offset := Vector3(cos(angle) * 3.05, 0.0, sin(angle) * 3.05)
		var pillar := _box(moonwell, "MoonwellPillar_%d" % i, offset + Vector3(0.0, 1.45, 0.0), Vector3(0.62, 2.9, 0.62), Color("686b62"))
		pillar.material_override = _material_for_surface("ruined stone", Color("686b62"))
		_box(moonwell, "MoonwellPillarCap_%d" % i, offset + Vector3(0.0, 2.95, 0.0), Vector3(0.92, 0.24, 0.92), Color("8b8978"))
	var moon_crystal := _sphere(moonwell, "MoonwellCrystal", Vector3(0.0, 1.05, 0.0), 0.52, Color("72b6b2"), 1.5)
	moon_crystal.scale = Vector3(0.58, 1.65, 0.58)
	moon_crystal.material_override = _painter_mat(Color("72b6b2"), 7.0, 0.12, 8, Color("326e70"))
	var moon_light := OmniLight3D.new()
	moon_light.name = "MoonwellGlow"
	moon_light.position = Vector3(0.0, 2.4, 0.0)
	moon_light.light_color = Color("75c6c1")
	moon_light.light_energy = 0.8
	moon_light.omni_range = 10.0
	moonwell.add_child(moon_light)

	# Ruinas da vigia: pedras tombadas, brasas e um marco de pedra com runas.
	var outpost := Node3D.new()
	outpost.name = "FallenWatchOutpost"
	outpost.position = Vector3(-35.0, 0.0, -63.0)
	expansion.add_child(outpost)
	_box(outpost, "OutpostFoundation", Vector3(0.0, 0.12, 0.0), Vector3(11.0, 0.24, 8.0), Color("4e5049"))
	for i in range(5):
		var x := -4.0 + float(i) * 2.0
		var wall := _box(outpost, "BrokenWallSegment_%d" % i, Vector3(x, 1.05 + float(i % 2) * 0.18, -3.1), Vector3(1.7, 2.1, 0.55), Color("65645a"))
		wall.rotation.z = float(i % 2) * 0.08 - 0.04
	var fallen_column := _box(outpost, "FallenColumn", Vector3(2.2, 0.48, 1.2), Vector3(4.6, 0.52, 0.62), Color("777469"))
	fallen_column.rotation.z = -0.16
	var rune_stone := _box(outpost, "OutpostRuneStone", Vector3(-3.8, 1.6, 2.0), Vector3(1.0, 3.2, 0.72), Color("77776c"))
	var rune := _sphere(outpost, "OutpostRune", Vector3(-3.8, 1.85, 2.42), 0.24, Color("c18b5c"), 0.42)
	rune.scale = Vector3(0.65, 1.0, 0.28)
	rune.material_override = _painter_mat(Color("c18b5c"), 8.0, 0.12, 8, Color("704b3a"))
	var campfire := _sphere(outpost, "OutpostEmberBed", Vector3(2.7, 0.32, 2.8), 0.9, Color("392f2a"), 0.3)
	campfire.scale = Vector3(1.2, 0.28, 1.0)
	for i in range(4):
		var ember := _sphere(outpost, "OutpostEmber_%d" % i, Vector3(2.4 + randf_range(-0.38, 0.38), 0.55 + randf_range(0.0, 0.45), 2.8 + randf_range(-0.32, 0.32)), 0.12, Color("ff9b55"), 0.2)
		ember.material_override = _painter_mat(Color("ff9b55"), 8.0, 0.05)
	var firelight := OmniLight3D.new()
	firelight.position = Vector3(2.7, 1.5, 2.8)
	firelight.light_color = Color("ff9452")
	firelight.light_energy = 1.1
	firelight.omni_range = 7.0
	outpost.add_child(firelight)

	# Pedras de orientacao levam o jogador do caminho antigo ate o pântano.
	for i in range(7):
		var z := -61.0 - float(i) * 5.0
		var x := 7.5 + sin(float(i) * 0.72) * 2.2
		var marker := _box(expansion, "AncientTrailMarker_%d" % i, Vector3(x, 0.85, z), Vector3(0.72, 1.7, 0.62), Color("5f6259"))
		marker.rotation.z = randf_range(-0.1, 0.1)
		var marker_rune := _sphere(expansion, "AncientTrailRune_%d" % i, Vector3(x, 1.0, z + 0.34), 0.13, Color("9bb7a0"), 0.24)
		marker_rune.material_override = _painter_mat(Color("9bb7a0"), 8.0, 0.08, 8, Color("47685b"))

	# Pequenas luzes guiam sem poluir a tela nem criar muitos draw calls.
	for i in range(3):
		var torch_root := Node3D.new()
		torch_root.name = "AncientTrailTorch_%d" % i
		torch_root.position = Vector3(-8.0, 0.0, -49.0 - float(i) * 14.0)
		expansion.add_child(torch_root)
		_box(torch_root, "TorchPost", Vector3(0.0, 1.0, 0.0), Vector3(0.18, 2.0, 0.18), Color("49372d"))
		var flame := _sphere(torch_root, "TorchFlame", Vector3(0.0, 2.15, 0.0), 0.22, Color("e8a45c"), 0.42)
		flame.material_override = _painter_mat(Color("e8a45c"), 8.0, 0.05)
		var torch_light := OmniLight3D.new()
		torch_light.position = Vector3(0.0, 2.2, 0.0)
		torch_light.light_color = Color("e6a15e")
		torch_light.light_energy = 0.72
		torch_light.omni_range = 6.0
		torch_root.add_child(torch_light)

	# Three additional landmarks extend exploration beyond the first expansion.
	var cinder_root := Node3D.new()
	cinder_root.name = "CinderHollow"
	cinder_root.position = Vector3(48.0, 0.0, -101.0)
	add_child(cinder_root)
	_box(cinder_root, "CinderCaveLeftPillar", Vector3(-2.2, 1.7, 0.0), Vector3(0.9, 3.4, 1.1), Color("51463f"))
	_box(cinder_root, "CinderCaveRightPillar", Vector3(2.2, 1.7, 0.0), Vector3(0.9, 3.4, 1.1), Color("51463f"))
	_box(cinder_root, "CinderCaveLintel", Vector3(0.0, 3.35, 0.0), Vector3(5.3, 0.8, 1.2), Color("625044"))
	for crystal_index in range(3):
		var crystal := _sphere(cinder_root, "CinderCrystal_%02d" % crystal_index, Vector3(-1.0 + float(crystal_index) * 1.0, 0.55, -1.1), 0.42, Color("a75c54"), 1.25)
		crystal.rotation.z = deg_to_rad(float(crystal_index - 1) * 18.0)
		var crystal_light := OmniLight3D.new()
		crystal_light.position = crystal.position + Vector3(0.0, 0.7, 0.0)
		crystal_light.light_color = Color("c56b5b")
		crystal_light.light_energy = 0.38
		crystal_light.omni_range = 4.5
		cinder_root.add_child(crystal_light)

	var bridge_root := Node3D.new()
	bridge_root.name = "WardenStoneBridge"
	bridge_root.position = Vector3(-48.0, 0.0, -104.0)
	add_child(bridge_root)
	_box(bridge_root, "WardenBridgeDeck", Vector3(0.0, 0.22, 0.0), Vector3(10.0, 0.45, 3.4), Color("65645d"))
	for side in [-1.0, 1.0]:
		_box(bridge_root, "WardenBridgeParapet", Vector3(side * 4.35, 0.85, 0.0), Vector3(0.55, 1.25, 3.4), Color("77736a"))
		for pillar_index in range(3):
			_box(bridge_root, "WardenBridgePillar", Vector3(side * 4.35, 1.75, -1.15 + float(pillar_index) * 1.15), Vector3(0.8, 0.65, 0.65), Color("91806a"))
	for rune_index in range(5):
		var bridge_rune := _sphere(bridge_root, "WardenBridgeRune_%02d" % rune_index, Vector3(-3.2 + float(rune_index) * 1.6, 0.48, -1.42), 0.16, Color("8db5a0"), 0.12)
		bridge_rune.material_override = _painter_mat(Color("8db5a0"), 7.0, 0.04)

	var bell_root := Node3D.new()
	bell_root.name = "EchoingBellTower"
	bell_root.position = Vector3(0.0, 0.0, -121.0)
	add_child(bell_root)
	for corner in [Vector2(-1.5, -1.5), Vector2(1.5, -1.5), Vector2(-1.5, 1.5), Vector2(1.5, 1.5)]:
		_box(bell_root, "BellTowerPillar", Vector3(corner.x, 2.2, corner.y), Vector3(0.42, 4.4, 0.42), Color("625b51"))
	_box(bell_root, "BellTowerTopBeam", Vector3(0.0, 4.35, 0.0), Vector3(3.8, 0.45, 3.8), Color("76634e"))
	var bell := _sphere(bell_root, "EchoingBell", Vector3(0.0, 3.1, 0.0), 0.62, Color("b08b52"), 1.0)
	bell.scale = Vector3(0.85, 1.0, 0.85)
	var bell_light := OmniLight3D.new()
	bell_light.position = Vector3(0.0, 3.0, 0.0)
	bell_light.light_color = Color("e4c27e")
	bell_light.light_energy = 0.5
	bell_light.omni_range = 7.0
	bell_root.add_child(bell_light)

func _build_swamp_region() -> void:
	# A connected second biome: shallow poisonous pools, dead trees and three cleanseable totems.
	var swamp_ground := _box(self, "SwampMire", Vector3(0, -0.08, -91), Vector3(74, 0.16, 76), Color("354b43"))
	swamp_ground.material_override = _painter_mat(Color("354b43"), 2.8, 0.16, 3, Color("243a33"))
	for i in range(8):
		var x := randf_range(-29.0, 29.0)
		var z := randf_range(-119.0, -63.0)
		var pool := _sphere(self, "ToxicPool", Vector3(x, 0.025, z), randf_range(2.0, 4.2), Color("425f58"), 0.12)
		pool.scale = Vector3(1.5, 0.08, 1.0)
	for i in range(15):
		var x := randf_range(-33.0, 33.0)
		var z := randf_range(-125.0, -61.0)
		var trunk := _box(self, "DeadSwampTree", Vector3(x, 2.0, z), Vector3(0.45, 4.0, 0.45), Color("403b34"))
		trunk.rotation.z = randf_range(-0.18, 0.18)
		for branch in [-1.0, 1.0]:
			var limb := _box(self, "DeadBranch", Vector3(x + branch * 0.75, 3.2, z), Vector3(1.8, 0.22, 0.24), Color("4b4439"))
			limb.rotation.z = branch * -0.42
	for i in range(3):
		var x: float = [-13.0, 0.0, 13.0][i]
		var totem := Node3D.new()
		totem.name = "SwampTotem_%d" % i
		totem.position = Vector3(x, 0.0, -91.0 - (i % 2) * 9.0)
		totem.set_meta("used", swamp_totem_ids.has(i))
		add_child(totem)
		_box(totem, "TotemStone", Vector3(0, 1.25, 0), Vector3(1.0, 2.5, 0.9), Color("5c6254"))
		var purified := swamp_totem_ids.has(i)
		var rune_color := Color("91b69a") if purified else Color("a83d50")
		var rune := _sphere(totem, "TotemRune", Vector3(0, 1.45, 0.5), 0.28, rune_color, 0.34)
		rune.material_override = _painter_mat(rune_color, 8.0, 0.2)
	var boss_marker := _sphere(self, "WitchAltar", Vector3(0, 0.4, -119), 2.2, Color("40544d"), 0.7)
	boss_marker.scale = Vector3(1.5, 0.35, 1.5)
	var mist_light := OmniLight3D.new()
	mist_light.position = Vector3(0, 3.0, -92)
	mist_light.light_color = Color("76a18b")
	mist_light.light_energy = 0.65
	mist_light.omni_range = 24.0
	add_child(mist_light)

func _build_river_region() -> void:
	# Rio Prateado: a second major biome with a traversable bridge and strong navigation landmarks.
	var water_mesh := PlaneMesh.new()
	water_mesh.size = Vector2(20.0, 58.0)
	var water := MeshInstance3D.new()
	water.name = "SilverRiverWater"
	water.mesh = water_mesh
	water.position = Vector3(55.0, 0.035, -127.0)
	var water_material := StandardMaterial3D.new()
	water_material.albedo_color = Color("477b88")
	water_material.metallic = 0.22
	water_material.roughness = 0.24
	water_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	water_material.albedo_color.a = 0.88
	water_material.emission_enabled = true
	water_material.emission = Color("244b59")
	water_material.emission_energy_multiplier = 0.35
	var river_tint := Color("477b88", 0.88)
	water.material_override = _painter_mat(river_tint, 2.2, 0.08, 5, Color("244b59"))
	add_child(water)
	# Pale stone banks and a broad bridge connect both sides of the river.
	for side in [-1.0, 1.0]:
		for i in range(9):
			var z := -153.0 + float(i) * 6.4
			var bank := _sphere(self, "SilverBankStone", Vector3(55.0 + side * randf_range(10.5, 12.5), 0.35, z), randf_range(0.8, 1.6), Color("777d78"), 1.2)
			bank.scale = Vector3(1.4, 0.7, 1.0)
	var bridge := _box(self, "SilverRiverBridge", Vector3(55.0, 0.32, -127.0), Vector3(25.0, 0.58, 4.2), Color("8a8678"))
	bridge.material_override = _painter_mat(Color("8a8678"), 6.0, 0.12)
	for side in [-1.0, 1.0]:
		for x in [45.0, 65.0]:
			_box(self, "BridgePillar", Vector3(x, 1.0, -127.0 + side * 2.0), Vector3(0.65, 1.4, 0.65), Color("686e6b"))
	# Silver reeds and luminous stones give the river its own identity without heavy particle costs.
	for i in range(22):
		var side := -1.0 if i % 2 == 0 else 1.0
		var reed_x := 55.0 + side * randf_range(11.0, 15.0)
		var reed_z := randf_range(-153.0, -101.0)
		var reed := _box(self, "SilverReed", Vector3(reed_x, 0.85, reed_z), Vector3(0.12, randf_range(0.8, 1.8), 0.12), Color("819d8c"))
		reed.rotation.z = randf_range(-0.22, 0.22)
	var beacon := _sphere(self, "RiverBeacon", Vector3(73.0, 1.2, -127.0), 0.65, Color("8ac6c4"), 1.0)
	beacon.material_override = _painter_mat(Color("8ac6c4"), 7.0, 0.18)
	var beacon_light := OmniLight3D.new()
	beacon_light.position = Vector3(73.0, 2.2, -127.0)
	beacon_light.light_color = Color("74c6c2")
	beacon_light.light_energy = 1.0
	beacon_light.omni_range = 9.0
	add_child(beacon_light)
	# The drowned road now has a readable destination: a broken gate above the
	# river's source. Its silhouette guides exploration toward the Leviathan.
	var gate := Node3D.new()
	gate.name = "DrownedRiverGate"
	gate.position = Vector3(55.0, 0.0, -157.0)
	add_child(gate)
	for side in [-1.0, 1.0]:
		var pillar := _box(gate, "GatePillar", Vector3(side * 5.2, 3.0, 0.0), Vector3(1.5, 6.0, 1.7), Color("626c68"))
		pillar.rotation.z = side * -0.035
		_box(gate, "PillarFoot", Vector3(side * 5.2, 0.55, 0.0), Vector3(2.1, 1.1, 2.2), Color("777d75"))
	var lintel := _box(gate, "BrokenGateLintel", Vector3(0.0, 6.0, 0.0), Vector3(12.0, 1.25, 1.8), Color("77786d"))
	lintel.rotation.z = -0.045
	var keystone := _sphere(gate, "RiverKeystone", Vector3(0.0, 5.1, 0.98), 0.72, Color("83bdb8"), 1.15)
	keystone.material_override = _painter_mat(Color("83bdb8"), 8.0, 0.2)
	var keystone_light := OmniLight3D.new()
	keystone_light.position = Vector3(0.0, 5.1, 1.1)
	keystone_light.light_color = Color("65bdb5")
	keystone_light.light_energy = 0.8
	keystone_light.omni_range = 7.0
	gate.add_child(keystone_light)
	# Fallen masonry, half-buried on both banks, makes the route feel ancient.
	for i in range(6):
		var side := -1.0 if i % 2 == 0 else 1.0
		var rubble := _box(self, "RiverRuinRubble", Vector3(55.0 + side * randf_range(14.0, 20.0), 0.35, -112.0 - float(i) * 7.0), Vector3(randf_range(1.8, 3.2), 0.7, randf_range(1.2, 2.4)), Color("666e68"))
		rubble.rotation.y = randf_range(-0.5, 0.5)
	# Small upright markers distinguish the old crossing from ordinary shoreline.
	for i in range(4):
		var marker_x := 43.0 + float(i) * 8.0
		var marker := _box(self, "RiverWaystone", Vector3(marker_x, 1.0, -105.0), Vector3(0.55, 2.0, 0.55), Color("657d78"))
		marker.rotation.z = randf_range(-0.08, 0.08)
	_build_river_relics()
	_build_river_treasure_chests()
	_build_river_shrine_puzzle()


func _build_whisper_grove() -> void:
	# Optional side-area east of the Silver River, connected by a readable stepping-stone path.
	var island := _sphere(self, "WhisperGroveIsland", Vector3(96.0, -0.06, -145.0), 1.0, Color("405b4d"), 0.22)
	island.scale = Vector3(19.0, 0.18, 17.0)
	island.material_override = _painter_mat(Color("405b4d"), 2.4, 0.18)
	var moss_ring := _sphere(self, "WhisperGroveMossRing", Vector3(96.0, 0.025, -145.0), 1.0, Color("526b53"), 0.08)
	moss_ring.scale = Vector3(14.5, 0.10, 12.5)
	for i in range(5):
		var step := _sphere(self, "GroveSteppingStone", Vector3(70.0 + float(i) * 5.0, 0.16, -145.0 + sin(float(i) * 0.7) * 1.8), 1.0, Color("777d72"), 0.34)
		step.scale = Vector3(2.2, 0.28, 1.65)
		step.rotation.y = -0.16 + float(i) * 0.06
	# Pale trunks and low canopies frame the clearing without blocking the route.
	for i in range(7):
		var angle := TAU * float(i) / 7.0
		var tree_pos := Vector3(96.0 + cos(angle) * 14.0, 0.0, -145.0 + sin(angle) * 12.0)
		var trunk := _box(self, "GroveSilverBirch", tree_pos + Vector3(0.0, 2.0, 0.0), Vector3(0.55, 4.0, 0.55), Color("77766b"))
		trunk.rotation.z = cos(angle) * 0.07
		var canopy := _sphere(self, "GroveMutedCanopy", tree_pos + Vector3(0.0, 4.5, 0.0), 2.4, Color("536b59"), 2.9)
		canopy.scale = Vector3(1.2, 0.82, 1.0)
		canopy.material_override = _painter_mat(Color("536b59"), 3.2, 0.16)
	# Three small lantern altars make the side area a compact exploration objective.
	var lantern_positions := [Vector3(88.0, 0.0, -139.0), Vector3(103.0, 0.0, -137.0), Vector3(96.0, 0.0, -154.0)]
	for i in range(3):
		var lantern := Node3D.new()
		lantern.name = "WhisperLantern_%d" % i
		lantern.position = lantern_positions[i]
		lantern.set_meta("lit", whisper_lantern_ids.has(i))
		add_child(lantern)
		_box(lantern, "LanternStoneBase", Vector3(0.0, 0.42, 0.0), Vector3(1.6, 0.84, 1.5), Color("666d64"))
		_box(lantern, "LanternPillar", Vector3(0.0, 1.55, 0.0), Vector3(0.58, 1.55, 0.58), Color("777b70"))
		var glow_color := Color("8ac9bc") if whisper_lantern_ids.has(i) else Color("405c58")
		var flame := _sphere(lantern, "LanternFlame", Vector3(0.0, 2.55, 0.0), 0.42, glow_color, 0.78)
		flame.material_override = _painter_mat(glow_color, 7.0, 0.22)
		var light := OmniLight3D.new()
		light.name = "LanternLight"
		light.position = Vector3(0.0, 2.65, 0.0)
		light.light_color = Color("79cbbd")
		light.light_energy = 0.9 if whisper_lantern_ids.has(i) else 0.16
		light.omni_range = 7.0
		lantern.add_child(light)
	# A distant stone arch is the grove's skyline marker.
	var arch := Node3D.new()
	arch.name = "WhisperGroveArch"
	arch.position = Vector3(96.0, 0.0, -162.0)
	add_child(arch)
	_box(arch, "GroveArchLeft", Vector3(-3.0, 2.2, 0.0), Vector3(0.8, 4.4, 0.9), Color("686f68"))
	_box(arch, "GroveArchRight", Vector3(3.0, 2.2, 0.0), Vector3(0.8, 4.4, 0.9), Color("686f68"))
	_box(arch, "GroveArchTop", Vector3(0.0, 4.25, 0.0), Vector3(6.8, 0.8, 1.0), Color("77796d"))

	_spawn_whisper_stag_guardian()


func _spawn_whisper_stag_guardian() -> void:
	# A low-cost procedural stone spirit keeps the side quest playable while
	# the separately generated Thrixel GLB awaits canonical asset vendoring.
	var guardian := Node3D.new()
	guardian.name = "WhisperStagGuardian"
	guardian.position = Vector3(96.0, 0.0, -145.0)
	add_child(guardian)

	_box(guardian, "StagPedestal", Vector3(0.0, 0.24, 0.0), Vector3(2.5, 0.48, 2.0), Color("4a554d"))
	_box(guardian, "StagPedestalTrim", Vector3(0.0, 0.51, 0.0), Vector3(2.18, 0.08, 1.72), Color("857453"))
	var torso := _sphere(guardian, "StagStoneTorso", Vector3(0.0, 1.58, 0.0), 0.62, Color("58645a"), 1.12)
	torso.scale = Vector3(1.48, 0.88, 0.92)
	var chest := _sphere(guardian, "StagStoneChest", Vector3(0.0, 1.73, 0.42), 0.42, Color("667267"), 0.86)
	chest.scale = Vector3(0.95, 1.12, 0.82)
	var neck := _sphere(guardian, "StagStoneNeck", Vector3(0.0, 2.05, 0.48), 0.34, Color("59675e"), 0.95)
	neck.scale = Vector3(0.88, 1.45, 0.86)
	var head := _sphere(guardian, "StagStoneHead", Vector3(0.0, 2.73, 0.72), 0.34, Color("6a7468"), 0.58)
	head.scale = Vector3(1.0, 1.1, 0.9)
	var muzzle := _sphere(guardian, "StagStoneMuzzle", Vector3(0.0, 2.59, 1.0), 0.17, Color("8a8977"), 0.3)
	muzzle.scale = Vector3(1.0, 0.8, 1.25)

	for leg_data in [
		[Vector3(-0.43, 0.94, -0.32), "FrontLeft"],
		[Vector3(0.43, 0.94, -0.32), "FrontRight"],
		[Vector3(-0.43, 0.94, 0.36), "BackLeft"],
		[Vector3(0.43, 0.94, 0.36), "BackRight"]
	]:
		var leg_position: Vector3 = leg_data[0]
		var leg_name: String = leg_data[1]
		var leg := _box(guardian, "StagLeg" + leg_name, leg_position, Vector3(0.17, 0.9, 0.18), Color("46534b"))
		leg.rotation.x = -0.035 if "Front" in leg_name else 0.035
		_box(guardian, "StagHoof" + leg_name, Vector3(leg_position.x, 0.43, leg_position.z + 0.025), Vector3(0.22, 0.16, 0.24), Color("343d39"))

	_add_stag_antler_segment(guardian, "StagAntlerLeftMain", Vector3(-0.17, 2.9, 0.72), Vector3(-0.43, 3.28, 0.72), 0.065, Color("b39a68"))
	_add_stag_antler_segment(guardian, "StagAntlerLeftOuter", Vector3(-0.43, 3.28, 0.72), Vector3(-0.72, 3.48, 0.72), 0.05, Color("b39a68"))
	_add_stag_antler_segment(guardian, "StagAntlerLeftTip", Vector3(-0.43, 3.28, 0.72), Vector3(-0.46, 3.68, 0.72), 0.045, Color("c4aa74"))
	_add_stag_antler_segment(guardian, "StagAntlerLeftInner", Vector3(-0.35, 3.16, 0.72), Vector3(-0.12, 3.43, 0.72), 0.045, Color("b39a68"))
	_add_stag_antler_segment(guardian, "StagAntlerRightMain", Vector3(0.17, 2.9, 0.72), Vector3(0.43, 3.28, 0.72), 0.065, Color("b39a68"))
	_add_stag_antler_segment(guardian, "StagAntlerRightOuter", Vector3(0.43, 3.28, 0.72), Vector3(0.72, 3.48, 0.72), 0.05, Color("b39a68"))
	_add_stag_antler_segment(guardian, "StagAntlerRightTip", Vector3(0.43, 3.28, 0.72), Vector3(0.46, 3.68, 0.72), 0.045, Color("c4aa74"))
	_add_stag_antler_segment(guardian, "StagAntlerRightInner", Vector3(0.35, 3.16, 0.72), Vector3(0.12, 3.43, 0.72), 0.045, Color("b39a68"))

	var eye_material := StandardMaterial3D.new()
	eye_material.albedo_color = Color("9debd7")
	eye_material.emission_enabled = true
	eye_material.emission = Color("58d9c0")
	eye_material.emission_energy_multiplier = 2.0
	eye_material.roughness = 0.22
	for side in [-1.0, 1.0]:
		var eye := _sphere(guardian, "StagSpiritEye", Vector3(side * 0.16, 2.74, 1.005), 0.075, Color("9debd7"))
		eye.material_override = eye_material
	var rune := _sphere(guardian, "StagPedestalRune", Vector3(0.0, 0.67, 1.02), 0.12, Color("72cfc0"))
	rune.material_override = eye_material

	# Peitoral ritual, placas de musgo e veios luminosos esculpidos na pedra.
	var chest_medallion := _sphere(guardian, "StagChestMedallion", Vector3(0.0, 1.78, 0.79), 0.19, Color("b39a68"), 0.075)
	chest_medallion.scale = Vector3(1.0, 1.0, 0.42)
	chest_medallion.material_override = eye_material
	for side in [-1.0, 1.0]:
		var shoulder_plate := _sphere(guardian, "StagShoulderPlate", Vector3(side * 0.53, 1.91, 0.18), 0.25, Color("737b6b"), 0.32)
		shoulder_plate.scale = Vector3(1.0, 0.72, 0.82)
		var shoulder_moss := _sphere(guardian, "StagShoulderMoss", Vector3(side * 0.57, 2.08, 0.18), 0.16, Color("536f59"), 0.18)
		shoulder_moss.scale = Vector3(1.25, 0.45, 0.9)
		var antler_band := _sphere(guardian, "StagAntlerBand", Vector3(side * 0.31, 3.12, 0.72), 0.085, Color("7bcbbb"), 0.12)
		antler_band.scale = Vector3(1.0, 1.0, 0.65)
		antler_band.material_override = eye_material
	# Thin inlays read as old cracks filled with spirit light, not extra armor.
	for crack_index in range(3):
		var crack := _box(guardian, "StagStoneInlay_%d" % crack_index, Vector3(-0.22 + float(crack_index) * 0.22, 1.55 + float(crack_index % 2) * 0.16, 0.56), Vector3(0.035, 0.28, 0.035), Color("72cfc0"))
		crack.rotation.z = -0.35 if crack_index % 2 == 0 else 0.42
		crack.material_override = eye_material
	var neck_collar := _sphere(guardian, "StagAncientCollar", Vector3(0.0, 2.17, 0.58), 0.34, Color("887553"), 0.11)
	neck_collar.scale = Vector3(1.08, 0.48, 0.88)
	var collar_gem := _sphere(guardian, "StagCollarGem", Vector3(0.0, 2.18, 0.91), 0.09, Color("a1ead6"), 0.16)
	collar_gem.material_override = eye_material

	var eye_glow := OmniLight3D.new()
	eye_glow.name = "StagSpiritGlow"
	eye_glow.position = Vector3(0.0, 2.72, 1.12)
	eye_glow.light_color = Color("72cfc0")
	eye_glow.light_energy = 0.55
	eye_glow.omni_range = 6.5
	guardian.add_child(eye_glow)

	var idle := create_tween().set_loops()
	idle.tween_property(guardian, "rotation:y", 0.045, 2.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	idle.tween_property(guardian, "rotation:y", -0.045, 5.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_request_whisper_stag_model(guardian)


func _request_whisper_stag_model(guardian: Node3D) -> void:
	# Existing Thrixel model is fetched once and cached locally; the procedural
	# guardian remains visible if the player is offline or the service is down.
	const STAG_URL := "https://api.thrixel.com/api/v1/10f1f722-53d8-4ca0-b99b-e0e687bc8fec/download?format=glb&quality=full&texture_size=1024"
	const CACHE_PATH := "user://cache/whisper_stag.glb"
	if FileAccess.file_exists(CACHE_PATH):
		var cached := FileAccess.open(CACHE_PATH, FileAccess.READ)
		if cached and _apply_whisper_stag_model(cached.get_buffer(cached.get_length()), guardian):
			return
	var request := HTTPRequest.new()
	request.name = "WhisperStagModelRequest"
	request.timeout = 30.0
	guardian.add_child(request)
	request.request_completed.connect(_on_whisper_stag_model_downloaded.bind(guardian, request))
	var request_error := request.request(STAG_URL)
	if request_error != OK:
		push_warning("Não foi possível iniciar o download do Guardião Cervo: %s" % request_error)
		request.queue_free()


func _on_whisper_stag_model_downloaded(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, guardian: Node3D, request: HTTPRequest) -> void:
	if is_instance_valid(request):
		request.queue_free()
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200 or body.is_empty():
		push_warning("O Guardião Cervo 3D não pôde ser baixado; mantendo o modelo local.")
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://cache"))
	var cache_file := FileAccess.open("user://cache/whisper_stag.glb", FileAccess.WRITE)
	if cache_file:
		cache_file.store_buffer(body)
	_apply_whisper_stag_model(body, guardian)


func _apply_whisper_stag_model(data: PackedByteArray, guardian: Node3D) -> bool:
	if data.is_empty() or not is_instance_valid(guardian):
		return false
	var gltf := GLTFDocument.new()
	var state := GLTFState.new()
	var parse_error := gltf.append_from_buffer(data, "", state)
	if parse_error != OK:
		push_warning("O modelo GLB do Guardião Cervo não pôde ser interpretado.")
		return false
	var imported := gltf.generate_scene(state)
	if imported == null:
		return false
	imported.name = "ThrixelWhisperStag"
	imported.position = Vector3(0.0, 0.54, 0.0)
	guardian.add_child(imported)
	# Keep the stone pedestal and hide only the temporary procedural animal.
	for child in guardian.get_children():
		if child is MeshInstance3D and child.name not in ["StagPedestal", "StagPedestalTrim"]:
			child.visible = false
	return true


func _add_stag_antler_segment(parent: Node3D, segment_name: String, start: Vector3, finish: Vector3, radius: float, color: Color) -> MeshInstance3D:
	var direction := finish - start
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius * 0.52
	mesh.bottom_radius = radius
	mesh.height = direction.length()
	mesh.radial_segments = 8
	var segment := MeshInstance3D.new()
	segment.name = segment_name
	segment.mesh = mesh
	segment.position = (start + finish) * 0.5
	segment.rotation.z = atan2(-direction.x, direction.y)
	segment.material_override = _material_for_surface("StagAntler", color)
	parent.add_child(segment)
	return segment

func _build_river_treasure_chests() -> void:
	# Three optional caches reward exploration on both banks and near the old gate.
	var positions := [Vector3(39.0, 0.0, -137.0), Vector3(91.0, 0.0, -115.0), Vector3(62.0, 0.0, -164.0)]
	for i in range(positions.size()):
		var chest := Node3D.new()
		chest.name = "RiverTreasureChest_%d" % i
		chest.position = positions[i]
		chest.set_meta("opened", river_chest_ids.has(i))
		add_child(chest)
		_box(chest, "ChestBase", Vector3(0.0, 0.48, 0.0), Vector3(1.45, 0.86, 0.92), Color("465b5b"))
		_box(chest, "ChestFrontBand", Vector3(0.0, 0.5, 0.48), Vector3(1.52, 0.16, 0.12), Color("b49a63"))
		_box(chest, "ChestLeftBand", Vector3(-0.54, 0.52, 0.0), Vector3(0.12, 0.95, 0.98), Color("a78d5e"))
		_box(chest, "ChestRightBand", Vector3(0.54, 0.52, 0.0), Vector3(0.12, 0.95, 0.98), Color("a78d5e"))
		var lid_pivot := Node3D.new()
		lid_pivot.name = "ChestLidPivot"
		lid_pivot.position = Vector3(0.0, 0.88, -0.42)
		chest.add_child(lid_pivot)
		var lid := _box(lid_pivot, "ChestLid", Vector3(0.0, 0.18, 0.42), Vector3(1.48, 0.42, 0.92), Color("536d69"))
		var clasp := _box(chest, "ChestClasp", Vector3(0.0, 0.63, 0.54), Vector3(0.22, 0.3, 0.12), Color("d1b36f"))
		var glow := _sphere(chest, "ChestGlow", Vector3(0.0, 1.35, 0.0), 0.22, Color("8fd8ca"), 0.34)
		glow.material_override = _painter_mat(Color("8fd8ca"), 8.0, 0.28)
		glow.visible = not river_chest_ids.has(i)
		var light := OmniLight3D.new()
		light.name = "ChestGlowLight"
		light.position = Vector3(0.0, 1.45, 0.0)
		light.light_color = Color("72c9bd")
		light.light_energy = 0.65 if not river_chest_ids.has(i) else 0.0
		light.omni_range = 4.0
		chest.add_child(light)
		if river_chest_ids.has(i):
			lid_pivot.rotation.x = -1.05
			clasp.visible = false

func _build_river_shrine_puzzle() -> void:
	# A three-ring mechanism gives the river region a tactile, repeatable puzzle.
	var shrine := Node3D.new()
	shrine.name = "RiverShrinePuzzle"
	shrine.position = Vector3(82.0, 0.0, -143.0)
	shrine.set_meta("solved", river_shrine_solved)
	add_child(shrine)
	_box(shrine, "PuzzlePlinth", Vector3(0.0, 0.48, 0.0), Vector3(3.2, 0.96, 2.0), Color("56666a"))
	_box(shrine, "PuzzleBackplate", Vector3(0.0, 2.25, -0.72), Vector3(2.65, 2.65, 0.32), Color("3d555b"))
	for i in range(3):
		var ring_node := Node3D.new()
		ring_node.name = "PuzzleRing_%d" % i
		ring_node.position = Vector3(0.0, 2.25, -0.48 + float(i) * 0.025)
		ring_node.rotation_degrees.x = 90.0
		ring_node.rotation.z = float(river_puzzle_ring_steps[i]) * PI * 0.5
		var ring_mesh := TorusMesh.new()
		ring_mesh.inner_radius = 0.42 + float(i) * 0.24
		ring_mesh.outer_radius = ring_mesh.inner_radius + 0.09
		ring_mesh.rings = 32
		ring_mesh.ring_segments = 8
		var ring := MeshInstance3D.new()
		ring.name = "RingMesh"
		ring.mesh = ring_mesh
		ring.material_override = _painter_mat([Color("9bc7c0"), Color("7caaa7"), Color("c0b58d")][i], 7.0, 0.16)
		ring_node.add_child(ring)
		var marker := _sphere(ring_node, "RingMarker", Vector3(0.0, 0.0, -ring_mesh.outer_radius - 0.12), 0.105, Color("b9e9dd"), 0.16)
		marker.material_override = _painter_mat(Color("b9e9dd"), 8.0, 0.24)
		shrine.add_child(ring_node)
	var lever := Node3D.new()
	lever.name = "PuzzleLever"
	lever.position = Vector3(1.48, 1.05, 0.0)
	shrine.add_child(lever)
	_box(lever, "LeverBase", Vector3(0.0, 0.0, 0.0), Vector3(0.42, 0.3, 0.42), Color("756b51"))
	var lever_arm := _box(lever, "LeverArm", Vector3(0.0, 0.48, 0.0), Vector3(0.16, 1.0, 0.18), Color("9a8058"))
	lever_arm.rotation.z = -0.35
	var drawer := Node3D.new()
	drawer.name = "PuzzleOfferingDrawer"
	drawer.position = Vector3(0.0, 1.0, 0.95)
	shrine.add_child(drawer)
	_box(drawer, "DrawerBody", Vector3(0.0, 0.0, 0.0), Vector3(1.0, 0.45, 0.55), Color("35464a"))
	var lid := _box(drawer, "DrawerLid", Vector3(0.0, 0.28, -0.2), Vector3(1.08, 0.12, 0.62), Color("788a83"))
	lid.rotation.x = -0.08
	var crystal := _sphere(shrine, "PuzzleRewardCrystal", Vector3(0.0, 1.55, 1.05), 0.28, Color("9b4e62"), 0.5)
	crystal.material_override = _painter_mat(Color("9b4e62"), 8.0, 0.22)
	crystal.visible = river_shrine_solved
	var clue := Label3D.new()
	clue.name = "PuzzleSequenceClue"
	clue.text = "MARÉ: I  •  III  •  II"
	clue.position = Vector3(0.0, 3.95, 0.05)
	clue.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	clue.font_size = 30
	clue.modulate = Color("b8dcd5")
	shrine.add_child(clue)
	var glow := OmniLight3D.new()
	glow.name = "PuzzleGlow"
	glow.position = Vector3(0.0, 2.3, 0.2)
	glow.light_color = Color("70c7c0")
	glow.light_energy = 0.85 if not river_shrine_solved else 1.35
	glow.omni_range = 8.0
	shrine.add_child(glow)
	if river_shrine_solved:
		lever.rotation.z = -0.85
		lid.rotation.x = -1.1

func _build_river_relics() -> void:
	# Optional discoveries reward exploration and persist independently of the main quest.
	var relic_positions := [Vector3(39.0, 0.0, -111.0), Vector3(70.0, 0.0, -151.0), Vector3(88.0, 0.0, -127.0)]
	for i in range(relic_positions.size()):
		var relic := Node3D.new()
		relic.name = "RiverMemoryRelic_%d" % i
		relic.position = relic_positions[i]
		relic.set_meta("relic_id", i)
		relic.set_meta("collected", river_relic_ids.has(i))
		add_child(relic)
		var plinth := _box(relic, "RelicPlinth", Vector3(0.0, 0.42, 0.0), Vector3(1.15, 0.84, 1.15), Color("626f6c"))
		plinth.rotation.y = 0.18 * float(i)
		var crystal := _sphere(relic, "RiverMemoryCrystal", Vector3(0.0, 1.35, 0.0), 0.38, Color("91d9d0"), 0.72)
		crystal.material_override = _painter_mat(Color("91d9d0"), 8.0, 0.22)
		var light := OmniLight3D.new()
		light.position = Vector3(0.0, 1.55, 0.0)
		light.light_color = Color("65c9c0")
		light.light_energy = 0.65
		light.omni_range = 4.5
		relic.add_child(light)
		var sign := Label3D.new()
		sign.text = "ECO DO RIO"
		sign.position = Vector3(0.0, 2.05, 0.0)
		sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		sign.font_size = 28
		sign.modulate = Color("c3e8df")
		relic.add_child(sign)
		relic.visible = not river_relic_ids.has(i)

func _make_person(label: String, pos: Vector3, is_master := false) -> Node3D:
	var root := Node3D.new()
	root.name = label
	root.position = pos
	add_child(root)
	var tunic := Color("4e7180") if is_master else Color("a66a53")
	_sphere(root,"Body",Vector3(0,0.95,0),0.48,tunic,1.25)
	_sphere(root,"Head",Vector3(0,1.85,0),0.48,Color("d6a77c"),0.95)
	_sphere(root,"Hood",Vector3(0,2.25,-0.08),0.53,Color("34434a") if is_master else Color("5b493b"),0.55)
	_box(root,"Legs",Vector3(0,0.28,0),Vector3(0.55,0.55,0.42),Color("403a38"))
	return root

func _build_npcs() -> void:
	var npc := _make_person("Mestre Azulan",Vector3(2,0,-4),true)
	npc.set_meta("interact_name","Mestre Azulan")
	var marker := _sphere(npc,"QuestMarker",Vector3(0,3.0,0),0.16,Color("e8bd65"))
	marker.name = "QuestMarker"
	var sign := Label3D.new()
	sign.text = "MESTRE AZULAN"
	sign.position = Vector3(0,3.5,0)
	sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sign.font_size = 48
	sign.modulate = Color("f4dfb3")
	npc.add_child(sign)
	var river_guardian := _make_person("Guardião do Rio", Vector3(74.0, 0.0, -127.0), true)
	river_guardian.set_meta("interact_name", "Guardião do Rio")
	var river_sign := Label3D.new()
	river_sign.text = "GUARDIÃO DO RIO"
	river_sign.position = Vector3(0.0, 3.5, 0.0)
	river_sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	river_sign.font_size = 42
	river_sign.modulate = Color("b7e0d9")
	river_guardian.add_child(river_sign)

func _build_enemies() -> void:
	for i in range(6):
		var e := CharacterBody3D.new()
		e.set_script(ENEMY_SCRIPT)
		e.name = "Goblin_%d" % i
		e.position = Vector3(randf_range(-18,18),0,randf_range(-24,-9))
		e.set("enemy_kind", i % 3)
		add_child(e)
		enemies.append(e)
	var boss := CharacterBody3D.new()
	boss.set_script(ENEMY_SCRIPT)
	boss.name = "Guardiao_da_Cicatriz"
	boss.position = Vector3(0, 0, -39)
	boss.set("enemy_kind", 3)
	add_child(boss)
	enemies.append(boss)
	if quest_stage >= 4: boss.visible = false; boss.set_physics_process(false)
	for i in range(5):
		var mireling := CharacterBody3D.new()
		mireling.set_script(ENEMY_SCRIPT)
		mireling.name = "Mireling_%d" % i
		mireling.position = Vector3(randf_range(-24.0, 24.0), 0.0, randf_range(-110.0, -72.0))
		mireling.set("enemy_kind", 2 if i % 2 == 0 else 1)
		add_child(mireling)
		enemies.append(mireling)
	var witch := CharacterBody3D.new()
	witch.set_script(ENEMY_SCRIPT)
	witch.name = "Bruxa_do_Pantano"
	witch.position = Vector3(0.0, 0.0, -119.0)
	witch.set("enemy_kind", 4)
	add_child(witch)
	enemies.append(witch)
	if quest_stage >= 7: witch.visible = false; witch.set_physics_process(false)
	var leviathan := CharacterBody3D.new()
	leviathan.set_script(ENEMY_SCRIPT)
	leviathan.name = "Leviata_do_Lodo"
	leviathan.position = Vector3(55.0, 0.0, -143.0)
	leviathan.set("enemy_kind", 6)
	add_child(leviathan)
	leviathan.set("hp", river_boss_hp)
	leviathan.call("sync_boss_phase")
	enemies.append(leviathan)
	if quest_stage < 12 or quest_stage >= 13:
		leviathan.visible = false
		leviathan.set_physics_process(false)
	for i in range(4):
		var river_knight := CharacterBody3D.new()
		river_knight.set_script(ENEMY_SCRIPT)
		river_knight.name = "Cavaleiro_Afogado_%d" % i
		river_knight.position = Vector3(48.0 + float(i % 2) * 13.0, 0.0, -116.0 - float(i / 2) * 17.0)
		river_knight.set("enemy_kind", 5)
		add_child(river_knight)
		enemies.append(river_knight)
		if quest_stage >= 11:
			river_knight.visible = false
			river_knight.set_physics_process(false)
	# Vigia opcional da Floresta Ancestral: criatura original, sem alterar as missões principais.
	var root_warden := CharacterBody3D.new()
	root_warden.set_script(ENEMY_SCRIPT)
	root_warden.name = "Vigia_das_Raizes"
	root_warden.position = Vector3(-169.0, 0.0, -137.0)
	root_warden.set("enemy_kind", 9)
	add_child(root_warden)
	enemies.append(root_warden)
	# Corvos Glaciais rondam os cristais da Montanha Gelada; encontro opcional.
	for i in range(2):
		var ice_raven := CharacterBody3D.new()
		ice_raven.set_script(ENEMY_SCRIPT)
		ice_raven.name = "Corvo_Glacial_%d" % i
		ice_raven.position = Vector3(-179.0 + float(i) * 26.0, 0.0, -267.0 - float(i) * 12.0)
		ice_raven.set("enemy_kind", 10)
		add_child(ice_raven)
		enemies.append(ice_raven)
	# Espectros opcionais guardam as margens do Rio Prateado; não contam para a missão dos cavaleiros.
	for i in range(2):
		var wraith := CharacterBody3D.new()
		wraith.set_script(ENEMY_SCRIPT)
		wraith.name = "Espectro_Afogado_%d" % i
		wraith.position = Vector3(69.0 + float(i) * 11.0, 0.0, -127.0 - float(i) * 9.0)
		wraith.set("enemy_kind", 7)
		add_child(wraith)
		enemies.append(wraith)
		if quest_stage < 9:
			wraith.visible = false
			wraith.set_physics_process(false)
	# Caranguejos de Prata patrulham as águas rasas; encontros opcionais do Capítulo II.
	for i in range(2):
		var crab := CharacterBody3D.new()
		crab.set_script(ENEMY_SCRIPT)
		crab.name = "Caranguejo_de_Prata_%d" % i
		crab.position = Vector3(38.0 + float(i) * 27.0, 0.0, -103.0 - float(i) * 13.0)
		crab.set("enemy_kind", 8)
		add_child(crab)
		enemies.append(crab)
		if quest_stage < 9:
			crab.visible = false
			crab.set_physics_process(false)

func _get_player_level() -> int:
	return 1 + int(maxi(0, xp) / 100)

func _xp_needed_for_next_level() -> int:
	return _get_player_level() * 100

func _refresh_player_stats(levels_gained: int = 0) -> void:
	if not is_instance_valid(player): return
	var level := _get_player_level()
	player.max_hp = 100 + (level - 1) * 12
	player.attack_damage = 35 + weapon_level * 10 + (level - 1) * 3
	if levels_gained > 0:
		player.hp = mini(player.max_hp, player.hp + 25 * levels_gained)
		player_health_changed(player.hp, player.max_hp)

func _grant_xp(amount: int) -> void:
	if amount <= 0: return
	var previous_level := _get_player_level()
	xp = maxi(0, xp + amount)
	var current_level := _get_player_level()
	var levels_gained := current_level - previous_level
	_refresh_player_stats(levels_gained)
	if levels_gained > 0 and is_instance_valid(toast_label):
		toast_label.text = "NÍVEL %d! +%d vida máxima • +%d dano • +%d cura" % [current_level, 12 * levels_gained, 3 * levels_gained, 25 * levels_gained]
	_update_inventory()

func _build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Tobi"
	player.set_script(PLAYER_SCRIPT)
	player.position = Vector3(0,0,15)
	player.set("world", self)
	var level := _get_player_level()
	player.max_hp = 100 + (level - 1) * 12
	player.attack_damage = 35 + weapon_level * 10 + (level - 1) * 3
	add_child(player)


func _build_hud() -> void:
	var level: int = _get_player_level()
	var current_level_xp: int = xp - ((level - 1) * 100)
	var xp_needed: int = _xp_needed_for_next_level()
	hud = CanvasLayer.new()
	hud.name = "GameHUD"
	hud.layer = 90
	hud.visible = true
	add_child(hud)

	# A consistent dark-fantasy UI skin: warm parchment text, muted stone panels
	# and restrained amber/teal accents. All controls remain native Godot UI.
	var ui_theme := Theme.new()
	ui_theme.set_color("font_color", "Label", Color("e8e0cf"))
	ui_theme.set_color("font_shadow_color", "Label", Color(0.02, 0.025, 0.025, 0.9))
	ui_theme.set_constant("shadow_offset_x", "Label", 1)
	ui_theme.set_constant("shadow_offset_y", "Label", 1)
	ui_theme.set_color("font_color", "Button", Color("f0e7d4"))
	ui_theme.set_color("font_hover_color", "Button", Color("fff2cf"))
	ui_theme.set_color("font_pressed_color", "Button", Color("d8bd8b"))
	ui_theme.set_font_size("font_size", "Button", 12)
	var ui_root := Control.new()
	ui_root.name = "HUDRoot"
	ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_root.theme = ui_theme
	ui_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_root.z_index = 1
	hud.add_child(ui_root)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.025, 0.033, 0.031, 0.96)
	panel_style.border_color = Color("9a8058")
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(12)
	panel_style.corner_detail = 6
	panel_style.anti_aliasing = true
	panel_style.content_margin_left = 15.0
	panel_style.content_margin_right = 15.0
	panel_style.content_margin_top = 11.0
	panel_style.content_margin_bottom = 11.0
	panel_style.shadow_color = Color(0.0, 0.0, 0.0, 0.58)
	panel_style.shadow_size = 3
	panel_style.shadow_offset = Vector2(0, 1)
	var quest_panel_style := panel_style.duplicate() as StyleBoxFlat
	quest_panel_style.bg_color = Color(0.055, 0.047, 0.034, 0.97)
	quest_panel_style.border_color = Color("b18a52")
	var status_panel_style := panel_style.duplicate() as StyleBoxFlat
	status_panel_style.bg_color = Color(0.025, 0.045, 0.041, 0.97)
	status_panel_style.border_color = Color("648c7d")
	var progress_panel_style := panel_style.duplicate() as StyleBoxFlat
	progress_panel_style.bg_color = Color(0.047, 0.039, 0.027, 0.97)
	progress_panel_style.border_color = Color("9d7946")
	var button_normal := StyleBoxFlat.new()
	button_normal.bg_color = Color(0.07, 0.085, 0.075, 0.96)
	button_normal.border_color = Color("9c8055")
	button_normal.set_border_width_all(2)
	button_normal.set_corner_radius_all(18)
	button_normal.corner_detail = 6
	button_normal.anti_aliasing = true
	button_normal.content_margin_left = 8.0
	button_normal.content_margin_right = 8.0
	button_normal.content_margin_top = 6.0
	button_normal.content_margin_bottom = 6.0
	button_normal.shadow_color = Color(0.0, 0.0, 0.0, 0.48)
	button_normal.shadow_size = 5
	button_normal.shadow_offset = Vector2(0, 2)
	var button_hover := button_normal.duplicate() as StyleBoxFlat
	button_hover.bg_color = Color(0.15, 0.17, 0.13, 0.96)
	button_hover.border_color = Color("d2ad70")
	var button_pressed := button_normal.duplicate() as StyleBoxFlat
	button_pressed.bg_color = Color(0.25, 0.19, 0.12, 0.98)
	ui_theme.set_stylebox("normal", "Button", button_normal)
	ui_theme.set_stylebox("hover", "Button", button_hover)
	ui_theme.set_stylebox("pressed", "Button", button_pressed)
	ui_theme.set_stylebox("disabled", "Button", button_normal)

	# Quest card — compact hierarchy instead of a large block of plain text.
	var quest_panel := PanelContainer.new()
	quest_panel.name = "QuestCard"
	quest_panel.position = Vector2(18, 16)
	var hud_viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var hud_compact := hud_viewport_size.x < 700.0
	quest_panel.custom_minimum_size = Vector2(minf(330.0, maxf(248.0, hud_viewport_size.x * 0.78)), 112 if not hud_compact else 104)
	quest_panel.add_theme_stylebox_override("panel", quest_panel_style)
	ui_root.add_child(quest_panel)
	var quest_box := VBoxContainer.new()
	quest_box.add_theme_constant_override("separation", 5)
	quest_panel.add_child(quest_box)
	var title := Label.new()
	title.text = "TOBI  &  BREU"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_constant_override("outline_size", 2)
	title.add_theme_color_override("font_outline_color", Color(0.015, 0.012, 0.008, 0.95))
	title.add_theme_color_override("font_color", Color("d8b77c"))
	quest_box.add_child(title)
	var quest_kicker := Label.new()
	quest_kicker.text = "DARK FANTASY   •   JORNADA ATUAL"
	quest_kicker.add_theme_font_size_override("font_size", 9)
	quest_kicker.add_theme_color_override("font_color", Color("8e9a8d"))
	quest_box.add_child(quest_kicker)
	quest_label = Label.new()
	quest_label.text = quest_text
	quest_label.add_theme_font_size_override("font_size", 15)
	quest_label.add_theme_color_override("font_color", Color("eee5d3"))
	quest_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quest_box.add_child(quest_label)
	objective_label = Label.new()
	objective_label.text = "Objetivo: encontre Mestre Azulan"
	objective_label.add_theme_font_size_override("font_size", 12)
	objective_label.add_theme_color_override("font_color", Color("c6b18b"))
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quest_box.add_child(objective_label)

	# Player status card with distinct health and stamina tracks.
	var status_panel := PanelContainer.new()
	status_panel.name = "PlayerStatusCard"
	status_panel.position = Vector2(18, 138)
	status_panel.custom_minimum_size = Vector2(minf(260.0, maxf(224.0, hud_viewport_size.x * 0.72)), 78 if not hud_compact else 72)
	status_panel.add_theme_stylebox_override("panel", status_panel_style)
	ui_root.add_child(status_panel)
	var status_box := VBoxContainer.new()
	status_box.add_theme_constant_override("separation", 3)
	status_panel.add_child(status_box)
	var status_head := HBoxContainer.new()
	status_box.add_child(status_head)
	health_label = Label.new()
	health_label.text = "TOBI  •  VIDA"
	health_label.add_theme_font_size_override("font_size", 11)
	health_label.add_theme_color_override("font_color", Color("e6c9a0"))
	status_head.add_child(health_label)
	var status_spacer := Control.new()
	status_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_head.add_child(status_spacer)
	health_value_label = Label.new()
	health_value_label.text = "%d / %d" % [player.hp, player.max_hp]
	health_value_label.add_theme_font_size_override("font_size", 10)
	health_value_label.add_theme_color_override("font_color", Color("e8e0cf"))
	health_value_label.name = "HealthValue"
	status_head.add_child(health_value_label)
	health_bar = ProgressBar.new()
	health_bar.custom_minimum_size = Vector2(minf(230.0, maxf(194.0, hud_viewport_size.x * 0.64)), 16)
	health_bar.max_value = player.max_hp
	health_bar.value = player.hp
	health_bar.show_percentage = false
	health_bar.add_theme_stylebox_override("background", _hud_bar_style(Color("292d29")))
	health_bar.add_theme_stylebox_override("fill", _hud_bar_style(Color("a84d4b")))
	status_box.add_child(health_bar)
	stamina_bar = ProgressBar.new()
	stamina_bar.custom_minimum_size = Vector2(minf(230.0, maxf(194.0, hud_viewport_size.x * 0.64)), 9)
	stamina_bar.max_value = 100
	stamina_bar.value = 100
	stamina_bar.show_percentage = false
	stamina_bar.add_theme_stylebox_override("background", _hud_bar_style(Color("292d29")))
	stamina_bar.add_theme_stylebox_override("fill", _hud_bar_style(Color("78a99a")))
	status_box.add_child(stamina_bar)

	# Level and resources are grouped into one small readable strip.
	var progress_panel := PanelContainer.new()
	progress_panel.name = "ProgressCard"
	progress_panel.position = Vector2(18, 224)
	progress_panel.custom_minimum_size = Vector2(minf(260.0, maxf(224.0, hud_viewport_size.x * 0.72)), 58)
	progress_panel.add_theme_stylebox_override("panel", progress_panel_style)
	ui_root.add_child(progress_panel)
	var progress_box := VBoxContainer.new()
	progress_box.add_theme_constant_override("separation", 3)
	progress_panel.add_child(progress_box)
	xp_label = Label.new()
	xp_label.text = "NÍVEL %d   •   %d / %d XP" % [level, current_level_xp, xp_needed - ((level - 1) * 100)]
	xp_label.add_theme_font_size_override("font_size", 11)
	xp_label.add_theme_color_override("font_color", Color("d8b77c"))
	progress_box.add_child(xp_label)
	xp_bar = ProgressBar.new()
	xp_bar.max_value = maxi(1, xp_needed - ((level - 1) * 100))
	xp_bar.value = current_level_xp
	xp_bar.custom_minimum_size = Vector2(minf(230.0, maxf(194.0, hud_viewport_size.x * 0.64)), 10)
	xp_bar.show_percentage = false
	xp_bar.add_theme_stylebox_override("background", _hud_bar_style(Color("292d29")))
	xp_bar.add_theme_stylebox_override("fill", _hud_bar_style(Color("c39a58")))
	progress_box.add_child(xp_bar)
	inventory_label = Label.new()
	inventory_label.text = "POÇÕES %d   •   FRAGMENTOS %d   •   ESPADA +%d" % [potions, shards, weapon_level]
	inventory_label.add_theme_font_size_override("font_size", 9)
	inventory_label.add_theme_color_override("font_color", Color("b9c1b5"))
	progress_box.add_child(inventory_label)

	# Boss encounter bar stays centered and only appears during the boss quest.
	boss_hud_panel = PanelContainer.new()
	boss_hud_panel.name = "BossHealthCard"
	boss_hud_panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	boss_hud_panel.position = Vector2(-180, 14)
	boss_hud_panel.custom_minimum_size = Vector2(360, 54)
	boss_hud_panel.visible = false
	boss_hud_panel.add_theme_stylebox_override("panel", progress_panel_style)
	ui_root.add_child(boss_hud_panel)
	var boss_box := VBoxContainer.new()
	boss_box.add_theme_constant_override("separation", 3)
	boss_hud_panel.add_child(boss_box)
	boss_health_label = Label.new()
	boss_health_label.text = "LEVIATÃ DO LODO"
	boss_health_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_health_label.add_theme_font_size_override("font_size", 12)
	boss_health_label.add_theme_color_override("font_color", Color("d99a83"))
	boss_box.add_child(boss_health_label)
	boss_health_bar = ProgressBar.new()
	boss_health_bar.max_value = 680
	boss_health_bar.value = 680
	boss_health_bar.custom_minimum_size = Vector2(330, 10)
	boss_health_bar.show_percentage = false
	boss_health_bar.add_theme_stylebox_override("background", _hud_bar_style(Color("292323")))
	boss_health_bar.add_theme_stylebox_override("fill", _hud_bar_style(Color("a43f46")))
	boss_box.add_child(boss_health_bar)

	combo_label = Label.new()
	combo_label.name = "ComboLabel"
	combo_label.position = Vector2(18, 292)
	combo_label.text = "COMBO  •  pronto"
	combo_label.add_theme_font_size_override("font_size", 10)
	combo_label.add_theme_color_override("font_color", Color("d8b77c"))
	ui_root.add_child(combo_label)
	whisper_grove_label = Label.new()
	whisper_grove_label.name = "WhisperGroveLabel"
	whisper_grove_label.position = Vector2(18, 310)
	whisper_grove_label.text = "BOSQUE DOS SUSSURROS  •  0/3"
	whisper_grove_label.add_theme_font_size_override("font_size", 10)
	whisper_grove_label.add_theme_color_override("font_color", Color("9acfc2"))
	whisper_grove_label.visible = false
	ui_root.add_child(whisper_grove_label)
	shadow_skill_label = Label.new()
	shadow_skill_label.name = "ShadowSkillLabel"
	shadow_skill_label.position = Vector2(18, 328)
	shadow_skill_label.text = "BREU  •  Pulso [K]  •  Aparar [F]"
	shadow_skill_label.add_theme_font_size_override("font_size", 10)
	shadow_skill_label.add_theme_color_override("font_color", Color("b6a1d6"))
	ui_root.add_child(shadow_skill_label)

	# Backpack is centered, padded and safe to use on touch screens.
	inventory_panel = PanelContainer.new()
	inventory_panel.name = "BackpackPanel"
	inventory_panel.set_anchors_preset(Control.PRESET_CENTER)
	inventory_panel.position = Vector2(-190, -145)
	inventory_panel.custom_minimum_size = Vector2(380, 290)
	inventory_panel.visible = false
	inventory_panel.add_theme_stylebox_override("panel", quest_panel_style)
	ui_root.add_child(inventory_panel)
	var inventory_box := VBoxContainer.new()
	inventory_box.add_theme_constant_override("separation", 12)
	inventory_panel.add_child(inventory_box)
	var inventory_title := Label.new()
	inventory_title.text = "MOCHILA"
	inventory_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inventory_title.add_theme_font_size_override("font_size", 22)
	inventory_title.add_theme_color_override("font_color", Color("d8b77c"))
	inventory_box.add_child(inventory_title)
	inventory_details = Label.new()
	inventory_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventory_details.add_theme_font_size_override("font_size", 12)
	inventory_box.add_child(inventory_details)
	var inventory_close := Button.new()
	inventory_close.text = "FECHAR MOCHILA"
	inventory_close.custom_minimum_size = Vector2(0, 50)
	inventory_close.pressed.connect(_toggle_inventory)
	inventory_box.add_child(inventory_close)

	prompt_label = Label.new()
	prompt_label.anchor_left = 0.5
	prompt_label.anchor_right = 0.5
	prompt_label.anchor_top = 0.78
	prompt_label.position = Vector2(-210, 0)
	prompt_label.size = Vector2(420, 48)
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.add_theme_font_size_override("font_size", 14)
	prompt_label.add_theme_color_override("font_color", Color("f0d39a"))
	ui_root.add_child(prompt_label)
	toast_label = Label.new()
	toast_label.position = Vector2(18, 350)
	toast_label.size = Vector2(440, 42)
	toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast_label.add_theme_font_size_override("font_size", 11)
	toast_label.add_theme_color_override("font_color", Color("f1d5a5"))
	ui_root.add_child(toast_label)

	# Joystick analógico do HUD criado por Claude; usa as mesmas ações de movimento.
	# O D-pad anterior é substituído pelo analógico, sem alterar os controles de teclado/controle.
	var joystick := Control.new()
	joystick.name = "VirtualJoystick"
	joystick.set_script(load("res://scripts/virtual_joystick.gd"))
	joystick.process_mode = Node.PROCESS_MODE_ALWAYS
	HUD_STYLE.place_corner(joystick, Vector2(0, 1), Vector2(150, -120), Vector2(156, 156))
	joystick.z_index = 20
	joystick.visible = OS.has_feature("mobile") or hud_viewport_size.x < 900.0
	ui_root.add_child(joystick)

	# Combat and utility controls: compact labels, consistent size and clear hierarchy.
	for data in [{"t":"⚔","a":"attack","p":Vector2(0.86,0.84)},{"t":"↟","a":"jump","p":Vector2(0.95,0.69)},{"t":"E","a":"interact","p":Vector2(0.72,0.87)},{"t":"◇","a":"dodge","p":Vector2(0.76,0.96)},{"t":"✚","a":"potion","p":Vector2(0.94,0.94)},{"t":"⚒","a":"upgrade","p":Vector2(0.64,0.73)},{"t":"▣","a":"inventory","p":Vector2(0.64,0.62)},{"t":"✦","a":"shadow","p":Vector2(0.86,0.70)},{"t":"◉","a":"guard","p":Vector2(0.76,0.86)}]:
		var action_btn := Button.new()
		action_btn.name = "TouchAction_" + data.a
		action_btn.text = data.t
		action_btn.anchor_left = data.p.x
		action_btn.anchor_right = data.p.x
		action_btn.anchor_top = data.p.y
		action_btn.anchor_bottom = data.p.y
		action_btn.position = Vector2(-25, -25)
		action_btn.size = Vector2(50, 50)
		action_btn.add_theme_font_size_override("font_size", 19)
		action_btn.tooltip_text = {"attack":"Ataque","jump":"Pular","interact":"Interagir","dodge":"Esquivar","potion":"Poção","upgrade":"Forjar","inventory":"Mochila","shadow":"Pulso sombrio","guard":"Aparar (janela de 0,38 s)"}[data.a]
		var action_fill := Color(0.055, 0.071, 0.064, 0.97)
		var action_accent := Color("9a8058")
		if data.a == "attack":
			action_fill = Color(0.20, 0.075, 0.055, 0.98)
			action_accent = Color("d39b5e")
			action_btn.size = Vector2(62, 62)
			action_btn.position = Vector2(-31, -31)
			action_btn.add_theme_font_size_override("font_size", 22)
		elif data.a == "shadow":
			action_fill = Color(0.105, 0.065, 0.16, 0.98)
			action_accent = Color("a68bcf")
		elif data.a == "potion":
			action_fill = Color(0.035, 0.12, 0.095, 0.98)
			action_accent = Color("7fbaa0")
		elif data.a == "upgrade":
			action_fill = Color(0.15, 0.11, 0.045, 0.98)
			action_accent = Color("d0ad6e")
		action_btn.add_theme_stylebox_override("normal", _ui_button_texture_style(action_accent))
		action_btn.add_theme_stylebox_override("hover", _ui_button_texture_style(action_accent.lightened(1.22)))
		action_btn.add_theme_stylebox_override("pressed", _ui_button_texture_style(Color("f0d49b")))
		action_btn.mouse_filter = Control.MOUSE_FILTER_STOP
		action_btn.process_mode = Node.PROCESS_MODE_ALWAYS
		action_btn.pressed.connect(_touch_action.bind(data.a))
		ui_root.add_child(action_btn)

	# Dedicated pause/menu access remains reachable on touch screens.
	var pause_btn := Button.new()
	pause_btn.name = "PauseMenuButton"
	pause_btn.text = "Ⅱ"
	pause_btn.anchor_left = 0.965
	pause_btn.anchor_right = 0.965
	pause_btn.anchor_top = 0.045
	pause_btn.anchor_bottom = 0.045
	pause_btn.position = Vector2(-34, -4)
	pause_btn.size = Vector2(48, 48)
	pause_btn.add_theme_font_size_override("font_size", 19)
	pause_btn.add_theme_stylebox_override("normal", _ui_button_texture_style(Color("c6a46b")))
	pause_btn.add_theme_stylebox_override("hover", _ui_button_texture_style(Color("f0d49b")))
	pause_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_btn.pressed.connect(_open_menu.bind("pause"))
	ui_root.add_child(pause_btn)

	_update_inventory()
	_apply_mobile_hud_layout(ui_root)
	# Recalcula as zonas de toque sempre que o Android muda entre retrato e paisagem.
	var hud_viewport := get_viewport()
	if not hud_viewport.size_changed.is_connected(_on_hud_viewport_resized):
		hud_viewport.size_changed.connect(_on_hud_viewport_resized)
	call_deferred("_on_hud_viewport_resized")


func _on_hud_viewport_resized() -> void:
	if not is_instance_valid(hud):
		return
	var ui_root := hud.get_node_or_null("HUDRoot") as Control
	if is_instance_valid(ui_root):
		_apply_mobile_hud_layout(ui_root)


func _apply_mobile_hud_layout(ui_root: Control) -> void:
	# Posicionamento por offsets ancorados aos cantos: evita os controles saltarem
	# para (0,0) quando o Android muda resolução/orientação.
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var mobile := OS.has_feature("mobile") or viewport_size.x < 900.0
	var joystick := ui_root.get_node_or_null("VirtualJoystick") as Control
	var touch_actions := ["attack", "jump", "interact", "dodge", "potion", "upgrade", "inventory", "shadow", "guard"]
	if not mobile:
		if joystick:
			joystick.visible = false
		for action in touch_actions:
			var desktop_hidden_button := ui_root.get_node_or_null("TouchAction_" + action) as Button
			if desktop_hidden_button:
				desktop_hidden_button.visible = false
		var desktop_pause := ui_root.get_node_or_null("PauseMenuButton") as Button
		if desktop_pause:
			desktop_pause.visible = false
		return
	if joystick:
		joystick.visible = true
	for action in touch_actions:
		var touch_button := ui_root.get_node_or_null("TouchAction_" + action) as Button
		if touch_button:
			touch_button.visible = true
	var portrait := viewport_size.y > viewport_size.x
	var compact_scale := 0.90 if portrait else 1.0
	if joystick:
		var center_x := minf(132.0, viewport_size.x * 0.28) if portrait else 150.0
		var joystick_size := Vector2.ONE * (140.0 if portrait else 156.0)
		HUD_STYLE.place_corner(joystick, Vector2(0, 1), Vector2(center_x, -120.0), joystick_size)
		joystick.visible = true
	var action_layout: Dictionary
	if portrait:
		action_layout = {
			"attack": [Vector2(0.88, 0.72), 76.0],
			"jump": [Vector2(0.68, 0.59), 56.0],
			"interact": [Vector2(0.68, 0.72), 56.0],
			"dodge": [Vector2(0.68, 0.85), 56.0],
			"potion": [Vector2(0.88, 0.85), 54.0],
			"shadow": [Vector2(0.88, 0.59), 54.0],
			"upgrade": [Vector2(0.68, 0.96), 50.0],
			"inventory": [Vector2(0.88, 0.96), 50.0],
			"guard": [Vector2(0.78, 0.48), 52.0]
		}
	else:
		action_layout = {
			"attack": [Vector2(0.91, 0.855), 78.0],
			"jump": [Vector2(0.96, 0.69), 60.0],
			"interact": [Vector2(0.755, 0.79), 58.0],
			"dodge": [Vector2(0.79, 0.94), 58.0],
			"potion": [Vector2(0.96, 0.94), 58.0],
			"shadow": [Vector2(0.82, 0.675), 56.0],
			"upgrade": [Vector2(0.66, 0.68), 52.0],
			"inventory": [Vector2(0.66, 0.82), 52.0],
			"guard": [Vector2(0.75, 0.60), 54.0]
		}
	for action in action_layout:
		var button := ui_root.get_node_or_null("TouchAction_" + action) as Button
		if not is_instance_valid(button):
			continue
		var data: Array = action_layout[action]
		var action_size := Vector2.ONE * maxf(48.0, float(data[1]) * compact_scale)
		var anchor: Vector2 = data[0]
		var center_offset := Vector2((anchor.x - 1.0) * viewport_size.x, (anchor.y - 1.0) * viewport_size.y)
		HUD_STYLE.place_corner(button, Vector2(1.0, 1.0), center_offset, action_size)
		button.add_theme_font_size_override("font_size", 12 if action != "attack" else 14)
		var touch_labels := {
			"attack":"⚔\nATACAR", "jump":"↟\nPULAR", "interact":"E\nUSAR",
			"dodge":"◇\nROLAR", "potion":"✚\nCURA", "shadow":"✦\nBREU",
			"upgrade":"⚒\nFORJAR", "inventory":"▣\nMOCHILA", "guard":"◉\nDEF"
		}
		button.text = touch_labels[action]
		button.mouse_filter = Control.MOUSE_FILTER_STOP
	var pause := ui_root.get_node_or_null("PauseMenuButton") as Button
	if pause:
		HUD_STYLE.place_corner(pause, Vector2(1.0, 0.0), Vector2(-42.0, 42.0), Vector2(48.0, 48.0))
		pause.add_theme_font_size_override("font_size", 21)
	var quest := ui_root.get_node_or_null("QuestCard") as PanelContainer
	if quest:
		quest.position = Vector2(12, 12)
		quest.custom_minimum_size.x = minf(300.0, viewport_size.x * (0.43 if not portrait else 0.78))
	var status := ui_root.get_node_or_null("PlayerStatusCard") as PanelContainer
	if status:
		status.position = Vector2(12, 132)
		status.custom_minimum_size.x = minf(250.0, viewport_size.x * (0.36 if not portrait else 0.74))
	var progress := ui_root.get_node_or_null("ProgressCard") as PanelContainer
	if progress:
		progress.position = Vector2(12, 216)
		progress.custom_minimum_size.x = minf(250.0, viewport_size.x * (0.36 if not portrait else 0.74))
	var combo := ui_root.get_node_or_null("ComboLabel") as Label
	if combo:
		combo.position = Vector2(14, 282)
	var grove := ui_root.get_node_or_null("WhisperGroveLabel") as Label
	if grove:
		grove.position = Vector2(14, 302)
	var shadow := ui_root.get_node_or_null("ShadowSkillLabel") as Label
	if shadow:
		shadow.position = Vector2(14, 322)


func _build_menus() -> void:
	menu_layer = CanvasLayer.new()
	menu_layer.name = "GameMenus"
	menu_layer.layer = 100
	menu_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(menu_layer)
	var dimmer := ColorRect.new()
	dimmer.name = "MenuBackdrop"
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.006, 0.009, 0.012, 0.94)
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	menu_layer.add_child(dimmer)
	menu_panel = PanelContainer.new()
	menu_panel.name = "MenuFrame"
	menu_panel.set_anchors_preset(Control.PRESET_CENTER)
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var is_mobile_ui := OS.has_feature("mobile") or viewport_size.x < 900.0
	var panel_size := Vector2(minf(680.0, viewport_size.x * (0.96 if is_mobile_ui else 0.92)), minf(600.0, viewport_size.y * (0.94 if is_mobile_ui else 0.86)))
	menu_panel.position = -panel_size * 0.5
	menu_panel.size = panel_size
	menu_panel.custom_minimum_size = panel_size
	menu_panel.clip_contents = true
	var menu_frame_style := _hud_button_style(Color("111916"), Color("a98752"), 18)
	menu_frame_style.set_border_width_all(2)
	menu_frame_style.shadow_color = Color(0.0, 0.0, 0.0, 0.82)
	menu_frame_style.shadow_size = 8
	menu_frame_style.shadow_offset = Vector2(0, 3)
	menu_frame_style.content_margin_left = 14.0 if is_mobile_ui else 22.0
	menu_frame_style.content_margin_right = 14.0 if is_mobile_ui else 22.0
	menu_frame_style.content_margin_top = 12.0 if is_mobile_ui else 18.0
	menu_frame_style.content_margin_bottom = 12.0 if is_mobile_ui else 18.0
	menu_panel.add_theme_stylebox_override("panel", menu_frame_style)
	menu_layer.add_child(menu_panel)
	var shell := VBoxContainer.new()
	shell.name = "MenuShell"
	shell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shell.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shell.add_theme_constant_override("separation", 10)
	menu_panel.add_child(shell)
	var top_rule := HBoxContainer.new()
	shell.add_child(top_rule)
	var brand_icon := TextureRect.new()
	brand_icon.name = "BrandSigil"
	brand_icon.texture = load("res://assets/icons/tobi_breu_icon.svg")
	brand_icon.custom_minimum_size = Vector2(34, 34)
	brand_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	brand_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	top_rule.add_child(brand_icon)
	var brand := Label.new()
	brand.text = "Tobi & Breu"
	brand.add_theme_font_size_override("font_size", 17)
	brand.add_theme_color_override("font_color", Color("e3c38b"))
	brand.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_rule.add_child(brand)
	var top_spacer := Control.new()
	top_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_rule.add_child(top_spacer)
	var close_btn := Button.new()
	close_btn.text = "×"
	close_btn.custom_minimum_size = Vector2(44, 44)
	close_btn.add_theme_font_size_override("font_size", 24)
	close_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	close_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	close_btn.pressed.connect(_menu_back)
	top_rule.add_child(close_btn)
	var rule := ColorRect.new()
	rule.custom_minimum_size = Vector2(0, 2)
	rule.color = Color("806342")
	shell.add_child(rule)
	menu_body = VBoxContainer.new()
	menu_body.name = "MenuPageContent"
	menu_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	menu_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	menu_body.add_theme_constant_override("separation", 14)
	shell.add_child(menu_body)
	menu_feedback = Label.new()
	menu_feedback.name = "MenuFeedback"
	menu_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_feedback.add_theme_font_size_override("font_size", 11)
	menu_feedback.add_theme_color_override("font_color", Color("9acfc2"))
	shell.add_child(menu_feedback)
	menu_layer.visible = true
	_show_menu_page("main")
	var menu_viewport := get_viewport()
	if not menu_viewport.size_changed.is_connected(_on_game_menu_viewport_resized):
		menu_viewport.size_changed.connect(_on_game_menu_viewport_resized)
	get_tree().paused = true


func _on_game_menu_viewport_resized() -> void:
	if not is_instance_valid(menu_panel):
		return
	var viewport_size := get_viewport().get_visible_rect().size
	var mobile_ui := OS.has_feature("mobile") or viewport_size.x < 900.0
	var panel_size := Vector2(minf(680.0, viewport_size.x * (0.96 if mobile_ui else 0.92)), minf(600.0, viewport_size.y * (0.94 if mobile_ui else 0.86)))
	menu_panel.position = -panel_size * 0.5
	menu_panel.size = panel_size
	menu_panel.custom_minimum_size = panel_size


func _show_menu_page(page: String) -> void:
	if not is_instance_valid(menu_body): return
	menu_page = page
	for child in menu_body.get_children():
		menu_body.remove_child(child)
		child.queue_free()
	menu_feedback.text = ""
	var header := PanelContainer.new()
	header.name = "MenuPageHeader"
	var header_style := _hud_button_style(Color("17211c"), Color("66563c"), 10)
	header_style.set_border_width_all(1)
	header_style.content_margin_left = 16.0
	header_style.content_margin_right = 16.0
	header_style.content_margin_top = 12.0
	header_style.content_margin_bottom = 12.0
	header.add_theme_stylebox_override("panel", header_style)
	menu_body.add_child(header)
	var header_box := VBoxContainer.new()
	header_box.add_theme_constant_override("separation", 5)
	header.add_child(header_box)
	var eyebrow := Label.new()
	eyebrow.text = "CRÔNICAS DO REINO   /   " + ("MENU PRINCIPAL" if page == "main" else "JORNADA")
	eyebrow.add_theme_font_size_override("font_size", 9)
	eyebrow.add_theme_color_override("font_color", Color("91aa9b"))
	header_box.add_child(eyebrow)
	var title := Label.new()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.add_theme_font_size_override("font_size", 27)
	title.add_theme_color_override("font_color", Color("f0d8a7"))
	title.add_theme_color_override("font_outline_color", Color("090d0b"))
	title.add_theme_constant_override("outline_size", 2)
	header_box.add_child(title)
	var subtitle := Label.new()
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.add_theme_color_override("font_color", Color("c0c7b9"))
	header_box.add_child(subtitle)
	var header_rule := ColorRect.new()
	header_rule.custom_minimum_size = Vector2(0, 2)
	header_rule.color = Color("806342")
	header_box.add_child(header_rule)
	var scroll := ScrollContainer.new()
	scroll.name = "MenuPageScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	menu_body.add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	scroll.add_child(content)
	if page in ["hub", "character"]:
		_menu_add_stat_strip(content)
	match page:
		"main":
			title.text = "A lenda desperta"
			subtitle.text = "Sua aventura começa agora."
			_menu_add_button(content, "JOGAR", _start_game, true)
			_menu_add_button(content, "CONFIGURAÇÕES", _show_menu_page.bind("settings"))
		"pause":
			title.text = "JORNADA PAUSADA"
			subtitle.text = "O mundo espera. Retome quando estiver pronto."
			_menu_add_button(content, "RETOMAR A AVENTURA", _close_menu, true)
			_menu_add_button(content, "ABRIR MENU DA JORNADA", _show_menu_page.bind("hub"))
			_menu_add_button(content, "SALVAR PROGRESSO", _save_from_menu)
		"hub":
			title.text = "MENU DA JORNADA"
			subtitle.text = "Escolha uma parte da sua aventura."
			_menu_add_button(content, "PERSONAGEM  •  ITENS E TÉCNICAS", _show_menu_page.bind("character"), true)
			_menu_add_button(content, "MUNDO  •  DIÁRIO E ATLAS", _show_menu_page.bind("world"))
			_menu_add_button(content, "RETOMAR A AVENTURA", _close_menu)
		"character":
			title.text = "PERSONAGEM"
			subtitle.text = "Recursos, equipamento e técnicas de Tobi e Breu."
			_menu_add_button(content, "MOCHILA", _show_menu_page.bind("inventory"), true)
			_menu_add_button(content, "EQUIPAMENTO & FORJA", _show_menu_page.bind("equipment"))
			_menu_add_button(content, "HABILIDADES", _show_menu_page.bind("skills"))
		"world":
			title.text = "MUNDO & MISSÕES"
			subtitle.text = "Acompanhe a história e explore as regiões."
			_menu_add_button(content, "DIÁRIO DE MISSÕES", _show_menu_page.bind("quests"), true)
			_menu_add_button(content, "ATLAS DO MUNDO", _show_menu_page.bind("map"))
			_menu_add_button(content, "CONFIGURAÇÕES", _show_menu_page.bind("settings"))
		"inventory":
			title.text = "MOCHILA DE TOBI"
			subtitle.text = "Poções, materiais e arma de Tobi."
			_update_inventory()
			_menu_add_section_label(content, "CONSUMÍVEIS", "Poções para recuperar vida")
			_menu_add_item_grid(content, [
				{"symbol": "✚", "name": "Poção de vida", "count": potions, "detail": "Recupera 45 de vida", "accent": Color("c77d72")}
			])
			_menu_add_section_label(content, "MATERIAIS", "Materiais coletados")
			_menu_add_item_grid(content, [
				{"symbol": "◆", "name": "Fragmentos Rubros", "count": shards, "detail": "Aprimoram a espada", "accent": Color("bd7a78")},
				{"symbol": "⌁", "name": "Orelhas de Goblin", "count": goblin_ears, "detail": "Troféus de goblins", "accent": Color("b5a078")},
				{"symbol": "❋", "name": "Ervas do Pântano", "count": swamp_herbs, "detail": "Coleta do pântano", "accent": Color("88a77c")},
				{"symbol": "◈", "name": "Essência Sombria", "count": dark_essence, "detail": "Saque de criaturas", "accent": Color("a88bc4")}
			])
			_menu_add_section_label(content, "EQUIPAMENTO", "Arma atual")
			_menu_add_card(content, "ESPADA DE TOBI  •  NÍVEL +%d" % weapon_level, "Dano: %d   •   Vida máxima: %d   •   Nível: %d" % [35 + weapon_level * 10 + (_get_player_level() - 1) * 3, player.max_hp, _get_player_level()])
			_menu_add_button(content, "EQUIPAMENTO", _show_menu_page.bind("equipment"))
		"equipment":
			title.text = "EQUIPAMENTO & FORJA"
			subtitle.text = "Prepare Tobi antes de enfrentar as criaturas do mundo."
			var level := _get_player_level()
			var damage := 35 + weapon_level * 10 + (level - 1) * 3
			_menu_add_card(content, "ESPADA DE TOBI  •  NÍVEL +%d" % weapon_level, "Dano atual: %d\nVida máxima: %d\nNível do aventureiro: %d\nFragmentos Rubros: %d" % [damage, player.max_hp, level, shards])
			if weapon_level < WEAPON_UPGRADE_COSTS.size():
				var cost: int = WEAPON_UPGRADE_COSTS[weapon_level]
				var master := get_node_or_null("Mestre Azulan")
				var near_forge := is_instance_valid(master) and player.global_position.distance_to(master.global_position) <= 5.0
				var forge_caption := "APRIMORAR ESPADA  •  %d FRAGMENTOS" % cost if near_forge else "FORJA  •  VISITE MESTRE AZULAN"
				var forge := _menu_add_button(content, forge_caption, _upgrade_from_menu, true)
				forge.disabled = not near_forge or shards < cost
				if not near_forge:
					_menu_add_card(content, "FORJA DISTANTE", "Aprimoramentos só podem ser feitos ao lado de Mestre Azulan, na Clareira Inicial.")
				elif shards < cost:
					_menu_add_card(content, "FALTAM FRAGMENTOS", "Você precisa de mais %d Fragmentos Rubros." % (cost - shards))
			else:
				_menu_add_card(content, "FORJA", "Sua espada já alcançou o nível máximo disponível nesta versão.")
			_menu_add_card(content, "PROTEÇÃO", "Vida máxima atual: %d. Poções disponíveis: %d." % [player.max_hp, potions])
		"skills":
			title.text = "TÉCNICAS & VÍNCULO"
			subtitle.text = "As habilidades reais disponíveis para Tobi e Breu."
			_menu_add_card(content, "COMBATE • SEQUÊNCIA DE GOLPES", "Encadeie até três ataques. O terceiro golpe causa dano ampliado e consome vigor.")
			_menu_add_card(content, "ESQUIVA", "Deslocamento rápido para escapar de ataques. Usa vigor, que se recupera com o tempo. Vigor atual: %d%%." % int(player.stamina))
			_menu_add_card(content, "BREU • PULSO SOMBRIO", "A habilidade do companheiro revela presenças ocultas e atinge inimigos próximos. Recarga: %.1f s." % player.shadow_pulse_cooldown)
			_menu_add_card(content, "SALTO", "Pule para atravessar desníveis e explorar o terreno.")
		"quests":
			title.text = "DIÁRIO DA JORNADA"
			subtitle.text = "A história, os objetivos e os contratos registrados."
			_menu_add_section_label(content, "CAPÍTULO ATUAL", "A missão que guia seus passos")
			_menu_add_card(content, "OBJETIVO PRINCIPAL", quest_text + "\n" + (objective_label.text if is_instance_valid(objective_label) else "Sem objetivo ativo."))
			_menu_add_section_label(content, "REGISTRO DE EXPLORAÇÃO", "Atividades opcionais e descobertas")
			_menu_add_progress_row(content, "Cavaleiros Afogados", "Derrote os guardiões do Rio Prateado", river_knights_defeated, 3, Color("7da9ad"))
			_menu_add_progress_row(content, "Totens Purificados", "Quebre os selos corrompidos do pântano", swamp_totems, 3, Color("c49a62"))
			_menu_add_progress_row(content, "Lanternas do Bosque", "Acenda as três lanternas dos sussurros", whisper_lantern_ids.size(), 3, Color("83b9a7"))
			var blessing_text := "Bênção recebida" if whisper_guardian_reward_claimed else "Converse com o Cervo Guardião após acender as lanternas"
			_menu_add_card(content, "RECOMPENSA DO BOSQUE", blessing_text)
			if guild_contract_started:
				_menu_add_progress_row(content, "Contrato da Guilda", "Recupere os selos antigos", guild_relic_ids.size(), 3, Color("c49a62"))
				_menu_add_card(content, "ESTADO DO CONTRATO", "Concluído" if guild_contract_claimed else "Em andamento")
		"map":
			title.text = "ATLAS DO MUNDO"
			subtitle.text = "Regiões e marcos conhecidos de Tobi e Breu."
			_menu_add_card(content, "REGIÕES NATURAIS", "CLAREIRA INICIAL  •  (0, 0)\nPÂNTANO DOS RATOS  •  (0, -91)\nRIO PRATEADO  •  (55, -127)\nBOSQUE DOS SUSSURROS  •  (96, -145)\nFLORESTA ANCESTRAL  •  (-158, -104)\nMONTANHA GELADA  •  (-166, -260)\nDESFILADEIRO RUBRO  •  (166, -260)\nRUÍNAS ANTIGAS  •  (164, -65)\nPLANÍCIE DOURADA  •  (0, 246)\nCUME DAS NUVENS  •  (0, -325)\nTEMPLO DO CORAÇÃO  •  (165, -330)")
			_menu_add_card(content, "CIVILIZAÇÃO & EXPLORAÇÃO", "VILA DO CARVALHO  •  CIDADE DE PEDRA\nGUILDA DOS VIGIAS  •  CAVERNA DO ECO\nMASMORRA DAS CINZAS  •  CASTELO DO SILÊNCIO")
			_menu_add_card(content, "LEGENDA", "As coordenadas são aproximadas e usam a Clareira Inicial como referência. O atlas não teletransporta o personagem.")
		"settings":
			title.text = "CONFIGURAÇÕES"
			subtitle.text = "Ajuste a câmera e consulte os controles."
			_menu_add_card(content, "GRÁFICOS • 4K ADAPTATIVO", "PC com tela 4K: renderização 3840×2160 automática. Outras telas de PC: 1920×1080. Android: resolução nativa do aparelho para preservar desempenho.")
			_menu_add_card(content, "SENSIBILIDADE DA CÂMERA", "Arraste na metade direita da tela para girar a câmera. Ajuste a velocidade abaixo.")
			var sensitivity := HSlider.new()
			sensitivity.min_value = 0.003
			sensitivity.max_value = 0.012
			sensitivity.step = 0.001
			sensitivity.value = camera_sensitivity_setting
			sensitivity.custom_minimum_size = Vector2(0, 42)
			sensitivity.value_changed.connect(_set_camera_sensitivity)
			sensitivity.drag_ended.connect(func(_changed: bool): _save_settings())
			content.add_child(sensitivity)
			var sensitivity_value := Label.new()
			sensitivity_value.text = "Sensibilidade: %.3f" % camera_sensitivity_setting
			sensitivity_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			sensitivity_value.add_theme_color_override("font_color", Color("d8b77c"))
			sensitivity.value_changed.connect(func(value: float): sensitivity_value.text = "Sensibilidade: %.3f" % value)
			content.add_child(sensitivity_value)
			_menu_add_card(content, "CONTROLES", "Mover: direcional esquerdo\nCâmera: arraste no lado direito\nAtacar: ATACAR  •  Pular: PULAR\nEsquivar: ESQUIVAR  •  Interagir: INTERAGIR\nPoção: POÇÃO  •  Breu: BREU")
			_menu_add_button(content, "SALVAR CONFIGURAÇÕES", _save_settings, true)


func _menu_add_item_grid(parent: Control, items: Array) -> void:
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 9)
	grid.add_theme_constant_override("v_separation", 9)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(grid)
	for item in items:
		var slot := PanelContainer.new()
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var style := _hud_button_style(Color("18211d"), Color("596a5c"), 9)
		style.set_border_width_all(1)
		style.content_margin_left = 11.0
		style.content_margin_right = 11.0
		style.content_margin_top = 10.0
		style.content_margin_bottom = 10.0
		slot.add_theme_stylebox_override("panel", style)
		grid.add_child(slot)
		var stack := VBoxContainer.new()
		stack.add_theme_constant_override("separation", 4)
		slot.add_child(stack)
		var top := HBoxContainer.new()
		stack.add_child(top)
		var symbol := Label.new()
		symbol.text = str(item.get("symbol", "◇"))
		symbol.add_theme_font_size_override("font_size", 18)
		symbol.add_theme_color_override("font_color", item.get("accent", Color("d8b77c")))
		top.add_child(symbol)
		var amount := Label.new()
		amount.text = "× %d" % int(item.get("count", 0))
		amount.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		amount.add_theme_font_size_override("font_size", 15)
		amount.add_theme_color_override("font_color", Color("f0dfbf"))
		top.add_child(amount)
		var item_name := Label.new()
		item_name.text = str(item.get("name", "Item"))
		item_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		item_name.add_theme_font_size_override("font_size", 11)
		item_name.add_theme_color_override("font_color", Color("dfc18e"))
		stack.add_child(item_name)
		var detail := Label.new()
		detail.text = str(item.get("detail", ""))
		detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		detail.add_theme_font_size_override("font_size", 9)
		detail.add_theme_color_override("font_color", Color("9eaa9f"))
		stack.add_child(detail)


func _menu_add_stat_strip(parent: Control) -> void:
	var strip := HBoxContainer.new()
	strip.name = "JourneyStatStrip"
	strip.add_theme_constant_override("separation", 8)
	parent.add_child(strip)
	var level := _get_player_level()
	_menu_add_stat_tile(strip, "NÍVEL", "%02d" % level, Color("d8b77c"))
	_menu_add_stat_tile(strip, "VIDA", "%d/%d" % [player.hp, player.max_hp], Color("c77d72"))
	_menu_add_stat_tile(strip, "POÇÕES", "%02d" % potions, Color("83b9a7"))
	_menu_add_stat_tile(strip, "FRAGMENTOS", "%02d" % shards, Color("b58bcb"))


func _menu_add_stat_tile(parent: Control, caption: String, value: String, accent: Color) -> void:
	var tile := PanelContainer.new()
	tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var tile_style := _hud_button_style(Color("202a24"), Color("596c5d"), 9)
	tile_style.set_border_width_all(1)
	tile_style.content_margin_left = 8.0
	tile_style.content_margin_right = 8.0
	tile_style.content_margin_top = 8.0
	tile_style.content_margin_bottom = 8.0
	tile.add_theme_stylebox_override("panel", tile_style)
	parent.add_child(tile)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 2)
	tile.add_child(stack)
	var number := Label.new()
	number.text = value
	number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	number.add_theme_font_size_override("font_size", 18)
	number.add_theme_color_override("font_color", accent)
	stack.add_child(number)
	var name := Label.new()
	name.text = caption
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name.add_theme_font_size_override("font_size", 8)
	name.add_theme_color_override("font_color", Color("aeb9ad"))
	stack.add_child(name)


func _menu_add_section_label(parent: Control, kicker: String, caption: String) -> void:
	var group := VBoxContainer.new()
	group.add_theme_constant_override("separation", 2)
	parent.add_child(group)
	var label := Label.new()
	label.text = kicker
	label.add_theme_font_size_override("font_size", 9)
	label.add_theme_color_override("font_color", Color("c49a62"))
	group.add_child(label)
	var detail := Label.new()
	detail.text = caption
	detail.add_theme_font_size_override("font_size", 11)
	detail.add_theme_color_override("font_color", Color("b9c4b8"))
	group.add_child(detail)


func _menu_add_progress_row(parent: Control, heading: String, detail: String, current: int, target: int, accent: Color) -> void:
	var card := PanelContainer.new()
	var style := _hud_button_style(Color("19231e"), Color("526457"), 10)
	style.set_border_width_all(1)
	style.content_margin_left = 13.0
	style.content_margin_right = 13.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	card.add_theme_stylebox_override("panel", style)
	parent.add_child(card)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 5)
	card.add_child(stack)
	var heading_row := HBoxContainer.new()
	stack.add_child(heading_row)
	var title := Label.new()
	title.text = heading
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 12)
	title.add_theme_color_override("font_color", Color("e5d7bd"))
	heading_row.add_child(title)
	var count := Label.new()
	count.text = "%d / %d" % [mini(current, target), target]
	count.add_theme_font_size_override("font_size", 11)
	count.add_theme_color_override("font_color", accent)
	heading_row.add_child(count)
	var note := Label.new()
	note.text = detail
	note.add_theme_font_size_override("font_size", 10)
	note.add_theme_color_override("font_color", Color("9eaa9f"))
	stack.add_child(note)
	var progress := ProgressBar.new()
	progress.custom_minimum_size = Vector2(0, 9)
	progress.max_value = maxi(1, target)
	progress.value = clampi(current, 0, target)
	progress.show_percentage = false
	progress.add_theme_stylebox_override("background", _hud_bar_style(Color("303a33")))
	progress.add_theme_stylebox_override("fill", _hud_bar_style(accent))
	stack.add_child(progress)


func _menu_add_hero(parent: Control) -> void:
	var hero := PanelContainer.new()
	hero.name = "MainMenuHero"
	var hero_style := _hud_button_style(Color("1b2822"), Color("a98752"), 16)
	hero_style.set_border_width_all(1)
	hero_style.shadow_color = Color(0.0, 0.0, 0.0, 0.55)
	hero_style.shadow_size = 12
	hero_style.shadow_offset = Vector2(0, 5)
	hero_style.content_margin_left = 14.0
	hero_style.content_margin_right = 14.0
	hero_style.content_margin_top = 14.0
	hero_style.content_margin_bottom = 14.0
	hero.add_theme_stylebox_override("panel", hero_style)
	parent.add_child(hero)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	hero.add_child(row)
	var sigil := TextureRect.new()
	sigil.name = "TobiBreuEmblem"
	sigil.texture = load("res://assets/icons/tobi_breu_icon.svg")
	sigil.custom_minimum_size = Vector2(112, 112)
	sigil.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	sigil.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(sigil)
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_theme_constant_override("separation", 7)
	row.add_child(copy)
	var names := Label.new()
	names.text = "TOBI  &  BREU"
	names.add_theme_font_size_override("font_size", 22)
	names.add_theme_color_override("font_color", Color("f0d8a7"))
	copy.add_child(names)
	var descriptor := Label.new()
	descriptor.text = "Fantasia sombria  •  Aventura 3D"
	descriptor.add_theme_font_size_override("font_size", 10)
	descriptor.add_theme_color_override("font_color", Color("a9b9a9"))
	copy.add_child(descriptor)
	var story := Label.new()
	story.text = "Dois companheiros. Um mundo consumido pelas sombras."
	story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story.add_theme_font_size_override("font_size", 13)
	story.add_theme_color_override("font_color", Color("e2e0d3"))
	copy.add_child(story)


func _menu_add_button(parent: Control, caption: String, callback: Callable, primary := false) -> Button:
	var button := Button.new()
	button.text = ("✦  " if primary else "◇  ") + caption + "     ›"
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.custom_minimum_size = Vector2(0, 78 if primary else 72)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 16 if primary else 14)
	button.add_theme_color_override("font_color", Color("f0dfbf") if primary else Color("c5cfc2"))
	button.add_theme_color_override("font_hover_color", Color("fff0cf"))
	var fill := Color(0.13, 0.085, 0.045, 0.99) if primary else Color(0.055, 0.075, 0.067, 0.98)
	var edge := Color("d8b77c") if primary else Color("8c7956")
	var normal_style := _ui_button_texture_style(edge)
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", _ui_button_texture_style(edge.lightened(1.22)))
	button.add_theme_stylebox_override("pressed", _ui_button_texture_style(Color("f0d49b")))
	button.add_theme_stylebox_override("focus", _ui_button_texture_style(Color("e8c987")))
	button.add_theme_stylebox_override("disabled", _ui_button_texture_style(Color("59645b")))
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _menu_add_card(parent: Control, heading: String, body: String) -> void:
	var card := PanelContainer.new()
	var card_style := _hud_button_style(Color("1a241f"), Color("786443"), 12)
	card_style.set_border_width_all(1)
	card_style.shadow_color = Color(0.0, 0.0, 0.0, 0.38)
	card_style.shadow_size = 2
	card_style.shadow_offset = Vector2(0, 1)
	card_style.content_margin_left = 15.0
	card_style.content_margin_right = 15.0
	card_style.content_margin_top = 12.0
	card_style.content_margin_bottom = 12.0
	card.add_theme_stylebox_override("panel", card_style)
	parent.add_child(card)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 5)
	card.add_child(box)
	var heading_row := HBoxContainer.new()
	box.add_child(heading_row)
	var marker := Label.new()
	marker.text = "◆"
	marker.add_theme_font_size_override("font_size", 10)
	marker.add_theme_color_override("font_color", Color("b18a52"))
	heading_row.add_child(marker)
	var title := Label.new()
	title.text = heading
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 11)
	title.add_theme_color_override("font_color", Color("dfc18e"))
	heading_row.add_child(title)
	var rule := ColorRect.new()
	rule.custom_minimum_size = Vector2(0, 1)
	rule.color = Color(0.48, 0.39, 0.25, 0.55)
	box.add_child(rule)
	var detail := Label.new()
	detail.text = body
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.add_theme_font_size_override("font_size", 13)
	detail.add_theme_color_override("font_color", Color("e5dfd0"))
	detail.add_theme_constant_override("line_spacing", 3)
	box.add_child(detail)


func _open_menu(page: String = "pause") -> void:
	if not is_instance_valid(menu_layer): return
	menu_layer.visible = true
	get_tree().paused = true
	_show_menu_page(page)


func _start_game() -> void:
	if is_instance_valid(hud):
		hud.visible = true
	if game_started:
		_close_menu()
		return
	if is_instance_valid(menu_layer):
		menu_layer.visible = false
	# O mundo já foi preparado na inicialização; não exibir uma segunda tela
	# de carregamento artificial nem manter a árvore pausada após tocar em Jogar.
	game_started = true
	get_tree().paused = false
	print("TOBI_BREU_GAME_STARTED")


func _close_menu() -> void:
	if is_instance_valid(menu_layer): menu_layer.visible = false
	get_tree().paused = false


func _menu_back() -> void:
	if menu_page == "main":
		if game_started: _close_menu()
		return
	if menu_page == "pause":
		_close_menu()
		return
	if menu_page == "hub":
		_show_menu_page("pause")
	elif menu_page == "character" or menu_page == "world":
		_show_menu_page("hub")
	elif menu_page == "inventory" or menu_page == "equipment" or menu_page == "skills":
		_show_menu_page("character")
	elif menu_page == "quests" or menu_page == "map" or menu_page == "settings":
		_show_menu_page("world" if game_started else "main")
	else:
		_show_menu_page("pause" if game_started else "main")


func _save_from_menu() -> void:
	_save_game()
	menu_feedback.text = "PROGRESSO SALVO COM SUCESSO"


func _upgrade_from_menu() -> void:
	var previous_level := weapon_level
	_upgrade_weapon()
	_show_menu_page("equipment")
	if weapon_level > previous_level:
		menu_feedback.text = "ESPADA APRIMORADA • NÍVEL +%d" % weapon_level
	elif is_instance_valid(toast_label):
		menu_feedback.text = toast_label.text


func _set_camera_sensitivity(value: float) -> void:
	camera_sensitivity_setting = value
	if is_instance_valid(player): player.camera_sensitivity = value


func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(settings_path) == OK:
		camera_sensitivity_setting = clampf(float(cfg.get_value("controls", "camera_sensitivity", 0.006)), 0.003, 0.012)


func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("controls", "camera_sensitivity", camera_sensitivity_setting)
	var result := cfg.save(settings_path)
	if is_instance_valid(menu_feedback):
		menu_feedback.text = "CONFIGURAÇÕES SALVAS" if result == OK else "NÃO FOI POSSÍVEL SALVAR"


func _hud_bar_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = color.lightened(0.22)
	style.set_border_width_all(1)
	style.set_corner_radius_all(7)
	style.anti_aliasing = true
	return style


func _ui_button_texture_style(tint: Color) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = load("res://assets/ui/button_frame.svg")
	style.texture_margin_left = 24.0
	style.texture_margin_right = 24.0
	style.texture_margin_top = 18.0
	style.texture_margin_bottom = 18.0
	style.modulate_color = tint
	style.draw_center = true
	return style


func _hud_button_style(fill: Color, accent: Color, radius: int = 16) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = accent
	style.set_border_width_all(2)
	# Sombras menores reduzem o custo de renderização em telas móveis.
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.24)
	style.shadow_size = 2
	style.shadow_offset = Vector2(0, 1)
	style.set_corner_radius_all(radius)
	style.corner_detail = 4
	style.anti_aliasing = false
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style


func _touch_action(action: String) -> void:
	if action == "attack": player.do_attack()
	elif action == "jump": player.do_jump()
	elif action == "interact": _interact()
	elif action == "dodge": player.do_dodge()
	elif action == "potion": _use_potion()
	elif action == "upgrade": _upgrade_weapon()
	elif action == "inventory": _toggle_inventory()
	elif action == "shadow": player.do_shadow_pulse()
	elif action == "guard": player.do_guard()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if is_instance_valid(menu_layer) and menu_layer.visible:
				_menu_back()
			elif game_started:
				_open_menu("pause")
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_I:
			if is_instance_valid(menu_layer) and menu_layer.visible:
				_show_menu_page("inventory")
			else:
				_open_menu("inventory")
			get_viewport().set_input_as_handled()

func _toggle_inventory() -> void:
	if is_instance_valid(menu_layer) and menu_layer.visible:
		if menu_page == "inventory": _menu_back()
		else: _show_menu_page("inventory")
	else:
		_open_menu("inventory")

func _process(delta: float) -> void:
	day_clock = fposmod(day_clock + delta * 0.0022, TAU)
	if is_instance_valid(sun_light):
		var daylight := 0.52 + 0.48 * maxf(0.0, sin(day_clock))
		sun_light.light_energy = 0.28 + daylight * 0.95
		sun_light.rotation_degrees.x = -18.0 - daylight * 48.0
		if world_environment and world_environment.environment:
			world_environment.environment.ambient_light_energy = 0.28 + daylight * 0.42
	if save_toast_timer > 0.0:
		save_toast_timer = maxf(0.0, save_toast_timer - delta)
		if save_toast_timer == 0.0 and toast_label and toast_label.text == "Progresso salvo": toast_label.text = ""
	if boss_hud_panel:
		boss_hud_panel.visible = quest_stage == 12
		if quest_stage == 12:
			var river_boss := get_node_or_null("Leviata_do_Lodo")
			if river_boss and boss_health_bar:
				boss_health_bar.value = maxf(0.0, float(river_boss.get("hp")))
	if not is_instance_valid(player): return
	# Modelos opcionais entram somente quando o jogador alcança a área correspondente.
	# A carga em thread mantém a exploração jogável enquanto GLBs e texturas são preparados.
	if not nature_models_stream_requested and player.global_position.distance_to(Vector3(-145.0, 0.0, -145.0)) < 90.0:
		nature_models_stream_requested = true
		_build_downloaded_nature_models()
	if not itch_dungeon_stream_requested and player.global_position.distance_to(Vector3(226.0, 0.0, 89.0)) < 82.0:
		_start_itch_dungeon_streaming()
	if itch_dungeon_stream_requested and not itch_dungeon_assets_loaded:
		_poll_itch_dungeon_streaming()
	var nearest := 999.0
	var npc := get_node_or_null("Mestre Azulan")
	if npc:
		nearest = player.global_position.distance_to(npc.global_position)
	var shrine := get_node_or_null("OldShrine")
	var shrine_distance := player.global_position.distance_to(shrine.global_position) if shrine else 999.0
	var river_npc := get_node_or_null("Guardião do Rio")
	var river_distance := player.global_position.distance_to(river_npc.global_position) if river_npc else 999.0
	var river_puzzle := get_node_or_null("RiverShrinePuzzle")
	var river_puzzle_distance := player.global_position.distance_to(river_puzzle.global_position) if river_puzzle else 999.0
	var nearest_chest_id := _nearest_river_chest()
	var nearest_lantern_id := _nearest_whisper_lantern()
	var grove_distance := Vector2(player.global_position.x - 96.0, player.global_position.z + 145.0).length()
	if whisper_grove_label:
		whisper_grove_label.visible = grove_distance < 24.0
		whisper_grove_label.text = "BOSQUE DOS SUSSURROS  •  %d/3 LANTERNAS" % whisper_lantern_ids.size()
	var lantern_distance := player.global_position.distance_to(get_node_or_null("WhisperLantern_%d" % nearest_lantern_id).global_position) if nearest_lantern_id >= 0 and get_node_or_null("WhisperLantern_%d" % nearest_lantern_id) else 999.0
	var stag_guardian := get_node_or_null("WhisperStagGuardian")
	var stag_guardian_distance := player.global_position.distance_to(stag_guardian.global_position) if stag_guardian else 999.0
	var chest_distance := player.global_position.distance_to(get_node_or_null("RiverTreasureChest_%d" % nearest_chest_id).global_position) if nearest_chest_id >= 0 and get_node_or_null("RiverTreasureChest_%d" % nearest_chest_id) else 999.0
	var guild_board := get_node_or_null("GuildaDosVigias/GuildContractBoard")
	var guild_distance := player.global_position.distance_to(guild_board.global_position) if guild_board else 999.0
	var bell_tower := get_node_or_null("EchoingBellTower")
	var bell_tower_distance := player.global_position.distance_to(bell_tower.global_position) if bell_tower else 999.0
	var nearest_waystone_id := _nearest_ancient_waystone()
	var waystone_node := get_node_or_null("AncientWaystone_%d" % nearest_waystone_id) if nearest_waystone_id >= 0 else null
	var waystone_distance := player.global_position.distance_to(waystone_node.global_position) if waystone_node else 999.0
	var nearest_ashen_relic_id := _nearest_ashen_relic()
	var ashen_relic_distance := 999.0
	if nearest_ashen_relic_id >= 0:
		var ashen_relic := get_node_or_null("AldeiaDasCinzas/AshenRelic_%d" % nearest_ashen_relic_id)
		if ashen_relic: ashen_relic_distance = player.global_position.distance_to(ashen_relic.global_position)
	var ashen_altar := get_node_or_null("AldeiaDasCinzas/AshenRewardAltar")
	var ashen_altar_distance := player.global_position.distance_to(ashen_altar.global_position) if ashen_altar else 999.0
	var nearest_guild_relic_distance := 999.0
	for relic_id in range(3):
		var relic := get_node_or_null("GuildRelic_%d" % relic_id)
		if relic and relic.visible:
			nearest_guild_relic_distance = minf(nearest_guild_relic_distance, player.global_position.distance_to(relic.global_position))
	if guild_distance < 4.5: prompt_label.text = "E: QUADRO DA GUILDA DOS VIGIAS"
	elif nearest_guild_relic_distance < 3.8: prompt_label.text = "E: RECUPERAR SELO ANTIGO"
	elif nearest < 4.0: prompt_label.text = "E: FALAR COM AZULAN  •  U: FORJAR ESPADA"
	elif river_distance < 4.5: prompt_label.text = "E: FALAR COM O GUARDIÃO DO RIO"
	elif chest_distance < 3.2: prompt_label.text = "E: ABRIR BAÚ DO RIO PRATEADO"
	elif lantern_distance < 3.5: prompt_label.text = "E: ACENDER LANTERNA DO BOSQUE (%d/3)" % whisper_lantern_ids.size()
	elif stag_guardian_distance < 4.5 and whisper_lantern_ids.size() < 3: prompt_label.text = "O GUARDIÃO AGUARDA AS 3 LANTERNAS"
	elif stag_guardian_distance < 4.5 and whisper_guardian_reward_claimed: prompt_label.text = "O GUARDIÃO JÁ CONCEDEU SUA BÊNÇÃO"
	elif stag_guardian_distance < 4.5: prompt_label.text = "E: RECEBER A BÊNÇÃO DO GUARDIÃO"
	elif ashen_relic_distance < 3.6: prompt_label.text = "E: RECUPERAR RELÍQUIA DAS CINZAS  •  (%d/3)" % ashen_relic_ids.size()
	elif ashen_altar_distance < 4.0 and ashen_relic_ids.size() >= 3 and not ashen_reward_claimed: prompt_label.text = "E: REIVINDICAR TESOURO DA CRIPTA"
	elif ashen_altar_distance < 4.0 and ashen_reward_claimed: prompt_label.text = "ALTAR DAS CINZAS — DESPERTO"
	elif waystone_distance < 4.0: prompt_label.text = "E: ATIVAR PEDRA-ÂNCORA ANTIGA  •  (%d/3)" % ancient_waystone_ids.size()
	elif bell_tower_distance < 5.0 and bell_tower_ring_count < 3: prompt_label.text = "E: TOCAR O SINO ANTIGO  •  (%d/3)" % bell_tower_ring_count
	elif bell_tower_distance < 5.0: prompt_label.text = "SINO DO ÚLTIMO VIGIA — CONCLUÍDO"
	elif river_puzzle_distance < 4.8 and not river_shrine_solved: prompt_label.text = "E: GIRAR O ANEL DO ASTROLÁBIO  •  (%d/3)" % (mini(_river_puzzle_current_ring() + 1, 3))
	elif river_puzzle_distance < 4.8 and river_shrine_solved: prompt_label.text = "ASTROLÁBIO RESTAURADO — RECOMPENSA COLETADA"
	elif shrine_distance < 3.8: prompt_label.text = "INTERAGIR — Santuário Esquecido"
	elif quest_stage == 5 and _nearest_swamp_totem_distance() < 3.5: prompt_label.text = "INTERAGIR — Purificar Totem"
	else: prompt_label.text = "Arraste o lado direito para mover a câmera"
	if stamina_bar and player.has_method("get_stamina"):
		stamina_bar.value = player.get_stamina()
	if shadow_skill_label and player.shadow_pulse_cooldown > 0.0:
		shadow_skill_label.text = "BREU  •  Pulso Sombrio: %.1fs" % player.shadow_pulse_cooldown
	elif shadow_skill_label:
		shadow_skill_label.text = "BREU  •  Pulso Sombrio pronto [K]"
	if Input.is_action_just_pressed("interact"):
		_interact()
	if Input.is_action_just_pressed("attack"):
		player.do_attack()
	if Input.is_action_just_pressed("potion"):
		_use_potion()
	if Input.is_action_just_pressed("upgrade"):
		_upgrade_weapon()

func _river_puzzle_current_ring() -> int:
	for i in range(3):
		if river_puzzle_ring_steps[i] != RIVER_PUZZLE_TARGETS[i]:
			return i
	return 2

func _nearest_swamp_totem_distance() -> float:
	var nearest := 999.0
	for i in range(3):
		var totem := get_node_or_null("SwampTotem_%d" % i)
		if totem and not totem.get_meta("used", false) and is_instance_valid(player):
			nearest = minf(nearest, player.global_position.distance_to(totem.global_position))
	return nearest

func _nearest_whisper_lantern() -> int:
	if not is_instance_valid(player): return -1
	var best_id := -1
	var best_distance := 3.5
	for i in range(3):
		if whisper_lantern_ids.has(i): continue
		var lantern := get_node_or_null("WhisperLantern_%d" % i)
		if lantern:
			var distance := player.global_position.distance_to(lantern.global_position)
			if distance < best_distance:
				best_distance = distance
				best_id = i
	return best_id

func _activate_whisper_lantern(lantern_id: int) -> void:
	if lantern_id < 0 or lantern_id >= 3 or whisper_lantern_ids.has(lantern_id): return
	var lantern := get_node_or_null("WhisperLantern_%d" % lantern_id)
	if not lantern: return
	whisper_lantern_ids.append(lantern_id)
	whisper_lantern_ids.sort()
	lantern.set_meta("lit", true)
	var flame := lantern.get_node_or_null("LanternFlame")
	if flame:
		flame.material_override = _painter_mat(Color("8ac9bc"), 7.0, 0.22)
	var light := lantern.get_node_or_null("LanternLight")
	if light: light.light_energy = 0.9
	_grant_xp(22)
	dark_essence += 1
	if whisper_lantern_ids.size() == 3:
		shards += 1
		toast_label.text = "BOSQUE DESPERTOU! +22 XP • Essência +1 • Fragmento Rubro +1"
	else:
		toast_label.text = "LANTERNA ACESA (%d/3) • +22 XP • Essência Sombria +1" % whisper_lantern_ids.size()
	_update_inventory()
	_save_game()

func _nearest_river_chest() -> int:
	if not is_instance_valid(player): return -1
	var best_id := -1
	var best_distance := 3.2
	for i in range(3):
		if river_chest_ids.has(i): continue
		var chest := get_node_or_null("RiverTreasureChest_%d" % i)
		if chest:
			var distance := player.global_position.distance_to(chest.global_position)
			if distance < best_distance:
				best_distance = distance
				best_id = i
	return best_id

func _nearest_ashen_relic() -> int:
	if not is_instance_valid(player): return -1
	var best_id := -1
	var best_distance := 3.6
	for i in range(3):
		if ashen_relic_ids.has(i): continue
		var relic := get_node_or_null("AldeiaDasCinzas/AshenRelic_%d" % i)
		if relic:
			var distance := player.global_position.distance_to(relic.global_position)
			if distance < best_distance:
				best_distance = distance
				best_id = i
	return best_id

func _nearest_ancient_waystone() -> int:
	if not is_instance_valid(player): return -1
	var best_id := -1
	var best_distance := 4.0
	for i in range(3):
		if ancient_waystone_ids.has(i): continue
		var stone := get_node_or_null("AncientWaystone_%d" % i)
		if stone:
			var distance := player.global_position.distance_to(stone.global_position)
			if distance < best_distance:
				best_distance = distance
				best_id = i
	return best_id

func _build_ancient_waystones() -> void:
	var positions := [Vector3(-158.0, 0.0, -91.0), Vector3(-166.0, 0.0, -247.0), Vector3(158.0, 0.0, -91.0)]
	var labels := ["Raiz", "Geada", "Brasa"]
	for i in range(positions.size()):
		var stone := Node3D.new()
		stone.name = "AncientWaystone_%d" % i
		stone.position = positions[i]
		add_child(stone)
		var pillar := _box(stone, "WaystonePillar", Vector3(0.0, 1.7, 0.0), Vector3(1.35, 3.4, 0.8), Color("59665d"))
		pillar.rotation.z = -0.08 if i % 2 == 0 else 0.08
		_box(stone, "WaystoneBase", Vector3(0.0, 0.25, 0.0), Vector3(2.2, 0.5, 1.5), Color("454e49"))
		var rune := _sphere(stone, "WaystoneRune", Vector3(0.0, 1.8, 0.46), 0.28, Color("779b8a"), 1.6)
		rune.scale = Vector3(0.7, 1.4, 0.35)

		# Escultura modular: pedestal, molduras talhadas e fragmentos flutuantes.
		var theme_colors := [Color("739b78"), Color("8fc4d1"), Color("c66b53")]
		var accent_color: Color = theme_colors[i]
		var dais := _sphere(stone, "WaystoneDais", Vector3(0.0, 0.12, 0.0), 1.0, Color("343d38"), 0.28)
		dais.scale = Vector3(1.55, 0.42, 1.18)
		var crown := _box(stone, "WaystoneCrown", Vector3(0.0, 3.42, 0.0), Vector3(1.72, 0.34, 1.08), Color("777b70"))
		crown.rotation.y = 0.12 if i == 1 else -0.08
		_box(stone, "WaystoneLowerCarving", Vector3(0.0, 0.72, 0.43), Vector3(1.52, 0.16, 0.12), Color("303b36"))
		_box(stone, "WaystoneUpperCarving", Vector3(0.0, 2.92, 0.43), Vector3(1.42, 0.13, 0.12), Color("303b36"))
		for glyph_index in range(3):
			var glyph := _box(stone, "WaystoneGlyph_%d" % glyph_index, Vector3(-0.34 + float(glyph_index) * 0.34, 1.25 + float(glyph_index) * 0.34, 0.49), Vector3(0.10, 0.24, 0.07), accent_color)
			glyph.rotation.z = -0.42 if glyph_index == 1 else 0.38
			glyph.material_override = _painter_mat(accent_color, 8.0, 0.22)
		for shard_index in range(2):
			var shard := _sphere(stone, "WaystoneShard_%d" % shard_index, Vector3(-0.92 + float(shard_index) * 1.84, 1.0 + float(shard_index % 2) * 0.38, 0.0), 0.22, accent_color, 0.72)
			shard.scale = Vector3(0.48, 1.55, 0.48)
			shard.rotation.z = -0.24 if shard_index == 0 else 0.24
			shard.material_override = _painter_mat(accent_color, 7.0, 0.18)
		for corner in [-1.0, 1.0]:
			var brace := _box(stone, "WaystoneBrace", Vector3(corner * 0.78, 0.52, 0.0), Vector3(0.34, 0.9, 0.92), Color("4a514b"))
			brace.rotation.z = corner * -0.12
		var rune_light := OmniLight3D.new()
		rune_light.name = "WaystoneAccentLight"
		rune_light.position = Vector3(0.0, 2.0, 1.1)
		rune_light.light_color = accent_color
		rune_light.light_energy = 0.32 if not ancient_waystone_ids.has(i) else 0.85
		rune_light.omni_range = 4.0
		stone.add_child(rune_light)
		_add_region_title("PEDRA-ÂNCORA: " + labels[i].to_upper(), stone.position + Vector3(0.0, 4.2, 0.0), Color("b9d8c1"))
		if ancient_waystone_ids.has(i):
			rune.material_override = _painter_mat(Color("b9e6c9"), 8.0, 0.45)

func _open_river_chest(chest_id: int) -> void:
	if chest_id < 0 or chest_id >= 3 or river_chest_ids.has(chest_id): return
	var chest := get_node_or_null("RiverTreasureChest_%d" % chest_id)
	if not chest: return
	river_chest_ids.append(chest_id)
	river_chest_ids.sort()
	chest.set_meta("opened", true)
	var lid_pivot := chest.get_node_or_null("ChestLidPivot")
	if lid_pivot: lid_pivot.rotation.x = -1.05
	var clasp := chest.get_node_or_null("ChestClasp")
	if clasp: clasp.visible = false
	var glow := chest.get_node_or_null("ChestGlow")
	if glow: glow.visible = false
	var light := chest.get_node_or_null("ChestGlowLight")
	if light: light.light_energy = 0.0
	var xp_reward: int = [35, 45, 55][chest_id]
	var essence_reward := 1 if chest_id < 2 else 2
	var shard_reward := 1 if chest_id == 2 else 0
	_grant_xp(xp_reward)
	dark_essence += essence_reward
	shards += shard_reward
	toast_label.text = "BAÚ ABERTO! +%d XP • Essência Sombria +%d%s" % [xp_reward, essence_reward, " • Fragmento Rubro +1" if shard_reward > 0 else ""]
	_update_inventory()
	_save_game()

func _interact() -> void:
	var ashen_relic_id := _nearest_ashen_relic()
	if ashen_relic_id >= 0:
		var ashen_relic := get_node_or_null("AldeiaDasCinzas/AshenRelic_%d" % ashen_relic_id)
		if ashen_relic and ashen_relic.visible:
			ashen_relic_ids.append(ashen_relic_id)
			ashen_relic_ids.sort()
			ashen_relic.visible = false
			_grant_xp(35)
			dark_essence += 1
			if ashen_relic_ids.size() >= 3:
				toast_label.text = "AS TRÊS RELÍQUIAS DAS CINZAS RECUPERADAS! O altar da cripta despertou."
				var reward_crystal := get_node_or_null("AldeiaDasCinzas/AshenRewardAltar/AshenRewardCrystal")
				if reward_crystal:
					reward_crystal.material_override = _painter_mat(Color("d7a5df"), 7.0, 0.18, 13, Color("734d83"))
				var altar_light := OmniLight3D.new()
				altar_light.name = "AshenRewardLight"
				altar_light.position = Vector3(-15.0, 2.0, 17.0)
				altar_light.light_color = Color("c78bd9")
				altar_light.light_energy = 0.65
				altar_light.omni_range = 7.0
				get_node("AldeiaDasCinzas").add_child(altar_light)
			else:
				toast_label.text = "RELÍQUIA DAS CINZAS RECUPERADA (%d/3) • +35 XP • Essência +1" % ashen_relic_ids.size()
			_update_inventory()
			_save_game()
		return
	var ashen_altar := get_node_or_null("AldeiaDasCinzas/AshenRewardAltar")
	if ashen_altar and player.global_position.distance_to(ashen_altar.global_position) < 4.0:
		if ashen_relic_ids.size() < 3:
			toast_label.text = "O altar está selado. Recupere as três relíquias espalhadas pela aldeia (%d/3)." % ashen_relic_ids.size()
		elif not ashen_reward_claimed:
			ashen_reward_claimed = true
			_grant_xp(150)
			shards += 5
			dark_essence += 4
			potions += 2
			toast_label.text = "TESOURO DA CRIPTA REIVINDICADO! +150 XP • 5 Fragmentos • 4 Essências • 2 Poções"
			_update_inventory()
			_save_game()
		else:
			toast_label.text = "O altar já entregou seu tesouro."
		return
	var waystone_id := _nearest_ancient_waystone()
	if waystone_id >= 0:
		var waystone := get_node_or_null("AncientWaystone_%d" % waystone_id)
		if waystone and player.global_position.distance_to(waystone.global_position) < 4.0:
			if not ancient_waystone_ids.has(waystone_id):
				ancient_waystone_ids.append(waystone_id)
				ancient_waystone_ids.sort()
				var waystone_rune := waystone.get_node_or_null("WaystoneRune")
				if waystone_rune: waystone_rune.material_override = _painter_mat(Color("b9e6c9"), 8.0, 0.45)
				_grant_xp(30)
				dark_essence += 1
				if ancient_waystone_ids.size() >= 3:
					_grant_xp(120)
					shards += 4
					potions += 2
					toast_label.text = "AS TRÊS PEDRAS-ÂNCORA DESPERTARAM! +120 XP • 4 Fragmentos • 2 Poções"
				else:
					toast_label.text = "PEDRA-ÂNCORA DESPERTADA • +30 XP • Essência +1 (%d/3)" % ancient_waystone_ids.size()
				_update_inventory()
				_save_game()
			else:
				toast_label.text = "Esta Pedra-Âncora já foi despertada."
			return
	var bell_tower := get_node_or_null("EchoingBellTower")
	if bell_tower and player.global_position.distance_to(bell_tower.global_position) < 5.0:
		if bell_tower_ring_count < 3:
			bell_tower_ring_count += 1
			var bell_mesh := bell_tower.get_node_or_null("EchoingBell")
			if bell_mesh:
				bell_mesh.rotation.z = -0.22 if bell_tower_ring_count % 2 == 1 else 0.22
			if bell_tower_ring_count >= 3:
				_grant_xp(75)
				shards += 4
				dark_essence += 2
				potions += 1
				toast_label.text = "SINO DO ÚLTIMO VIGIA! +75 XP • 4 Fragmentos • 2 Essências • 1 Poção"
				_update_inventory()
			else:
				toast_label.text = "O sino antigo ecoa pela névoa... (%d/3)" % bell_tower_ring_count
			_save_game()
		else:
			toast_label.text = "O sino repousa. A última vigília foi concluída."
		return
	var guild_board := get_node_or_null("GuildaDosVigias/GuildContractBoard")
	if guild_board and player.global_position.distance_to(guild_board.global_position) < 4.5:
		if not guild_contract_started:
			guild_contract_started = true
			toast_label.text = "Guilda: recupere os três selos perdidos na Caverna, na Masmorra e no Castelo."
		elif guild_relic_ids.size() >= 3 and not guild_contract_claimed:
			guild_contract_claimed = true
			_grant_xp(240)
			shards += 8
			dark_essence += 5
			potions += 3
			toast_label.text = "CONTRATO DA GUILDA CONCLUÍDO! +240 XP • 8 Fragmentos • 5 Essências • 3 Poções"
			_update_inventory()
		else:
			toast_label.text = "Guilda: selos recuperados %d/3. Explore as regiões marcadas no mapa." % guild_relic_ids.size()
		_save_game()
		return
	for relic_id in range(3):
		var guild_relic := get_node_or_null("GuildRelic_%d" % relic_id)
		if guild_relic and guild_relic.visible and player.global_position.distance_to(guild_relic.global_position) < 3.8:
			if not guild_contract_started:
				toast_label.text = "Um selo antigo. A Guilda dos Vigias pode saber o que fazer com ele."
				return
			guild_relic_ids.append(relic_id)
			guild_relic_ids.sort()
			guild_relic.visible = false
			_grant_xp(45)
			toast_label.text = "%s recuperado! (%d/3) • Leve os selos ao quadro da Guilda." % [str(guild_relic.get_meta("relic_name")), guild_relic_ids.size()]
			_save_game()
			return
	var chest_id := _nearest_river_chest()
	if chest_id >= 0:
		_open_river_chest(chest_id)
		return
	var lantern_id := _nearest_whisper_lantern()
	if lantern_id >= 0:
		_activate_whisper_lantern(lantern_id)
		return
	var stag_guardian := get_node_or_null("WhisperStagGuardian")
	if stag_guardian and player.global_position.distance_to(stag_guardian.global_position) < 4.5:
		if whisper_lantern_ids.size() < 3:
			toast_label.text = "O Guardião Cervo permanece adormecido. Acenda as três lanternas do bosque."
		elif whisper_guardian_reward_claimed:
			toast_label.text = "O Guardião inclina a cabeça. A bênção antiga já vive em você."
		else:
			whisper_guardian_reward_claimed = true
			_grant_xp(90)
			shards += 3
			dark_essence += 2
			potions += 1
			toast_label.text = "Bênção do Cervo Ancião • +90 XP • 3 Fragmentos • 2 Essências • 1 Poção"
			_update_inventory()
			_save_game()
		return
	for i in range(3):
		var relic := get_node_or_null("RiverMemoryRelic_%d" % i)
		if relic and relic.visible and player.global_position.distance_to(relic.global_position) < 3.2:
			if not river_relic_ids.has(i):
				river_relic_ids.append(i)
				river_relic_ids.sort()
				relic.visible = false
				_grant_xp(25)
				dark_essence += 1
				toast_label.text = "ECO DO RIO RECUPERADO • +25 XP • Essência Sombria +1 (%d/3)" % river_relic_ids.size()
				_update_inventory()
				_save_game()
			else:
				toast_label.text = "Este eco já foi recuperado."
			return
	var river_puzzle := get_node_or_null("RiverShrinePuzzle")
	if river_puzzle and player.global_position.distance_to(river_puzzle.global_position) < 4.8:
		if river_shrine_solved:
			toast_label.text = "O Astrolábio da Corrente Prateada já foi restaurado."
		else:
			var ring_index := _river_puzzle_current_ring()
			river_puzzle_ring_steps[ring_index] = (river_puzzle_ring_steps[ring_index] + 1) % 4
			var ring_node := river_puzzle.get_node_or_null("PuzzleRing_%d" % ring_index)
			if ring_node:
				ring_node.rotation.z = float(river_puzzle_ring_steps[ring_index]) * PI * 0.5
			if river_puzzle_ring_steps[ring_index] == RIVER_PUZZLE_TARGETS[ring_index]:
				if ring_index < 2:
					toast_label.text = "Anel %d alinhado! O próximo mecanismo despertou." % (ring_index + 1)
				else:
					river_shrine_solved = true
					river_puzzle.set_meta("solved", true)
					var lever := river_puzzle.get_node_or_null("PuzzleLever")
					var drawer := river_puzzle.get_node_or_null("PuzzleOfferingDrawer/DrawerLid")
					var reward_crystal := river_puzzle.get_node_or_null("PuzzleRewardCrystal")
					if lever: lever.rotation.z = -0.85
					if drawer: drawer.rotation.x = -1.1
					if reward_crystal: reward_crystal.visible = true
					_grant_xp(60)
					dark_essence += 3
					shards += 2
					toast_label.text = "ASTROLÁBIO RESTAURADO! +60 XP • 3 Essências • 2 Fragmentos Rubros"
					_update_inventory()
			else:
				toast_label.text = "O anel girou. Continue alinhando a marca luminosa."
			_save_game()
		return
	if quest_stage == 5:
		for i in range(3):
			var totem := get_node_or_null("SwampTotem_%d" % i)
			if totem and player.global_position.distance_to(totem.global_position) < 3.5:
				if not totem.get_meta("used", false):
					totem.set_meta("used", true)
					swamp_totem_ids.append(i)
					swamp_totems = swamp_totem_ids.size()
					var rune := totem.get_node_or_null("TotemRune")
					if rune: rune.material_override = _painter_mat(Color("91b69a"), 8.0, 0.12)
					toast_label.text = "Totem purificado (%d/3)" % swamp_totems
					objective_label.text = "Objetivo: purifique os 3 totens do Pântano dos Ratos (%d/3)" % swamp_totems
					if swamp_totems >= 3:
						quest_stage = 6
						quest_text = "A Bruxa do Pântano despertou"
						objective_label.text = "Objetivo: derrote a Bruxa do Pântano no altar ao norte"
						toast_label.text = "Os três selos se romperam. A Bruxa despertou no altar!"
					_update_quest()
					_save_game()
				else:
					toast_label.text = "Este totem já foi purificado."
				return
	var shrine := get_node_or_null("OldShrine")
	if shrine and player.global_position.distance_to(shrine.global_position) < 3.8:
		if not shrine.get_meta("used", false):
			shrine.set_meta("used", true)
			checkpoint_position = shrine.global_position + Vector3(0, 0, 4)
			shards += 1
			_grant_xp(25)
			toast_label.text = "Santuário ativado: novo ponto de retorno! +25 XP • Fragmento Rubro +1"
			_update_inventory()
			_save_game()
		else:
			toast_label.text = "O santuário está em silêncio."
		return
	var river_npc := get_node_or_null("Guardião do Rio")
	if river_npc and player.global_position.distance_to(river_npc.global_position) < 4.5:
		if quest_stage == 9:
			quest_stage = 10
			river_knights_defeated = 0
			quest_text = "Cavaleiros Afogados (0/3)"
			objective_label.text = "Objetivo: derrote 3 Cavaleiros Afogados (%d/3)" % river_knights_defeated
			toast_label.text = "Guardião: os cavaleiros presos sob a água protegem a passagem. Liberte o rio!"
			_save_game()
		elif quest_stage == 11:
			quest_stage = 12
			_activate_river_boss()
			quest_text = "O Leviatã do Lodo despertou"
			objective_label.text = "Objetivo: derrote o Leviatã do Lodo no coração do rio"
			toast_label.text = "Guardião: a correnteza escondia uma criatura antiga. Ela despertou!"
			_save_game()
		elif quest_stage == 13:
			quest_stage = 14
			quest_text = "O Rio Prateado foi libertado"
			_grant_xp(180)
			shards += 6
			potions += 2
			dark_essence += 4
			objective_label.text = "CAPÍTULO II CONCLUÍDO — O rio voltou a cantar"
			toast_label.text = "O rio está livre! +180 XP • 6 Fragmentos Rubros • 2 Poções"
			_update_inventory()
			_save_game()
		else:
			toast_label.text = "Guardião: escute a água. O Silêncio Cinzento ainda está se espalhando."
		_update_quest()
		return
	var npc := get_node_or_null("Mestre Azulan")
	if npc and player.global_position.distance_to(npc.global_position) < 4.5:
		if quest_stage == 0:
			quest_stage = 1
			quest_text = "Derrote os goblins corrompidos (0/3)"
			_save_game()
			objective_label.text = "Objetivo: derrote 3 goblins corrompidos"
			toast_label.text = "Azulan: O Coração Rubro foi roubado. A floresta está perdendo suas cores!"
		elif quest_stage == 1:
			toast_label.text = "Azulan: Afaste os goblins da trilha e volte quando terminar."
		elif quest_stage == 2:
			quest_stage = 3
			_grant_xp(40)
			quest_text = "Investigue a Cicatriz Rubra"
			objective_label.text = "Objetivo: derrote o Guardião do Silêncio ao norte"
			_save_game()
			_update_inventory()
			toast_label.text = "Azulan: A corrupção tem um coração. Vá até a cicatriz ao norte e destrua seu guardião!"
		elif quest_stage == 4:
			quest_stage = 5
			quest_text = "Os selos do Pântano"
			objective_label.text = "Objetivo: purifique os 3 totens do Pântano dos Ratos"
			_save_game()
			toast_label.text = "Azulan: Siga ao norte. Purifique os três totens antes que a Bruxa desperte!"
		elif quest_stage == 7:
			quest_stage = 8
			quest_text = "O primeiro fragmento do Coração Rubro"
			_grant_xp(150)
			shards += 5
			potions += 2
			objective_label.text = "CAPÍTULO I CONCLUÍDO — fale com Azulan para seguir ao Rio Prateado"
			toast_label.text = "Azulan: A Bruxa caiu. A trilha do Coração Rubro segue pelo Rio Prateado. +150 XP, 5 fragmentos e 2 poções."
			_update_inventory()
			_save_game()
		elif quest_stage == 8:
			quest_stage = 9
			_reveal_river_wraiths()
			quest_text = "Encontre o Guardião do Rio Prateado"
			_grant_xp(30)
			objective_label.text = "Objetivo: encontre o Guardião do Rio Prateado a leste"
			toast_label.text = "Azulan: atravesse a trilha de pedra para leste. O Guardião conhece a passagem submersa."
			_update_inventory()
			_save_game()
		else:
			toast_label.text = "Azulan: Breu percebe coisas que os olhos não veem. Confie nele."
		_update_quest()

func _reveal_river_wraiths() -> void:
	for enemy in enemies:
		if is_instance_valid(enemy) and int(enemy.get("enemy_kind")) == 7:
			enemy.visible = true
			enemy.set_physics_process(true)

func _upgrade_weapon() -> void:
	var npc := get_node_or_null("Mestre Azulan")
	if not is_instance_valid(player) or not npc or player.global_position.distance_to(npc.global_position) > 5.0:
		toast_label.text = "A forja de Azulan só funciona perto do mestre."
		return
	if weapon_level >= WEAPON_UPGRADE_COSTS.size():
		toast_label.text = "A espada já alcançou seu poder máximo."
		return
	var cost: int = WEAPON_UPGRADE_COSTS[weapon_level]
	if shards < cost:
		toast_label.text = "Faltam %d Fragmentos Rubros para melhorar a espada." % (cost - shards)
		return
	shards -= cost
	weapon_level += 1
	_refresh_player_stats(false)
	toast_label.text = "ESPADA APRIMORADA • Nível %d • Dano %d" % [weapon_level, player.attack_damage]
	_update_inventory()
	_save_game()

func enemy_defeated(kind: int = 0) -> void:
	if quest_stage == 12 and kind == 6:
		quest_stage = 13
		quest_text = "O Leviatã caiu — volte ao Guardião do Rio"
		_grant_xp(160)
		shards += 5
		dark_essence += 5
		potions += 2
		objective_label.text = "Objetivo: retorne ao Guardião do Rio"
		toast_label.text = "LEVIATÃ DERROTADO • +160 XP • 5 Fragmentos Rubros"
		_update_inventory()
		_update_quest()
		_save_game()
		return
	if kind == 6:
		return
	if quest_stage == 10 and kind == 5:
		river_knights_defeated += 1
		_grant_xp(22)
		shards += 1
		quest_text = "Cavaleiros Afogados (%d/3)" % mini(river_knights_defeated, 3)
		if river_knights_defeated >= 3:
			quest_stage = 11
			quest_text = "Retorne ao Guardião do Rio"
			objective_label.text = "Objetivo: retorne ao Guardião do Rio"
			toast_label.text = "Os três cavaleiros foram libertados. O caminho está aberto!"
		else:
			objective_label.text = "Objetivo: derrote 3 Cavaleiros Afogados (%d/3)" % river_knights_defeated
			toast_label.text = "Cavaleiro Afogado derrotado (%d/3) • +22 XP" % river_knights_defeated
		_update_inventory()
		_update_quest()
		_save_game()
		return
	if kind == 5:
		return
	if kind == 7:
		_grant_xp(18)
		dark_essence += 1
		toast_label.text = "ESPECTRO AFOGADO DERROTADO • +18 XP • Essência Sombria +1"
		_update_inventory()
		_save_game()
		return
	if kind == 8:
		_grant_xp(22)
		dark_essence += 1
		shards += 1
		toast_label.text = "CARANGUEJO DE PRATA DERROTADO • +22 XP • Fragmento Rubro +1"
		_update_inventory()
		_save_game()
		return
	if kind == 9:
		_grant_xp(35)
		dark_essence += 2
		swamp_herbs += 1
		if randf() < 0.35: shards += 1
		toast_label.text = "VIGIA DAS RAÍZES DERROTADO • +35 XP • 2 Essências Sombrias"
		_update_inventory()
		_save_game()
		return
	if kind == 10:
		_grant_xp(25)
		shards += 1
		dark_essence += 1
		toast_label.text = "CORVO GLACIAL DERROTADO • +25 XP • Fragmento Rubro +1"
		_update_inventory()
		_save_game()
		return
	# Every enemy grants basic rewards, but the first contract specifically
	# requires three corrupted goblins (kind 0), not any enemy archetype.
	if kind == 4:
		if quest_stage == 6:
			quest_stage = 7
			swamp_boss_defeated = true
			quest_text = "A Bruxa foi derrotada — volte a Azulan"
			_grant_xp(130)
			shards += 4
			potions += 1
			dark_essence += 3
			swamp_herbs += 2
			objective_label.text = "Objetivo: volte ao Mestre Azulan"
			toast_label.text = "BRUXA DERROTADA • +130 XP • 4 Fragmentos Rubros"
			_update_inventory()
			_update_quest()
			_save_game()
		return
	if kind == 3:
		if quest_stage == 3:
			quest_stage = 4
			quest_text = "A Cicatriz Rubra foi silenciada"
			objective_label.text = "Objetivo: volte ao Mestre Azulan"
			_grant_xp(100)
			shards += 3
			dark_essence += 2
			toast_label.text = "GUARDIÃO DERROTADO • +100 XP • 3 Fragmentos Rubros"
			_update_inventory()
			_update_quest()
			_save_game()
		return
	_grant_xp(10)
	# Common enemies now have distinct material drops in addition to XP.
	if kind == 0:
		goblin_ears += 1
		if randf() < 0.20: potions += 1
	elif kind == 1:
		goblin_ears += 2
		if randf() < 0.30: shards += 1
	elif kind == 2:
		if randf() < 0.55: swamp_herbs += 1
	if randf() < 0.18: shards += 1
	if quest_stage == 1 and kind == 0:
		defeated_count += 1
	_update_inventory()
	_save_game()
	if toast_label:
		if kind == 0: toast_label.text = "Loot: +1 Orelha de Goblin"
		elif kind == 1: toast_label.text = "Loot: +2 Orelhas de Goblin"
		elif kind == 2: toast_label.text = "O inimigo deixou materiais para coletar."
	if quest_stage == 1 and kind == 0:
		quest_text = "Derrote os goblins corrompidos (%d/3)" % mini(defeated_count, 3)
		_save_game()
		_update_quest()
		if defeated_count >= 3:
			quest_stage = 2
			_grant_xp(40)
			quest_text = "Volte ao Mestre Azulan"
			_save_game()
			_update_inventory()
			objective_label.text = "Objetivo: retorne ao Mestre Azulan"
			toast_label.text = "Missão concluída! +40 XP  •  O caminho para o Pântano foi revelado."
			_update_quest()


func combat_combo_changed(step: int) -> void:
	if not is_instance_valid(combo_label): return
	if step <= 0:
		combo_label.text = "COMBO  •  pronto"
	else:
		combo_label.text = "COMBO %d/3  •  %s" % [step, ["Corte", "Corte duplo", "Golpe final"][step - 1]]

func player_parry_success() -> void:
	if is_instance_valid(toast_label):
		toast_label.text = "APARO PERFEITO! Contra-ataque • +22 de vigor"


func player_perfect_dodge() -> void:
	if is_instance_valid(toast_label):
		toast_label.text = "ESQUIVA PERFEITA! +10 FÔLEGO"

func shadow_pulse_used(cooldown: float) -> void:
	if is_instance_valid(shadow_skill_label):
		shadow_skill_label.text = "BREU  •  Pulso Sombrio: recarregando"
	if is_instance_valid(toast_label):
		toast_label.text = "BREU LIBEROU O PULSO SOMBRIO! Dano em área aplicado."

func _activate_river_boss() -> void:
	var river_boss := get_node_or_null("Leviata_do_Lodo")
	if river_boss:
		river_boss.visible = true
		river_boss.set_physics_process(true)
		river_boss.set("hp", river_boss_hp)
		river_boss.call("sync_boss_phase")
	if boss_hud_panel:
		boss_hud_panel.visible = true
	if boss_health_bar:
		boss_health_bar.value = river_boss_hp

func river_boss_phase_changed() -> void:
	if is_instance_valid(toast_label):
		toast_label.text = "O LEVIATÃ ENTROU EM FÚRIA! Cuidado com os golpes ampliados."
	if is_instance_valid(boss_health_label):
		boss_health_label.text = "LEVIATÃ DO LODO  •  FÚRIA"

func boss_health_changed(current: int, maximum: int) -> void:
	river_boss_hp = clampi(current, 0, maximum)
	if boss_health_bar:
		boss_health_bar.max_value = maximum
		boss_health_bar.value = current
	if boss_health_label:
		boss_health_label.text = ("LEVIATÃ DO LODO  •  FÚRIA  •  %d/%d" % [current, maximum]) if river_boss_hp <= 340 else ("LEVIATÃ DO LODO  •  %d/%d" % [current, maximum])
	# Evita gravar o arquivo de save em todo golpe: registra cada faixa de 10% e a derrota.
	var health_band := floori(float(river_boss_hp) / maxf(1.0, float(maximum)) * 10.0)
	if health_band != river_boss_saved_band or river_boss_hp <= 0:
		river_boss_saved_band = health_band
		_save_game()

func player_health_changed(current: int, maximum: int) -> void:
	if health_bar:
		health_bar.max_value = maximum
		health_bar.value = current
	if health_label: health_label.text = "TOBI  •  VIDA"
	if health_value_label: health_value_label.text = "%d / %d" % [current, maximum]

func player_defeated() -> void:
	toast_label.text = "Tobi caiu! Retornando ao acampamento..."
	await get_tree().create_timer(1.2).timeout
	if is_instance_valid(player):
		player.global_position = checkpoint_position
		player.velocity = Vector3.ZERO
		player.hp = player.max_hp
		player.invulnerable = 1.5
		player_health_changed(player.hp, player.max_hp)
		toast_label.text = "Breu protegeu Tobi. Continue a missão!"

func _update_quest() -> void:
	if quest_label: quest_label.text = "MISSÃO: " + quest_text


func _update_inventory() -> void:
	var level := _get_player_level()
	var xp_needed := _xp_needed_for_next_level()
	var current_level_xp := xp - ((level - 1) * 100)
	if xp_label:
		xp_label.text = "NÍVEL %d  •  EXP %d/%d" % [level, current_level_xp, xp_needed - ((level - 1) * 100)]
	if xp_bar:
		xp_bar.max_value = xp_needed - ((level - 1) * 100)
		xp_bar.value = current_level_xp
	if inventory_label:
		inventory_label.text = "POÇÕES %d  •  FRAGMENTOS %d  •  ESPADA +%d" % [potions, shards, weapon_level]
	if inventory_details:
		inventory_details.text = "CONSUMÍVEIS\nPoções de vida: %d\n\nMATERIAIS\nFragmentos Rubros: %d\nOrelhas de Goblin: %d\nErvas do Pântano: %d\nEssência Sombria: %d\n\nEQUIPAMENTO\nEspada de Tobi: nível %d — dano %d\nVida máxima: %d\n\nNÍVEL %d  •  %d/%d XP" % [potions, shards, goblin_ears, swamp_herbs, dark_essence, weapon_level, 35 + weapon_level * 10 + (level - 1) * 3, 100 + (level - 1) * 12, level, current_level_xp, xp_needed - ((level - 1) * 100)]

func _use_potion() -> void:
	if not is_instance_valid(player) or potions <= 0:
		toast_label.text = "Sem poções disponíveis."
		return
	if player.hp >= player.max_hp:
		toast_label.text = "Sua vida já está cheia."
		return
	potions -= 1
	player.hp = mini(player.max_hp, player.hp + 45)
	player_health_changed(player.hp, player.max_hp)
	_update_inventory()
	_save_game()
	toast_label.text = "Poção usada: +45 de vida."

func _save_game() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("meta", "save_version", 16)
	cfg.set_value("progress", "quest_stage", quest_stage)
	cfg.set_value("progress", "quest_text", quest_text)
	cfg.set_value("progress", "defeated_count", defeated_count)
	cfg.set_value("progress", "xp", xp)
	cfg.set_value("progress", "shards", shards)
	cfg.set_value("progress", "potions", potions)
	cfg.set_value("progress", "weapon_level", weapon_level)
	cfg.set_value("inventory", "goblin_ears", goblin_ears)
	cfg.set_value("inventory", "swamp_herbs", swamp_herbs)
	cfg.set_value("inventory", "dark_essence", dark_essence)
	cfg.set_value("progress", "player_hp", player.hp if is_instance_valid(player) else 100)
	cfg.set_value("progress", "checkpoint_x", checkpoint_position.x)
	cfg.set_value("progress", "checkpoint_z", checkpoint_position.z)
	cfg.set_value("progress", "swamp_totems", swamp_totems)
	cfg.set_value("progress", "swamp_totem_ids", swamp_totem_ids)
	cfg.set_value("progress", "swamp_boss_defeated", swamp_boss_defeated)
	cfg.set_value("progress", "river_knights_defeated", river_knights_defeated)
	cfg.set_value("progress", "river_relic_ids", river_relic_ids)
	cfg.set_value("progress", "river_chest_ids", river_chest_ids)
	cfg.set_value("progress", "whisper_lantern_ids", whisper_lantern_ids)
	cfg.set_value("progress", "whisper_guardian_reward_claimed", whisper_guardian_reward_claimed)
	cfg.set_value("progress", "river_shrine_solved", river_shrine_solved)
	cfg.set_value("progress", "river_puzzle_ring_steps", river_puzzle_ring_steps)
	cfg.set_value("progress", "river_boss_hp", river_boss_hp)
	cfg.set_value("progress", "guild_relic_ids", guild_relic_ids)
	cfg.set_value("progress", "guild_contract_started", guild_contract_started)
	cfg.set_value("progress", "guild_contract_claimed", guild_contract_claimed)
	cfg.set_value("progress", "bell_tower_ring_count", bell_tower_ring_count)
	cfg.set_value("progress", "ancient_waystone_ids", ancient_waystone_ids)
	cfg.set_value("progress", "ashen_relic_ids", ashen_relic_ids)
	cfg.set_value("progress", "ashen_reward_claimed", ashen_reward_claimed)
	cfg.set_value("progress", "shrine_used", get_node_or_null("OldShrine").get_meta("used", false) if get_node_or_null("OldShrine") else false)
	# Grava em arquivo temporário e valida antes de substituir o progresso atual.
	var temp_path := save_path + ".tmp"
	var backup_path := save_path + ".bak"
	var temp_error := cfg.save(temp_path)
	if temp_error != OK:
		push_error("Falha ao gravar save temporário: %s" % error_string(temp_error))
		return
	var verification := ConfigFile.new()
	if verification.load(temp_path) != OK:
		push_error("Save temporário inválido; o progresso anterior foi preservado.")
		DirAccess.remove_absolute(ProjectSettings.globalize_path(temp_path))
		return
	var current_save := ConfigFile.new()
	if FileAccess.file_exists(save_path) and current_save.load(save_path) == OK:
		var backup_error := DirAccess.copy_absolute(ProjectSettings.globalize_path(save_path), ProjectSettings.globalize_path(backup_path))
		if backup_error != OK:
			push_warning("Não foi possível atualizar o backup do save: %s" % error_string(backup_error))
			DirAccess.remove_absolute(ProjectSettings.globalize_path(temp_path))
			return
	if FileAccess.file_exists(save_path):
		var remove_error := DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
		if remove_error != OK:
			push_error("Não foi possível substituir o save atual: %s" % error_string(remove_error))
			DirAccess.remove_absolute(ProjectSettings.globalize_path(temp_path))
			return
	var rename_error := DirAccess.rename_absolute(ProjectSettings.globalize_path(temp_path), ProjectSettings.globalize_path(save_path))
	if rename_error != OK:
		push_error("Falha ao finalizar save: %s" % error_string(rename_error))
		if not FileAccess.file_exists(save_path) and FileAccess.file_exists(backup_path):
			DirAccess.copy_absolute(ProjectSettings.globalize_path(backup_path), ProjectSettings.globalize_path(save_path))
		return
	if toast_label and toast_label.text.is_empty():
		toast_label.text = "Progresso salvo"
		save_toast_timer = 1.6

func _load_save() -> void:
	var cfg := ConfigFile.new()
	var load_error := cfg.load(save_path)
	if load_error != OK:
		var backup_path := save_path + ".bak"
		if not FileAccess.file_exists(backup_path):
			return
		var backup_cfg := ConfigFile.new()
		if backup_cfg.load(backup_path) != OK:
			push_warning("Save principal e backup estão inválidos; nenhum progresso foi sobrescrito.")
			return
		cfg = backup_cfg
		push_warning("Save principal inválido; progresso recuperado do backup.")
		DirAccess.copy_absolute(ProjectSettings.globalize_path(backup_path), ProjectSettings.globalize_path(save_path))
	var save_version := int(cfg.get_value("meta", "save_version", 1))
	# Version 1 saves remain compatible; unknown future versions are not loaded.
	if save_version > 16:
		return
	quest_stage = clampi(int(cfg.get_value("progress", "quest_stage", 0)), 0, 14)
	defeated_count = int(cfg.get_value("progress", "defeated_count", 0))
	xp = int(cfg.get_value("progress", "xp", 0))
	shards = int(cfg.get_value("progress", "shards", 0))
	potions = int(cfg.get_value("progress", "potions", 3))
	weapon_level = clampi(int(cfg.get_value("progress", "weapon_level", 0)), 0, 3)
	goblin_ears = maxi(0, int(cfg.get_value("inventory", "goblin_ears", 0)))
	swamp_herbs = maxi(0, int(cfg.get_value("inventory", "swamp_herbs", 0)))
	dark_essence = maxi(0, int(cfg.get_value("inventory", "dark_essence", 0)))
	quest_text = str(cfg.get_value("progress", "quest_text", "Fale com Mestre Azulan"))
	saved_shrine_used = bool(cfg.get_value("progress", "shrine_used", false))
	swamp_totems = clampi(int(cfg.get_value("progress", "swamp_totems", 0)), 0, 3)
	swamp_totem_ids.clear()
	var saved_totem_ids: Array = cfg.get_value("progress", "swamp_totem_ids", [])
	for saved_id in saved_totem_ids:
		var totem_id := int(saved_id)
		if totem_id >= 0 and totem_id < 3 and not swamp_totem_ids.has(totem_id):
			swamp_totem_ids.append(totem_id)
	# Migration for v3 saves, which stored only a count and not individual totem IDs.
	if swamp_totem_ids.is_empty() and swamp_totems > 0:
		for old_id in range(swamp_totems):
			swamp_totem_ids.append(old_id)
	swamp_totems = swamp_totem_ids.size()
	swamp_boss_defeated = bool(cfg.get_value("progress", "swamp_boss_defeated", false))
	river_knights_defeated = clampi(int(cfg.get_value("progress", "river_knights_defeated", 0)), 0, 3)
	river_relic_ids.clear()
	var saved_relic_ids: Array = cfg.get_value("progress", "river_relic_ids", [])
	for saved_relic_id in saved_relic_ids:
		var relic_id := int(saved_relic_id)
		if relic_id >= 0 and relic_id < 3 and not river_relic_ids.has(relic_id):
			river_relic_ids.append(relic_id)
	river_relic_ids.sort()
	river_chest_ids.clear()
	var saved_chest_ids: Array = cfg.get_value("progress", "river_chest_ids", [])
	for saved_chest_id in saved_chest_ids:
		var chest_id := int(saved_chest_id)
		if chest_id >= 0 and chest_id < 3 and not river_chest_ids.has(chest_id):
			river_chest_ids.append(chest_id)
	river_chest_ids.sort()
	whisper_lantern_ids.clear()
	var saved_lantern_ids: Array = cfg.get_value("progress", "whisper_lantern_ids", [])
	for saved_lantern_id in saved_lantern_ids:
		var lantern_id := int(saved_lantern_id)
		if lantern_id >= 0 and lantern_id < 3 and not whisper_lantern_ids.has(lantern_id):
			whisper_lantern_ids.append(lantern_id)
	whisper_lantern_ids.sort()
	whisper_guardian_reward_claimed = bool(cfg.get_value("progress", "whisper_guardian_reward_claimed", false))
	river_shrine_solved = bool(cfg.get_value("progress", "river_shrine_solved", false))
	river_puzzle_ring_steps = [0, 0, 0]
	var saved_ring_steps: Array = cfg.get_value("progress", "river_puzzle_ring_steps", [0, 0, 0])
	for ring_id in range(mini(3, saved_ring_steps.size())):
		river_puzzle_ring_steps[ring_id] = posmod(int(saved_ring_steps[ring_id]), 4)
	river_boss_hp = clampi(int(cfg.get_value("progress", "river_boss_hp", 680)), 0, 680)
	guild_relic_ids.clear()
	var saved_guild_relic_ids: Array = cfg.get_value("progress", "guild_relic_ids", [])
	for saved_guild_id in saved_guild_relic_ids:
		var guild_id := int(saved_guild_id)
		if guild_id >= 0 and guild_id < 3 and not guild_relic_ids.has(guild_id):
			guild_relic_ids.append(guild_id)
	guild_relic_ids.sort()
	guild_contract_started = bool(cfg.get_value("progress", "guild_contract_started", false))
	guild_contract_claimed = bool(cfg.get_value("progress", "guild_contract_claimed", false))
	bell_tower_ring_count = clampi(int(cfg.get_value("progress", "bell_tower_ring_count", 0)), 0, 3)
	ancient_waystone_ids.clear()
	var saved_waystone_ids: Array = cfg.get_value("progress", "ancient_waystone_ids", [])
	for saved_waystone_id in saved_waystone_ids:
		var waystone_id := int(saved_waystone_id)
		if waystone_id >= 0 and waystone_id < 3 and not ancient_waystone_ids.has(waystone_id):
			ancient_waystone_ids.append(waystone_id)
	ancient_waystone_ids.sort()
	ashen_relic_ids.clear()
	var saved_ashen_relic_ids: Array = cfg.get_value("progress", "ashen_relic_ids", [])
	for saved_ashen_id in saved_ashen_relic_ids:
		var ashen_id := int(saved_ashen_id)
		if ashen_id >= 0 and ashen_id < 3 and not ashen_relic_ids.has(ashen_id):
			ashen_relic_ids.append(ashen_id)
	ashen_relic_ids.sort()
	ashen_reward_claimed = bool(cfg.get_value("progress", "ashen_reward_claimed", false))
	saved_player_hp = int(cfg.get_value("progress", "player_hp", 100))
	var checkpoint_x := float(cfg.get_value("progress", "checkpoint_x", 0.0))
	var checkpoint_z := float(cfg.get_value("progress", "checkpoint_z", 15.0))
	# Migrate old saves that had activated the shrine before checkpoints existed.
	if saved_shrine_used and not cfg.has_section_key("progress", "checkpoint_x"):
		checkpoint_x = 15.0
		checkpoint_z = 29.0
	# Reject corrupted or out-of-world checkpoint coordinates before using them.
	if absf(checkpoint_x) <= 140.0 and absf(checkpoint_z) <= 140.0:
		checkpoint_position = Vector3(checkpoint_x, 0.0, checkpoint_z)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		_save_game()


func _build_wandering_lighthouse() -> void:
	# Novo ponto opcional no extremo sudoeste, construído com geometria leve.
	var root := Node3D.new()
	root.name = "FarolDosErrantes"
	root.position = Vector3(-245.0, 0.0, 220.0)
	add_child(root)
	var ground := _box(root, "WanderingLighthouseGround", Vector3(0.0, -0.08, 0.0), Vector3(66.0, 0.16, 56.0), Color("4b514c"))
	ground.material_override = _painter_mat(Color("4b514c"), 3.0, 0.16, 3, Color("313d39"))
	var access_road := _box(self, "WanderingLighthouseRoad", Vector3(-210.0, 0.025, 187.0), Vector3(7.0, 0.05, 94.0), Color("655744"))
	access_road.rotation.y = -0.72
	_box(root, "LighthouseFoundation", Vector3(0.0, 0.35, -3.0), Vector3(10.0, 0.7, 10.0), Color("5e625c"))
	_box(root, "LighthouseLowerShaft", Vector3(0.0, 4.0, -3.0), Vector3(6.2, 7.0, 6.2), Color("77786e"))
	_box(root, "LighthouseUpperShaft", Vector3(0.0, 9.2, -3.0), Vector3(4.7, 3.4, 4.7), Color("898779"))
	_box(root, "LighthouseLanternRoom", Vector3(0.0, 11.6, -3.0), Vector3(5.5, 1.3, 5.5), Color("39464a"))
	_box(root, "LighthouseRoof", Vector3(0.0, 12.45, -3.0), Vector3(6.5, 0.45, 6.5), Color("4a3f3c"))
	var beacon := _sphere(root, "WanderingBeacon", Vector3(0.0, 14.0, -3.0), 0.72, Color("e5bd78"), 1.1)
	beacon.material_override = _painter_mat(Color("e5bd78"), 8.0, 0.22)
	var beacon_light := OmniLight3D.new()
	beacon_light.name = "WanderingBeaconLight"
	beacon_light.position = Vector3(0.0, 14.0, -3.0)
	beacon_light.light_color = Color("e7c58b")
	beacon_light.light_energy = 1.15
	beacon_light.omni_range = 24.0
	root.add_child(beacon_light)
	for side in [-1.0, 1.0]:
		_box(root, "LanternArchPillar", Vector3(side * 8.0, 2.7, 15.0), Vector3(1.6, 5.4, 1.6), Color("696c64"))
	_box(root, "LanternArchLintel", Vector3(0.0, 5.5, 15.0), Vector3(18.0, 1.4, 1.8), Color("77776d"))
	var grave_positions := [
		Vector3(-22.0, 0.0, -16.0), Vector3(-14.0, 0.0, -22.0),
		Vector3(14.0, 0.0, -21.0), Vector3(23.0, 0.0, -12.0),
		Vector3(-24.0, 0.0, 8.0), Vector3(-15.0, 0.0, 21.0),
		Vector3(16.0, 0.0, 20.0), Vector3(25.0, 0.0, 7.0)
	]
	for i in range(grave_positions.size()):
		var marker := Node3D.new()
		marker.name = "WanderingGrave_%02d" % i
		marker.position = grave_positions[i]
		root.add_child(marker)
		_box(marker, "GraveStone", Vector3(0.0, 0.85, 0.0), Vector3(1.2, 1.7, 0.38), Color("77786f"))
		_box(marker, "GraveCap", Vector3(0.0, 1.72, 0.0), Vector3(1.45, 0.22, 0.48), Color("89897c"))
		if i % 2 == 0:
			_box(marker, "CarvedCross", Vector3(0.0, 1.05, 0.22), Vector3(0.16, 0.72, 0.08), Color("b6a98d"))
	for i in range(5):
		var lamp := Node3D.new()
		lamp.name = "WanderingPathLamp_%d" % i
		lamp.position = Vector3(-16.0 + float(i) * 8.0, 0.0, 11.0)
		root.add_child(lamp)
		_box(lamp, "LampPost", Vector3(0.0, 1.5, 0.0), Vector3(0.18, 3.0, 0.18), Color("493c32"))
		var flame := _sphere(lamp, "LampFlame", Vector3(0.0, 3.15, 0.0), 0.2, Color("e6b36e"), 0.4)
		flame.material_override = _painter_mat(Color("e6b36e"), 8.0, 0.12)
	for i in range(9):
		var angle := TAU * float(i) / 9.0
		var rock := _sphere(root, "WeatheredBoundaryRock", Vector3(cos(angle) * 29.0, 0.8, sin(angle) * 24.0), 1.0, Color("5d625d"), 1.8 + float(i % 3) * 0.35)
		rock.scale = Vector3(1.4, 0.8, 1.1)
	_add_region_title("FAROL DOS ERRANTES", root.position + Vector3(0.0, 17.0, 0.0), Color("e3c99b"))
