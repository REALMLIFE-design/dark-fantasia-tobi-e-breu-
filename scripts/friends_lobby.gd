extends Control

const MENU_SCENE := "res://scenes/menu.tscn"

var notice: AcceptDialog
var status_label: Label
var friends_body: Label
var requests_body: Label
var requests_content: VBoxContainer
var friend_username_input: LineEdit
var room_code_input: LineEdit
var room_status_label: Label
var invite_button: Button
var create_room_button: Button
var join_room_button: Button
var account_button: Button

func _ready() -> void:
	_build_lobby()
	SupabaseAuth.session_changed.connect(_on_session_changed)
	SupabaseAuth.rpc_completed.connect(_on_rpc_completed)
	SupabaseAuth.rpc_failed.connect(_on_rpc_failed)
	_refresh_auth_state()
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

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	scroll.add_child(margin)
	var layout := VBoxContainer.new()
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_theme_constant_override("separation", 12)
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
	account_button = Button.new()
	account_button.text = "ENTRAR"
	account_button.custom_minimum_size = Vector2(90, 46)
	account_button.pressed.connect(_on_account_button_pressed)
	header.add_child(account_button)

	var subtitle := Label.new()
	subtitle.text = "Convide seus amigos para explorar Azulan • até 4 jogadores por sala"
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.add_theme_color_override("font_color", Color("b5c4c2"))
	layout.add_child(subtitle)

	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_color_override("font_color", Color("d8b77c"))
	status_label.add_theme_font_size_override("font_size", 12)
	layout.add_child(status_label)

	var columns := HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 14)
	layout.add_child(columns)
	var friends_panel := _make_panel("SEUS AMIGOS", "Entre na sua conta para carregar sua lista.")
	friends_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	friends_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_child(friends_panel)
	friends_body = friends_panel.get_node("PanelContent/PanelBody") as Label
	var requests_panel := _make_panel("PEDIDOS DE AMIZADE", "Carregando pedidos...")
	requests_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	requests_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_child(requests_panel)
	requests_content = requests_panel.get_node("PanelContent") as VBoxContainer
	requests_body = requests_panel.get_node("PanelContent/PanelBody") as Label

	var invite_row := HBoxContainer.new()
	invite_row.add_theme_constant_override("separation", 8)
	layout.add_child(invite_row)
	friend_username_input = LineEdit.new()
	friend_username_input.placeholder_text = "Nome do aventureiro"
	friend_username_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	friend_username_input.custom_minimum_size.y = 48
	friend_username_input.editable = false
	invite_row.add_child(friend_username_input)
	invite_button = Button.new()
	invite_button.text = "ADICIONAR AMIGO"
	invite_button.custom_minimum_size = Vector2(160, 48)
	invite_button.disabled = true
	invite_button.pressed.connect(_send_friend_request)
	invite_row.add_child(invite_button)

	var room_row := HBoxContainer.new()
	room_row.add_theme_constant_override("separation", 8)
	layout.add_child(room_row)
	create_room_button = Button.new()
	create_room_button.text = "CRIAR SALA PRIVADA"
	create_room_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	create_room_button.custom_minimum_size.y = 50
	create_room_button.disabled = true
	create_room_button.pressed.connect(_create_room)
	room_row.add_child(create_room_button)
	room_code_input = LineEdit.new()
	room_code_input.placeholder_text = "Código da sala"
	room_code_input.custom_minimum_size = Vector2(140, 50)
	room_code_input.editable = false
	room_row.add_child(room_code_input)
	join_room_button = Button.new()
	join_room_button.text = "ENTRAR"
	join_room_button.custom_minimum_size = Vector2(90, 50)
	join_room_button.disabled = true
	join_room_button.pressed.connect(_join_room)
	room_row.add_child(join_room_button)

	room_status_label = Label.new()
	room_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	room_status_label.add_theme_color_override("font_color", Color("e4d0a6"))
	layout.add_child(room_status_label)

	var footer := Label.new()
	footer.text = "Amizades e criação/entrada em salas usam as funções protegidas do Supabase. A partida multiplayer em tempo real ainda será conectada; por enquanto, a sessão fica ativa enquanto o jogo estiver aberto."
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
	content.name = "PanelContent"
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
	empty.name = "PanelBody"
	empty.text = empty_text
	empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	empty.size_flags_vertical = Control.SIZE_EXPAND_FILL
	empty.add_theme_color_override("font_color", Color("b5c4c2"))
	content.add_child(empty)
	return panel

func _refresh_auth_state() -> void:
	var authenticated := SupabaseAuth.is_authenticated()
	account_button.text = "SAIR" if authenticated else "ENTRAR"
	friend_username_input.editable = authenticated
	room_code_input.editable = authenticated
	invite_button.disabled = not authenticated
	create_room_button.disabled = not authenticated
	join_room_button.disabled = not authenticated
	if authenticated:
		status_label.text = "CONECTADO • Conta autenticada pelo Supabase."
		_load_friends()
		_load_friend_requests()
	else:
		status_label.text = "MODO CONVIDADO • Entre com e-mail e senha para usar amigos e salas."
		friends_body.text = "Sua lista aparecerá aqui depois do login."
		requests_body.text = "Entre na conta para ver pedidos pendentes."
		room_status_label.text = ""

