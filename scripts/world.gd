extends Node3D

const PLAYER_SCRIPT = preload("res://scripts/player.gd")
const ENEMY_SCRIPT = preload("res://scripts/enemy.gd")
const PAINTER_SHADER = preload("res://scripts/painter_material.gdshader")
const SURFACE_ALBEDO_ATLAS = preload("res://assets/textures/surface_albedo_atlas.png")
const SURFACE_ROUGHNESS_ATLAS = preload("res://assets/textures/surface_roughness_atlas.png")
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
const RIVER_PUZZLE_TARGETS := [1, 3, 2]

func _ready() -> void:
	_create_loading_screen()
	_set_loading_progress(4.0, "Acendendo as runas...")
	await get_tree().process_frame
	_load_save()
	_load_settings()
	river_boss_saved_band = floori(float(river_boss_hp) / 68.0)
	_set_loading_progress(10.0, "Moldando o mundo...")
	await get_tree().process_frame
	_build_environment()
	_build_landscape()
	_set_loading_progress(24.0, "Erguendo as terras esquecidas...")
	await get_tree().process_frame
	_build_open_world_expansion()
	_build_ruins_and_props()
	_build_region_landmarks()
	_set_loading_progress(40.0, "Despertando as regiões...")
	await get_tree().process_frame
	_build_swamp_region()
	_build_river_region()
	_build_whisper_grove()
	_build_outer_regions()
	_set_loading_progress(62.0, "Reacendendo as cidades...")
	await get_tree().process_frame
	_build_world_civilization()
	_build_npcs()
	_build_enemies()
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
	print("TOBI_BREU_BOOT_READY")


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
	frame.position = Vector2(-190.0, -205.0)
	frame.size = Vector2(380.0, 410.0)
	frame.add_theme_stylebox_override("panel", _hud_button_style(Color(0.025, 0.035, 0.035, 0.98), Color("9d7546"), 20))
	loading_root.add_child(frame)
	var stack := VBoxContainer.new()
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 12)
	frame.add_child(stack)
	var emblem := TextureRect.new()
	emblem.custom_minimum_size = Vector2(112.0, 112.0)
	emblem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	emblem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	emblem.texture = load("res://assets/icons/tobi_breu_icon.svg")
	stack.add_child(emblem)
	var heading := Label.new()
	heading.text = "TOBI  &  BREU"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 26)
	heading.add_theme_color_override("font_color", Color("e5c58c"))
	stack.add_child(heading)
	var subtitle := Label.new()
	subtitle.text = "Dark fantasy  •  uma jornada nas sombras"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 10)
	subtitle.add_theme_color_override("font_color", Color("a8a18e"))
	stack.add_child(subtitle)
	loading_progress = ProgressBar.new()
	loading_progress.custom_minimum_size = Vector2(290.0, 15.0)
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
	var footer := Label.new()
	footer.text = "Que a luz encontre o seu caminho"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 9)
	footer.add_theme_color_override("font_color", Color("777d75"))
	stack.add_child(footer)


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
	material.set_shader_parameter("bump_strength", bump_strength)
	return material


func _material_for_surface(surface_name: String, color: Color) -> ShaderMaterial:
	var key := surface_name.to_lower()
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
	world_environment = WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("17252c")
	sky_mat.sky_horizon_color = Color("b17b63")
	sky_mat.ground_bottom_color = Color("101b1b")
	sky_mat.ground_horizon_color = Color("54483d")
	sky.sky_material = sky_mat
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("84908a")
	e.ambient_light_energy = 0.62
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.fog_enabled = true
	e.fog_light_color = Color("89918a")
	e.fog_density = 0.012
	world_environment.environment = e
	add_child(world_environment)
	sun_light = DirectionalLight3D.new()
	sun_light.rotation_degrees = Vector3(-42, -28, 0)
	sun_light.light_color = Color("ffd0a1")
	sun_light.light_energy = 1.15
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
	# grass clumps as merged visual rhythm, not thousands of instances
	for i in range(36):
		var x := randf_range(-34, 34)
		var z := randf_range(-38, 38)
		if abs(x) < 6.0: continue
		var tuft := _sphere(self, "BrushGrass", Vector3(x, 0.18, z), randf_range(0.35, 0.8), Color("526b46"), 0.55)
		tuft.scale = Vector3(1.8, 0.55, 1.0)

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
	var tree := Node3D.new()
	tree.position = pos
	tree.scale = Vector3.ONE * scale_factor
	add_child(tree)
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.24
	trunk_mesh.bottom_radius = 0.48
	trunk_mesh.height = 4.2
	trunk_mesh.radial_segments = 7
	var trunk := MeshInstance3D.new()
	trunk.name = "PaintedBark"
	trunk.mesh = trunk_mesh
	trunk.position = Vector3(0, 2.1, 0)
	trunk.material_override = _painter_mat(Color("49372d"), 5.0, 0.12, 4, Color("30231e"))
	tree.add_child(trunk)
	for i in range(3):
		var crown := _sphere(tree, "PaintedCanopy", Vector3(randf_range(-0.8,0.8), 4.0 + i*0.9, randf_range(-0.6,0.6)), 2.5 - i*0.25, [Color("405d49"),Color("526e50"),Color("344b42")][i], 3.5)
		var canopy_color: Color = [Color("405d49"),Color("526e50"),Color("344b42")][i]
		crown.material_override = _painter_mat(canopy_color, 4.0, 0.13, 1, canopy_color.darkened(0.32))
		crown.scale = Vector3(1.2, 0.9, 1.0)

