extends Control
## Front-end mobile independente. Mantém o mundo 3D intacto e abre a cena principal
## somente quando o jogador escolhe continuar ou iniciar uma partida local.

const GAME_SCENE := "res://scenes/main.tscn"
const SAVE_PATH := "user://tobi_breu_save.cfg"
const SETTINGS_PATH := "user://dark_world_settings.cfg"

const C_BG := Color("#090d13")
const C_PANEL := Color("#121923")
const C_PANEL_ALT := Color("#192331")
const C_GOLD := Color("#c5a15c")
const C_GOLD_DARK := Color("#80633d")
const C_TEXT := Color("#f1eee6")
const C_MUTED := Color("#a3adba")
const C_BLUE := Color("#789ab4")

var page := "login"
var brand_column: VBoxContainer
var panel_body: VBoxContainer
var page_title: Label
var status_label: Label
var room_code_input: LineEdit
var volume_slider: HSlider


func _ready() -> void:
	_build_shell()
	_show_login()
	get_viewport().size_changed.connect(_layout_for_size)
	_layout_for_size()


func _build_shell() -> void:
	var background := ColorRect.new()
	background.color = C_BG
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var accent := ColorRect.new()
	accent.color = C_GOLD_DARK
	accent.position = Vector2(0, 0)
	accent.size = Vector2(5, 720)
	accent.anchor_bottom = 1.0
	accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(accent)

	var margins := MarginContainer.new()
	margins.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margins.add_theme_constant_override("margin_left", 34)
	margins.add_theme_constant_override("margin_right", 34)
	margins.add_theme_constant_override("margin_top", 24)
	margins.add_theme_constant_override("margin_bottom", 24)
	add_child(margins)

	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 18)
	margins.add_child(outer)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	outer.add_child(header)
	var header_title := _label("DARK WORLD", 17, C_TEXT, true)
	header.add_child(header_title)
	var header_subtitle := _label("A LENDA DE TOBI E BREU", 10, C_GOLD)
	header.add_child(header_subtitle)
	var header_spacer := Control.new()
	header_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(header_spacer)
	var version := _label("MOBILE  •  0.12.0", 10, C_MUTED)
	header.add_child(version)

	var content := HBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 24)
	outer.add_child(content)

	brand_column = VBoxContainer.new()
	brand_column.custom_minimum_size = Vector2(330, 0)
	brand_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	brand_column.add_theme_constant_override("separation", 14)
	content.add_child(brand_column)
	brand_column.add_child(_label("UMA JORNADA\nNAS SOMBRAS", 31, C_TEXT, true))
	brand_column.add_child(_gold_rule(82))
	brand_column.add_child(_label("Explore terras esquecidas.\nEnfrente criaturas antigas.\nDescubra o segredo de Breu.", 15, C_MUTED))
	var brand_spacer := Control.new()
	brand_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	brand_column.add_child(brand_spacer)
	brand_column.add_child(_label("UM RPG DE AÇÃO E FANTASIA\nFEITO PARA JOGAR NO CELULAR", 10, C_GOLD))

	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _panel_style(C_PANEL, C_GOLD_DARK, 14))
	content.add_child(card)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	card.add_child(scroll)

	var inner := MarginContainer.new()
	inner.add_theme_constant_override("margin_left", 26)
	inner.add_theme_constant_override("margin_right", 26)
	inner.add_theme_constant_override("margin_top", 22)
	inner.add_theme_constant_override("margin_bottom", 22)
	inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(inner)

	panel_body = VBoxContainer.new()
	panel_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel_body.add_theme_constant_override("separation", 12)
	inner.add_child(panel_body)


func _layout_for_size() -> void:
	if brand_column:
		brand_column.visible = get_viewport_rect().size.x >= 900.0


func _label(value: String, size: int = 14, color: Color = C_MUTED, bold: bool = false) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	if bold:
		label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.35))
		label.add_theme_constant_override("shadow_offset_x", 1)
		label.add_theme_constant_override("shadow_offset_y", 1)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func _gold_rule(width: float = 72.0) -> Control:
	var rule := ColorRect.new()
	rule.color = C_GOLD
	rule.custom_minimum_size = Vector2(width, 2)
	rule.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	return rule


