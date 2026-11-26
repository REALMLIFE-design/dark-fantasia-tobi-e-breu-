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
	return await _auth_request("signup", {
		"email": email.strip_edges(),
		"password": password,
		"data": {"name": username.strip_edges()}
	})

func sign_out() -> void:
	if is_authenticated():
		var headers := _headers()
		headers.append("Authorization: Bearer " + access_token)
		_http.request(SUPABASE_URL + "/auth/v1/logout", headers, HTTPClient.METHOD_POST)
	access_token = ""
	refresh_token = ""
	user_id = ""
	user_email = ""
	session_changed.emit("")

func _auth_request(endpoint: String, payload: Dictionary) -> Dictionary:
	var headers := _headers()
	var error := _http.request(
		SUPABASE_URL + "/auth/v1/" + endpoint,
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(payload)
	)
	if error != OK:
		return {"ok": false, "message": "Não foi possível iniciar a conexão com o servidor."}
	var response: Array = await _http.request_completed
	var response_code: int = response[1]
	var body_text := response[3].get_string_from_utf8()
	var parsed = JSON.parse_string(body_text)
	var data: Dictionary = parsed if parsed is Dictionary else {}
	if response_code < 200 or response_code >= 300:
		return {"ok": false, "message": _error_message(data, response_code)}
	if data.has("access_token"):
		access_token = str(data.get("access_token", ""))
		refresh_token = str(data.get("refresh_token", ""))
		var user: Dictionary = data.get("user", {})
		user_id = str(user.get("id", ""))
		user_email = str(user.get("email", ""))
		session_changed.emit(user_id)
		return {"ok": true, "session": true, "message": "Login realizado com sucesso."}
	var needs_confirmation := data.has("id") and not data.has("access_token")
	if needs_confirmation:
		return {"ok": true, "session": false, "message": "Conta criada! Confirme seu e-mail e depois entre."}
	return {"ok": false, "message": "O servidor respondeu, mas não retornou uma sessão válida."}

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
