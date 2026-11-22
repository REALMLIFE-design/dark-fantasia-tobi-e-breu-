extends Control

@onready var status_label: Label = $CenterContainer/Content/Status

func _ready() -> void:
	status_label.text = UpdateManager.get_status()
	UpdateManager.status_changed.connect(_on_update_status_changed)
	await UpdateManager.check_for_updates()
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_update_status_changed(message: String) -> void:
	if is_instance_valid(status_label):
		status_label.text = message
