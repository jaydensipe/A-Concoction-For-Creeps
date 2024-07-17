extends Window

var _x_buffer: int = 30
var _y_buffer: int = 45
@onready var _prev_mouse_input_mode: Input.MouseMode = Input.mouse_mode

func _ready() -> void:
	window_input.connect(func(event: InputEvent) -> void:
		if (event is InputEventKey):
			if (event.is_action_pressed(&"debug")):
				visible = false
				_prev_mouse_input_mode = Input.mouse_mode

				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	)

	focus_exited.connect(func() -> void:
		Input.set_mouse_mode(_prev_mouse_input_mode)
	)

	close_requested.connect(func() -> void:
		visible = false
	)

func _process(_delta: float) -> void:
	position.x = clampi(position.x, _x_buffer, (DisplayServer.window_get_size_with_decorations().x - get_size_with_decorations().x) - _x_buffer)
	position.y = clampi(position.y, _y_buffer, (DisplayServer.window_get_size_with_decorations().y - get_size_with_decorations().y) - _y_buffer)
