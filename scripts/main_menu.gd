extends Control

const STORY_SCENE := "res://scenes/main.tscn"
const MAX_ADVENTURE_PLAYERS := 4
const UI_BUTTON_TEXTURE := preload("res://assets/ui/button_frame.svg")

var status_label: Label
var notice_dialog: AcceptDialog
var update_status_label: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_menu()
	print("TOBI_BREU_BOOT_READY")

func _build_menu() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = Color("101a1b")
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var glow := ColorRect.new()
	glow.color = Color(0.12, 0.20, 0.18, 0.32)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.anchor_left = 0.0
	glow.anchor_top = 0.0
	glow.anchor_right = 0.48
	glow.anchor_bottom = 1.0
	background.add_child(glow)

	var scroll := ScrollContainer.new()
	scroll.name = "BootMenuScroll"
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	scroll.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(scroll)
	var center := CenterContainer.new()
	center.custom_minimum_size.y = get_viewport_rect().size.y
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)

	var layout := VBoxContainer.new()
	var viewport_size := get_viewport_rect().size
	var viewport_width := viewport_size.x
	var mobile_ui := OS.has_feature("mobile") or viewport_width < 900.0
	layout.custom_minimum_size = Vector2(minf(560.0, viewport_width * (0.94 if mobile_ui else 0.90)), 0)
	layout.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	layout.add_theme_constant_override("separation", 12)
	center.add_child(layout)

	var eyebrow := Label.new()
	eyebrow.text = "UMA AVENTURA EM DARK FANTASY"
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eyebrow.add_theme_color_override("font_color", Color("b7a77a"))
	eyebrow.add_theme_font_size_override("font_size", 14)
	layout.add_child(eyebrow)

	var title := Label.new()
	title.text = "TOBI  &  BREU"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color("f0e9d7"))
	title.add_theme_font_size_override("font_size", 38 if viewport_width < 600.0 else 48)
	layout.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "DARK WORLD  •  ESCOLHA COMO JOGAR"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override("font_color", Color("a9b5a9"))
	subtitle.add_theme_font_size_override("font_size", 13)
	layout.add_child(subtitle)

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 12
	layout.add_child(spacer)

	_add_menu_button(layout, "MODO HISTÓRIA", "Continue sua jornada solo", _start_story, true)
	_add_menu_button(layout, "HISTÓRIA COOPERATIVA", "Aventura com até 4 jogadores", _show_coop_info)
	_add_menu_button(layout, "MULTIPLAYER", "Jogue com amigos em uma sala", _show_multiplayer_info)
	_add_menu_button(layout, "AMIGOS  •  CONECTAR GOOGLE", "Login e lista de amigos", _show_google_info)
	_add_menu_button(layout, "CONFIGURAÇÕES", "Preferências do jogo", _show_settings)

	var footer := Label.new()
	footer.text = "A campanha original continua sendo a base da aventura."
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_color_override("font_color", Color("788984"))
	footer.add_theme_font_size_override("font_size", 12)
	layout.add_child(footer)

	update_status_label = Label.new()
	update_status_label.text = "AUTO • Atualizações: verificando..."
	update_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	update_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	update_status_label.add_theme_color_override("font_color", Color("b7a77a"))
	update_status_label.add_theme_font_size_override("font_size", 12)
	layout.add_child(update_status_label)
	if has_node("/root/UpdateManager"):
		var updater := get_node("/root/UpdateManager")
		update_status_label.text = updater.get_status()
		updater.status_changed.connect(_on_update_status_changed)

	notice_dialog = AcceptDialog.new()
	notice_dialog.title = "TOBI & BREU ONLINE"
	add_child(notice_dialog)

func _add_menu_button(parent: VBoxContainer, heading: String, detail: String, action: Callable, primary := false) -> void:
	var button := Button.new()
	var available_width := get_viewport_rect().size.x
	var mobile_ui := OS.has_feature("mobile") or available_width < 900.0
	button.custom_minimum_size = Vector2(minf(520.0, available_width * (0.90 if mobile_ui else 0.84)), 76 if mobile_ui else 68)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	button.text = heading + "\n" + detail
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.add_theme_font_size_override("font_size", 16 if primary else 14)
	button.add_theme_color_override("font_color", Color("f4eddb"))
	button.add_theme_color_override("font_hover_color", Color("fff8e8"))
	var normal := StyleBoxTexture.new()
	normal.texture = UI_BUTTON_TEXTURE
	normal.texture_margin_left = 24.0
	normal.texture_margin_right = 24.0
	normal.texture_margin_top = 18.0
	normal.texture_margin_bottom = 18.0
	normal.modulate_color = Color("b79a5b") if primary else Color("8caa98")
	button.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate() as StyleBoxTexture
	hover.modulate_color = Color("f0d49b")
	button.add_theme_stylebox_override("hover", hover)
	var pressed := normal.duplicate() as StyleBoxTexture
	pressed.modulate_color = Color("d7b06d")
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", hover)
	button.pressed.connect(action)
	parent.add_child(button)

func _start_story() -> void:
	get_tree().change_scene_to_file(STORY_SCENE)

func _show_coop_info() -> void:
	_show_notice("História cooperativa", "A aventura será compartilhada por até 4 jogadores. A campanha atual será preservada. O servidor gratuito e a sincronização da história ainda precisam ser configurados.")

func _show_multiplayer_info() -> void:
	_show_notice("Multiplayer", "As salas privadas e os convites de amigos fazem parte do Tobi e Breu Online. A conexão multiplayer ainda não está ativa nesta versão.")

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
		update_status_label.text = "AUTO • " + message
