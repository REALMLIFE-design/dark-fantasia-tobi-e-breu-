extends CharacterBody3D

const PLUGIN_ASSET_LOADER = preload("res://scripts/plugin_asset_loader.gd")
var hp := 70
var dead := false
var attack_timer := 0.0
var attack_windup_timer := 0.0
var attack_windup_duration := 0.52
var attack_telegraph: MeshInstance3D
var attack_telegraph_material: StandardMaterial3D
var attack_impact_flash := 0.0
var hit_flash := 0.0
var visual: Node3D
var target: Node3D
var patrol_origin := Vector3.ZERO
var phase := 0.0
var enemy_kind := 0
var move_speed := 2.25
var attack_damage := 9
var attack_range := 1.65
var hit_flash_materials: Array[StandardMaterial3D] = []
var hit_flash_base_colors: Array[Color] = []
var hit_recoil := 0.0
var attack_pose := 0.0
var death_time := 0.42
var base_visual_scale := Vector3.ONE
var idle_time := 0.0
var weapon_pivot_ref: Node3D
var boss_slam_active := false
var boss_attack_count := 0
var boss_slam_radius := 5.4
var boss_enraged := false
var boss_core_material: StandardMaterial3D
var crab_lunge_velocity := Vector3.ZERO
var crab_lunge_timer := 0.0
var crab_claws: Array[Node3D] = []
var ice_wings: Array[Node3D] = []

