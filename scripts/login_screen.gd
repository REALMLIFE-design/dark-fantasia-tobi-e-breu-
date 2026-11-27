extends Control

const MENU_SCENE := "res://scenes/menu.tscn"
# Set this to the Google OAuth Web Client ID after configuring the provider in Supabase.
# Never put a private client secret in the game.
const GOOGLE_WEB_CLIENT_ID := ""

var notice: AcceptDialog
var email_input: LineEdit
var password_input: LineEdit
var username_input: LineEdit
var password_visible := false

func _ready() -> void:
	_build_screen()
	print("TOBI_BREU_LOGIN_SCREEN_READY")
	print("TOBI_BREU_BOOT_READY")

func _build_screen() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var art := TextureRect.new()
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.texture = load("res://assets/ui/dark_world_key_art.svg")
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(art)
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.015, 0.035, 0.045, 0.52)
	add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	var viewport_size := get_viewport_rect().size
	var panel_width := minf(430.0, maxf(280.0, viewport_size.x - 32.0))
	panel.custom_minimum_size = Vector2(panel_width, 0)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _panel_style())
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(panel_width, maxf(260.0, viewport_size.y - 32.0))
	scroll.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	scroll.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	center.add_child(scroll)
	scroll.add_child(panel)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 14)
	stack.add_theme_constant_override("margin_left", 24)
	stack.add_theme_constant_override("margin_right", 24)
	stack.add_theme_constant_override("margin_top", 22)
	stack.add_theme_constant_override("margin_bottom", 22)
	panel.add_child(stack)
	var eyebrow := _label("UMA NOVA JORNADA COMEÇA", 12, Color("b9d8c5"))
	stack.add_child(eyebrow)
	var title := _label("TOBI  &  BREU", 36, Color("f4e6c8"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stack.add_child(title)
	var subtitle := _label("Entre para salvar sua aventura e encontrar amigos.", 14, Color("c4d1c9"))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stack.add_child(subtitle)
	username_input = LineEdit.new()
	username_input.placeholder_text = "Nome de aventureiro (para criar conta)"
	username_input.custom_minimum_size.y = 46
	stack.add_child(username_input)
	email_input = LineEdit.new()
	email_input.placeholder_text = "Seu e-mail"
	email_input.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_EMAIL_ADDRESS
	email_input.custom_minimum_size.y = 46
	stack.add_child(email_input)
	password_input = LineEdit.new()
	password_input.placeholder_text = "Senha (mínimo 6 caracteres)"
	password_input.secret = true
	password_input.custom_minimum_size.y = 46
	password_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var password_row := HBoxContainer.new()
	password_row.add_theme_constant_override("separation", 8)
	password_row.add_child(password_input)
	var password_toggle := Button.new()
	password_toggle.text = "MOSTRAR"
	password_toggle.custom_minimum_size = Vector2(92, 46)
	password_toggle.pressed.connect(_toggle_password_visibility.bind(password_toggle))
	password_row.add_child(password_toggle)
	stack.add_child(password_row)
	var login_button := Button.new()
	login_button.text = "ENTRAR COM E-MAIL"
	login_button.custom_minimum_size = Vector2(0, 52)
	login_button.pressed.connect(_on_email_login)
	stack.add_child(login_button)
	var signup_button := Button.new()
	signup_button.text = "CRIAR CONTA"
	signup_button.custom_minimum_size = Vector2(0, 52)
	signup_button.pressed.connect(_on_email_signup)
	stack.add_child(signup_button)
	var recovery_button := Button.new()
	recovery_button.text = "ESQUECI MINHA SENHA"
	recovery_button.custom_minimum_size = Vector2(0, 46)
	recovery_button.pressed.connect(_on_password_recovery)
	stack.add_child(recovery_button)
	var resend_button := Button.new()
	resend_button.text = "REENVIAR CONFIRMAÇÃO DO E-MAIL"
	resend_button.custom_minimum_size = Vector2(0, 46)
	resend_button.pressed.connect(_on_resend_confirmation)
	stack.add_child(resend_button)
	var google := Button.new()
	google.text = "G   Entrar com Google"
	google.custom_minimum_size = Vector2(0, 58)
	_style_button(google, Color("e9eee9"), Color("253b3b"))
	google.pressed.connect(_on_google_pressed)
	stack.add_child(google)
	var guest := Button.new()
	guest.text = "JOGAR OFFLINE COMO VISITANTE"
	guest.custom_minimum_size = Vector2(0, 52)
	_style_button(guest, Color("344f47"), Color("f2e8d1"))
	guest.pressed.connect(_continue_as_guest)
	stack.add_child(guest)
	var note := _label("O acesso Google ainda precisa ser configurado para esta versão. O modo visitante mantém a campanha local.", 11, Color("c4c8b9"))
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stack.add_child(note)
	notice = AcceptDialog.new()
	notice.title = "CONTA GOOGLE"
	add_child(notice)

func _toggle_password_visibility(button: Button) -> void:
	password_visible = not password_visible
	password_input.secret = not password_visible
	button.text = "OCULTAR" if password_visible else "MOSTRAR"

func _on_email_login() -> void:
	if email_input.text.strip_edges().is_empty() or password_input.text.is_empty():
		_show_notice("Digite seu e-mail e sua senha.")
		return
	var result: Dictionary = await SupabaseClient.sign_in(email_input.text, password_input.text)
	_show_auth_result(result)

func _on_email_signup() -> void:
	var clean_username := username_input.text.strip_edges()
	if email_input.text.strip_edges().is_empty() or password_input.text.length() < 6 or clean_username.is_empty() or clean_username.length() > 24:
		_show_notice("Preencha e-mail, nome de aventureiro (até 24 caracteres) e uma senha com pelo menos 6 caracteres.")
		return
	var result: Dictionary = await SupabaseClient.sign_up(email_input.text, password_input.text, username_input.text)
	_show_auth_result(result)

func _on_password_recovery() -> void:
	if email_input.text.strip_edges().is_empty():
		_show_notice("Digite o e-mail da sua conta no campo acima.")
		return
	var result: Dictionary = await SupabaseClient.request_password_recovery(email_input.text)
	_show_notice(str(result.get("message", "Não foi possível solicitar a recuperação agora.")))

func _on_resend_confirmation() -> void:
	if email_input.text.strip_edges().is_empty():
		_show_notice("Digite o e-mail usado no cadastro.")
		return
	var result: Dictionary = await SupabaseClient.resend_signup_confirmation(email_input.text)
	_show_notice(str(result.get("message", "Não foi possível reenviar a confirmação agora.")))

func _show_auth_result(result: Dictionary) -> void:
	_show_notice(str(result.get("message", "Não foi possível concluir a autenticação.")))
	if result.get("ok", false) and result.get("session", false):
		await get_tree().create_timer(0.8).timeout
		get_tree().change_scene_to_file(MENU_SCENE)

func _on_google_pressed() -> void:
	if GOOGLE_WEB_CLIENT_ID.strip_edges().is_empty():
		_show_notice("O botão e a tela já estão prontos, mas a autenticação real ainda não foi ligada. Falta configurar o provedor Google no Supabase e o fluxo nativo Android. Nenhuma conta será simulada.")
		return
	_show_notice("O Client ID foi preenchido, mas o fluxo nativo de autenticação ainda precisa ser integrado e validado no Android antes de aceitar contas.")

func _continue_as_guest() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)

func _show_notice(message: String) -> void:
	notice.dialog_text = message
	notice.popup_centered()

func _label(value: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label

func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.055, 0.065, 0.93)
	style.border_color = Color("8b9d75")
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 18
	style.content_margin_bottom = 18
	return style

func _style_button(button: Button, bg: Color, fg: Color) -> void:
	button.add_theme_color_override("font_color", fg)
	button.add_theme_font_size_override("font_size", 16)
	var normal := StyleBoxFlat.new()
	normal.bg_color = bg
	normal.set_corner_radius_all(10)
	normal.content_margin_left = 16
	normal.content_margin_right = 16
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = bg.lightened(0.12)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