func _panel_style(fill: Color, border: Color, radius: int = 10) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func _button(caption: String, callback: Callable, primary: bool = false) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(0, 54)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", C_BG if primary else C_TEXT)
	button.add_theme_color_override("font_hover_color", C_BG if primary else C_GOLD)
	button.add_theme_color_override("font_pressed_color", C_BG)
	var normal := _panel_style(C_GOLD if primary else C_PANEL_ALT, C_GOLD_DARK, 8)
	var hover := _panel_style(Color("#d6b775") if primary else Color("#222f3e"), C_GOLD, 8)
	var pressed := _panel_style(Color("#9f804a") if primary else Color("#0d131b"), C_GOLD_DARK, 8)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", _panel_style(C_PANEL_ALT, C_GOLD, 8))
	button.pressed.connect(callback)
	return button


func _clear_page() -> void:
	for child in panel_body.get_children():
		panel_body.remove_child(child)
		child.queue_free()
	status_label = null
	room_code_input = null


func _page_heading(kicker: String, title: String, description: String) -> void:
	panel_body.add_child(_label(kicker, 10, C_GOLD, true))
	page_title = _label(title, 25, C_TEXT, true)
	panel_body.add_child(page_title)
	panel_body.add_child(_gold_rule(64))
	panel_body.add_child(_label(description, 13, C_MUTED))


func _show_login() -> void:
	page = "login"
	_clear_page()
	_page_heading("BEM-VINDO A DARK WORLD", "Entre na sua jornada", "Entre para salvar seu progresso. Você também pode jogar localmente como visitante.")
	panel_body.add_child(_button("CONTINUAR COM GOOGLE", _on_google_login, true))
	panel_body.add_child(_button("ENTRAR COMO CONVIDADO", _start_guest_game))
	panel_body.add_child(_label("O login Google ainda depende da configuração OAuth no painel do Supabase e do redirecionamento Android.", 11, C_MUTED))
	status_label = _label("CONEXÃO ONLINE: NÃO VALIDADA", 10, C_BLUE)
	panel_body.add_child(status_label)


func _on_google_login() -> void:
	if status_label:
		status_label.text = "LOGIN GOOGLE AINDA NÃO ATIVADO — FALTA CONFIGURAR O CLIENT ID E O REDIRECT ANDROID NO SUPABASE."


func _start_guest_game() -> void:
	_start_game(false)


func _start_game(new_game: bool) -> void:
	page = "loading"
	_clear_page()
	_page_heading("PREPARANDO A AVENTURA", "Carregando Dark World", "Preparando o mundo, os personagens e seu ponto de retorno.")
	var progress := ProgressBar.new()
	progress.custom_minimum_size = Vector2(0, 14)
	progress.max_value = 100
	progress.value = 12
	progress.show_percentage = false
	panel_body.add_child(progress)
	var tween := create_tween()
	tween.tween_property(progress, "value", 100.0, 0.65)
	await get_tree().create_timer(0.72).timeout
	if new_game:
		var absolute_save := ProjectSettings.globalize_path(SAVE_PATH)
		if FileAccess.file_exists(SAVE_PATH):
			DirAccess.remove_absolute(absolute_save)
	get_tree().change_scene_to_file(GAME_SCENE)


func _show_main_menu() -> void:
	page = "menu"
	_clear_page()
	_page_heading("O MUNDO ESQUECIDO DESPERTOU", "Sua jornada continua", "Escolha como deseja explorar o mundo.")
	panel_body.add_child(_button("CONTINUAR", Callable(self, "_start_game").bind(false), true))
	panel_body.add_child(_button("NOVO JOGO", Callable(self, "_start_game").bind(true)))
	panel_body.add_child(_button("MULTIJOGADOR", _show_lobby))
	panel_body.add_child(_button("CONFIGURAÇÕES", _show_settings))
	panel_body.add_child(_button("CRÉDITOS", _show_credits))
	panel_body.add_child(_button("VOLTAR AO LOGIN", _show_login))


