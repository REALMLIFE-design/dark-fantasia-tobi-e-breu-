extends Control

const STORY_SCENE := "res://scenes/main.tscn"
const FRIENDS_LOBBY_SCENE := "res://scenes/friends_lobby.tscn"
const SETTINGS_PATH := "user://tobi_breu_menu_settings.cfg"
const MAX_ADVENTURE_PLAYERS := 4

var status_label: Label
var notice_dialog: AcceptDialog
var settings_dialog: AcceptDialog
var master_volume_slider: HSlider
var fullscreen_toggle: CheckButton

func _ready() -> void:
	_build_menu()
	_load_menu_settings()
	print("TOBI_BREU_BOOT_READY")

func _build_menu() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = Color("101a1b")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var glow := ColorRect.new()
	glow.color = Color(0.12, 0.20, 0.18, 0.32)
	glow.anchor_left = 0.0
	glow.anchor_top = 0.0
	glow.anchor_right = 0.48
	glow.anchor_bottom = 1.0
	background.add_child(glow)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var layout := VBoxContainer.new()
	layout.custom_minimum_size = Vector2(560, 0)
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
	title.add_theme_font_size_override("font_size", 48)
	layout.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "DARK WORLD  •  ESCOLHA COMO JOGAR"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override("font_color", Color("a9b5a9"))
	subtitle.add_theme_font_size_override("font_size", 13)
	layout.add_child(subtitle)

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 8
	layout.add_child(spacer)

	_add_menu_button(layout, "MODO HISTÓRIA", "Continue sua jornada solo", _start_story, true)
	_add_menu_button(layout, "HISTÓRIA COOPERATIVA", "Prepare uma aventura com até 4 jogadores", _open_friends_lobby)
	_add_menu_button(layout, "MULTIPLAYER", "Jogue com amigos em uma sala", _open_friends_lobby)
	_add_menu_button(layout, "AMIGOS  •  LOBBY", "Ver grupo, convites e salas", _open_friends_lobby)
	_add_menu_button(layout, "CONFIGURAÇÕES", "Áudio e tela", _show_settings)
	_add_menu_button(layout, "CONTROLES", "Como jogar com Tobi e Breu", _show_controls)

	var footer := Label.new()
	footer.text = "A campanha original continua sendo a base da aventura.\nOnline: login falso não é usado; conexão multiplayer ainda não está ativa."
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_color_override("font_color", Color("788984"))
	footer.add_theme_font_size_override("font_size", 12)
	layout.add_child(footer)
	_add_menu_button(layout, "SAIR DO JOGO", "Fechar Dark World", _quit_game)

	notice_dialog = AcceptDialog.new()
	notice_dialog.title = "TOBI & BREU"
	add_child(notice_dialog)
	_build_settings_dialog()

func _add_menu_button(parent: VBoxContainer, heading: String, detail: String, action: Callable, primary := false) -> void:
	var button := Button.new()
	button.custom_minimum_size = Vector2(520, 56)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.text = heading + "\n" + detail
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.add_theme_font_size_override("font_size", 16 if primary else 14)
	button.add_theme_color_override("font_color", Color("f4eddb"))
	button.add_theme_color_override("font_hover_color", Color("fff8e8"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("34463f") if primary else Color("202e2d")
	normal.border_color = Color("b79a5b") if primary else Color("52665d")
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(8)
	normal.content_margin_left = 16
	normal.content_margin_right = 16
	normal.content_margin_top = 6
	normal.content_margin_bottom = 6
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("40584c") if primary else Color("2b3d39")
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.pressed.connect(action)
	parent.add_child(button)

func _start_story() -> void:
	get_tree().change_scene_to_file(STORY_SCENE)

func _open_friends_lobby() -> void:
	get_tree().change_scene_to_file(FRIENDS_LOBBY_SCENE)

func _build_settings_dialog() -> void:
	settings_dialog = AcceptDialog.new()
	settings_dialog.title = "CONFIGURAÇÕES"
	settings_dialog.dialog_text = "Ajuste o áudio e a exibição do jogo."
	settings_dialog.min_size = Vector2i(460, 260)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 14)
	settings_dialog.add_child(stack)

	var volume_label := Label.new()
	volume_label.text = "VOLUME GERAL"
	stack.add_child(volume_label)
	master_volume_slider = HSlider.new()
	master_volume_slider.min_value = 0.0
	master_volume_slider.max_value = 1.0
	master_volume_slider.step = 0.05
	master_volume_slider.value = 0.8
	master_volume_slider.value_changed.connect(_on_volume_changed)
	stack.add_child(master_volume_slider)

	fullscreen_toggle = CheckButton.new()
	fullscreen_toggle.text = "Tela cheia"
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	stack.add_child(fullscreen_toggle)
	add_child(settings_dialog)
	settings_dialog.confirmed.connect(_save_menu_settings)

func _show_settings() -> void:
	settings_dialog.popup_centered()

func _on_volume_changed(value: float) -> void:
	var master_bus := AudioServer.get_bus_index("Master")
	if master_bus >= 0:
		AudioServer.set_bus_volume_db(master_bus, linear_to_db(maxf(value, 0.001)))
	_save_menu_settings()

func _on_fullscreen_toggled(enabled: bool) -> void:
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	_save_menu_settings()

func _load_menu_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	var volume := clampf(float(config.get_value("audio", "master_volume", 0.8)), 0.0, 1.0)
	master_volume_slider.value = volume
	_on_volume_changed(volume)
	var fullscreen := bool(config.get_value("display", "fullscreen", false))
	fullscreen_toggle.button_pressed = fullscreen
	_on_fullscreen_toggled(fullscreen)

func _save_menu_settings() -> void:
	if not is_instance_valid(master_volume_slider) or not is_instance_valid(fullscreen_toggle):
		return
	var config := ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume_slider.value)
	config.set_value("display", "fullscreen", fullscreen_toggle.button_pressed)
	config.save(SETTINGS_PATH)

func _show_controls() -> void:
	_show_notice("Controles da aventura", "Mover: WASD ou setas\nAtacar: J\nInteragir: E\nPular: Espaço\nEsquiva: Q\nUsar poção: H\nMelhorar espada: U\n\nNo celular, os controles de toque dependem da interface mobile da build.")

func _quit_game() -> void:
	get_tree().quit()

func _show_notice(dialog_title: String, message: String) -> void:
	notice_dialog.title = dialog_title
	notice_dialog.dialog_text = message
	notice_dialog.popup_centered()
