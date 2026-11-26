extends Control

const MENU_SCENE := "res://scenes/menu.tscn"
const MAX_PLAYERS := 4

var notice: AcceptDialog
var room_code_input: LineEdit
var room_status: Label
var slot_labels: Array[Label] = []
var active_room_id := ""
var active_room_code := ""
var room_refresh_timer: Timer
var friend_search_input: LineEdit
var friend_requests_stack: VBoxContainer

func _ready() -> void:
	_build_lobby()
	room_refresh_timer = Timer.new()
	room_refresh_timer.wait_time = 4.0
	room_refresh_timer.timeout.connect(_refresh_room_members)
	add_child(room_refresh_timer)
	if SupabaseClient.is_authenticated():
		await _load_friend_requests()
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
	friend_stack.add_child(_label("Encontre aventureiros pelo nome de usuário.", 13))
	var search_row := HBoxContainer.new()
	friend_search_input = LineEdit.new()
	friend_search_input.placeholder_text = "Nome do aventureiro"
	friend_search_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	friend_search_input.text_submitted.connect(func(_value: String): _search_and_add_friend())
	search_row.add_child(friend_search_input)
	var add_friend := Button.new()
	add_friend.text = "ADICIONAR"
	add_friend.pressed.connect(_search_and_add_friend)
	search_row.add_child(add_friend)
	friend_stack.add_child(search_row)
	var refresh_friends := Button.new()
	refresh_friends.text = "ATUALIZAR AMIGOS"
	refresh_friends.pressed.connect(_load_friend_requests)
	friend_stack.add_child(refresh_friends)
	friend_stack.add_child(_label("AMIGOS E SOLICITAÇÕES", 13, Color("e2c58c")))
	friend_requests_stack = VBoxContainer.new()
	friend_requests_stack.add_theme_constant_override("separation", 6)
	friend_stack.add_child(friend_requests_stack)

	var party := _panel("SEU GRUPO  •  ATÉ 4 JOGADORES")
	party.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	party.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_child(party)
	var party_stack := party.get_child(0) as VBoxContainer
	room_status = _label("Crie uma sala ou entre usando um código.", 12, Color("e2c58c"))
	party_stack.add_child(room_status)
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
		slot_labels.append(slot_label)
		party_stack.add_child(slot)

	var create_room := Button.new()
	create_room.text = "CRIAR SALA"
	create_room.custom_minimum_size.y = 44
	create_room.pressed.connect(_create_room)
	party_stack.add_child(create_room)
	var code_row := HBoxContainer.new()
	room_code_input = LineEdit.new()
	room_code_input.placeholder_text = "Código da sala"
	room_code_input.max_length = 12
	room_code_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	room_code_input.text_submitted.connect(func(_value: String): _join_room())
	code_row.add_child(room_code_input)
	var join_room := Button.new()
	join_room.text = "ENTRAR"
	join_room.pressed.connect(_join_room)
	code_row.add_child(join_room)
	party_stack.add_child(code_row)

	var footer_text := "Salas online usam sua conta Supabase. Amigos, convites e jogadores em movimento ainda serão conectados."
	if not SupabaseClient.is_authenticated():
		footer_text = "Entre com e-mail na tela inicial para criar ou entrar em salas online. Visitante continua no modo offline."
	root.add_child(_label(footer_text, 12, Color("e2c58c")))

	notice = AcceptDialog.new()
	notice.title = "TOBI & BREU ONLINE"
	add_child(notice)


func _search_and_add_friend() -> void:
	if not SupabaseClient.is_authenticated():
		_show_notice("Entre com sua conta para adicionar amigos.")
		return
	var search_name := friend_search_input.text.strip_edges()
	if search_name.is_empty():
		_show_notice("Digite o nome de usuário do seu amigo.")
		return
	var search_result: Dictionary = await SupabaseClient.find_profile_by_username(search_name)
	if not search_result.get("ok", false):
		_show_notice(str(search_result.get("message", "Não foi possível buscar o jogador.")))
		return
	var profiles = search_result.get("data", [])
	if not profiles is Array or profiles.is_empty():
		_show_notice("Nenhum aventureiro encontrado com esse nome.")
		return
	var target: Dictionary = profiles[0]
	var target_id := str(target.get("id", ""))
	var requests_result: Dictionary = await SupabaseClient.list_friend_requests()
	if requests_result.get("ok", false):
		var existing = requests_result.get("data", [])
		if existing is Array:
			for request in existing:
				var same_pair := (str(request.get("requester_id", "")) == SupabaseClient.user_id and str(request.get("addressee_id", "")) == target_id) or (str(request.get("requester_id", "")) == target_id and str(request.get("addressee_id", "")) == SupabaseClient.user_id)
				if same_pair and str(request.get("status", "")) in ["pending", "accepted"]:
					_show_notice("Vocês já têm uma solicitação ou amizade registrada.")
					return
	var send_result: Dictionary = await SupabaseClient.send_friend_request(target_id)
	if send_result.get("ok", false):
		_show_notice("Solicitação enviada para %s!" % str(target.get("username", "Aventureiro")))
		friend_search_input.text = ""
		await _load_friend_requests()
	else:
		_show_notice(str(send_result.get("message", "Não foi possível enviar a solicitação.")))