func _show_lobby() -> void:
	page = "lobby"
	_clear_page()
	_page_heading("AVENTURA COOPERATIVA", "Jogar com amigos", "O lobby visual está preparado para grupos de até quatro jogadores.")
	panel_body.add_child(_label("SEU GRUPO  •  1 / 4", 11, C_GOLD, true))
	for slot in ["Você — Líder", "Vaga disponível", "Vaga disponível", "Vaga disponível"]:
		var row := PanelContainer.new()
		row.add_theme_stylebox_override("panel", _panel_style(C_PANEL_ALT, Color("#303d4b"), 7))
		row.custom_minimum_size = Vector2(0, 42)
		var row_label := _label("  ◈  " + slot, 12, C_TEXT if slot.begins_with("Você") else C_MUTED)
		row.add_child(row_label)
		panel_body.add_child(row)
	panel_body.add_child(_button("CONVIDAR AMIGOS", _online_not_ready))
	panel_body.add_child(_button("CRIAR SALA", _online_not_ready, true))
	panel_body.add_child(_label("ENTRAR COM CÓDIGO", 11, C_GOLD, true))
	room_code_input = LineEdit.new()
	room_code_input.placeholder_text = "Código da sala"
	room_code_input.max_length = 12
	room_code_input.custom_minimum_size = Vector2(0, 48)
	room_code_input.add_theme_stylebox_override("normal", _panel_style(Color("#0c121a"), Color("#46515e"), 7))
	room_code_input.add_theme_color_override("font_color", C_TEXT)
	panel_body.add_child(room_code_input)
	panel_body.add_child(_button("ENTRAR NA SALA", _join_room_placeholder))
	status_label = _label("ONLINE AINDA NÃO CONECTADO — O SUPABASE JÁ TEM AS TABELAS INICIAIS, MAS A AUTENTICAÇÃO E AS REGRAS DE ENTRADA PRECISAM SER FINALIZADAS.", 10, C_BLUE)
	panel_body.add_child(status_label)
	panel_body.add_child(_button("VOLTAR AO MENU", _show_main_menu))


func _online_not_ready() -> void:
	if status_label:
		status_label.text = "AÇÃO ONLINE BLOQUEADA: A SESSÃO DE JOGADOR E A CONEXÃO MULTIPLAYER AINDA NÃO FORAM INTEGRADAS AO JOGO."


func _join_room_placeholder() -> void:
	if not room_code_input:
		return
	var code := room_code_input.text.strip_edges().to_upper()
	if code.length() < 6 or code.length() > 12:
		if status_label:
			status_label.text = "O CÓDIGO PRECISA TER ENTRE 6 E 12 CARACTERES."
		return
	if status_label:
		status_label.text = "CÓDIGO VALIDADO LOCALMENTE. A ENTRADA NA SALA DEPENDE DA CONEXÃO ONLINE."


func _show_settings() -> void:
	page = "settings"
	_clear_page()
	_page_heading("PREFERÊNCIAS", "Configurações", "Ajustes locais do jogo neste dispositivo.")
	panel_body.add_child(_label("VOLUME GERAL", 11, C_GOLD, true))
	volume_slider = HSlider.new()
	volume_slider.min_value = 0
	volume_slider.max_value = 100
	volume_slider.step = 1
	volume_slider.custom_minimum_size = Vector2(0, 34)
	volume_slider.value = _load_volume()
	volume_slider.value_changed.connect(_on_volume_changed)
	panel_body.add_child(volume_slider)
	panel_body.add_child(_label("As opções de qualidade gráfica e controles avançados serão ligadas ao menu de pausa na próxima etapa.", 12, C_MUTED))
	panel_body.add_child(_button("VOLTAR AO MENU", _show_main_menu, true))


func _load_volume() -> float:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		return float(config.get_value("audio", "master_volume", 80.0))
	return 80.0


func _on_volume_changed(value: float) -> void:
	var bus := AudioServer.get_bus_index("Master")
	if bus >= 0:
		AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(value / 100.0, 0.001)))
	var config := ConfigFile.new()
	config.set_value("audio", "master_volume", value)
	config.save(SETTINGS_PATH)


func _show_credits() -> void:
	page = "credits"
	_clear_page()
	_page_heading("SOBRE O PROJETO", "Tobi e Breu", "Dark World — A Lenda de Tobi e Breu.")
	panel_body.add_child(_label("Um RPG de ação e fantasia em desenvolvimento para Android, com exploração, combate, missões, chefes e progressão.", 14, C_TEXT))
	panel_body.add_child(_label("Desenvolvimento: REALMLIFE-design\nMotor: Godot 4.3\nVersão pública registrada: 0.12.0", 12, C_MUTED))
	panel_body.add_child(_button("VOLTAR AO MENU", _show_main_menu, true))


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		match page:
			"menu", "lobby", "settings", "credits":
				_show_main_menu()
			_:
				_show_login()
