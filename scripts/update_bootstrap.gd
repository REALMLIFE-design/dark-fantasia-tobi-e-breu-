extends Control

class BootstrapAtmosphere extends Control:
	var elapsed := 0.0

	func _process(delta: float) -> void:
		elapsed += delta
		queue_redraw()

	func _draw() -> void:
		var center := Vector2(size.x * 0.5, size.y * 0.43)
		var base_radius := minf(size.x, size.y) * 0.19
		for i in range(4):
			var radius := base_radius + float(i) * 27.0 + sin(elapsed * 0.55 + float(i)) * 5.0
			var start := elapsed * 0.075 + float(i) * 0.8
			draw_arc(center, radius, start, start + PI * 1.58, 96, Color(0.32, 0.63, 0.66, 0.11 + float(i) * 0.025), 1.4, true)
		for i in range(22):
			var angle := float(i) * TAU / 22.0 + elapsed * 0.11
			var radius := base_radius + 38.0 + sin(elapsed * 0.7 + float(i)) * 22.0
			var point := center + Vector2(cos(angle), sin(angle)) * radius
			draw_circle(point, 1.2 if i % 3 else 1.8, Color(0.73, 0.78, 0.67, 0.32))

class LoadingSpinner extends Control:
	var phase := 0.0

	func _process(delta: float) -> void:
		phase = fposmod(phase + delta * 4.2, TAU)
		queue_redraw()

	func _draw() -> void:
		var center := size * 0.5
		draw_arc(center, 14.0, 0.0, TAU, 48, Color(0.34, 0.55, 0.58, 0.42), 2.4, true)
		draw_arc(center, 14.0, phase, phase + TAU * 0.68, 48, Color("d8b77c"), 3.2, true)

@onready var status_label: Label = $CenterContainer/Content/Status

func _ready() -> void:
	status_label.text = UpdateManager.get_status()
	if not UpdateManager.status_changed.is_connected(_on_update_status_changed):
		UpdateManager.status_changed.connect(_on_update_status_changed)
	_add_loading_ambience()

	# A verificação de rede roda em segundo plano. O menu e o jogo não podem
	# esperar até 30 segundos pelo manifesto ou pelo download de uma atualização.
	UpdateManager.check_for_updates()
	await get_tree().create_timer(0.78).timeout
	var fade := create_tween()
	fade.tween_property(self, "modulate:a", 0.0, 0.22)
	await fade.finished
	var error := get_tree().change_scene_to_file("res://scenes/login.tscn")
	if error != OK:
		push_error("Não foi possível abrir o menu principal: %s" % error)

func _add_loading_ambience() -> void:
	var atmosphere := BootstrapAtmosphere.new()
	atmosphere.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	atmosphere.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(atmosphere)
	move_child(atmosphere, 1)

	var corner := HBoxContainer.new()
	corner.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	corner.offset_left = -206.0
	corner.offset_top = -62.0
	corner.offset_right = -22.0
	corner.offset_bottom = -20.0
	corner.alignment = BoxContainer.ALIGNMENT_END
	corner.add_theme_constant_override("separation", 10)
	corner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(corner)
	var spinner := LoadingSpinner.new()
	spinner.custom_minimum_size = Vector2(34, 34)
	corner.add_child(spinner)
	var label := Label.new()
	label.text = "INICIALIZANDO"
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", Color("b5c4c2"))
	corner.add_child(label)

func _on_update_status_changed(message: String) -> void:
	if is_instance_valid(status_label):
		status_label.text = message