func _ready() -> void:
	add_to_group("enemies")
	patrol_origin = global_position
	phase = randf() * TAU
	if enemy_kind == 1:
		hp = 95
		move_speed = 1.65
		attack_damage = 14
	elif enemy_kind == 2:
		hp = 52
		move_speed = 3.0
		attack_damage = 7
	elif enemy_kind == 3:
		hp = 320
		move_speed = 1.55
		attack_damage = 18
		attack_range = 2.25
	elif enemy_kind == 4:
		hp = 440
		move_speed = 1.9
		attack_damage = 22
		attack_range = 2.4
	elif enemy_kind == 5:
		hp = 150
		move_speed = 1.85
		attack_damage = 16
		attack_range = 1.95
	elif enemy_kind == 6:
		hp = 680
		move_speed = 1.72
		attack_damage = 27
		attack_range = 2.85
	elif enemy_kind == 7:
		hp = 185
		move_speed = 2.15
		attack_damage = 13
		attack_range = 1.9
	elif enemy_kind == 8:
		hp = 145
		move_speed = 2.05
		attack_damage = 15
		attack_range = 2.0
	elif enemy_kind == 9:
		hp = 230
		move_speed = 2.3
		attack_damage = 18
		attack_range = 2.2
	elif enemy_kind == 10:
		hp = 125
		move_speed = 2.75
		attack_damage = 12
		attack_range = 1.75
	var capsule := CapsuleShape3D.new(); capsule.radius = 0.42; capsule.height = 1.5
	var col := CollisionShape3D.new(); col.shape = capsule; col.position.y = 0.75; add_child(col)
	visual = Node3D.new(); add_child(visual)
	_create_attack_telegraph()
	# Materiais cacheados depois da montagem visual completa.
	var body := CapsuleMesh.new(); body.radius = 0.36; body.height = 0.88
	var body_color := Color("68744b") if enemy_kind == 0 else (Color("6c5268") if enemy_kind == 1 else (Color("7e7047") if enemy_kind == 2 else (Color("542f3d") if enemy_kind == 3 else (Color("365c52") if enemy_kind == 4 else (Color("477b88") if enemy_kind == 5 else (Color("456a5f") if enemy_kind == 6 else (Color("536d82") if enemy_kind == 7 else Color("536f78"))))))))
	if enemy_kind == 9: body_color = Color("4b5d3c")
	elif enemy_kind == 10: body_color = Color("7c9da8")
	_add(body, Vector3(0, 0.78, 0), body_color)
	var chest := SphereMesh.new(); chest.radius = 0.39; chest.height = 0.52
	_add(chest, Vector3(0, 1.02, 0), body_color.lightened(0.12))
	if enemy_kind == 3: visual.scale = Vector3(1.8, 2.0, 1.8)
	elif enemy_kind == 4: visual.scale = Vector3(1.65, 1.8, 1.65)
	elif enemy_kind == 5: visual.scale = Vector3(1.22, 1.35, 1.22)
	elif enemy_kind == 6: visual.scale = Vector3(2.15, 2.0, 2.15)
	elif enemy_kind == 7: visual.scale = Vector3(1.18, 1.55, 1.18)
	elif enemy_kind == 8: visual.scale = Vector3(1.38, 0.92, 1.38)
	elif enemy_kind == 10: visual.scale = Vector3(1.12, 1.0, 1.12)
	base_visual_scale = visual.scale
	var head_pivot := Node3D.new(); head_pivot.name = "HeadPivot"; head_pivot.position = Vector3(0, 1.34, 0); visual.add_child(head_pivot)
	var head := SphereMesh.new(); head.radius = 0.29 if enemy_kind < 3 else 0.34; head.height = 0.58; head.radial_segments = 12
	_add_to(head_pivot, head, Vector3(0, 0.08, 0), Color("9caa70") if enemy_kind < 3 else Color("a6a18b"))
	var brow := BoxMesh.new(); brow.size = Vector3(0.38, 0.09, 0.08)
	_add_to(head_pivot, brow, Vector3(0, 0.14, 0.245), Color("302b29"))
	var hat: CylinderMesh = CylinderMesh.new(); hat.top_radius = 0.0; hat.bottom_radius = 0.42 if enemy_kind == 4 else 0.30; hat.height = 0.62
	_add_to(head_pivot, hat, Vector3(0, 0.42, -0.015), Color("493e34") if enemy_kind != 4 else Color("263f3b"))
	var left_arm := _make_enemy_limb("LeftArm", Vector3(-0.38, 1.12, 0), Vector3(0, -0.22, 0), Vector3(0.18, 0.52, 0.18), body_color.darkened(0.08))
	var right_arm := _make_enemy_limb("RightArm", Vector3(0.38, 1.12, 0), Vector3(0, -0.22, 0), Vector3(0.18, 0.52, 0.18), body_color.darkened(0.08))
	var weapon_pivot := Node3D.new(); weapon_pivot.name = "WeaponPivot"; weapon_pivot.position = Vector3(0, -0.40, 0); right_arm.add_child(weapon_pivot)
	weapon_pivot_ref = weapon_pivot
	var weapon := BoxMesh.new(); weapon.size = Vector3(0.13, 0.78, 0.13)
	_add_to(weapon_pivot, weapon, Vector3(0.02, -0.43, 0.04), Color("7e5b3c"))
	if enemy_kind == 10:
		# Corvo Glacial: silhueta aviária, asas articuladas e plumagem facetada.
		left_arm.visible = false
		right_arm.visible = false
		weapon_pivot.visible = false
		head_pivot.visible = false
		var bird_body := SphereMesh.new(); bird_body.radius = 0.43; bird_body.height = 0.78
		_add(bird_body, Vector3(0.0, 0.96, 0.04), Color("536d7c"))
		var bird_head := SphereMesh.new(); bird_head.radius = 0.27; bird_head.height = 0.48
		_add(bird_head, Vector3(0.0, 1.43, 0.27), Color("8baab5"))
		var beak := CylinderMesh.new(); beak.top_radius = 0.0; beak.bottom_radius = 0.12; beak.height = 0.34
		var beak_node := _add_to(visual, beak, Vector3(0.0, 1.38, 0.57), Color("c9a66c"))
		beak_node.rotation.x = PI * 0.5
		var eye_material := StandardMaterial3D.new()
		eye_material.albedo_color = Color("a9edff")
		eye_material.emission_enabled = true
		eye_material.emission = Color("66c9e8")
		eye_material.emission_energy_multiplier = 1.4
		for side in [-1.0, 1.0]:
			var eye_mesh := SphereMesh.new(); eye_mesh.radius = 0.055; eye_mesh.height = 0.11
			var eye_node := MeshInstance3D.new(); eye_node.mesh = eye_mesh
			eye_node.position = Vector3(side * 0.16, 1.47, 0.48)
			eye_node.material_override = eye_material
			visual.add_child(eye_node)
			var wing_pivot := Node3D.new()
			wing_pivot.name = "GlacialWing_%s" % ("L" if side < 0.0 else "R")
			wing_pivot.position = Vector3(side * 0.28, 1.16, -0.02)
			visual.add_child(wing_pivot)
			ice_wings.append(wing_pivot)
			var wing_mesh := BoxMesh.new(); wing_mesh.size = Vector3(0.82, 0.11, 0.34)
			var wing_node := _add_to(wing_pivot, wing_mesh, Vector3(side * 0.42, 0.0, 0.0), Color("91b6c3"))
			wing_node.rotation.z = side * -0.12
			for feather_index in range(3):
				var feather := BoxMesh.new(); feather.size = Vector3(0.34, 0.075, 0.13)
				var feather_node := _add_to(wing_pivot, feather, Vector3(side * (0.58 + float(feather_index) * 0.10), -0.015, -0.16 - float(feather_index) * 0.08), Color("c0dbe0"))
				feather_node.rotation.y = side * -0.12
		var tail_feather: CylinderMesh = CylinderMesh.new()
		tail_feather.top_radius = 0.0
		tail_feather.bottom_radius = 0.11
		tail_feather.height = 0.48
		tail_feather.radial_segments = 6
		var tail_node := _add_to(visual, tail_feather, Vector3(0.0, 0.78, -0.48), Color("a8c4cc"))
		tail_node.rotation.x = -PI * 0.5
		var talon := CylinderMesh.new(); talon.top_radius = 0.0; talon.bottom_radius = 0.075; talon.height = 0.32
		for side in [-1.0, 1.0]:
			var talon_node := _add_to(visual, talon, Vector3(side * 0.17, 0.56, 0.12), Color("7b6a58"))
			talon_node.rotation.x = PI
	# Distinct silhouettes for elite enemies and the swamp witch.
	if enemy_kind == 1 or enemy_kind == 3:
		for side in [-1.0, 1.0]:
			var shoulder := SphereMesh.new(); shoulder.radius = 0.22 if enemy_kind == 1 else 0.29
			_add_to(visual, shoulder, Vector3(side * 0.43, 1.18, 0.0), Color("59483c") if enemy_kind == 1 else Color("382d39"))
	if enemy_kind == 3 or enemy_kind == 4:
		for side in [-1.0, 1.0]:
			var horn: CylinderMesh = CylinderMesh.new(); horn.top_radius = 0.0; horn.bottom_radius = 0.13; horn.height = 0.48
			_add_to(head_pivot, horn, Vector3(side * 0.25, 0.30, -0.02), Color("3b3035") if enemy_kind == 3 else Color("263f3b"))
	if enemy_kind == 4:
		var crystal := SphereMesh.new(); crystal.radius = 0.12; crystal.height = 0.24
		var crystal_m := StandardMaterial3D.new(); crystal_m.albedo_color = Color("8ce4b2"); crystal_m.emission_enabled = true; crystal_m.emission = Color("3ba879"); crystal_m.emission_energy_multiplier = 1.8
		var crystal_i := MeshInstance3D.new(); crystal_i.mesh = crystal; crystal_i.position = Vector3(0.02, -0.12, 0.04); crystal_i.material_override = crystal_m; weapon_pivot.add_child(crystal_i)
	# Character-specific silhouette layers: ragged robes, belts, armor and claws.
	if enemy_kind == 4:
		var robe := CylinderMesh.new(); robe.top_radius = 0.30; robe.bottom_radius = 0.52; robe.height = 0.78; robe.radial_segments = 7
		_add(robe, Vector3(0, 0.48, 0), Color("293f39"))
		for shard_index in range(5):
			var shard: CylinderMesh = CylinderMesh.new(); shard.top_radius = 0.0; shard.bottom_radius = 0.10; shard.height = 0.42
			_add_to(visual, shard, Vector3(cos(float(shard_index) * TAU / 5.0) * 0.35, 0.20, sin(float(shard_index) * TAU / 5.0) * 0.35), Color("416b58"))
	elif enemy_kind == 3:
		var chest_plate := BoxMesh.new(); chest_plate.size = Vector3(0.58, 0.58, 0.16)
		_add(chest_plate, Vector3(0, 0.94, 0.25), Color("3a303a"))
		var crest := SphereMesh.new(); crest.radius = 0.13
		_add(crest, Vector3(0, 1.08, 0.35), Color("b45c55"))
	elif enemy_kind == 6:
		var shell := SphereMesh.new(); shell.radius = 0.52; shell.height = 0.72
		_add(shell, Vector3(0, 1.12, -0.10), Color("304b45"))
		for side in [-1.0, 1.0]:
			var tusk: CylinderMesh = CylinderMesh.new(); tusk.top_radius = 0.0; tusk.bottom_radius = 0.22; tusk.height = 0.82
			_add(tusk, Vector3(side * 0.43, 1.28, 0.30), Color("c2b58b"))
		var core := SphereMesh.new(); core.radius = 0.19; core.height = 0.36
		var core_material := StandardMaterial3D.new(); core_material.albedo_color = Color("9bc6a0"); core_material.emission_enabled = true; core_material.emission = Color("477b63"); core_material.emission_energy_multiplier = 1.7
		boss_core_material = core_material
		var core_instance := MeshInstance3D.new(); core_instance.mesh = core; core_instance.position = Vector3(0, 1.12, 0.38); core_instance.material_override = core_material; visual.add_child(core_instance)
	elif enemy_kind == 7:
		var shroud := CylinderMesh.new(); shroud.top_radius = 0.12; shroud.bottom_radius = 0.48; shroud.height = 1.22; shroud.radial_segments = 7
		var shroud_material := StandardMaterial3D.new(); shroud_material.albedo_color = Color("526d83", 0.72); shroud_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA; shroud_material.roughness = 1.0
		var shroud_instance := MeshInstance3D.new(); shroud_instance.mesh = shroud; shroud_instance.position = Vector3(0, 0.58, 0); shroud_instance.material_override = shroud_material; visual.add_child(shroud_instance)
		var wraith_core := SphereMesh.new(); wraith_core.radius = 0.16; wraith_core.height = 0.30
		var wraith_glow := StandardMaterial3D.new(); wraith_glow.albedo_color = Color("a9d9df"); wraith_glow.emission_enabled = true; wraith_glow.emission = Color("5da9c0"); wraith_glow.emission_energy_multiplier = 2.2
		var core_instance := MeshInstance3D.new(); core_instance.mesh = wraith_core; core_instance.position = Vector3(0, 1.02, 0.25); core_instance.material_override = wraith_glow; visual.add_child(core_instance)
		for side in [-1.0, 1.0]:
			var claw: CylinderMesh = CylinderMesh.new(); claw.top_radius = 0.0; claw.bottom_radius = 0.075; claw.height = 0.44
			_add_to(visual, claw, Vector3(side * 0.48, 0.48, 0.16), Color("9ab9c1"))
	elif enemy_kind == 8:
		# Caranguejo de Prata: low profile, broad mineral shell and two oversized claws.
		var shell := SphereMesh.new(); shell.radius = 0.68; shell.height = 0.52; shell.radial_segments = 16; shell.rings = 8
		var shell_instance := _add_to(visual, shell, Vector3(0.0, 0.78, -0.04), Color("536f78"))
		var shell_mat := StandardMaterial3D.new(); shell_mat.albedo_color = Color("536f78"); shell_mat.roughness = 0.82
		shell_mat.metallic = 0.16; shell_instance.material_override = shell_mat
		var belly := SphereMesh.new(); belly.radius = 0.43; belly.height = 0.28
		_add_to(visual, belly, Vector3(0.0, 0.48, 0.04), Color("344b52"))
		var core := SphereMesh.new(); core.radius = 0.14; core.height = 0.24
		var core_mat := StandardMaterial3D.new(); core_mat.albedo_color = Color("8bd8d0"); core_mat.emission_enabled = true
		core_mat.emission = Color("3b9994"); core_mat.emission_energy_multiplier = 1.35
		var core_i := MeshInstance3D.new(); core_i.mesh = core; core_i.position = Vector3(0.0, 0.83, 0.47); core_i.material_override = core_mat; visual.add_child(core_i)
		for side in [-1.0, 1.0]:
			var claw_base := SphereMesh.new(); claw_base.radius = 0.19; claw_base.height = 0.25
			_add_to(visual, claw_base, Vector3(side * 0.62, 0.58, 0.42), Color("607d82"))
			var claw_pivot := Node3D.new(); claw_pivot.position = Vector3(side * 0.72, 0.55, 0.68); visual.add_child(claw_pivot)
			var claw := BoxMesh.new(); claw.size = Vector3(0.24, 0.22, 0.46)
			_add_to(claw_pivot, claw, Vector3(0.0, 0.0, 0.04), Color("9baba0"))
			for pincer_side in [-1.0, 1.0]:
				var pincer: CylinderMesh = CylinderMesh.new(); pincer.top_radius = 0.0; pincer.bottom_radius = 0.09; pincer.height = 0.27
				var pincer_i := _add_to(claw_pivot, pincer, Vector3(pincer_side * 0.10, -0.07, 0.25), Color("c1b88f"))
				pincer_i.rotation.x = PI * 0.5
			crab_claws.append(claw_pivot)
			for pincer_side in [-1.0, 1.0]:
				var pincer: CylinderMesh = CylinderMesh.new(); pincer.top_radius = 0.0; pincer.bottom_radius = 0.09; pincer.height = 0.27
				var pincer_i := _add_to(visual, pincer, Vector3(side * 0.72 + pincer_side * 0.10, 0.48, 0.94), Color("c1b88f"))
				pincer_i.rotation.x = PI * 0.5
		var crab_legs: Array[Node3D] = []
		for side in [-1.0, 1.0]:
			for leg_index in range(3):
				var leg_pivot := Node3D.new(); leg_pivot.name = "CrabLeg_%s_%d" % ["L" if side < 0.0 else "R", leg_index]
				leg_pivot.position = Vector3(side * 0.42, 0.55, 0.20 - float(leg_index) * 0.28); visual.add_child(leg_pivot)
				var leg_mesh := CapsuleMesh.new(); leg_mesh.radius = 0.075; leg_mesh.height = 0.54
				var leg_i := _add_to(leg_pivot, leg_mesh, Vector3(side * 0.20, -0.04, 0.0), Color("455e65"))
				leg_i.rotation.z = side * -0.72
				var foot := SphereMesh.new(); foot.radius = 0.09; foot.height = 0.13
				_add_to(leg_pivot, foot, Vector3(side * 0.39, -0.12, 0.0), Color("9aaca6"))
				crab_legs.append(leg_pivot)
		visual.get_meta("left_arm_node", left_arm).visible = false
		visual.get_meta("right_arm_node", right_arm).visible = false
		head_pivot.visible = false
		visual.set_meta("crab_legs", crab_legs)
	elif enemy_kind == 5:
		var breastplate := BoxMesh.new(); breastplate.size = Vector3(0.66, 0.62, 0.18)
		_add(breastplate, Vector3(0, 0.98, 0.25), Color("344e57"))
		var shield := BoxMesh.new(); shield.size = Vector3(0.52, 0.72, 0.12)
		_add_to(left_arm, shield, Vector3(-0.08, -0.12, 0.20), Color("78949a"))
		var crest := SphereMesh.new(); crest.radius = 0.16
		_add(crest, Vector3(0, 1.08, 0.36), Color("b6d9ce"))
	else:
		for side in [-1.0, 1.0]:
			var wrist := SphereMesh.new(); wrist.radius = 0.13; wrist.height = 0.16
			_add_to(left_arm if side < 0.0 else right_arm, wrist, Vector3(0, -0.42, 0.02), Color("8c7959"))
	if enemy_kind == 9:
		# Armadura de casca, espinhos de raiz e núcleo verde: silhueta exclusiva do Vigia.
		var bark_plate := SphereMesh.new(); bark_plate.radius = 0.48; bark_plate.height = 0.72
		_add(bark_plate, Vector3(0.0, 1.16, -0.12), Color("344638"))
		var chest_core := SphereMesh.new(); chest_core.radius = 0.19; chest_core.height = 0.32
		var core_material := StandardMaterial3D.new()
		core_material.albedo_color = Color("a6d77b")
		core_material.emission_enabled = true
		core_material.emission = Color("5c9d49")
		core_material.emission_energy_multiplier = 1.35
		var core_instance := MeshInstance3D.new()
		core_instance.mesh = chest_core
		core_instance.position = Vector3(0.0, 1.12, 0.39)
		core_instance.material_override = core_material
		visual.add_child(core_instance)
		for side in [-1.0, 1.0]:
			var shoulder_spine := CylinderMesh.new()
			shoulder_spine.top_radius = 0.0
			shoulder_spine.bottom_radius = 0.19
			shoulder_spine.height = 0.82
			var spine := _add_to(visual, shoulder_spine, Vector3(side * 0.52, 1.45, -0.12), Color("78875a"))
			spine.rotation.z = side * -0.62
			var brow_thorn := CylinderMesh.new()
			brow_thorn.top_radius = 0.0
			brow_thorn.bottom_radius = 0.10
			brow_thorn.height = 0.48
			var thorn := _add_to(head_pivot, brow_thorn, Vector3(side * 0.25, 0.34, 0.0), Color("a18a58"))
			thorn.rotation.z = side * -0.52
			var eye := SphereMesh.new(); eye.radius = 0.065; eye.height = 0.13
			var eye_node := _add_to(head_pivot, eye, Vector3(side * 0.15, 0.08, 0.285), Color("b5e98a"))
			eye_node.material_override = core_material
		for spine_index in range(5):
			var back_spine := CylinderMesh.new()
			back_spine.top_radius = 0.0
			back_spine.bottom_radius = 0.105
			back_spine.height = 0.55
			var back_node := _add_to(visual, back_spine, Vector3(-0.32 + float(spine_index) * 0.16, 1.55, -0.38), Color("65764e"))
			back_node.rotation.x = -0.42
	var left_leg := _make_enemy_limb("LeftLeg", Vector3(-0.18, 0.58, 0), Vector3(0, -0.22, 0), Vector3(0.21, 0.50, 0.21), body_color.darkened(0.18))
	var right_leg := _make_enemy_limb("RightLeg", Vector3(0.18, 0.58, 0), Vector3(0, -0.22, 0), Vector3(0.21, 0.50, 0.21), body_color.darkened(0.18))
	if enemy_kind == 8 or enemy_kind == 10:
		left_leg.visible = false
		right_leg.visible = false
	if enemy_kind < 3:
		for leg_node in [left_leg, right_leg]:
			var boot := BoxMesh.new(); boot.size = Vector3(0.25, 0.16, 0.34)
			_add_to(leg_node, boot, Vector3(0, -0.43, 0.07), Color("40342d"))
	visual.set_meta("left_arm", left_arm); visual.set_meta("right_arm", right_arm)
	visual.set_meta("left_arm_node", left_arm); visual.set_meta("right_arm_node", right_arm)
	visual.set_meta("left_leg", left_leg); visual.set_meta("right_leg", right_leg)
	visual.set_meta("left_leg_node", left_leg); visual.set_meta("right_leg_node", right_leg)
	visual.set_meta("head", head_pivot)
	var label := Label3D.new()
	if enemy_kind == 6: label.text = "LEVIATÃ DO LODO"
	elif enemy_kind == 3: label.text = "GUARDIÃO DO SILÊNCIO"
	elif enemy_kind == 4: label.text = "BRUXA DO PÂNTANO"
	elif enemy_kind == 5: label.text = "CAVALEIRO AFOGADO"
	elif enemy_kind == 7: label.text = "ESPECTRO AFOGADO"
	elif enemy_kind == 8: label.text = "CARANGUEJO DE PRATA"
	elif enemy_kind == 9: label.text = "VIGIA DAS RAÍZES"
	elif enemy_kind == 10: label.text = "CORVO GLACIAL"
	elif enemy_kind == 1: label.text = "GOBLIN BRUTO"
	elif enemy_kind == 2: label.text = "GOBLIN BATEDOR"
	else: label.text = "GOBLIN CORROMPIDO"
	label.position.y = 2.35
	label.font_size = 24
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	visual.add_child(label)
	_try_attach_imported_enemy_model()
	_cache_hit_flash_materials(visual)
	target = get_tree().get_first_node_in_group("player")


