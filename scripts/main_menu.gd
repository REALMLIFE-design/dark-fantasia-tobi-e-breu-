extends Control

class LoadingSpinner extends Control:
	var phase := 0.0

	func _process(delta: float) -> void:
		phase = fposmod(phase + delta * 4.2, TAU)
		queue_redraw()

	func _draw() -> void:
		var center := size * 0.5
		draw_arc(center, 14.0, 0.0, TAU, 48, Color(0.34, 0.55, 0.58, 0.42), 2.4, true)
		draw_arc(center, 14.0, phase, phase + TAU * 0.68, 48, Color("d8b77c"), 3.2, true)

const STORY_SCENE := "res://scenes/main.tscn"
const MAX_ADVENTURE_PLAYERS := 4

var status_label: Label
var notice_dialog: AcceptDialog
var update_status_label: Label
var portal_ring: Panel
var menu_content: ScrollContainer
var _loading_story := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_menu()
	call_deferred("_start_menu_ambience")
	print("DARK_WORLD_LEGEND_BOOT_READY")

func _build_menu() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var viewport_size := get_viewport_rect().size
	var mobile_ui := OS.has_feature("mobile") or viewport_size.x < 900.0

	# Cinematic dark-fantasy foundation with restrained portal-like geometry.
	var background := ColorRect.new()
	background.color = Color("101b25")
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var cold_wash := ColorRect.new()
	cold_wash.color = Color(0.10, 0.22, 0.29, 0.34)
	cold_wash.anchor_left = 0.0
	cold_wash.anchor_top = 0.0
	cold_wash.anchor_right = 0.58
	cold_wash.anchor_bottom = 1.0
	cold_wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.add_child(cold_wash)

	var warm_edge := ColorRect.new()
	warm_edge.color = Color(0.58, 0.37, 0.18, 0.72)
	warm_edge.anchor_left = 0.0
	warm_edge.anchor_right = 1.0
	warm_edge.anchor_top = 0.0
	warm_edge.anchor_bottom = 0.0
	warm_edge.custom_minimum_size.y = 3.0
	warm_edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.add_child(warm_edge)

	var frame := ColorRect.new()
	frame.color = Color(0.45, 0.72, 0.76, 0.10)
	frame.anchor_left = 0.035
	frame.anchor_top = 0.055
	frame.anchor_right = 0.965
	frame.anchor_bottom = 0.945
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.add_child(frame)
	var inner_frame := ColorRect.new()
	inner_frame.color = Color("101b25")
	inner_frame.anchor_left = 0.002
	inner_frame.anchor_top = 0.002
	inner_frame.anchor_right = 0.998
	inner_frame.anchor_bottom = 0.998
	inner_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(inner_frame)

	# Decorative portal-ring motif; intentionally static and inexpensive on mobile.
	var ring := Panel.new()
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if mobile_ui:
		ring.anchor_left = 0.72
		ring.anchor_top = 0.035
		ring.anchor_right = 0.97
		ring.anchor_bottom = 0.23
	else:
		ring.anchor_left = 0.70
		ring.anchor_top = 0.14
		ring.anchor_right = 0.93
		ring.anchor_bottom = 0.58
	var ring_style := StyleBoxFlat.new()
	ring_style.bg_color = Color(0.20, 0.43, 0.49, 0.035)
	ring_style.border_color = Color(0.43, 0.78, 0.82, 0.24)
	ring_style.set_border_width_all(2)
	ring_style.set_corner_radius_all(999)
	ring.add_theme_stylebox_override("panel", ring_style)
	background.add_child(ring)
	portal_ring = ring
	# O portal permanece discreto também no celular, como marca visual do reino.
	_add_menu_ambient_motes(background, viewport_size)

	var scroll := ScrollContainer.new()
	scroll.name = "BootMenuScroll"
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	scroll.process_mode = Node.PROCESS_MODE_ALWAYS
	scroll.modulate.a = 0.0
	add_child(scroll)
	menu_content = scroll

	var center := CenterContainer.new()
	center.custom_minimum_size.y = viewport_size.y
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)

	var columns := HBoxContainer.new()
	columns.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	columns.add_theme_constant_override("separation", 34 if not mobile_ui else 0)
	center.add_child(columns)

	var layout := VBoxContainer.new()
	var content_width := minf(560.0, viewport_size.x * (0.90 if mobile_ui else 0.49))
	layout.custom_minimum_size = Vector2(content_width, 0)
	layout.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	layout.add_theme_constant_override("separation", 10)
	columns.add_child(layout)

	var eyebrow := Label.new()
	eyebrow.text = "CRÔNICAS DO REINO  /  CAPÍTULO I"
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	eyebrow.add_theme_color_override("font_color", Color("9bc8c7"))
	eyebrow.add_theme_font_size_override("font_size", 11)
	layout.add_child(eyebrow)

	var title := Label.new()
	title.text = "DARK WORLD"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.add_theme_color_override("font_color", Color("f1eee5"))
	title.add_theme_font_size_override("font_size", 38 if mobile_ui else 54)
	layout.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "A LENDA DE TOBI E BREU"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	subtitle.add_theme_color_override("font_color", Color("d8b77c"))
	subtitle.add_theme_font_size_override("font_size", 16)
	layout.add_child(subtitle)

	var story_tagline := Label.new()
	story_tagline.text = "Dois amigos. Um mundo entre a luz e a escuridão."
	story_tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	story_tagline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story_tagline.add_theme_color_override("font_color", Color("b5c4c2"))
	story_tagline.add_theme_font_size_override("font_size", 13)
	layout.add_child(story_tagline)

	_add_rule(layout, Color("55777a"), 1)
	var section := Label.new()
	section.text = "ESCOLHA SEU CAMINHO"
	section.add_theme_color_override("font_color", Color("d8b77c"))
	section.add_theme_font_size_override("font_size", 11)
	layout.add_child(section)

	_add_menu_button(layout, "CONTINUAR A JORNADA", "Retome sua aventura", _start_story, true)
	_add_menu_button(layout, "HISTÓRIA COOPERATIVA", "Aventura com até %d jogadores" % MAX_ADVENTURE_PLAYERS, _show_coop_info)
	_add_menu_button(layout, "MULTIPLAYER", "Explore com seus amigos", _show_multiplayer_info)
	_add_menu_button(layout, "AMIGOS  •  CONTA GOOGLE", "Conta e lista de amigos", _show_google_info)
	_add_menu_button(layout, "CONFIGURAÇÕES", "Áudio, imagem e controles", _show_settings)

	var footer := Label.new()
	footer.text = "QUE A LUZ ENCONTRE VOCÊS PELO CAMINHO."
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	footer.add_theme_color_override("font_color", Color("819795"))
	footer.add_theme_font_size_override("font_size", 10)
	layout.add_child(footer)

	update_status_label = Label.new()
	update_status_label.text = "SISTEMA  •  Verificando atualizações..."
	update_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	update_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	update_status_label.add_theme_color_override("font_color", Color("9bc8c7"))
	update_status_label.add_theme_font_size_override("font_size", 11)
	layout.add_child(update_status_label)
	if has_node("/root/UpdateManager"):
		var updater := get_node("/root/UpdateManager")
		update_status_label.text = updater.get_status()
		updater.status_changed.connect(_on_update_status_changed)

	if not mobile_ui:
		var lore := VBoxContainer.new()
		lore.custom_minimum_size = Vector2(minf(300.0, viewport_size.x * 0.27), 0)
		lore.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		lore.add_theme_constant_override("separation", 12)
		columns.add_child(lore)
		var lore_panel := PanelContainer.new()
		var panel_style := StyleBoxFlat.new()
		panel_style.bg_color = Color(0.055, 0.095, 0.12, 0.82)
		panel_style.border_color = Color(0.38, 0.62, 0.64, 0.42)
		panel_style.set_border_width_all(1)
		panel_style.content_margin_left = 20
		panel_style.content_margin_right = 20
		panel_style.content_margin_top = 22
		panel_style.content_margin_bottom = 22
		lore_panel.add_theme_stylebox_override("panel", panel_style)
		lore.add_child(lore_panel)
		var lore_content := VBoxContainer.new()
		lore_content.add_theme_constant_override("separation", 12)
		lore_panel.add_child(lore_content)
		var lore_kicker := Label.new()
		lore_kicker.text = "ARQUIVO DE AZULAN  /  001"
		lore_kicker.add_theme_color_override("font_color", Color("9bc8c7"))
		lore_kicker.add_theme_font_size_override("font_size", 10)
		lore_content.add_child(lore_kicker)
		var lore_title := Label.new()
		lore_title.text = "O mundo\nainda sonha."
		lore_title.add_theme_color_override("font_color", Color("f1eee5"))
		lore_title.add_theme_font_size_override("font_size", 27)
		lore_content.add_child(lore_title)
		_add_rule(lore_content, Color("9a784c"), 2)
		var lore_text := Label.new()
		lore_text.text = "Há lugares onde a luz floresce entre ruínas antigas. E há segredos que só dois amigos podem descobrir."
		lore_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lore_text.add_theme_color_override("font_color", Color("b5c4c2"))
		lore_text.add_theme_font_size_override("font_size", 13)
		lore_content.add_child(lore_text)
		var coordinates := Label.new()
		coordinates.text = "TOBI  +  BREU\nREINO DE AZULAN"
		coordinates.add_theme_color_override("font_color", Color("d8b77c"))
		coordinates.add_theme_font_size_override("font_size", 11)
		lore_content.add_child(coordinates)

	notice_dialog = AcceptDialog.new()
	notice_dialog.title = "DARK WORLD • A LENDA DE TOBI E BREU"
	add_child(notice_dialog)

