extends Node
## Cliente mínimo do Supabase Auth para Godot 4.
## Usa somente a publishable key (segura para cliente com RLS); nunca incluir service_role.
signal session_changed(user_id: String)

const SUPABASE_URL := "https://wxzvtbfsemwmwjjhqstp.supabase.co"
const SUPABASE_PUBLISHABLE_KEY := "sb_publishable_vhP03uo8hlslL44Nv0o0kA_4Wkp59yL"

var access_token := ""
var refresh_token := ""
var user_id := ""
var user_email := ""
var _http: HTTPRequest
var _request_busy := false
var _token_expires_at := 0

func _ready() -> void:
	_http = HTTPRequest.new()
	_http.timeout = 20.0
	add_child(_http)

func is_authenticated() -> bool:
	return not access_token.is_empty() and not user_id.is_empty()

func sign_in(email: String, password: String) -> Dictionary:
	return await _auth_request("token?grant_type=password", {
		"email": email.strip_edges(),
		"password": password
	})

func sign_up(email: String, password: String, username: String) -> Dictionary:
	var clean_username := username.strip_edges()
	if clean_username.is_empty() or clean_username.length() > 24:
		return {"ok": false, "message": "O nome de aventureiro deve ter entre 1 e 24 caracteres."}
	return await _auth_request("signup", {
		"email": email.strip_edges(),
		"password": password,
		"data": {"name": clean_username}
	})

func sign_out() -> void:
	while _request_busy:
		await get_tree().process_frame
	if is_authenticated():
		_request_busy = true
		var headers := _headers()
		headers.append("Authorization: Bearer " + access_token)
		var error := _http.request(SUPABASE_URL + "/auth/v1/logout", headers, HTTPClient.METHOD_POST)
		if error == OK:
			await _http.request_completed
		_request_busy = false
	access_token = ""
	refresh_token = ""
	user_id = ""
	user_email = ""
	_token_expires_at = 0
	session_changed.emit("")

func _auth_request(endpoint: String, payload: Dictionary) -> Dictionary:
	if _request_busy:
		return {"ok": false, "message": "Aguarde a requisição atual terminar."}
	_request_busy = true
	var headers := _headers()
	var error := _http.request(
		SUPABASE_URL + "/auth/v1/" + endpoint,
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(payload)
	)
	if error != OK:
		_request_busy = false
		return {"ok": false, "message": "Não foi possível iniciar a conexão com o servidor."}
	var response: Array = await _http.request_completed
	_request_busy = false
	var response_code: int = response[1]
	var body_text: String = response[3].get_string_from_utf8()
	var parsed = JSON.parse_string(body_text)
	var data: Dictionary = parsed if parsed is Dictionary else {}
	if response_code < 200 or response_code >= 300:
		return {"ok": false, "message": _error_message(data, response_code)}
	if endpoint == "recover":
		return {"ok": true, "session": false, "message": "Se esse e-mail estiver cadastrado, enviaremos as instruções de recuperação. Confira sua caixa de entrada e o spam."}
	if endpoint == "resend":
		return {"ok": true, "session": false, "message": "Se a conta existir e precisar de confirmação, enviaremos outro e-mail. Confira também o spam."}
	if data.has("access_token"):
		access_token = str(data.get("access_token", ""))
		refresh_token = str(data.get("refresh_token", ""))
		_token_expires_at = int(Time.get_unix_time_from_system()) + int(data.get("expires_in", 3600))
		var user: Dictionary = data.get("user", {})
		user_id = str(user.get("id", ""))
		user_email = str(user.get("email", ""))
		session_changed.emit(user_id)
		return {"ok": true, "session": true, "message": "Login realizado com sucesso."}
	var needs_confirmation := data.has("id") and not data.has("access_token")
	if needs_confirmation:
		return {"ok": true, "session": false, "message": "Conta criada! Confirme seu e-mail e depois entre."}
	return {"ok": false, "message": "O servidor respondeu, mas não retornou uma sessão válida."}

func refresh_session() -> Dictionary:
	if refresh_token.is_empty():
		return {"ok": false, "message": "A sessão expirou. Entre novamente."}
	return await _auth_request("token?grant_type=refresh_token", {"refresh_token": refresh_token})

func request_password_recovery(email: String) -> Dictionary:
	var clean_email := email.strip_edges()
	if clean_email.is_empty():
		return {"ok": false, "message": "Digite seu e-mail para recuperar a senha."}
	return await _auth_request("recover", {"email": clean_email})

func resend_signup_confirmation(email: String) -> Dictionary:
	var clean_email := email.strip_edges()
	if clean_email.is_empty():
		return {"ok": false, "message": "Digite seu e-mail para reenviar a confirmação."}
	return await _auth_request("resend", {"type": "signup", "email": clean_email})


func create_game_room(chapter: String = "Floresta Corrompida", max_players: int = 4) -> Dictionary:
	var result := await _rest_request("rpc/create_game_room", HTTPClient.METHOD_POST, {
		"p_chapter": chapter,
		"p_max_players": clampi(max_players, 1, 4)
	})
	if not result.get("ok", false):
		return result
	var rows = result.get("data", [])
	if rows is Array and not rows.is_empty():
		return {"ok": true, "room": rows[0]}
	return {"ok": false, "message": "O servidor não retornou os dados da sala."}