func _try_attach_imported_enemy_model() -> void:
	# GLBs externos substituem a aparência procedural somente quando o binário existe.
	# Sem o arquivo, o modelo procedural original permanece visível como fallback.
	var asset_key := ""
	var imported_scale := Vector3.ONE
	match enemy_kind:
		7:
			asset_key = "thrixel_drowned_wraith"
		8:
			asset_key = "thrixel_river_crab"
			imported_scale = Vector3.ONE * 0.85
		9:
			asset_key = "thrixel_stag_guardian"
		_:
			return
	var packed_scene := PLUGIN_ASSET_LOADER.load_optional_scene(asset_key)
	if packed_scene == null:
		return
	var imported_model := packed_scene.instantiate() as Node3D
	if imported_model == null:
		push_warning("O modelo 3D do inimigo não tem raiz Node3D: " + asset_key)
		return
	imported_model.name = "ImportedEnemyModel_" + asset_key
	imported_model.position = Vector3.ZERO
	imported_model.scale = imported_scale
	for child in visual.get_children():
		_set_enemy_fallback_meshes_visible(child, false)
	visual.add_child(imported_model)
	visual.set_meta("imported_enemy_model", imported_model)
	visual.set_meta("imported_enemy_asset_key", asset_key)
	_cache_hit_flash_materials(imported_model)