func _start_menu_ambience() -> void:
	await get_tree().process_frame
	if is_instance_valid(portal_ring):
		portal_ring.pivot_offset = portal_ring.size * 0.5
		portal_ring.rotation = 0.0
		var rotation_tween := create_tween().set_loops()
		rotation_tween.tween_property(portal_ring, "rotation", TAU, 34.0).from(0.0).set_trans(Tween.TRANS_LINEAR)
		var pulse_tween := create_tween().set_loops()
		pulse_tween.tween_property(portal_ring, "modulate:a", 0.52, 3.2).from(1.0)
		pulse_tween.tween_property(portal_ring, "modulate:a", 1.0, 3.2)
	if is_instance_valid(menu_content):
		create_tween().tween_property(menu_content, "modulate:a", 1.0, 0.85).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _add_menu_ambient_motes(parent: Control, viewport_size: Vector2) -> void:
	# Pequenas partículas lentas dão profundidade sem usar shaders pesados ou imagens grandes.
	for i in range(14):
		var mote := ColorRect.new()
		var x := fposmod(float(i * 137 + 41), maxf(viewport_size.x - 8.0, 1.0))
		var y := fposmod(float(i * 83 + 29), maxf(viewport_size.y - 8.0, 1.0))
		var side := 2.0 if i % 3 != 0 else 3.0
		mote.size = Vector2(side, side)
		mote.position = Vector2(x, y + 72.0)
		mote.color = Color(0.62, 0.83, 0.80, 0.22)
		mote.mouse_filter = Control.MOUSE_FILTER_IGNORE
		mote.z_index = 2
		parent.add_child(mote)
		var duration := 8.0 + float(i % 5) * 1.35
		var drift := 70.0 + float(i % 4) * 24.0
		var mote_tween := create_tween().set_loops()
		mote_tween.tween_property(mote, "position", Vector2(x, y - drift), duration).from(Vector2(x, y + drift))
		mote_tween.parallel().tween_property(mote, "modulate:a", 0.68, duration * 0.45).from(0.0)
		mote_tween.tween_property(mote, "modulate:a", 0.0, duration * 0.55)

