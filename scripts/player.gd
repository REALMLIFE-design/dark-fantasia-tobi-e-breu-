extends CharacterBody3D
var world: Node3D
var speed := 6.2
var jump_velocity := 7.0
var attack_cooldown := 0.0
var yaw := 0.0
var visual: Node3D
var camera_pivot: Node3D
var camera: Camera3D
var hp := 100
var max_hp := 100
var attack_damage := 35
var attack_flash := 0.0
var hit_targets: Array[Node] = []
var attack_visual: Node3D
var cat: Node3D
var anim_time := 0.0
var invulnerable := 0.0
var stamina := 100.0
var dodge_cooldown := 0.0
var dodge_time := 0.0
var dodge_direction := Vector3.ZERO
var camera_yaw_offset := 0.0
var camera_sensitivity := 0.006
var hit_reaction := 0.0
var damage_flash := 0.0
var perfect_dodge_flash := 0.0
var dodge_perfect_used := false
var damage_flash_materials: Array[StandardMaterial3D] = []
var damage_flash_base_colors: Array[Color] = []
var death_pose := false
var landing_time := 0.0
var combo_step := 0
var combo_timer := 0.0
var shadow_pulse_cooldown := 0.0
var pulse_ring: MeshInstance3D
var pulse_material: StandardMaterial3D
var pulse_visual_timer := 0.0

func _ready() -> void:
	add_to_group("player")
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.42
	capsule.height = 1.75
	var collision := CollisionShape3D.new()
	collision.shape = capsule
	collision.position.y = 0.9
	add_child(collision)
	visual = Node3D.new()
	visual.name = "TobiVisual"
	add_child(visual)
	attack_visual = Node3D.new()
	attack_visual.name = "AttackMotion"
	visual.add_child(attack_visual)
	_create_shadow_pulse_visual()
	_make_character()
	_cache_damage_flash_materials(visual)
	camera_pivot = Node3D.new()
	camera_pivot.position.y = 1.45
	add_child(camera_pivot)
	camera = Camera3D.new()
	camera.position = Vector3(0,2.4,6.5)
	camera.rotation_degrees.x = -13
	camera.current = true
	camera.fov = 72
	camera_pivot.add_child(camera)