func _set_enemy_fallback_meshes_visible(node: Node, should_be_visible: bool) -> void:
	if node is MeshInstance3D:
		(node as MeshInstance3D).visible = should_be_visible
	for child in node.get_children():
		_set_enemy_fallback_meshes_visible(child, should_be_visible)

func sync_boss_phase() -> void:
	if enemy_kind == 6 and hp <= 340:
		_enter_boss_enrage(false)

func _enter_boss_enrage(notify_world: bool = true) -> void:
	if boss_enraged:
		return
	boss_enraged = true
	move_speed = 2.35
	attack_damage = 31
	attack_range = 3.1
	boss_slam_radius = 6.0
	base_visual_scale *= 1.06
	if is_instance_valid(visual):
		visual.scale = base_visual_scale
	if is_instance_valid(boss_core_material):
		boss_core_material.albedo_color = Color("d85a4d")
		boss_core_material.emission = Color("b52c26")
		boss_core_material.emission_energy_multiplier = 2.8
	if is_instance_valid(attack_telegraph_material):
		attack_telegraph_material.albedo_color = Color(1.0, 0.24, 0.035, 0.9)
	if notify_world and get_parent().has_method("river_boss_phase_changed"):
		get_parent().river_boss_phase_changed()

func _add(mesh: Mesh, pos: Vector3, color: Color) -> void:
	var mi := MeshInstance3D.new(); mi.mesh = mesh; mi.position = pos
	var m := StandardMaterial3D.new(); m.albedo_color = color; m.roughness = 0.95; mi.material_override = m; visual.add_child(mi)

