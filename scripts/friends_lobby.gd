extends Control

const MENU_SCENE := "res://scenes/menu.tscn"
const MAX_PLAYERS := 4
var notice: AcceptDialog

func _ready() -> void:
	_build_lobby()
	print("TOBI_BREU_LOBBY_SCREEN_READY")

func _build_lobby() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var art := TextureRect.new()
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.texture = load("res://assets/ui/lobby_art.svg")
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(art)
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.01, 0.025, 0.035, 0.62)
	add_child(shade)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 30)
	margin.add_theme_constant_override("margin_right", 30)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 14)
	margin.add_child(root)
	var top := HBoxContainer.new()
	root.add_child(top)
	var title := Label.new()
	title.text = "SALÃO DOS AVENTUREIROS"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("f1dfb8"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	var back := Button.new()
	back.text = "VOLTAR"
	back.pressed.connect(func(): get_tree().change_scene_to_file(MENU_SCENE))
	top.add_child(back)
	var subtitle := Label.new()
	subtitle.text = "Monte seu grupo e prepare-se para explorar Dark World."
	subtitle.add_theme_color_override("font_color", Color("c4d4ca"))
	root.add_child(subtitle)
	var columns := HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 16)
	root.add_child(columns)
	var friends := _panel("AMIGOS")
	friends.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	friends.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_child(friends)
	var friend_stack := friends.get_child(0) as VBoxContainer
	friend_stack.add_child(_label("Sua lista de amigos aparecerá aqui.", 15))
	friend_stack.add_child(_label("Status: serviço de amigos ainda não conectado.", 12, Color("e2c58c")))
	var invite := Button.new()
	invite.text = "CONVIDAR AMIGO"
	invite.pressed.connect(_show_backend_notice)
	friend_stack.add_child(invite)
	var party := _panel("SEU GRUPO  •  ATÉ 4 JOGADORES")
	party.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	party.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_child(party)
	var party_stack := party.get_child(0) as VBoxContainer
	for i in range(MAX_PLAYERS):
		var slot := PanelContainer.new()
		var slot_style := StyleBoxFlat.new()
		slot_style.bg_color = Color(0.08, 0.14, 0.15, 0.86)
		slot_style.border_color = Color("62786b")
		slot_style.set_border_width_all(1)
		slot_style.set_corner_radius_all(8)
		slot.add_theme_stylebox_override("panel", slot_style)
		var slot_label := _label("JOGADOR %d  •  VAGA LIVRE" % (i + 1), 13)
		slot.add_child(slot_label)
		party_stack.add_child(slot)
	var room_row := HBoxContainer.new()
	var create_room := Button.new()
	create_room.text = "CRIAR SALA"
	create_room.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	create_room.pressed.connect(_show_backend_notice)
	room_row.add_child(create_room)
	var join_room := Button.new()
	join_room.text = "ENTRAR COM CÓDIGO"
	join_room.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	join_room.pressed.connect(_show_backend_notice)
	room_row.add_child(join_room)
	party_stack.add_child(room_row)
	var footer := _label("ONLINE INDISPONÍVEL NESTA BUILD — nenhum amigo ou jogador fictício será exibido.", 12, Color("e2c58c"))
	root.add_child(footer)
	notice = AcceptDialog.new()
	notice.title = "TOBI & BREU ONLINE"
	add_child(notice)

func _panel(heading: String) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.055, 0.065, 0.92)
	style.border_color = Color("8b9d75")
	style.set_border_width_all(2)
	style.set_corner_radius_all(14)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", style)
	var stack := VBoxContainer.new()
	stack.add_child(_label(heading, 18, Color("f1dfb8")))
	panel.add_child(stack)
	return panel

func _label(value: String, size: int, color := Color("d5e0d7")) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func _show_backend_notice() -> void:
	notice.dialog_text = "A interface do lobby está pronta. Para convites, salas e lista de amigos em tempo real, ainda precisamos conectar um servidor multiplayer e o banco de dados de contas."
	notice.popup_centered()