func _mat(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = 0.88
	return m

func _part(mesh: Mesh, pos: Vector3, color: Color, scale := Vector3.ONE) -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	mi.scale = scale
	mi.material_override = _mat(color)
	if attack_visual and mesh is BoxMesh and pos.x > 0.4:
		attack_visual.add_child(mi)
	else:
		visual.add_child(mi)

func _make_character() -> void:
	# Articulated low-poly hero: separate pivots allow real procedural posing.
	var body := CapsuleMesh.new(); body.radius = 0.34; body.height = 0.88
	_part(body, Vector3(0, 0.93, 0), Color("526c68"), Vector3(1.0, 1.12, 0.82))
	var chest := SphereMesh.new(); chest.radius = 0.38; chest.height = 0.52
	_part(chest, Vector3(0, 1.15, 0.015), Color("718982"), Vector3(1.0, 0.72, 0.76))
	var head_pivot := Node3D.new(); head_pivot.name = "HeadPivot"; head_pivot.position = Vector3(0, 1.55, 0); visual.add_child(head_pivot)
	var head := SphereMesh.new(); head.radius = 0.31; head.height = 0.62; head.radial_segments = 16
	_add_visual_part(head_pivot, head, Vector3(0, 0.10, 0), Color("d9ae83"))
	var hood := SphereMesh.new(); hood.radius = 0.43; hood.height = 0.58; hood.radial_segments = 12
	_add_visual_part(head_pivot, hood, Vector3(0, 0.30, -0.075), Color("344c49"), Vector3(1.0, 0.72, 1.0))
	var face_shadow := BoxMesh.new(); face_shadow.size = Vector3(0.34, 0.12, 0.045)
	_add_visual_part(head_pivot, face_shadow, Vector3(0, 0.08, 0.285), Color("263735"))
	var eye_mesh := SphereMesh.new(); eye_mesh.radius = 0.025; eye_mesh.height = 0.04
	for eye_x in [-0.105, 0.105]:
		var eye := _add_visual_part(head_pivot, eye_mesh, Vector3(eye_x, 0.055, 0.309), Color("e6c88a"))
		var eye_material := _mat(Color("e6c88a")); eye_material.emission_enabled = true; eye_material.emission = Color("9c7541"); eye_material.emission_energy_multiplier = 0.35; eye.material_override = eye_material
	var scarf := TorusMesh.new(); scarf.inner_radius = 0.22; scarf.outer_radius = 0.31
	_add_visual_part(visual, scarf, Vector3(0, 1.43, 0), Color("a15d43"))
	var belt := BoxMesh.new(); belt.size = Vector3(0.68, 0.12, 0.40)
	_part(belt, Vector3(0, 0.62, 0), Color("8b5d3e"))
	var buckle := BoxMesh.new(); buckle.size = Vector3(0.14, 0.15, 0.055)
	_part(buckle, Vector3(0, 0.63, 0.225), Color("d2b879"))
	# Shoulder/arm pivots; right arm carries the sword.
	var left_arm := _make_limb("LeftArm", Vector3(-0.39, 1.28, 0), Vector3(0, -0.24, 0), Vector3(0.19, 0.55, 0.20), Color("526c68"))
	var right_arm := _make_limb("RightArm", Vector3(0.39, 1.28, 0), Vector3(0, -0.24, 0), Vector3(0.19, 0.55, 0.20), Color("526c68"))
	var sword_pivot := Node3D.new(); sword_pivot.name = "SwordPivot"; sword_pivot.position = Vector3(0, -0.42, 0.03); right_arm.add_child(sword_pivot)
	var blade := BoxMesh.new(); blade.size = Vector3(0.095, 0.82, 0.12)
	_add_visual_part(sword_pivot, blade, Vector3(0.02, -0.52, 0.05), Color("c6d0ce"))
	var guard := BoxMesh.new(); guard.size = Vector3(0.34, 0.075, 0.13)
	_add_visual_part(sword_pivot, guard, Vector3(0.02, -0.12, 0.05), Color("c49a59"))
	var grip := CylinderMesh.new(); grip.top_radius = 0.045; grip.bottom_radius = 0.045; grip.height = 0.25
	_add_visual_part(sword_pivot, grip, Vector3(0.02, 0.035, 0.05), Color("513b32"))
	var left_leg := _make_limb("LeftLeg", Vector3(-0.19, 0.58, 0), Vector3(0, -0.24, 0), Vector3(0.22, 0.54, 0.23), Color("354642"))
	var right_leg := _make_limb("RightLeg", Vector3(0.19, 0.58, 0), Vector3(0, -0.24, 0), Vector3(0.22, 0.54, 0.23), Color("354642"))
	for leg in [left_leg, right_leg]:
		var boot := BoxMesh.new(); boot.size = Vector3(0.27, 0.18, 0.38)
		_add_visual_part(leg, boot, Vector3(0, -0.47, 0.07), Color("302a27"))
	# Split cloth cape gives a readable silhouette and reacts to movement.
	var cape_pivot := Node3D.new(); cape_pivot.name = "CapePivot"; cape_pivot.position = Vector3(0, 1.27, -0.20); visual.add_child(cape_pivot)
	var cape := BoxMesh.new(); cape.size = Vector3(0.68, 0.88, 0.09)
	_add_visual_part(cape_pivot, cape, Vector3(0, -0.48, -0.03), Color("263a3b"))
	# Layered leather details, shoulder guards, gloves and stitched tunic panels.
	for side in [-1.0, 1.0]:
		var shoulder_guard := SphereMesh.new(); shoulder_guard.radius = 0.22; shoulder_guard.height = 0.22
		_add_visual_part(visual, shoulder_guard, Vector3(side * 0.39, 1.34, 0.015), Color("806044"), Vector3(1.0, 0.62, 0.92))
		var knee_guard := SphereMesh.new(); knee_guard.radius = 0.14; knee_guard.height = 0.13
		_add_visual_part(visual, knee_guard, Vector3(side * 0.19, 0.42, 0.16), Color("9a7950"), Vector3(1.0, 0.72, 0.55))
	var tunic_panel := BoxMesh.new(); tunic_panel.size = Vector3(0.22, 0.46, 0.045)
	_add_visual_part(visual, tunic_panel, Vector3(0, 0.86, 0.22), Color("3e5752"))
	for side in [-1.0, 1.0]:
		var pouch := BoxMesh.new(); pouch.size = Vector3(0.17, 0.19, 0.15)
		_add_visual_part(visual, pouch, Vector3(side * 0.31, 0.61, 0.12), Color("674a37"))
	var cape_clasp := SphereMesh.new(); cape_clasp.radius = 0.075
	_add_visual_part(visual, cape_clasp, Vector3(0, 1.37, 0.20), Color("d0ad68"))
	# A readable hero crest and layered travel gear give Tobi a stronger silhouette.
	var chest_crest := CylinderMesh.new(); chest_crest.top_radius = 0.105; chest_crest.bottom_radius = 0.105; chest_crest.height = 0.045; chest_crest.radial_segments = 8
	var crest_instance := _add_visual_part(visual, chest_crest, Vector3(0, 1.12, 0.235), Color("c6a05e"))
	crest_instance.rotation.x = PI * 0.5
	var crest_glow := _mat(Color("d5b66f")); crest_glow.emission_enabled = true; crest_glow.emission = Color("8c5d2f"); crest_glow.emission_energy_multiplier = 0.22; crest_instance.material_override = crest_glow
	var hood_point := CylinderMesh.new(); hood_point.top_radius = 0.015; hood_point.bottom_radius = 0.19; hood_point.height = 0.34; hood_point.radial_segments = 8
	_add_visual_part(head_pivot, hood_point, Vector3(0, 0.48, -0.10), Color("2d4542"), Vector3(0.88, 1.0, 0.8))
	for side in [-1.0, 1.0]:
		var bracer := BoxMesh.new(); bracer.size = Vector3(0.22, 0.16, 0.24)
		_add_visual_part(visual, bracer, Vector3(side * 0.40, 0.98, 0.035), Color("785b43"))
		var bracer_trim := BoxMesh.new(); bracer_trim.size = Vector3(0.225, 0.035, 0.245)
		_add_visual_part(visual, bracer_trim, Vector3(side * 0.40, 0.91, 0.035), Color("b28b58"))
		var boot_strap := BoxMesh.new(); boot_strap.size = Vector3(0.235, 0.07, 0.245)
		_add_visual_part(visual, boot_strap, Vector3(side * 0.19, 0.30, 0.015), Color("896746"))
	var cape_hem := BoxMesh.new(); cape_hem.size = Vector3(0.70, 0.07, 0.105)
	_add_visual_part(cape_pivot, cape_hem, Vector3(0, -0.89, -0.03), Color("9b6049"))
	# Breu, the shadow cat companion, has four articulated paws and a segmented tail.
	cat = Node3D.new(); cat.name = "Breu"; cat.position = Vector3(-0.9, 0, 0.65); visual.add_child(cat)
	var cat_body := SphereMesh.new(); cat_body.radius = 0.31; cat_body.height = 0.58
	_add_visual_part(cat, cat_body, Vector3(0, 0.36, 0), Color("20242a"), Vector3(1.25, 0.8, 1.0))
	var cat_head_pivot := Node3D.new(); cat_head_pivot.name = "CatHeadPivot"; cat_head_pivot.position = Vector3(0, 0.59, -0.17); cat.add_child(cat_head_pivot)
	var cat_head := SphereMesh.new(); cat_head.radius = 0.23; cat_head.height = 0.42
	_add_visual_part(cat_head_pivot, cat_head, Vector3.ZERO, Color("171b21"))
	for x in [-0.14, 0.14]:
		var ear: CylinderMesh = CylinderMesh.new(); ear.top_radius = 0.0; ear.bottom_radius = 0.085; ear.height = 0.22
		_add_visual_part(cat_head_pivot, ear, Vector3(x, 0.19, -0.015), Color("171b21"))
		var eye := SphereMesh.new(); eye.radius = 0.035
		_add_visual_part(cat_head_pivot, eye, Vector3(x * 0.62, -0.015, 0.205), Color("d5c46d"))
	var tail_pivot := Node3D.new(); tail_pivot.name = "TailPivot"; tail_pivot.position = Vector3(0, 0.42, 0.25); cat.add_child(tail_pivot)
	for segment in range(3):
		var tail_segment := Node3D.new(); tail_segment.name = "TailSegment%d" % segment
		tail_segment.position = Vector3(0, 0.0, 0.13 if segment == 0 else 0.15)
		tail_segment.rotation.x = PI * 0.5
		tail_pivot.add_child(tail_segment)
		var tail_mesh := CapsuleMesh.new(); tail_mesh.radius = 0.065 - float(segment) * 0.012; tail_mesh.height = 0.28
		_add_visual_part(tail_segment, tail_mesh, Vector3(0, 0.0, 0.11), Color("171b21"))
		if segment < 2: tail_pivot = tail_segment
	var paw_pivots: Array[Node3D] = []
	for x in [-0.20, 0.20]:
		for z in [-0.16, 0.18]:
			var paw_pivot := Node3D.new(); paw_pivot.name = "Paw"; paw_pivot.position = Vector3(x, 0.19, z); cat.add_child(paw_pivot)
			var paw := SphereMesh.new(); paw.radius = 0.105; paw.height = 0.15
			_add_visual_part(paw_pivot, paw, Vector3(0, -0.06, 0), Color("171b21"))
			paw_pivots.append(paw_pivot)
	# Cache pivots for the animation state machine.
	visual.set_meta("left_arm", left_arm); visual.set_meta("right_arm", right_arm)
	visual.set_meta("left_leg", left_leg); visual.set_meta("right_leg", right_leg)
	visual.set_meta("cape", cape_pivot); visual.set_meta("head", head_pivot)
	cat.set_meta("tail", tail_pivot); cat.set_meta("head", cat_head_pivot); cat.set_meta("paws", paw_pivots)

func _add_visual_part(parent: Node3D, mesh: Mesh, pos: Vector3, color: Color, part_scale := Vector3.ONE) -> MeshInstance3D:
	var mi := MeshInstance3D.new(); mi.mesh = mesh; mi.position = pos; mi.scale = part_scale; mi.material_override = _mat(color); parent.add_child(mi)
	return mi

func _make_limb(part_name: String, pivot_pos: Vector3, mesh_pos: Vector3, mesh_size: Vector3, color: Color) -> Node3D:
	var pivot := Node3D.new(); pivot.name = part_name; pivot.position = pivot_pos; visual.add_child(pivot)
	var limb := CapsuleMesh.new(); limb.radius = mesh_size.x * 0.5; limb.height = mesh_size.y
	_add_visual_part(pivot, limb, mesh_pos, color, Vector3(1.0, 1.0, mesh_size.z / mesh_size.x))
	return pivot

func _physics_process(delta: float) -> void:
	attack_cooldown = maxf(0.0,attack_cooldown-delta)
	combo_timer = maxf(0.0, combo_timer - delta)
	if combo_timer <= 0.0 and combo_step != 0:
		combo_step = 0
		if world and world.has_method("combat_combo_changed"): world.combat_combo_changed(0)
	shadow_pulse_cooldown = maxf(0.0, shadow_pulse_cooldown - delta)
	_update_shadow_pulse_visual(delta)
	if Input.is_action_just_pressed("dodge"):
		do_dodge()
	if Input.is_action_just_pressed("shadow"):
		do_shadow_pulse()
	dodge_cooldown = maxf(0.0, dodge_cooldown-delta)
	dodge_time = maxf(0.0, dodge_time-delta)
	stamina = minf(100.0, stamina + 16.0 * delta)
	attack_flash = maxf(0.0,attack_flash-delta)
	hit_reaction = maxf(0.0, hit_reaction - delta)
	damage_flash = maxf(0.0, damage_flash - delta)
	perfect_dodge_flash = maxf(0.0, perfect_dodge_flash - delta)
	_update_damage_flash()
	landing_time = maxf(0.0, landing_time - delta)
	invulnerable = maxf(0.0,invulnerable-delta)
	anim_time += delta
	var was_on_floor := is_on_floor()
	var input := Input.get_vector("move_left","move_right","move_forward","move_back")
	var direction := (camera_pivot.global_basis * Vector3(input.x,0,input.y)).normalized()
	direction.y = 0
	if direction.length() > 0.1:
		direction = direction.normalized()
		velocity.x = move_toward(velocity.x,direction.x*speed,24.0*delta)
		velocity.z = move_toward(velocity.z,direction.z*speed,24.0*delta)
		rotation.y = lerp_angle(rotation.y,atan2(direction.x,direction.z),delta*12.0)
	else:
		velocity.x = move_toward(velocity.x,0,speed*7*delta)
		velocity.z = move_toward(velocity.z,0,speed*7*delta)
	if not is_on_floor(): velocity.y -= 18.0*delta
	elif Input.is_action_just_pressed("jump"): do_jump()
	if dodge_time > 0.0:
		velocity.x = dodge_direction.x * 12.5
		velocity.z = dodge_direction.z * 12.5
	move_and_slide()
	if not was_on_floor and is_on_floor(): landing_time = 0.16
	# Procedural animation state machine: idle, walk/run, jump, land, dodge, attack, hit and defeat.
	var planar_speed := Vector2(velocity.x, velocity.z).length()
	var moving := planar_speed > 0.35
	var gait_speed := 11.5 if planar_speed > speed * 0.72 else 8.0
	var gait := sin(anim_time * gait_speed) if moving else 0.0
	var bob := absf(gait) * 0.055 if moving else sin(anim_time * 2.0) * 0.012
	visual.position.y = bob - (0.045 * (landing_time / 0.16))
	var left_arm: Node3D = visual.get_meta("left_arm")
	var right_arm: Node3D = visual.get_meta("right_arm")
	var left_leg: Node3D = visual.get_meta("left_leg")
	var right_leg: Node3D = visual.get_meta("right_leg")
	var cape_pivot: Node3D = visual.get_meta("cape")
	var head_pivot: Node3D = visual.get_meta("head")
	left_leg.rotation.x = gait * 0.68
	right_leg.rotation.x = -gait * 0.68
	left_leg.rotation.z = sin(anim_time * gait_speed * 0.5) * 0.035 if moving else 0.0
	right_leg.rotation.z = -left_leg.rotation.z
	left_arm.rotation.x = -gait * 0.46
	right_arm.rotation.x = gait * 0.38
	left_arm.rotation.z = 0.05
	right_arm.rotation.z = -0.10
	cape_pivot.rotation.x = -0.12 - (0.30 if moving else 0.0) + sin(anim_time * (5.0 if moving else 2.4)) * (0.055 if moving else 0.035)
	cape_pivot.rotation.z = sin(anim_time * 2.0) * 0.035
	head_pivot.rotation.x = sin(anim_time * 1.4) * 0.025
	visual.scale.y = 1.0 + sin(anim_time * 2.1) * (0.008 if not moving else 0.003)
	if not is_on_floor():
		left_leg.rotation.x = -0.28; right_leg.rotation.x = 0.32
		left_arm.rotation.x = -0.48; right_arm.rotation.x = -0.35
	if dodge_time > 0.0:
		visual.rotation.z = lerpf(visual.rotation.z, -0.30, delta * 14.0)
	else:
		visual.rotation.z = lerpf(visual.rotation.z, 0.0, delta * 10.0)
	if attack_flash > 0.0:
		var attack_phase := 1.0 - attack_flash / 0.28
		right_arm.rotation.x = -1.25 + sin(attack_phase * PI) * 0.22
		left_arm.rotation.x = 0.22 + sin(attack_phase * PI) * 0.18
		right_arm.rotation.z = -0.72
	else:
		right_arm.rotation.z = lerpf(right_arm.rotation.z, -0.10, delta * 10.0)
	if hit_reaction > 0.0:
		visual.rotation.x = lerpf(visual.rotation.x, 0.16, delta * 18.0)
		left_arm.rotation.x = -0.85
		right_arm.rotation.x = 0.42
	else:
		visual.rotation.x = lerpf(visual.rotation.x, 0.0, delta * 8.0)
	if hp <= 0:
		death_pose = true
		visual.rotation.z = lerpf(visual.rotation.z, 1.25, delta * 2.5)
		left_arm.rotation.x = -0.35
		right_arm.rotation.x = -0.35
	if is_instance_valid(cat):
		cat.position.x = -0.9 + sin(anim_time * 2.0) * 0.06
		cat.position.y = absf(sin(anim_time * (7.0 if moving else 2.8))) * (0.07 if moving else 0.025)
		var tail_pivot: Node3D = cat.get_meta("tail")
		var cat_head: Node3D = cat.get_meta("head")
		tail_pivot.rotation.x = sin(anim_time * 3.0) * (0.42 if moving else 0.25)
		tail_pivot.rotation.z = sin(anim_time * 2.1) * 0.28
		cat_head.rotation.y = sin(anim_time * 1.7) * 0.12
		var paws: Array = cat.get_meta("paws")
		for paw_index in range(paws.size()):
			var paw_node: Node3D = paws[paw_index]
			var phase_offset := 0.0 if paw_index % 2 == 0 else PI
			paw_node.rotation.x = sin(anim_time * (9.0 if moving else 2.0) + phase_offset) * (0.38 if moving else 0.035)
	# camera stays behind Tobi and soft-follows
	camera_pivot.rotation.y = lerp_angle(camera_pivot.rotation.y,-rotation.y + camera_yaw_offset,delta*4.0)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		camera_yaw_offset -= Input.get_last_mouse_velocity().x*0.0015
	# Right analog stick: orbit and tilt the camera on Bluetooth/USB controllers.
	var connected_pads := Input.get_connected_joypads()
	if not connected_pads.is_empty():
		var pad_id: int = connected_pads[0]
		var look_x := Input.get_joy_axis(pad_id, JOY_AXIS_RIGHT_X)
		var look_y := Input.get_joy_axis(pad_id, JOY_AXIS_RIGHT_Y)
		if absf(look_x) > 0.12:
			camera_yaw_offset -= look_x * delta * 2.4
		if absf(look_y) > 0.12:
			camera.rotation.x = clampf(camera.rotation.x + look_y * delta * 1.8, -0.75, -0.08)
	if attack_flash > 0.0:
		attack_visual.rotation.y = sin((1.0 - attack_flash / 0.28) * PI) * 1.35
	else:
		attack_visual.rotation.y = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		# Drag on the right half of the screen to orbit the camera.
		if event.position.x > get_viewport().get_visible_rect().size.x * 0.42:
			camera_yaw_offset -= event.relative.x * camera_sensitivity
			camera.rotation.x = clampf(camera.rotation.x - event.relative.y * 0.003, -0.75, -0.08)

func do_jump() -> void:
	if is_on_floor(): velocity.y = jump_velocity

func do_attack() -> void:
	if attack_cooldown > 0.0 or hp <= 0 or stamina < 8.0: return
	if combo_timer <= 0.0: combo_step = 0
	combo_step = (combo_step % 3) + 1
	combo_timer = 1.05
	attack_cooldown = 0.40 if combo_step == 3 else 0.48
	stamina -= 8.0
	attack_flash = 0.28
	var multipliers := [1.0, 1.25, 1.65]
	var combo_damage := int(round(float(attack_damage) * multipliers[combo_step - 1]))
	if world and world.has_method("combat_combo_changed"):
		world.combat_combo_changed(combo_step)
	var forward := global_basis.z
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.get("dead") == true: continue
		var offset: Vector3 = enemy.global_position - global_position
		var flat := Vector3(offset.x, 0.0, offset.z)
		if flat.length() <= 2.65 and (flat.length() < 0.01 or forward.dot(flat.normalized()) > 0.18):
			enemy.take_damage(combo_damage)


func _create_shadow_pulse_visual() -> void:
	# A lightweight expanding ring gives Breu's area skill readable range feedback.
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 0.84
	ring_mesh.outer_radius = 1.0
	ring_mesh.rings = 8
	ring_mesh.ring_segments = 32
	pulse_ring = MeshInstance3D.new()
	pulse_ring.name = "BreuShadowPulseRing"
	pulse_ring.mesh = ring_mesh
	pulse_ring.position.y = 0.10
	pulse_ring.rotation.x = PI * 0.5
	pulse_ring.visible = false
	pulse_material = StandardMaterial3D.new()
	pulse_material.albedo_color = Color(0.42, 0.16, 0.72, 0.9)
	pulse_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pulse_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pulse_material.emission_enabled = true
	pulse_material.emission = Color(0.32, 0.08, 0.72)
	pulse_material.emission_energy_multiplier = 1.8
	pulse_ring.material_override = pulse_material
	add_child(pulse_ring)

func _update_shadow_pulse_visual(delta: float) -> void:
	if pulse_visual_timer <= 0.0:
		if is_instance_valid(pulse_ring): pulse_ring.visible = false
		return
	pulse_visual_timer = maxf(0.0, pulse_visual_timer - delta)
	var progress := 1.0 - pulse_visual_timer / 0.72
	if is_instance_valid(pulse_ring):
		pulse_ring.visible = true
		pulse_ring.scale = Vector3.ONE * lerpf(0.35, 4.2, progress)
		var alpha := 0.9 * (1.0 - progress)
		pulse_material.albedo_color = Color(0.42, 0.16, 0.72, alpha)
		pulse_material.emission_energy_multiplier = lerpf(2.2, 0.2, progress)

func do_shadow_pulse() -> void:
	if hp <= 0 or shadow_pulse_cooldown > 0.0 or stamina < 35.0: return
	shadow_pulse_cooldown = 8.0
	pulse_visual_timer = 0.72
	if is_instance_valid(pulse_ring):
		pulse_ring.visible = true
		pulse_ring.scale = Vector3.ONE * 0.35
	stamina -= 35.0
	attack_flash = 0.34
	var pulse_damage := int(round(float(attack_damage) * 1.35))
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.get("dead") == true: continue
		var offset: Vector3 = enemy.global_position - global_position
		var flat := Vector3(offset.x, 0.0, offset.z)
		if flat.length() <= 4.2:
			enemy.take_damage(pulse_damage)
	if world and world.has_method("shadow_pulse_used"):
		world.shadow_pulse_used(shadow_pulse_cooldown)

func do_dodge() -> void:
	if dodge_cooldown > 0.0 or stamina < 28.0 or hp <= 0: return
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	dodge_direction = (camera_pivot.global_basis * Vector3(input.x, 0, input.y)).normalized()
	dodge_direction.y = 0
	if dodge_direction.length() < 0.1: dodge_direction = -global_basis.z
	dodge_direction = dodge_direction.normalized()
	dodge_perfect_used = false
	dodge_time = 0.24
	dodge_cooldown = 0.85
	stamina -= 28.0
	invulnerable = maxf(invulnerable, 0.28)
	velocity.y = 1.2

func get_stamina() -> float:
	return stamina


func apply_boss_slam_knockback(direction: Vector3, strength: float) -> void:
	if hp <= 0:
		return
	var push := Vector3(direction.x, 0.0, direction.z).normalized()
	if push.length() < 0.01:
		push = -global_basis.z
	velocity.x = push.x * strength
	velocity.z = push.z * strength
	velocity.y = maxf(velocity.y, 3.6 if strength >= 11.0 else 2.8)

func take_damage(amount: int) -> void:
	if hp <= 0: return
	if invulnerable > 0.0:
		if dodge_time > 0.0 and not dodge_perfect_used:
			dodge_perfect_used = true
			perfect_dodge_flash = 0.22
			stamina = minf(100.0, stamina + 10.0)
			if world and world.has_method("player_perfect_dodge"):
				world.player_perfect_dodge()
		return
	hp = maxi(0, hp - amount)
	hit_reaction = 0.22
	damage_flash = 0.16
	invulnerable = 0.65
	if world and world.has_method("player_health_changed"):
		world.player_health_changed(hp, max_hp)
	if hp <= 0:
		velocity = Vector3.ZERO
		hit_reaction = 0.0
		if world and world.has_method("player_defeated"):
			world.player_defeated()

func _cache_damage_flash_materials(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		var source_material := mesh_instance.material_override as StandardMaterial3D
		if source_material:
			var flash_material := source_material.duplicate() as StandardMaterial3D
			mesh_instance.material_override = flash_material
			damage_flash_materials.append(flash_material)
			damage_flash_base_colors.append(flash_material.albedo_color)
	for child in node.get_children():
		_cache_damage_flash_materials(child)

func _update_damage_flash() -> void:
	var damage_strength := clampf(damage_flash / 0.16, 0.0, 1.0)
	var perfect_strength := clampf(perfect_dodge_flash / 0.22, 0.0, 1.0)
	for i in range(damage_flash_materials.size()):
		var material := damage_flash_materials[i]
		if is_instance_valid(material):
			if perfect_strength > 0.0:
				material.albedo_color = damage_flash_base_colors[i].lerp(Color("62d8c8"), perfect_strength * 0.78)
				material.emission_enabled = true
				material.emission = Color("35cdbb")
				material.emission_energy_multiplier = perfect_strength * 1.35
			else:
				material.albedo_color = damage_flash_base_colors[i].lerp(Color("ff5555"), damage_strength * 0.72)
				material.emission_enabled = false
				material.emission_energy_multiplier = 0.0
