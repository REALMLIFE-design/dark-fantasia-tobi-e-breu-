extends Control

const MENU_SCENE := "res://scenes/menu.tscn"
# Set this to the OAuth Web Client ID after configuring Google Identity/Firebase.
# Never put a private client secret in the game.
const GOOGLE_WEB_CLIENT_ID := ""

var notice: AcceptDialog

func _ready() -> void:
	_build_screen()
	print("TOBI_BREU_LOGIN_SCREEN_READY")

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
	panel.custom_minimum_size = Vector2(430, 0)
	panel.add_theme_stylebox_override("panel", _panel_style())
	center.add_child(panel)
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

func _on_google_pressed() -> void:
	if GOOGLE_WEB_CLIENT_ID.strip_edges().is_empty():
		_show_notice("O botão e a tela já estão prontos, mas a autenticação real ainda não foi ligada. Falta configurar o OAuth do Google/Firebase e o cliente Android. Nenhuma conta será simulada.")
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
