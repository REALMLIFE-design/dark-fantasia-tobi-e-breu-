extends Control

const MENU_SCENE := "res://scenes/menu.tscn"

var notice: AcceptDialog

func _ready() -> void:
	_build_lobby()
	print("DARK_WORLD_FRIENDS_LOBBY_READY")

func _build_lobby() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var art := TextureRect.new()
	art.texture = load("res://assets/art/friends_lobby.svg")
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(art)
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.035, 0.045, 0.70)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	add_child(margin)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	margin.add_child(layout)

	var header := HBoxContainer.new()
	layout.add_child(header)
	var back := Button.new()
	back.text = "‹  VOLTAR"
	back.custom_minimum_size = Vector2(110, 46)
	back.pressed.connect(_go_back)
	header.add_child(back)
	var heading := Label.new()
	heading.text = "  LOBBY DE AVENTUREIROS"
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	heading.add_theme_color_override("font_color", Color("f1eee5"))
	heading.add_theme_font_size_override("font_size", 22)
	header.add_child(heading)

	var subtitle := Label.new()
	subtitle.text = "Convide seus amigos para explorar Azulan • até 4 jogadores por sala"
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.add_theme_color_override("font_color", Color("b5c4c2"))
	layout.add_child(subtitle)

	var status := Label.new()
	status.text = "MODO CONVIDADO  •  Entre com sua conta Dark World usando e-mail e senha para acessar a lista de amigos."
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.add_theme_color_override("font_color", Color("d8b77c"))
	status.add_theme_font_size_override("font_size", 12)
	layout.add_child(status)

	var columns := HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 14)
	layout.add_child(columns)
	var friends_panel := _make_panel("SEUS AMIGOS", "Sua lista aparecerá aqui depois do login.")
	friends_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	friends_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_child(friends_panel)
	var requests_panel := _make_panel("PEDIDOS DE AMIZADE", "Convites recebidos e enviados aparecerão aqui.")
	requests_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	requests_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_child(requests_panel)

	var invite_row := HBoxContainer.new()
	invite_row.add_theme_constant_override("separation", 8)
	layout.add_child(invite_row)
	var friend_code := LineEdit.new()
	friend_code.placeholder_text = "Digite o nome do aventureiro"
	friend_code.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	friend_code.custom_minimum_size.y = 48
	friend_code.editable = false
	invite_row.add_child(friend_code)
	var invite := Button.new()
	invite.text = "ADICIONAR AMIGO"
	invite.custom_minimum_size = Vector2(160, 48)
	invite.disabled = true
	invite_row.add_child(invite)

	var room_row := HBoxContainer.new()
	room_row.add_theme_constant_override("separation", 8)
	layout.add_child(room_row)
	var create_room := Button.new()
	create_room.text = "CRIAR SALA PRIVADA"
	create_room.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	create_room.custom_minimum_size.y = 50
	create_room.disabled = true
	room_row.add_child(create_room)
	var join_room := Button.new()
	join_room.text = "ENTRAR COM CÓDIGO"
	join_room.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	join_room.custom_minimum_size.y = 50
	join_room.disabled = true
	room_row.add_child(join_room)

	var footer := Label.new()
	footer.text = "A conexão multiplayer ainda não está ativa nesta versão. As salas e amizades já têm regras seguras no Supabase; as ações serão liberadas após o login por e-mail e senha."
	footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	footer.add_theme_color_override("font_color", Color("9aadaa"))
	footer.add_theme_font_size_override("font_size", 10)
	layout.add_child(footer)
	notice = AcceptDialog.new()
	notice.title = "DARK WORLD • MULTIPLAYER"
	add_child(notice)

func _make_panel(title_text: String, empty_text: String) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.07, 0.085, 0.88)
	style.border_color = Color(0.36, 0.62, 0.62, 0.55)
	style.set_border_width_all(1)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", style)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)
	var heading := Label.new()
	heading.text = title_text
	heading.add_theme_color_override("font_color", Color("d8b77c"))
	heading.add_theme_font_size_override("font_size", 14)
	content.add_child(heading)
	var rule := ColorRect.new()
	rule.color = Color(0.36, 0.62, 0.62, 0.6)
	rule.custom_minimum_size.y = 1
	content.add_child(rule)
	var empty := Label.new()
	empty.text = empty_text
	empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	empty.size_flags_vertical = Control.SIZE_EXPAND_FILL
	empty.add_theme_color_override("font_color", Color("b5c4c2"))
	content.add_child(empty)
	return panel

func _go_back() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