func _add_to(parent: Node3D, mesh: Mesh, pos: Vector3, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new(); mi.mesh = mesh; mi.position = pos
	var m := StandardMaterial3D.new(); m.albedo_color = color; m.roughness = 0.95; mi.material_override = m; parent.add_child(mi)
	return mi

func _make_enemy_limb(part_name: String, pivot_pos: Vector3, mesh_pos: Vector3, mesh_size: Vector3, color: Color) -> Node3D:
	var pivot := Node3D.new(); pivot.name = part_name; pivot.position = pivot_pos; visual.add_child(pivot)
	var limb := CapsuleMesh.new(); limb.radius = mesh_size.x * 0.5; limb.height = mesh_size.y
	_add_to(pivot, limb, mesh_pos, color)
	return pivot

func _create_attack_telegraph() -> void:
	var ring := TorusMesh.new()
	ring.inner_radius = 0.88
	ring.outer_radius = 1.0
	ring.rings = 8
	ring.ring_segments = 24
	attack_telegraph = MeshInstance3D.new()
	attack_telegraph.name = "AttackWarning"
	attack_telegraph.mesh = ring
	attack_telegraph.position = Vector3(0.0, 0.055, 0.0)
	attack_telegraph.scale = Vector3(attack_range, 1.0, attack_range)
	attack_telegraph.visible = false
	attack_telegraph_material = StandardMaterial3D.new()
	attack_telegraph_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	attack_telegraph_material.albedo_color = Color(1.0, 0.18, 0.12, 0.82)
	attack_telegraph_material.emission_enabled = true
	attack_telegraph_material.emission = Color(0.95, 0.08, 0.035)
	attack_telegraph_material.emission_energy_multiplier = 1.35
	attack_telegraph_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	attack_telegraph.material_override = attack_telegraph_material
	add_child(attack_telegraph)

func _attack_warning_color() -> Color:
	if enemy_kind == 6:
		return Color("ff4d32") if boss_enraged else Color("f08a43")
	if enemy_kind == 8:
		return Color("62d8c8")
	if enemy_kind == 9:
		return Color("a0cf70")
	if enemy_kind == 10:
		return Color("9deaff")
	if enemy_kind == 7:
		return Color("79c9f2")
	if enemy_kind == 5:
		return Color("e7c477")
	return Color("ef765f")

func _begin_attack() -> void:
	var enraged := enemy_kind == 6 and hp <= 340
	if enemy_kind == 6:
		boss_attack_count += 1
		boss_slam_active = boss_attack_count % 2 == 0
		boss_slam_radius = 6.0 if enraged else 5.4
	if enemy_kind == 6:
		if boss_slam_active:
			attack_windup_duration = 1.35 if enraged else 1.05
		else:
			attack_windup_duration = 0.82 if enraged else 1.05
	else:
		attack_windup_duration = 0.92 if enemy_kind == 8 else (0.62 if enemy_kind == 10 else (0.78 if enemy_kind >= 3 else (0.38 if enemy_kind == 2 else (0.68 if enemy_kind == 5 else 0.56))))
	attack_windup_timer = attack_windup_duration
	attack_pose = attack_windup_duration
	attack_telegraph.visible = true
	var warning_color := _attack_warning_color()
	attack_telegraph_material.albedo_color = Color(warning_color.r, warning_color.g, warning_color.b, 0.82)
	attack_telegraph_material.emission = warning_color
	var warning_radius := boss_slam_radius if boss_slam_active else (2.75 if enemy_kind == 8 else attack_range)
	attack_telegraph.scale = Vector3(warning_radius, 1.0, warning_radius)
	attack_timer = 1.25 if enemy_kind != 2 else 0.95
	if enemy_kind >= 3:
		attack_timer += 0.45
	if enemy_kind == 6:
		attack_timer += 0.7 if not enraged else 0.25

func _resolve_attack() -> void:
	attack_telegraph.visible = false
	attack_impact_flash = 0.12
	var slam_resolved := boss_slam_active
	boss_slam_active = false
	attack_telegraph.scale = Vector3(attack_range, 1.0, attack_range)
	if not is_instance_valid(target) or not target.has_method("take_damage"):
		return
	var flat := target.global_position - global_position
	flat.y = 0.0
	var reach := (boss_slam_radius + 0.35) if slam_resolved else (2.85 if enemy_kind == 8 else attack_range + (0.35 if enemy_kind >= 3 else 0.18))
	if enemy_kind == 8:
		# Investida curta: o caranguejo avança com as duas pinças e recua após o impacto.
		if flat.length() > 0.01:
			crab_lunge_velocity = flat.normalized() * 7.2
			crab_lunge_timer = 0.22
		if flat.length() <= reach:
			target.take_damage(attack_damage)
	else:
		if flat.length() <= reach:
			target.take_damage(attack_damage)
			if slam_resolved and target.has_method("apply_boss_slam_knockback"):
				var push_direction := flat.normalized() if flat.length() > 0.01 else Vector3.FORWARD
				target.apply_boss_slam_knockback(push_direction, 11.5 if boss_enraged else 9.0)

func _physics_process(delta: float) -> void:
	if dead:
		attack_telegraph.visible = false
		death_time -= delta
		visual.scale = visual.scale.lerp(Vector3.ZERO, delta * 7.0)
		visual.rotation.z = move_toward(visual.rotation.z, 1.15, delta * 3.5)
		position.y -= delta * 0.35
		if death_time <= 0.0: queue_free()
		return
	if enemy_kind == 3 and int(get_parent().get("quest_stage")) < 3: return
	if enemy_kind == 4 and int(get_parent().get("quest_stage")) < 6: return
	if enemy_kind == 5 and int(get_parent().get("quest_stage")) != 10: return
	if enemy_kind == 6 and int(get_parent().get("quest_stage")) != 12: return
	if enemy_kind == 7 and int(get_parent().get("quest_stage")) < 9: return
	if enemy_kind == 8 and int(get_parent().get("quest_stage")) < 9: return
	idle_time += delta
	attack_timer = maxf(0.0, attack_timer - delta)
	attack_pose = maxf(0.0, attack_pose - delta)
	hit_flash = maxf(0.0, hit_flash - delta)
	_update_hit_flash_materials()
	hit_recoil = maxf(0.0, hit_recoil - delta)
	attack_impact_flash = maxf(0.0, attack_impact_flash - delta)
	if not is_instance_valid(target): target = get_tree().get_first_node_in_group("player")
	var winding_up := attack_windup_timer > 0.0
	if winding_up:
		attack_windup_timer = maxf(0.0, attack_windup_timer - delta)
		attack_telegraph.visible = true
		var windup_progress := 1.0 - attack_windup_timer / maxf(attack_windup_duration, 0.01)
		var pulse := 0.88 + sin(idle_time * 18.0) * 0.08
		var warning_radius := boss_slam_radius if boss_slam_active else (2.75 if enemy_kind == 8 else attack_range)
		attack_telegraph.scale = Vector3(warning_radius, 1.0, warning_radius) * (pulse * (1.0 + windup_progress * 0.16))
		attack_telegraph_material.albedo_color.a = 0.42 + windup_progress * 0.48
		velocity.x = move_toward(velocity.x, 0.0, 16.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 16.0 * delta)
		if attack_windup_timer <= 0.0:
			_resolve_attack()
	elif is_instance_valid(target):
		var d := target.global_position - global_position
		d.y = 0.0
		if d.length() < 15.0 and d.length() > attack_range:
			velocity.x = move_toward(velocity.x, d.normalized().x * move_speed, 8.0 * delta)
			velocity.z = move_toward(velocity.z, d.normalized().z * move_speed, 8.0 * delta)
			look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z))
		elif d.length() <= attack_range:
			velocity.x = move_toward(velocity.x, 0.0, 12.0 * delta)
			velocity.z = move_toward(velocity.z, 0.0, 12.0 * delta)
			if attack_timer <= 0.0:
				_begin_attack()
		else:
			velocity.x = move_toward(velocity.x, 0.0, 8.0 * delta)
			velocity.z = move_toward(velocity.z, 0.0, 8.0 * delta)
	if crab_lunge_timer > 0.0:
		crab_lunge_timer = maxf(0.0, crab_lunge_timer - delta)
		velocity.x = crab_lunge_velocity.x
		velocity.z = crab_lunge_velocity.z
		crab_lunge_velocity = crab_lunge_velocity.lerp(Vector3.ZERO, delta * 8.0)
	else:
		crab_lunge_velocity = Vector3.ZERO
	if not is_on_floor(): velocity.y -= 18.0 * delta
	move_and_slide()
	var moving := Vector2(velocity.x, velocity.z).length() > 0.25 and not winding_up
	var gait := sin(idle_time * (9.0 if moving else 1.8) + phase) if moving else 0.0
	visual.position.y = (sin(idle_time * 2.4 + phase) * 0.13 if enemy_kind == 7 else (sin(idle_time * 3.1 + phase) * 0.16 if enemy_kind == 10 else absf(gait) * (0.055 if moving else 0.012) + sin(idle_time * 2.0 + phase) * 0.012))
	visual.rotation.z = lerpf(visual.rotation.z, -0.045 if moving else 0.0, delta * 5.0)
	var left_arm: Node3D = visual.get_meta("left_arm")
	var right_arm: Node3D = visual.get_meta("right_arm")
	var left_leg: Node3D = visual.get_meta("left_leg")
	var right_leg: Node3D = visual.get_meta("right_leg")
	var head_pivot: Node3D = visual.get_meta("head")
	if enemy_kind == 10:
		for wing_index in range(ice_wings.size()):
			var wing_side := -1.0 if wing_index == 0 else 1.0
			ice_wings[wing_index].rotation.z = wing_side * (0.08 + sin(idle_time * 8.5 + phase) * 0.34)
	if enemy_kind == 8:
		var crab_legs: Array = visual.get_meta("crab_legs", [])
		for i in range(crab_legs.size()):
			var leg: Node3D = crab_legs[i]
			leg.rotation.y = sin(idle_time * (8.0 if moving else 1.6) + phase + float(i) * 1.7) * (0.22 if moving else 0.045)
		var claw_swing := sin(idle_time * 2.8) * 0.06
		var attack_swing := 0.0 if attack_pose <= 0.0 else sin((1.0 - attack_pose / maxf(attack_windup_duration, 0.01)) * PI) * 0.72
		for i in range(crab_claws.size()):
			var claw_node := crab_claws[i]
			claw_node.rotation.x = claw_swing - attack_swing
			claw_node.rotation.y = (-1.0 if i == 0 else 1.0) * (0.08 + attack_swing * 0.32)
	left_leg.rotation.x = gait * 0.62
	right_leg.rotation.x = -gait * 0.62
	left_arm.rotation.x = -gait * 0.38
	right_arm.rotation.x = gait * 0.40
	head_pivot.rotation.x = sin(idle_time * 1.8 + phase) * 0.045
	head_pivot.rotation.y = sin(idle_time * 1.2 + phase) * 0.035
	if enemy_kind == 4:
		weapon_pivot_ref.rotation.z = sin(idle_time * 2.6) * 0.16
		weapon_pivot_ref.rotation.x = sin(idle_time * 1.9) * 0.12
	elif enemy_kind == 5:
		weapon_pivot_ref.rotation.x = sin(idle_time * 1.7) * 0.045
	if attack_pose > 0.0:
		var attack_weight := 1.0 - (attack_pose / maxf(attack_windup_duration, 0.01))
		right_arm.rotation.x = lerpf(-1.35, 0.22, attack_weight)
		right_arm.rotation.z = -0.24 - sin(attack_weight * PI) * 0.52
		left_arm.rotation.x = -0.30 + sin(attack_weight * PI) * 0.25
	if hit_recoil > 0.0:
		left_arm.rotation.x = 0.55
		right_arm.rotation.x = -0.55
		head_pivot.rotation.x = -0.18
	visual.scale = visual.scale.lerp(base_visual_scale * (Vector3(1.12, 0.88, 1.12) if hit_recoil > 0.0 else Vector3.ONE), minf(1.0, delta * 12.0))

