extends Node

signal session_changed(user: Dictionary)
signal auth_message(message: String)
signal auth_failed(message: String)

const SUPABASE_URL := "https://wxzvtbfsemwmwjjhqstp.supabase.co"
const SUPABASE_PUBLISHABLE_KEY := "sb_publishable_vhP03uo8hlslL44Nv0o0kA_4Wkp59yL"

var access_token := ""
var refresh_token := ""
var user_data: Dictionary = {}
var session_expires_at := 0
var _refresh_in_flight := false

func _process(_delta: float) -> void:
	if not refresh_token.is_empty() and not _refresh_in_flight and not access_token.is_empty():
		if session_expires_at > 0 and Time.get_unix_time_from_system() >= session_expires_at - 180:
			refresh_session()

func is_authenticated() -> bool:
	return not access_token.is_empty()

func get_access_token() -> String:
	return access_token

func get_user() -> Dictionary:
	return user_data.duplicate(true)

func sign_up(email: String, password: String) -> void:
	var clean_email := email.strip_edges().to_lower()
	if not _valid_email(clean_email):
		auth_failed.emit("Digite um e-mail válido.")
		return
	if password.length() < 8:
		auth_failed.emit("A senha precisa ter pelo menos 8 caracteres.")
		return
	_request_auth("sign_up", "/auth/v1/signup", {"email": clean_email, "password": password})

func sign_in(email: String, password: String) -> void:
	var clean_email := email.strip_edges().to_lower()
	if not _valid_email(clean_email) or password.is_empty():
		auth_failed.emit("Informe seu e-mail e sua senha.")
		return
	_request_auth("sign_in", "/auth/v1/token?grant_type=password", {"email": clean_email, "password": password})

func refresh_session() -> void:
	if refresh_token.is_empty() or _refresh_in_flight:
		return
	_refresh_in_flight = true
	_request_auth("refresh", "/auth/v1/token?grant_type=refresh_token", {"refresh_token": refresh_token})

func sign_out() -> void:
	var old_token := access_token
	_clear_session()
	if not old_token.is_empty():
		var request := HTTPRequest.new()
		add_child(request)
		request.request_completed.connect(func(_result: int, _code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
			request.queue_free()
		)
		var headers := PackedStringArray([
			"apikey: " + SUPABASE_PUBLISHABLE_KEY,
			"Authorization: Bearer " + old_token
		])
		request.request(SUPABASE_URL + "/auth/v1/logout", headers, HTTPClient.METHOD_POST)
	session_changed.emit({})

func _valid_email(value: String) -> bool:
	return value.contains("@") and value.find("@") > 0 and value.find(".", value.find("@")) > value.find("@") + 1

func _request_auth(action: String, endpoint: String, payload: Dictionary) -> void:
	var request := HTTPRequest.new()
	request.timeout = 25.0
	add_child(request)
	request.request_completed.connect(_on_request_completed.bind(action, request))
	var headers := PackedStringArray([
		"apikey: " + SUPABASE_PUBLISHABLE_KEY,
		"Content-Type: application/json"
	])
	var error := request.request(SUPABASE_URL + endpoint, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
	if error != OK:
		request.queue_free()
		if action == "refresh":
			_refresh_in_flight = false
		auth_failed.emit("Não foi possível iniciar a conexão. Verifique sua internet e tente novamente.")

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, action: String, request: HTTPRequest) -> void:
	if is_instance_valid(request):
		request.queue_free()
	if action == "refresh":
		_refresh_in_flight = false
	var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
	var data: Dictionary = parsed if parsed is Dictionary else {}
	if result != HTTPRequest.RESULT_SUCCESS:
		if action == "refresh":
			_clear_session()
			session_changed.emit({})
		auth_failed.emit("A conexão com o serviço de conta falhou. Tente novamente.")
		return
	if response_code < 200 or response_code >= 300:
		var message := str(data.get("msg", data.get("message", data.get("error_description", data.get("error", "Não foi possível entrar.")))))
		if action == "refresh":
			_clear_session()
			session_changed.emit({})
		auth_failed.emit(message)
		return
	if data.has("access_token"):
		_accept_session(data)
		return
	if action == "sign_up":
		auth_message.emit("Conta criada! Confira seu e-mail e confirme o cadastro antes de entrar.")
	else:
		auth_failed.emit("O serviço respondeu sem criar uma sessão. Confira seu e-mail e senha.")

func _accept_session(data: Dictionary) -> void:
	access_token = str(data.get("access_token", ""))
	refresh_token = str(data.get("refresh_token", ""))
	var expires_in := int(data.get("expires_in", 3600))
	session_expires_at = int(Time.get_unix_time_from_system()) + expires_in
	var raw_user: Variant = data.get("user", {})
	user_data = raw_user if raw_user is Dictionary else {}
	_refresh_in_flight = false
	session_changed.emit(user_data.duplicate(true))

func _clear_session() -> void:
	access_token = ""
	refresh_token = ""
	session_expires_at = 0
	user_data.clear()
	_refresh_in_flight = false