func _add_rule(parent: Control, tint: Color, thickness: float) -> void:
	var rule := ColorRect.new()
	rule.color = tint
	rule.custom_minimum_size = Vector2(0, thickness)
	rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rule)

func _add_menu_button(parent: VBoxContainer, heading: String, detail: String, action: Callable, primary := false) -> void:
	var button := Button.new()
	var available_width := get_viewport_rect().size.x
	var mobile_ui := OS.has_feature("mobile") or available_width < 900.0
	button.custom_minimum_size = Vector2(minf(520.0, available_width * (0.90 if mobile_ui else 0.48)), 68 if mobile_ui else 64)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	button.text = heading + "\n" + detail
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_size_override("font_size", 14 if primary else 13)
	button.add_theme_color_override("font_color", Color("fff7e8"))
	button.add_theme_color_override("font_hover_color", Color("ffffff"))
	button.add_theme_color_override("font_pressed_color", Color("d8b77c"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.12, 0.22, 0.27, 0.82) if primary else Color(0.07, 0.13, 0.17, 0.72)
	normal.border_color = Color("c49b60") if primary else Color("55777a")
	normal.set_border_width_all(1)
	normal.border_width_left = 4 if primary else 2
	normal.content_margin_left = 18
	normal.content_margin_right = 12
	normal.content_margin_top = 9
	normal.content_margin_bottom = 9
	normal.set_corner_radius_all(2)
	button.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.19, 0.32, 0.36, 0.96)
	hover.border_color = Color("9bc8c7")
	button.add_theme_stylebox_override("hover", hover)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.24, 0.30, 0.30, 1.0)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", hover)
	button.pressed.connect(action)
	parent.add_child(button)