func take_damage(amount: int) -> void:
	if dead: return
	if enemy_kind == 3 and int(get_parent().get("quest_stage")) < 3: return
	if enemy_kind == 4 and int(get_parent().get("quest_stage")) < 6: return
	if enemy_kind == 5 and int(get_parent().get("quest_stage")) != 10: return
	if enemy_kind == 6 and int(get_parent().get("quest_stage")) != 12: return
	if enemy_kind == 7 and int(get_parent().get("quest_stage")) < 9: return
	if enemy_kind == 8 and int(get_parent().get("quest_stage")) < 9: return
	hp -= amount
	_spawn_damage_number(amount)
	hit_flash = 0.14
	if enemy_kind == 6:
		if hp <= 340:
			_enter_boss_enrage()
		if get_parent().has_method("boss_health_changed"):
			get_parent().boss_health_changed(maxi(0, hp), 680)
	hit_recoil = 0.16
	visual.scale = Vector3(1.12,0.88,1.12)
	if hp <= 0:
		dead = true
		_spawn_death_burst()
		attack_pose = 0.0
		attack_windup_timer = 0.0
		attack_telegraph.visible = false
		var collision := get_node_or_null("CollisionShape3D")
		if collision: collision.set_deferred("disabled", true)
		var world := get_parent()
		if world.has_method("enemy_defeated"): world.enemy_defeated(enemy_kind)