func _build_ruins_and_props() -> void:
	for p in [Vector3(-16,0,-12),Vector3(17,0,-19),Vector3(-22,0,22),Vector3(23,0,28),Vector3(-34,0,2),Vector3(34,0,-2),Vector3(10,0,40),Vector3(-12,0,-42)]:
		_build_tree(p, randf_range(0.8,1.35))
	# broken stone gate, readable landmark
	for x in [-5.5,5.5]:
		_box(self,"GatePillar",Vector3(x,2.6,-27),Vector3(2.2,5.2,2.0),Color("77746a"))
	_box(self,"GateLintel",Vector3(0,5.0,-27),Vector3(13,1.6,2.4),Color("817c70"))
	_box(self,"BrokenLintel",Vector3(2.8,6.1,-27),Vector3(4.2,0.7,2.1),Color("6c6b63")).rotation.z = 0.22
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
	hud.layer = 10
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
	panel_style.shadow_size = 10
	panel_style.shadow_offset = Vector2(0, 4)
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
	quest_panel.custom_minimum_size = Vector2(330, 112)
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
	status_panel.custom_minimum_size = Vector2(260, 78)
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
	health_bar.custom_minimum_size = Vector2(230, 16)
	health_bar.max_value = player.max_hp
	health_bar.value = player.hp
	health_bar.show_percentage = false
	health_bar.add_theme_stylebox_override("background", _hud_bar_style(Color("292d29")))
	health_bar.add_theme_stylebox_override("fill", _hud_bar_style(Color("a84d4b")))
	status_box.add_child(health_bar)
	stamina_bar = ProgressBar.new()
	stamina_bar.custom_minimum_size = Vector2(230, 9)
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
	progress_panel.custom_minimum_size = Vector2(260, 58)
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
	xp_bar.custom_minimum_size = Vector2(230, 10)
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
	combo_label.position = Vector2(18, 292)
	combo_label.text = "COMBO  •  pronto"
	combo_label.add_theme_font_size_override("font_size", 10)
	combo_label.add_theme_color_override("font_color", Color("d8b77c"))
	ui_root.add_child(combo_label)
	whisper_grove_label = Label.new()
	whisper_grove_label.position = Vector2(18, 310)
	whisper_grove_label.text = "BOSQUE DOS SUSSURROS  •  0/3"
	whisper_grove_label.add_theme_font_size_override("font_size", 10)
	whisper_grove_label.add_theme_color_override("font_color", Color("9acfc2"))
	whisper_grove_label.visible = false
	ui_root.add_child(whisper_grove_label)
	shadow_skill_label = Label.new()
	shadow_skill_label.position = Vector2(18, 328)
	shadow_skill_label.text = "BREU  •  Pulso Sombrio [K]"
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
	inventory_title.text = "BOLSA DO TOBI"
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

	# Mobile movement pad — same input actions, but with unified circular-feel styling.
	for data in [{"t":"▲","a":"move_forward","p":Vector2(0.12,0.77)},{"t":"▼","a":"move_back","p":Vector2(0.12,0.93)},{"t":"◀","a":"move_left","p":Vector2(0.055,0.85)},{"t":"▶","a":"move_right","p":Vector2(0.185,0.85)}]:
		var move_btn := Button.new()
		move_btn.text = data.t
		move_btn.anchor_left = data.p.x
		move_btn.anchor_right = data.p.x
		move_btn.anchor_top = data.p.y
		move_btn.anchor_bottom = data.p.y
		move_btn.position = Vector2(-27, -27)
		move_btn.size = Vector2(54, 54)
		move_btn.add_theme_font_size_override("font_size", 19)
		move_btn.add_theme_stylebox_override("normal", _hud_button_style(Color(0.035, 0.075, 0.067, 0.92), Color("6e9b89"), 27))
		move_btn.add_theme_stylebox_override("hover", _hud_button_style(Color(0.09, 0.15, 0.12, 0.98), Color("a0c4a9"), 27))
		move_btn.add_theme_stylebox_override("pressed", _hud_button_style(Color(0.18, 0.23, 0.15, 1.0), Color("d5bd7e"), 27))
		move_btn.modulate = Color(1, 1, 1, 0.96)
		move_btn.button_down.connect(Input.action_press.bind(data.a))
		move_btn.button_up.connect(Input.action_release.bind(data.a))
		ui_root.add_child(move_btn)

	# Combat and utility controls: compact labels, consistent size and clear hierarchy.
	for data in [{"t":"ATACAR","a":"attack","p":Vector2(0.83,0.82)},{"t":"PULAR","a":"jump","p":Vector2(0.91,0.68)},{"t":"INTERAGIR","a":"interact","p":Vector2(0.72,0.9)},{"t":"ESQUIVAR","a":"dodge","p":Vector2(0.84,0.94)},{"t":"POÇÃO","a":"potion","p":Vector2(0.94,0.84)},{"t":"FORJAR","a":"upgrade","p":Vector2(0.70,0.70)},{"t":"MOCHILA","a":"inventory","p":Vector2(0.70,0.61)},{"t":"BREU","a":"shadow","p":Vector2(0.93,0.72)}]:
		var action_btn := Button.new()
		action_btn.text = data.t
		action_btn.anchor_left = data.p.x
		action_btn.anchor_right = data.p.x
		action_btn.anchor_top = data.p.y
		action_btn.anchor_bottom = data.p.y
		action_btn.position = Vector2(-50, -28)
		action_btn.size = Vector2(100, 56)
		action_btn.add_theme_font_size_override("font_size", 11)
		var action_fill := Color(0.055, 0.071, 0.064, 0.97)
		var action_accent := Color("9a8058")
		if data.a == "attack":
			action_fill = Color(0.20, 0.075, 0.055, 0.98)
			action_accent = Color("d39b5e")
			action_btn.size = Vector2(112, 64)
			action_btn.position = Vector2(-56, -32)
			action_btn.add_theme_font_size_override("font_size", 12)
		elif data.a == "shadow":
			action_fill = Color(0.105, 0.065, 0.16, 0.98)
			action_accent = Color("a68bcf")
		elif data.a == "potion":
			action_fill = Color(0.035, 0.12, 0.095, 0.98)
			action_accent = Color("7fbaa0")
		elif data.a == "upgrade":
			action_fill = Color(0.15, 0.11, 0.045, 0.98)
			action_accent = Color("d0ad6e")
		action_btn.add_theme_stylebox_override("normal", _hud_button_style(action_fill, action_accent, 16))
		action_btn.add_theme_stylebox_override("hover", _hud_button_style(action_fill.lightened(0.16), action_accent.lightened(0.18), 16))
		action_btn.add_theme_stylebox_override("pressed", _hud_button_style(action_fill.lightened(0.28), Color("f0d49b"), 16))
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
	pause_btn.add_theme_stylebox_override("normal", _hud_button_style(Color(0.035, 0.045, 0.04, 0.96), Color("b18a52"), 16))
	pause_btn.add_theme_stylebox_override("hover", _hud_button_style(Color(0.13, 0.11, 0.075, 0.98), Color("dfbd7b"), 16))
	pause_btn.pressed.connect(_open_menu.bind("pause"))
	ui_root.add_child(pause_btn)

	_update_inventory()


