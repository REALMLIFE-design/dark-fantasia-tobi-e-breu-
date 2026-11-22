extends Node

signal status_changed(message: String)

const GAME_VERSION := "0.12.2"
const MANIFEST_URL := "https://github.com/REALMLIFE-design/dark-fantasia-tobi-e-breu-/releases/latest/download/update-manifest.json"
const PENDING_PACK_PATH := "user://updates/pending.pck"
const TEMP_PACK_PATH := "user://updates/pending.download"
const PENDING_VERSION_PATH := "user://updates/pending_version.txt"
const INSTALLED_VERSION_PATH := "user://updates/installed_version.txt"
const UPDATE_DIR := "user://updates/"
const TRUSTED_DOWNLOAD_PREFIX := "https://github.com/REALMLIFE-design/dark-fantasia-tobi-e-breu-/releases/download/"

var status_message := "Atualizações: verificando..."

func _enter_tree() -> void:
	_apply_pending_patch()

func _ready() -> void:
	call_deferred("_check_for_updates")

func get_status() -> String:
	return status_message

func _set_status(message: String) -> void:
	status_message = message
	status_changed.emit(message)
	print("[UpdateManager] ", message)

func _apply_pending_patch() -> void:
	if not FileAccess.file_exists(PENDING_PACK_PATH):
		return
	var loaded := ProjectSettings.load_resource_pack(PENDING_PACK_PATH, true)
	if not loaded:
		_set_status("Atualização baixada, mas não pôde ser aplicada. Mantive seus dados.")
		return
	var version := GAME_VERSION
	if FileAccess.file_exists(PENDING_VERSION_PATH):
		var version_file := FileAccess.open(PENDING_VERSION_PATH, FileAccess.READ)
		if version_file:
			version = version_file.get_as_text().strip_edges()
			version_file.close()
	_write_text(INSTALLED_VERSION_PATH, version)
	_set_status("Jogo atualizado (" + version.left(8) + "). Boa aventura!")

func _check_for_updates() -> void:
	_set_status("Atualizações: verificando...")
	var manifest_response: Dictionary = await _http_get(MANIFEST_URL)
	if not manifest_response.get("ok", false):
		_set_status("Atualizações indisponíveis no momento; você pode jogar normalmente.")
		return
	var manifest_body: PackedByteArray = manifest_response["body"]
	var parsed: Variant = JSON.parse_string(manifest_body.get_string_from_utf8())
	if typeof(parsed) != TYPE_DICTIONARY:
		_set_status("Manifesto de atualização inválido; nenhuma alteração foi aplicada.")
		return
	var manifest: Dictionary = parsed
	var remote_version := str(manifest.get("version", ""))
	var download_url := str(manifest.get("download_url", ""))
	var expected_hash := str(manifest.get("sha256", "")).to_lower()
	if remote_version.is_empty() or not download_url.begins_with(TRUSTED_DOWNLOAD_PREFIX) or expected_hash.length() != 64:
		_set_status("Manifesto de atualização incompleto ou não confiável.")
		return
	if remote_version == _get_installed_version():
		_set_status("Jogo atualizado. Nenhuma atualização nova.")
		return
	_set_status("Nova atualização encontrada. Baixando arquivos...")
	var pack_response: Dictionary = await _http_get(download_url)
	if not pack_response.get("ok", false):
		_set_status("Não consegui baixar a atualização. Tente novamente mais tarde.")
		return
	var pack_bytes: PackedByteArray = pack_response["body"]
	var hash_context := HashingContext.new()
	if hash_context.start(HashingContext.HASH_SHA256) != OK:
		_set_status("Não foi possível verificar a atualização.")
		return
	hash_context.update(pack_bytes)
	if hash_context.finish().hex_encode().to_lower() != expected_hash:
		_set_status("A verificação da atualização falhou. O arquivo foi descartado.")
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(UPDATE_DIR))
	var output := FileAccess.open(TEMP_PACK_PATH, FileAccess.WRITE)
	if output == null:
		_set_status("Sem espaço ou permissão para guardar a atualização.")
		return
	output.store_buffer(pack_bytes)
	output.close()
	var pending_absolute := ProjectSettings.globalize_path(PENDING_PACK_PATH)
	var temp_absolute := ProjectSettings.globalize_path(TEMP_PACK_PATH)
	if FileAccess.file_exists(PENDING_PACK_PATH):
		DirAccess.remove_absolute(pending_absolute)
	if DirAccess.rename_absolute(temp_absolute, pending_absolute) != OK:
		_set_status("Não consegui preparar a atualização. Seus arquivos atuais continuam intactos.")
		return
	if not _write_text(PENDING_VERSION_PATH, remote_version):
		_set_status("A atualização foi baixada, mas não consegui registrar sua versão.")
		return
	_set_status("Atualização baixada! Feche e abra o jogo para aplicar. Seu progresso será preservado.")

func _get_installed_version() -> String:
	if not FileAccess.file_exists(INSTALLED_VERSION_PATH):
		return GAME_VERSION
	var file := FileAccess.open(INSTALLED_VERSION_PATH, FileAccess.READ)
	if file == null:
		return GAME_VERSION
	var value := file.get_as_text().strip_edges()
	file.close()
	return value if not value.is_empty() else GAME_VERSION

func _write_text(path: String, value: String) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(value)
	file.close()
	return true

func _http_get(url: String) -> Dictionary:
	var request_node := HTTPRequest.new()
	request_node.timeout = 30.0
	add_child(request_node)
	var request_error := request_node.request(url)
	if request_error != OK:
		request_node.queue_free()
		return {"ok": false}
	var response: Array = await request_node.request_completed
	request_node.queue_free()
	if response.size() < 4:
		return {"ok": false}
	var result_code: int = response[0]
	var response_code: int = response[1]
	var body: PackedByteArray = response[3]
	return {"ok": result_code == HTTPRequest.RESULT_SUCCESS and response_code >= 200 and response_code < 300, "body": body}