func _start_story() -> void:
	if _loading_story:
		return
	_loading_story = true
	var overlay := Control.new()
	overlay.name = "CinematicLoadingOverlay"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(overlay)

	var veil := ColorRect.new()
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.color = Color(0.025, 0.045, 0.060, 0.97)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(veil)

	var loading_art := TextureRect.new()
	loading_art.texture = load("res://assets/art/loading_azulan.svg")
	loading_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	loading_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	loading_art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	loading_art.modulate = Color(1, 1, 1, 0.72)
	loading_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(loading_art)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(center)
	var content := VBoxContainer.new()
	content.custom_minimum_size.x = minf(440.0, get_viewport_rect().size.x * 0.78)
	content.add_theme_constant_override("separation", 12)
	center.add_child(content)
	var emblem := Label.new()
	emblem.text = "✧"
	emblem.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emblem.add_theme_font_size_override("font_size", 42)
	emblem.add_theme_color_override("font_color", Color("d8b77c"))
	content.add_child(emblem)
	var heading := Label.new()
	heading.text = "O REINO SE REVELA"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 19)
	heading.add_theme_color_override("font_color", Color("f1eee5"))
	content.add_child(heading)
	var detail := Label.new()
	detail.text = "Tobi e Breu estão a caminho..."
	detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail.add_theme_font_size_override("font_size", 12)
	detail.add_theme_color_override("font_color", Color("9bc8c7"))
	content.add_child(detail)
	var progress_bar := ProgressBar.new()
	progress_bar.custom_minimum_size = Vector2(0, 5)
	progress_bar.show_percentage = false
	progress_bar.max_value = 100.0
	content.add_child(progress_bar)

	var corner := HBoxContainer.new()
	corner.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	corner.offset_left = -206.0
	corner.offset_top = -62.0
	corner.offset_right = -22.0
	corner.offset_bottom = -20.0
	corner.alignment = BoxContainer.ALIGNMENT_END
	corner.add_theme_constant_override("separation", 10)
	corner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(corner)
	var spinner := LoadingSpinner.new()
	spinner.custom_minimum_size = Vector2(34, 34)
	corner.add_child(spinner)
	var corner_label := Label.new()
	corner_label.text = "CARREGANDO"
	corner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	corner_label.add_theme_font_size_override("font_size", 10)
	corner_label.add_theme_color_override("font_color", Color("b5c4c2"))
	corner.add_child(corner_label)

	await get_tree().process_frame
	var request_error := ResourceLoader.load_threaded_request(STORY_SCENE)
	if request_error != OK:
		push_error("Não foi possível iniciar o carregamento da aventura: %s" % request_error)
		_loading_story = false
		overlay.queue_free()
		return

	var started_at := Time.get_ticks_msec()
	var progress: Array = []
	var load_status := ResourceLoader.load_threaded_get_status(STORY_SCENE, progress)
	while load_status == ResourceLoader.THREAD_LOAD_IN_PROGRESS or Time.get_ticks_msec() - started_at < 550:
		if not progress.is_empty():
			progress_bar.value = clampf(float(progress[0]) * 100.0, 0.0, 100.0)
		await get_tree().process_frame
		load_status = ResourceLoader.load_threaded_get_status(STORY_SCENE, progress)

	if load_status == ResourceLoader.THREAD_LOAD_LOADED:
		progress_bar.value = 100.0
		var packed_scene := ResourceLoader.load_threaded_get(STORY_SCENE) as PackedScene
		if packed_scene != null:
			get_tree().change_scene_to_packed(packed_scene)
			return

	detail.text = "Não foi possível carregar a aventura. Tente novamente."
	push_error("Falha ao carregar a cena principal: %s" % STORY_SCENE)
	await get_tree().create_timer(1.6).timeout
	overlay.queue_free()
	_loading_story = false

func _show_coop_info() -> void:
	_open_friends_lobby()

func _show_multiplayer_info() -> void:
	_open_friends_lobby()

func _show_google_info() -> void:
	_open_friends_lobby()

func _open_friends_lobby() -> void:
	var lobby := load("res://scenes/friends_lobby.tscn") as PackedScene
	if lobby == null:
		_show_notice("Lobby indisponível", "Não foi possível carregar o lobby de amigos.")
		return
	get_tree().root.add_child(lobby.instantiate())
	queue_free()

func _show_settings() -> void:
	_show_notice("Configurações", "As opções de áudio, gráficos e controles serão adicionadas aqui. Os controles atuais da aventura continuam disponíveis.")

func _show_notice(dialog_title: String, message: String) -> void:
	notice_dialog.title = dialog_title
	notice_dialog.dialog_text = message
	notice_dialog.popup_centered()

func _on_update_status_changed(message: String) -> void:
	if is_instance_valid(update_status_label):
		update_status_label.text = "SISTEMA  •  " + message
