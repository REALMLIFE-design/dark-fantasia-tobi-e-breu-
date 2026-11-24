extends Control

@onready var status_label: Label = $CenterContainer/Content/Status

func _ready() -> void:
	status_label.text = UpdateManager.get_status()
	if not UpdateManager.status_changed.is_connected(_on_update_status_changed):
		UpdateManager.status_changed.connect(_on_update_status_changed)

	# A verificação de rede roda em segundo plano. O menu e o jogo não podem
	# esperar até 30 segundos pelo manifesto ou pelo download de uma atualização.
	UpdateManager.check_for_updates()
	await get_tree().process_frame
	var error := get_tree().change_scene_to_file("res://scenes/menu.tscn")
	if error != OK:
		push_error("Não foi possível abrir o menu principal: %s" % error)

func _on_update_status_changed(message: String) -> void:
	if is_instance_valid(status_label):
		status_label.text = message
