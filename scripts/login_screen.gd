extends Control

const MENU_SCENE := "res://scenes/menu.tscn"
const SUPABASE_PROJECT := "wxzvtbfsemwmwjjhqstp"
const GOOGLE_REDIRECT_URI := "https://wxzvtbfsemwmwjjhqstp.supabase.co/auth/v1/callback"

var notice: AcceptDialog

func _ready() -> void:
	_build_screen()
	print("DARK_WORLD_LOGIN_GATE_READY")

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
	style.bg_color = Color(0.035, 0.075, 0.09, 0.91)
	style.border_color = Color(0.58, 0.72, 0.65, 0.58)
	style.set_border_width_all(1)
	style.content_margin_left = 28
	style.content_margin_right = 28
	style.content_margin_top = 28
	style.content_margin_bottom = 28
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 13)
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
	_add_button(content, "CONTINUAR COM GOOGLE", _on_google_pressed, true)
	_add_button(content, "JOGAR COMO CONVIDADO", _enter_as_guest)
	var hint := Label.new()
	hint.text = "O acesso de convidado preserva a campanha local. O login Google será ativado após cadastrar as credenciais OAuth do jogo."
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 10)
	hint.add_theme_color_override("font_color", Color("9aadaa"))
	content.add_child(hint)
	notice = AcceptDialog.new()
	notice.title = "Configuração do acesso Google"
	add_child(notice)

func _add_button(parent: VBoxContainer, caption: String, action: Callable, primary := false) -> void:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size.y = 54
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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

func _on_google_pressed() -> void:
	notice.dialog_text = "O projeto Supabase já está criado, mas o provedor Google ainda precisa de credenciais OAuth do proprietário.\n\nNo Google Cloud Console, crie um OAuth Client ID do tipo Web e configure este URI de redirecionamento:\n\n%s\n\nDepois cadastre o Client ID e o Client Secret em Supabase > Authentication > Sign In / Providers > Google. Também será necessário habilitar o retorno seguro ao aplicativo Android. Nenhum segredo deve ser colocado no APK." % GOOGLE_REDIRECT_URI
	notice.popup_centered(Vector2i(620, 360))

func _enter_as_guest() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
