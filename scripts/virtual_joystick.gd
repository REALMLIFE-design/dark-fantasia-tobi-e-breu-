extends Control

const RADIUS := 61.0
const KNOB_RADIUS := 25.0
var pointer_id := -1
var axis := Vector2.ZERO
var mouse_active := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and pointer_id == -1:
			pointer_id = event.index
			_update_axis(event.position)
		elif not event.pressed and event.index == pointer_id:
			pointer_id = -1
			_set_axis(Vector2.ZERO)
	elif event is InputEventScreenDrag and event.index == pointer_id:
		_update_axis(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		mouse_active = event.pressed
		if mouse_active: _update_axis(event.position)
		else: _set_axis(Vector2.ZERO)
	elif event is InputEventMouseMotion and mouse_active:
		_update_axis(event.position)

func _update_axis(local_position: Vector2) -> void:
	var offset := local_position - size * 0.5
	_set_axis(offset.limit_length(RADIUS) / RADIUS)

func _set_axis(value: Vector2) -> void:
	axis = value.limit_length(1.0)
	_set_action("move_left", maxf(0.0, -axis.x))
	_set_action("move_right", maxf(0.0, axis.x))
	_set_action("move_forward", maxf(0.0, -axis.y))
	_set_action("move_back", maxf(0.0, axis.y))
	queue_redraw()

func _set_action(action: String, strength: float) -> void:
	if strength > 0.08:
		Input.action_press(action, strength)
	else:
		Input.action_release(action)

func _draw() -> void:
	var center := size * 0.5
	draw_circle(center, RADIUS + 8.0, Color(0.035, 0.045, 0.055, 0.38))
	draw_arc(center, RADIUS, 0.0, TAU, 48, Color(0.83, 0.76, 0.61, 0.78), 3.0, true)
	draw_circle(center, RADIUS - 5.0, Color(0.18, 0.22, 0.21, 0.28))
	draw_circle(center + axis * RADIUS, KNOB_RADIUS, Color(0.78, 0.68, 0.48, 0.88))
	draw_arc(center + axis * RADIUS, KNOB_RADIUS, 0.0, TAU, 32, Color(0.98, 0.88, 0.67, 0.95), 2.0, true)

func _exit_tree() -> void:
	_set_axis(Vector2.ZERO)