func _build_menus() -> void:
	menu_layer = CanvasLayer.new()
	menu_layer.name = "GameMenus"
	menu_layer.layer = 30
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
	var panel_size := Vector2(minf(680.0, viewport_size.x * 0.92), minf(600.0, viewport_size.y * 0.90))
	menu_panel.position = -panel_size * 0.5
	menu_panel.size = panel_size
	menu_panel.custom_minimum_size = Vector2(0, 0)
	var menu_frame_style := _hud_button_style(Color("111916"), Color("a98752"), 18)
	menu_frame_style.set_border_width_all(2)
	menu_frame_style.shadow_color = Color(0.0, 0.0, 0.0, 0.82)
	menu_frame_style.shadow_size = 28
	menu_frame_style.shadow_offset = Vector2(0, 10)
	menu_frame_style.content_margin_left = 22.0
	menu_frame_style.content_margin_right = 22.0
	menu_frame_style.content_margin_top = 18.0
	menu_frame_style.content_margin_bottom = 18.0
	menu_panel.add_theme_stylebox_override("panel", menu_frame_style)
	menu_layer.add_child(menu_panel)
	var shell := VBoxContainer.new()
	shell.name = "MenuShell"
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
	close_btn.pressed.connect(_menu_back)
	top_rule.add_child(close_btn)
	var rule := ColorRect.new()
	rule.custom_minimum_size = Vector2(0, 2)
	rule.color = Color("806342")
	shell.add_child(rule)
	menu_body = VBoxContainer.new()
	menu_body.name = "MenuPageContent"
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
	get_tree().paused = true


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
	menu_body.add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	scroll.add_child(content)
	if page == "main":
		_menu_add_hero(content)
	if page in ["main", "hub", "character"]:
		_menu_add_stat_strip(content)
	match page:
		"main":
			title.text = "A lenda desperta"
			subtitle.text = "Explore um mundo esquecido. Proteja o vínculo entre Tobi e Breu."
			_menu_add_card(content, "JORNADA ATUAL", quest_text + "\n" + (objective_label.text if is_instance_valid(objective_label) else "Encontre Mestre Azulan"))
			_menu_add_button(content, "Jogar", _start_game, true)
			_menu_add_button(content, "CONFIGURAÇÕES", _show_menu_page.bind("settings"))
			_menu_add_button(content, "SALVAR PROGRESSO", _save_from_menu)
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
	button.custom_minimum_size = Vector2(0, 62 if primary else 56)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 14 if primary else 12)
	button.add_theme_color_override("font_color", Color("f0dfbf") if primary else Color("c5cfc2"))
	button.add_theme_color_override("font_hover_color", Color("fff0cf"))
	var fill := Color(0.13, 0.085, 0.045, 0.99) if primary else Color(0.055, 0.075, 0.067, 0.98)
	var edge := Color("d8b77c") if primary else Color("8c7956")
	var normal_style := _hud_button_style(fill, edge, 13)
	normal_style.shadow_color = Color(0.0, 0.0, 0.0, 0.52)
	normal_style.shadow_size = 7
	normal_style.shadow_offset = Vector2(0, 3)
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", _hud_button_style(fill.lightened(0.18), edge.lightened(0.2), 13))
	button.add_theme_stylebox_override("pressed", _hud_button_style(fill.lightened(0.3), Color("f0d49b"), 13))
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _menu_add_card(parent: Control, heading: String, body: String) -> void:
	var card := PanelContainer.new()
	var card_style := _hud_button_style(Color("1a241f"), Color("786443"), 12)
	card_style.set_border_width_all(1)
	card_style.shadow_color = Color(0.0, 0.0, 0.0, 0.38)
	card_style.shadow_size = 6
	card_style.shadow_offset = Vector2(0, 3)
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
	if game_started:
		_close_menu()
		return
	if is_instance_valid(menu_layer):
		menu_layer.visible = false
	_create_loading_screen()
	_set_loading_progress(28.0, "Abrindo os caminhos...")
	get_tree().paused = false
	await get_tree().process_frame
	var transition := loading_layer.create_tween()
	transition.tween_property(loading_progress, "value", 100.0, 0.72)
	_set_loading_progress(28.0, "As sombras se afastam...")
	await transition.finished
	_set_loading_progress(100.0, "Bem-vindo de volta, aventureiro.")
	await get_tree().create_timer(0.18, true).timeout
	game_started = true
	print("TOBI_BREU_GAME_STARTED")
	await _hide_loading_screen()
	get_tree().paused = false


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


func _hud_button_style(fill: Color, accent: Color, radius: int = 16) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = accent
	style.set_border_width_all(2)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.42)
	style.shadow_size = 5
	style.shadow_offset = Vector2(0, 2)
	style.set_corner_radius_all(radius)
	style.corner_detail = 6
	style.anti_aliasing = true
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
	cfg.set_value("meta", "save_version", 13)
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
	cfg.set_value("progress", "shrine_used", get_node_or_null("OldShrine").get_meta("used", false) if get_node_or_null("OldShrine") else false)
	cfg.save(save_path)
	if toast_label and toast_label.text.is_empty():
		toast_label.text = "Progresso salvo"
		save_toast_timer = 1.6

func _load_save() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(save_path) != OK: return
	var save_version := int(cfg.get_value("meta", "save_version", 1))
	# Version 1 saves remain compatible; unknown future versions are not loaded.
	if save_version > 13:
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