func join_room_by_code(room_code: String) -> Dictionary:
	var result := await _rest_request("rpc/join_room_by_code", HTTPClient.METHOD_POST, {
		"p_room_code": room_code.strip_edges().to_upper()
	})
	if not result.get("ok", false):
		return result
	var rows = result.get("data", [])
	if rows is Array and not rows.is_empty():
		return {"ok": true, "room": rows[0]}
	return {"ok": false, "message": "O servidor não retornou os dados da sala."}


func leave_game_room(room_id: String) -> Dictionary:
	if room_id.strip_edges().is_empty():
		return {"ok": false, "message": "Sala inválida."}
	return await _rest_request("rpc/leave_game_room", HTTPClient.METHOD_POST, {"p_room_id": room_id})


func list_room_members(room_id: String) -> Dictionary:
	return await _rest_request("room_members?select=user_id,joined_at,profiles(username,avatar_url)&room_id=eq." + room_id + "&order=joined_at.asc", HTTPClient.METHOD_GET)


func find_profile_by_username(username: String) -> Dictionary:
	var clean_name := username.strip_edges()
	if clean_name.is_empty():
		return {"ok": false, "message": "Digite o nome do aventureiro."}
	var encoded_name := clean_name.uri_encode()
	return await _rest_request("profiles?select=id,username,avatar_url&username=ilike." + encoded_name + "&id=neq." + user_id + "&limit=5", HTTPClient.METHOD_GET)


func get_profile(profile_id: String) -> Dictionary:
	return await _rest_request("profiles?select=id,username,avatar_url&id=eq." + profile_id + "&limit=1", HTTPClient.METHOD_GET)


func send_friend_request(addressee_id: String) -> Dictionary:
	if addressee_id.is_empty() or addressee_id == user_id:
		return {"ok": false, "message": "Escolha outro jogador para adicionar."}
	return await _rest_request("friend_requests", HTTPClient.METHOD_POST, {
		"requester_id": user_id,
		"addressee_id": addressee_id,
		"status": "pending"
	})


func list_friend_requests() -> Dictionary:
	var endpoint := "friend_requests?select=id,requester_id,addressee_id,status,created_at,requester:profiles!friend_requests_requester_id_fkey(username,avatar_url),addressee:profiles!friend_requests_addressee_id_fkey(username,avatar_url)&or=(requester_id.eq.%s,addressee_id.eq.%s)&order=created_at.desc&limit=50" % [user_id, user_id]
	return await _rest_request(endpoint, HTTPClient.METHOD_GET)


func respond_friend_request(request_id: String, accept: bool) -> Dictionary:
	if request_id.is_empty():
		return {"ok": false, "message": "Solicitação inválida."}
	var status := "accepted" if accept else "declined"
	var endpoint := "friend_requests?id=eq." + request_id + "&addressee_id=eq." + user_id + "&status=eq.pending"
	return await _rest_request(endpoint, HTTPClient.METHOD_PATCH, {"status": status})


func _rest_request(endpoint: String, method: int, payload: Dictionary = {}) -> Dictionary:
	if not is_authenticated():
		return {"ok": false, "message": "Entre na sua conta para usar os recursos online."}
	if _token_expires_at > 0 and int(Time.get_unix_time_from_system()) >= _token_expires_at - 60:
		var refreshed := await refresh_session()
		if not refreshed.get("ok", false):
			return refreshed
	if _request_busy:
		return {"ok": false, "message": "Aguarde a requisição atual terminar."}
	_request_busy = true
	var headers := _headers()
	headers.append("Authorization: Bearer " + access_token)
	var body := "" if method == HTTPClient.METHOD_GET else JSON.stringify(payload)
	var error := _http.request(SUPABASE_URL + "/rest/v1/" + endpoint, headers, method, body)
	if error != OK:
		_request_busy = false
		return {"ok": false, "message": "Não foi possível iniciar a conexão com o servidor."}
	var response: Array = await _http.request_completed
	_request_busy = false
	var response_code: int = response[1]
	var parsed = JSON.parse_string(response[3].get_string_from_utf8())
	if response_code < 200 or response_code >= 300:
		var error_data: Dictionary = parsed if parsed is Dictionary else {}
		return {"ok": false, "message": _error_message(error_data, response_code)}
	return {"ok": true, "data": parsed}


func _headers() -> PackedStringArray:
	return PackedStringArray([
		"Content-Type: application/json",
		"apikey: " + SUPABASE_PUBLISHABLE_KEY
	])

func _error_message(data: Dictionary, status_code: int) -> String:
	var message := str(data.get("msg", data.get("message", data.get("error_description", "Erro de autenticação."))))
	if message == "Invalid login credentials":
		message = "E-mail ou senha incorretos."
	elif message == "Email not confirmed":
		message = "Confirme seu e-mail antes de entrar."
	elif message == "User already registered":
		message = "Este e-mail já possui uma conta. Tente entrar."
	return "%s (código %d)" % [message, status_code]
