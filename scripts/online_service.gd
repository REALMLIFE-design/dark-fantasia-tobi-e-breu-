extends Node
## Cliente REST mínimo do Supabase para o front-end Godot.
## Usa somente a publishable key no cliente; nunca inclui service_role.

signal session_changed(signed_in: bool, player_id: String)

const SUPABASE_URL := "https://wxzvtbfsemwmwjjhqstp.supabase.co"
const SUPABASE_PUBLISHABLE_KEY := "sb_publishable_vhP03uo8hlslL44Nv0o0kA_4Wkp59yL"
const SESSION_PATH := "user://dark_world_session.cfg"

var access_token := ""
var refresh_token := ""
var player_id := ""
var username := ""
var _http: HTTPRequest


func _ready() -> void:
	_http = HTTPRequest.new()
	_http.timeout = 20.0
	_http.max_redirects = 4
	add_child(_http)
	_load_session()


func is_authenticated() -> bool:
	return not access_token.is_empty() and not player_id.is_empty()


func _load_session() -> void:
	var config := ConfigFile.new()
	if config.load(SESSION_PATH) == OK:
		access_token = str(config.get_value("session", "access_token", ""))
		refresh_token = str(config.get_value("session", "refresh_token", ""))
		player_id = str(config.get_value("session", "player_id", ""))
		username = str(config.get_value("session", "username", ""))


func _save_session() -> void:
	var config := ConfigFile.new()
	config.set_value("session", "access_token", access_token)
	config.set_value("session", "refresh_token", refresh_token)
	config.set_value("session", "player_id", player_id)
	config.set_value("session", "username", username)
	config.save(SESSION_PATH)


func _clear_session() -> void:
	access_token = ""
	refresh_token = ""
	player_id = ""
	username = ""
	var absolute_path := ProjectSettings.globalize_path(SESSION_PATH)
	if FileAccess.file_exists(SESSION_PATH):
		DirAccess.remove_absolute(absolute_path)
	session_changed.emit(false, "")


func _request_json(method: int, endpoint: String, payload: Variant = null, authenticated: bool = true) -> Dictionary:
	var headers := PackedStringArray([
		"apikey: " + SUPABASE_PUBLISHABLE_KEY,
		"Content-Type: application/json",
		"Accept: application/json"
	])
	if authenticated and not access_token.is_empty():
		headers.append("Authorization: Bearer " + access_token)
	var body := "" if payload == null else JSON.stringify(payload)
	var request_error := _http.request(SUPABASE_URL + endpoint, headers, method, body)
	if request_error != OK:
		return {"ok": false, "error": "Não foi possível iniciar a conexão com o servidor.", "code": request_error}
	var response: Array = await _http.request_completed
	var response_code: int = int(response[1])
	var response_body: PackedByteArray = response[3]
	var response_text := response_body.get_string_from_utf8()
	var parsed: Variant = JSON.parse_string(response_text) if not response_text.is_empty() else {}
	if response_code >= 200 and response_code < 300:
		return {"ok": true, "data": parsed, "code": response_code}
	var message := "Falha na comunicação online."
	if parsed is Dictionary:
		message = str(parsed.get("msg", parsed.get("message", parsed.get("error_description", parsed.get("error", message)))))
	return {"ok": false, "error": message, "code": response_code, "data": parsed}


func sign_in_guest() -> Dictionary:
	# A sessão persistida é renovada antes de criar outra conta anônima.
	if not refresh_token.is_empty():
		var refreshed := await _request_json(
			HTTPClient.METHOD_POST,
			"/auth/v1/token?grant_type=refresh_token",
			{"refresh_token": refresh_token},
			false
		)
		if refreshed.ok:
			_store_auth_response(refreshed.data)
			return {"ok": true, "player_id": player_id, "username": username, "reused": true}
		_clear_session()

	var guest_name := "Aventureiro-%04d" % randi_range(1000, 9999)
	var created := await _request_json(
		HTTPClient.METHOD_POST,
		"/auth/v1/signup",
		{"data": {"preferred_username": guest_name, "name": guest_name}},
		false
	)
	if not created.ok:
		return {"ok": false, "error": created.error, "code": created.code}
	_store_auth_response(created.data)
	if not is_authenticated():
		return {"ok": false, "error": "O Supabase não retornou uma sessão. Verifique se o login anônimo está ativado no projeto."}
	return {"ok": true, "player_id": player_id, "username": username, "reused": false}


func _store_auth_response(data: Variant) -> void:
	if not data is Dictionary:
		return
	access_token = str(data.get("access_token", ""))
	refresh_token = str(data.get("refresh_token", ""))
	var user: Variant = data.get("user", {})
	if user is Dictionary:
		player_id = str(user.get("id", ""))
		var metadata: Variant = user.get("user_metadata", {})
		if metadata is Dictionary:
			username = str(metadata.get("preferred_username", metadata.get("name", "Aventureiro")))
	if not access_token.is_empty() and not player_id.is_empty():
		_save_session()
		session_changed.emit(true, player_id)


func create_room(chapter: String = "Floresta Corrompida") -> Dictionary:
	if not is_authenticated():
		return {"ok": false, "error": "Entre como visitante para criar uma sessão online."}
	return await _request_json(
		HTTPClient.METHOD_POST,
		"/rest/v1/rpc/dark_world_create_room",
		{"p_chapter": chapter}
	)


func join_room(room_code: String) -> Dictionary:
	if not is_authenticated():
		return {"ok": false, "error": "Entre como visitante para entrar em uma sala online."}
	return await _request_json(
		HTTPClient.METHOD_POST,
		"/rest/v1/rpc/dark_world_join_room",
		{"p_room_code": room_code.strip_edges().to_upper()}
	)


func leave_room(room_id: String) -> Dictionary:
	if not is_authenticated():
		return {"ok": false, "error": "Nenhuma sessão online ativa."}
	return await _request_json(
		HTTPClient.METHOD_POST,
		"/rest/v1/rpc/leave_game_room",
		{"p_room_id": room_id}
	)


func list_friends() -> Dictionary:
	if not is_authenticated():
		return {"ok": false, "error": "Entre como visitante para carregar seus amigos."}
	return await _request_json(HTTPClient.METHOD_POST, "/rest/v1/rpc/dark_world_list_friends", {})


func list_friend_requests() -> Dictionary:
	if not is_authenticated():
		return {"ok": false, "error": "Entre como visitante para carregar solicitações."}
	return await _request_json(HTTPClient.METHOD_POST, "/rest/v1/rpc/dark_world_list_friend_requests", {})


func send_friend_request(target_username: String) -> Dictionary:
	if not is_authenticated():
		return {"ok": false, "error": "Entre como visitante para adicionar amigos."}
	return await _request_json(
		HTTPClient.METHOD_POST,
		"/rest/v1/rpc/dark_world_send_friend_request",
		{"p_username": target_username.strip_edges()}
	)


func respond_friend_request(request_id: String, accept: bool) -> Dictionary:
	if not is_authenticated():
		return {"ok": false, "error": "Entre como visitante para responder solicitações."}
	return await _request_json(
		HTTPClient.METHOD_POST,
		"/rest/v1/rpc/dark_world_respond_friend_request",
		{"p_request_id": request_id, "p_accept": accept}
	)