func _on_session_changed(_user: Dictionary) -> void:
	_refresh_auth_state()

func _load_friends() -> void:
	SupabaseAuth.rpc_call("dark_world_list_friends", {}, "list_friends")

func _load_friend_requests() -> void:
	SupabaseAuth.rpc_call("dark_world_list_friend_requests", {}, "list_requests")

func _send_friend_request() -> void:
	var username := friend_username_input.text.strip_edges()
	if username.is_empty():
		status_label.text = "Digite o nome do aventureiro que deseja adicionar."
		return
	SupabaseAuth.rpc_call("dark_world_send_friend_request", {"p_username": username}, "send_friend")

func _create_room() -> void:
	SupabaseAuth.rpc_call("dark_world_create_room", {"p_chapter": "A Lenda de Tobi e Breu"}, "create_room")

func _join_room() -> void:
	var code := room_code_input.text.strip_edges().to_upper()
	if code.is_empty():
		room_status_label.text = "Digite o código da sala."
		return
	SupabaseAuth.rpc_call("dark_world_join_room", {"p_room_code": code}, "join_room")

func _on_rpc_completed(tag: String, data: Variant) -> void:
	if tag == "list_friends":
		var rows: Array = data if data is Array else []
		if rows.is_empty():
			friends_body.text = "Ainda não há amigos adicionados."
		else:
			var names: PackedStringArray = []
			for row in rows:
				if row is Dictionary:
					names.append("• " + str(row.get("username", "Aventureiro")))
			friends_body.text = "\n".join(names)
	elif tag == "send_friend":
		status_label.text = "Pedido de amizade enviado!"
		friend_username_input.clear()
		_load_friend_requests()
	elif tag == "create_room":
		var rows: Array = data if data is Array else []
		if not rows.is_empty() and rows[0] is Dictionary:
			var room: Dictionary = rows[0]
			room_status_label.text = "SALA CRIADA • Código: %s • Compartilhe com seus amigos." % str(room.get("room_code", ""))
		else:
			room_status_label.text = "Sala criada, mas o código não veio na resposta."
	elif tag == "list_requests":
		var rows: Array = data if data is Array else []
		_render_friend_requests(rows)
	elif tag == "respond_friend":
		status_label.text = "Pedido de amizade atualizado."
		_load_friends()
		_load_friend_requests()
	elif tag == "join_room":
		var rows: Array = data if data is Array else []
		if not rows.is_empty() and rows[0] is Dictionary:
			var room: Dictionary = rows[0]
			room_status_label.text = "VOCÊ ENTROU NA SALA • %s • Jogadores: %s/%s" % [str(room.get("room_code", "")), str(room.get("player_count", "?")), str(room.get("max_players", "4"))]
		else:
			room_status_label.text = "Entrada confirmada. A sincronização da partida será conectada em seguida."

func _render_friend_requests(rows: Array) -> void:
	for child in requests_content.get_children():
		if child.name.begins_with("FriendRequest_"):
			child.queue_free()
	var incoming: PackedStringArray = []
	var outgoing: PackedStringArray = []
	var incoming_count := 0
	for row in rows:
		if not row is Dictionary:
			continue
		var username := str(row.get("username", "Aventureiro"))
		var direction := str(row.get("direction", ""))
		if direction == "received":
			incoming_count += 1
			incoming.append(username)
			var request_id := str(row.get("request_id", ""))
			var request_row := HBoxContainer.new()
			request_row.name = "FriendRequest_%d" % incoming_count
			request_row.add_theme_constant_override("separation", 5)
			var name_label := Label.new()
			name_label.text = username
			name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			name_label.add_theme_color_override("font_color", Color("d7e0d8"))
			request_row.add_child(name_label)
			var accept_button := Button.new()
			accept_button.text = "ACEITAR"
			accept_button.pressed.connect(_respond_friend_request.bind(request_id, true))
			request_row.add_child(accept_button)
			var decline_button := Button.new()
			decline_button.text = "RECUSAR"
			decline_button.pressed.connect(_respond_friend_request.bind(request_id, false))
			request_row.add_child(decline_button)
			requests_content.add_child(request_row)
		elif direction == "sent":
			outgoing.append(username)
	var summary := ""
	if incoming.is_empty():
		summary = "Nenhum pedido recebido."
	else:
		summary = "Pedidos recebidos: " + ", ".join(incoming)
	if not outgoing.is_empty():
		summary += "\nEnviados: " + ", ".join(outgoing)
	requests_body.text = summary

func _respond_friend_request(request_id: String, accept: bool) -> void:
	SupabaseAuth.rpc_call("dark_world_respond_friend_request", {"p_request_id": request_id, "p_accept": accept}, "respond_friend")

func _on_rpc_failed(tag: String, message: String) -> void:
	if tag == "list_friends":
		friends_body.text = "Não foi possível carregar a lista agora."
	elif tag == "list_requests":
		requests_body.text = "Não foi possível carregar os pedidos agora."
	elif tag == "create_room" or tag == "join_room":
		room_status_label.text = message
	else:
		status_label.text = message

func _on_account_button_pressed() -> void:
	if SupabaseAuth.is_authenticated():
		SupabaseAuth.sign_out()
	get_tree().change_scene_to_file("res://scenes/login.tscn")

func _go_back() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