func _load_friend_requests() -> void:
	if not SupabaseClient.is_authenticated() or not is_instance_valid(friend_requests_stack):
		return
	for child in friend_requests_stack.get_children():
		child.queue_free()
	var result: Dictionary = await SupabaseClient.list_friend_requests()
	if not result.get("ok", false):
		friend_requests_stack.add_child(_label("Não foi possível carregar amigos agora.", 12, Color("e2c58c")))
		return
	var requests = result.get("data", [])
	var visible_count := 0
	if requests is Array:
		for request in requests:
			var request_status := str(request.get("status", ""))
			if request_status not in ["pending", "accepted"]:
				continue
			var requester_id := str(request.get("requester_id", ""))
			var addressee_id := str(request.get("addressee_id", ""))
			var other_id := addressee_id if requester_id == SupabaseClient.user_id else requester_id
			var profile_result: Dictionary = await SupabaseClient.get_profile(other_id)
			var username := "Aventureiro"
			if profile_result.get("ok", false):
				var profile_rows = profile_result.get("data", [])
				if profile_rows is Array and not profile_rows.is_empty():
					username = str(profile_rows[0].get("username", username))
			if request_status == "accepted":
				friend_requests_stack.add_child(_label("AMIGO  •  %s" % username, 12))
				visible_count += 1
			elif addressee_id == SupabaseClient.user_id:
				var request_row := HBoxContainer.new()
				var request_label := _label("PEDIDO  •  %s" % username, 12, Color("e2c58c"))
				request_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				request_row.add_child(request_label)
				var request_id := str(request.get("id", ""))
				var accept_button := Button.new()
				accept_button.text = "ACEITAR"
				accept_button.pressed.connect(func(): _respond_to_friend_request(request_id, true))
				request_row.add_child(accept_button)
				var decline_button := Button.new()
				decline_button.text = "RECUSAR"
				decline_button.pressed.connect(func(): _respond_to_friend_request(request_id, false))
				request_row.add_child(decline_button)
				friend_requests_stack.add_child(request_row)
				visible_count += 1
			else:
				friend_requests_stack.add_child(_label("CONVITE ENVIADO  •  %s" % username, 12))
				visible_count += 1
	if visible_count == 0:
		friend_requests_stack.add_child(_label("Ainda não há amigos ou solicitações.", 12, Color("aebbb0")))


func _respond_to_friend_request(request_id: String, accept: bool) -> void:
	var result: Dictionary = await SupabaseClient.respond_friend_request(request_id, accept)
	if not result.get("ok", false):
		_show_notice(str(result.get("message", "Não foi possível atualizar a solicitação.")))
		return
	_show_notice("Amizade aceita!" if accept else "Solicitação recusada.")
	await _load_friend_requests()


func _create_room() -> void:
	if not SupabaseClient.is_authenticated():
		_show_notice("Entre com sua conta para criar uma sala online. O modo visitante continua disponível para a campanha offline.")
		return
	room_status.text = "CRIANDO SALA..."
	var result: Dictionary = await SupabaseClient.create_game_room("Floresta Corrompida", MAX_PLAYERS)
	if not result.get("ok", false):
		_show_notice(str(result.get("message", "Não foi possível criar a sala.")))
		room_status.text = "Não foi possível criar a sala."
		return
	_set_active_room(result.get("room", {}))


func _join_room() -> void:
	if not SupabaseClient.is_authenticated():
		_show_notice("Entre com sua conta para entrar em uma sala online.")
		return
	var code := room_code_input.text.strip_edges().to_upper()
	if code.length() < 6:
		_show_notice("Digite um código de sala com pelo menos 6 caracteres.")
		return
	room_status.text = "PROCURANDO SALA..."
	var result: Dictionary = await SupabaseClient.join_room_by_code(code)
	if not result.get("ok", false):
		_show_notice(str(result.get("message", "Não foi possível entrar na sala.")))
		room_status.text = "Não foi possível entrar na sala."
		return
	_set_active_room(result.get("room", {}))


func _set_active_room(room: Dictionary) -> void:
	active_room_id = str(room.get("room_id", ""))
	active_room_code = str(room.get("room_code", ""))
	if active_room_id.is_empty():
		_show_notice("O servidor não retornou um identificador válido para a sala.")
		return
	room_status.text = "SALA %s • aguardando jogadores..." % active_room_code
	room_code_input.text = active_room_code
	room_refresh_timer.start()
	await _refresh_room_members()
	_show_notice("Sala criada/aberta! Compartilhe este código com seus amigos: %s" % active_room_code)


func _refresh_room_members() -> void:
	if active_room_id.is_empty() or not SupabaseClient.is_authenticated():
		return
	var result: Dictionary = await SupabaseClient.list_room_members(active_room_id)
	if not result.get("ok", false):
		room_status.text = "Sala %s • não foi possível atualizar os jogadores." % active_room_code
		return
	var members = result.get("data", [])
	if not members is Array:
		return
	for i in range(MAX_PLAYERS):
		if i < members.size():
			var member: Dictionary = members[i]
			var profile = member.get("profiles", {})
			var username := str(profile.get("username", "Aventureiro")) if profile is Dictionary else "Aventureiro"
			slot_labels[i].text = "JOGADOR %d  •  %s" % [i + 1, username]
		else:
			slot_labels[i].text = "JOGADOR %d  •  VAGA LIVRE" % (i + 1)
	room_status.text = "SALA %s  •  %d/%d JOGADORES" % [active_room_code, members.size(), MAX_PLAYERS]


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
	_show_notice("A lista de amigos e os convites ainda não foram conectados. As salas por código já usam o banco online.")


func _show_notice(message: String) -> void:
	notice.dialog_text = message
	notice.popup_centered()
