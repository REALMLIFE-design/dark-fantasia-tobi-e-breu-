extends Control

const MENU_SCENE := "res://scenes/menu.tscn"

var notice: AcceptDialog
var email_input: LineEdit
var password_input: LineEdit
var status_label: Label

func _ready() -> void:
	_build_screen()
	SupabaseAuth.session_changed.connect(_on_session_changed)
	SupabaseAuth.auth_message.connect(_on_auth_message)
	SupabaseAuth.auth_failed.connect(_on_auth_failed)
	print("DARK_WORLD_LOGIN_GATE_READY")
	if SupabaseAuth.is_authenticated():
		_enter_game()

func _build_screen() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var art := TextureRect.new()
	art.texture = load("res://assets/art/login_portal.svg")
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(art)

	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.035, 0.045, 0.48)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(minf(520.0, get_viewport_rect().size.x * 0.88), 0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.075, 0.09, 0.93)
	style.border_color = Color(0.58, 0.72, 0.65, 0.58)
	style.set_border_width_all(1)
	style.content_margin_left = 28
	style.content_margin_right = 28
	style.content_margin_top = 24
	style.content_margin_bottom = 24
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 11)
	panel.add_child(content)
	var eyebrow := Label.new()
	eyebrow.text = "REINO DE AZULAN  •  ACESSO AO JOGO"
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eyebrow.add_theme_color_override("font_color", Color("9bc8c7"))
	eyebrow.add_theme_font_size_override("font_size", 11)
	content.add_child(eyebrow)
	var title := Label.new()
	title.text = "DARK WORLD"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color("f1eee5"))
	title.add_theme_font_size_override("font_size", 36)
	content.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "A LENDA DE TOBI E BREU"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override("font_color", Color("d8b77c"))
	subtitle.add_theme_font_size_override("font_size", 15)
	content.add_child(subtitle)
	var story := Label.new()
	story.text = "Entre no reino. Encontre seus amigos. Escreva sua lenda."
	story.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story.add_theme_color_override("font_color", Color("c0ceca"))
	content.add_child(story)

	email_input = LineEdit.new()
	email_input.placeholder_text = "Seu e-mail"
	email_input.custom_minimum_size.y = 48
	email_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	email_input.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_EMAIL_ADDRESS
	content.add_child(email_input)
	password_input = LineEdit.new()
	password_input.placeholder_text = "Sua senha (mínimo 8 caracteres)"
	password_input.custom_minimum_size.y = 48
	password_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	password_input.secret = true
	content.add_child(password_input)

	_add_button(content, "ENTRAR COM E-MAIL", _on_sign_in_pressed, true)
	_add_button(content, "CRIAR CONTA", _on_sign_up_pressed)
	_add_button(content, "JOGAR COMO CONVIDADO", _enter_as_guest)
	_add_button(content, "GOOGLE • DEPOIS", _on_google_pressed, false, true)

	status_label = Label.new()
	status_label.text = "Entre com sua conta ou continue como convidado. A confirmação de e-mail pode ser necessária."
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_size_override("font_size", 11)
	status_label.add_theme_color_override("font_color", Color("b9c9c3"))
	content.add_child(status_label)

	notice = AcceptDialog.new()
	notice.title = "DARK WORLD"
	add_child(notice)

func _add_button(parent: VBoxContainer, caption: String, action: Callable, primary := false, disabled := false) -> void:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size.y = 50
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.disabled = disabled
	button.add_theme_color_override("font_color", Color("fff7e8"))
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.16, 0.30, 0.33, 0.95) if primary else Color(0.07, 0.14, 0.17, 0.95)
	box.border_color = Color("d8b77c") if primary else Color("55777a")
	box.set_border_width_all(1)
	box.content_margin_left = 16
	box.content_margin_right = 16
	box.set_corner_radius_all(3)
	button.add_theme_stylebox_override("normal", box)
	var hover := box.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.22, 0.39, 0.40, 1.0)
	button.add_theme_stylebox_override("hover", hover)
	button.pressed.connect(action)
	parent.add_child(button)

func _on_sign_in_pressed() -> void:
	status_label.text = "Conectando à sua conta..."
	SupabaseAuth.sign_in(email_input.text, password_input.text)

func _on_sign_up_pressed() -> void:
	status_label.text = "Criando sua conta..."
	SupabaseAuth.sign_up(email_input.text, password_input.text)

func _on_session_changed(user: Dictionary) -> void:
	if user.is_empty():
		return
	status_label.text = "Login concluído. Abrindo o reino..."
	_enter_game()

func _on_auth_message(message: String) -> void:
	status_label.text = message

func _on_auth_failed(message: String) -> void:
	status_label.text = message

func _on_google_pressed() -> void:
	notice.dialog_text = "O login Google ficará para uma etapa posterior. Agora estamos priorizando cadastro e entrada por e-mail e senha no Supabase."
	notice.popup_centered()

func _enter_as_guest() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)

func _enter_game() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
