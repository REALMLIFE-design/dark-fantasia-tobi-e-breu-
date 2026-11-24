extends Control

const STORY_SCENE := "res://scenes/main.tscn"
const MAX_ADVENTURE_PLAYERS := 4

var status_label: Label
var notice_dialog: AcceptDialog
var update_status_label: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_menu()
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
	if mobile_ui:
		ring.visible = false

	var scroll := ScrollContainer.new()
	scroll.name = "BootMenuScroll"
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	scroll.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(scroll)

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
	get_tree().change_scene_to_file(STORY_SCENE)

func _show_coop_info() -> void:
	_show_notice("História cooperativa", "A aventura será compartilhada por até 4 jogadores. A campanha atual será preservada. O servidor gratuito e a sincronização da história ainda precisam ser configurados.")

func _show_multiplayer_info() -> void:
	_show_notice("Multiplayer", "As salas privadas e os convites de amigos fazem parte de Dark World: A Lenda de Tobi e Breu. A conexão multiplayer ainda não está ativa nesta versão.")

func _show_google_info() -> void:
	_show_notice("Conta Google", "O login Google será usado para identificar sua conta e adicionar amigos. A integração depende da configuração segura do OAuth e do servidor; nenhum login falso será exibido.")

func _show_settings() -> void:
	_show_notice("Configurações", "As opções de áudio, gráficos e controles serão adicionadas aqui. Os controles atuais da aventura continuam disponíveis.")

func _show_notice(dialog_title: String, message: String) -> void:
	notice_dialog.title = dialog_title
	notice_dialog.dialog_text = message
	notice_dialog.popup_centered()

func _on_update_status_changed(message: String) -> void:
	if is_instance_valid(update_status_label):
		update_status_label.text = "SISTEMA  •  " + message
