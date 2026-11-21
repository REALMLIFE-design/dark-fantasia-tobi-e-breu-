extends Control

const STORY_SCENE := "res://scenes/main.tscn"
const MAX_ADVENTURE_PLAYERS := 4

var status_label: Label
var notice_dialog: AcceptDialog

func _ready() -> void:
	_build_menu()

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
	layout.add_theme_constant_override("separation", 14)
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

	notice_dialog = AcceptDialog.new()
	notice_dialog.title = "TOBI & BREU ONLINE"
	add_child(notice_dialog)

func _add_menu_button(parent: VBoxContainer, heading: String, detail: String, action: Callable, primary := false) -> void:
	var button := Button.new()
	button.custom_minimum_size = Vector2(520, 62)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.text = heading + "\n" + detail
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.add_theme_font_size_override("font_size", 17 if primary else 15)
	button.add_theme_color_override("font_color", Color("f4eddb"))
	button.add_theme_color_override("font_hover_color", Color("fff8e8"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("34463f") if primary else Color("202e2d")
	normal.border_color = Color("b79a5b") if primary else Color("52665d")
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(8)
	normal.content_margin_left = 16
	normal.content_margin_right = 16
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("40584c") if primary else Color("2b3d39")
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
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