func _cache_hit_flash_materials(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		var source_material := mesh_instance.material_override as StandardMaterial3D
		if source_material:
			var flash_material := source_material.duplicate() as StandardMaterial3D
			mesh_instance.material_override = flash_material
			hit_flash_materials.append(flash_material)
			hit_flash_base_colors.append(flash_material.albedo_color)
	for child in node.get_children():
		_cache_hit_flash_materials(child)

func _update_hit_flash_materials() -> void:
	var strength := clampf(hit_flash / 0.14, 0.0, 1.0)
	for i in range(hit_flash_materials.size()):
		var material := hit_flash_materials[i]
		if is_instance_valid(material):
			material.albedo_color = hit_flash_base_colors[i].lerp(Color.WHITE, strength * 0.88)

func _spawn_damage_number(amount: int) -> void:
	if not is_instance_valid(visual): return
	var number_label := Label3D.new()
	number_label.name = "DamageNumber"
	number_label.text = str(amount)
	number_label.font_size = 42 if enemy_kind >= 3 else 34
	number_label.outline_size = 8
	number_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	number_label.no_depth_test = true
	number_label.position = Vector3(randf_range(-0.22, 0.22), 1.75, 0.12)
	number_label.modulate = Color("ffb36b") if enemy_kind >= 3 else Color("fff0d0")
	visual.add_child(number_label)
	var rise_tween := create_tween().set_parallel(true)
	rise_tween.tween_property(number_label, "position:y", number_label.position.y + 0.72, 0.58).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	rise_tween.tween_property(number_label, "modulate:a", 0.0, 0.58).set_delay(0.12)
	rise_tween.tween_callback(number_label.queue_free).set_delay(0.72)

func _spawn_death_burst() -> void:
	if not is_instance_valid(get_parent()): return
	var burst := Node3D.new()
	get_parent().add_child(burst)
	burst.global_position = global_position
	var burst_color := Color("d7c7a0")
	if enemy_kind == 6: burst_color = Color("d85a4d")
	elif enemy_kind == 7: burst_color = Color("79c9f2")
	elif enemy_kind == 8: burst_color = Color("62d8c8")
	elif enemy_kind == 9: burst_color = Color("8dc86a")
	elif enemy_kind == 10: burst_color = Color("a9eaff")
	elif enemy_kind >= 3: burst_color = Color("e7c477")
	for shard_index in range(6):
		var shard := MeshInstance3D.new()
		var shard_mesh := BoxMesh.new()
		shard_mesh.size = Vector3(0.12, 0.18, 0.12)
		shard.mesh = shard_mesh
		var shard_material := StandardMaterial3D.new()
		shard_material.albedo_color = burst_color
		shard_material.emission_enabled = true
		shard_material.emission = burst_color
		shard_material.emission_energy_multiplier = 0.65
		shard.material_override = shard_material
		burst.add_child(shard)
		var angle := TAU * float(shard_index) / 6.0
		shard.position = Vector3(cos(angle) * 0.16, 0.48 + float(shard_index % 2) * 0.12, sin(angle) * 0.16)
		var destination := shard.position + Vector3(cos(angle) * 0.72, 0.42 + float(shard_index % 3) * 0.08, sin(angle) * 0.72)
		var tween := burst.create_tween()
		tween.tween_property(shard, "position", destination, 0.38).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(shard, "scale", Vector3.ZERO, 0.38)
		if shard_index == 5: tween.tween_callback(burst.queue_free)
