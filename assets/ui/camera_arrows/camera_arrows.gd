extends Control

@onready var up_arrow: Button = $PanelContainer/MarginContainer/VBoxContainer/UpArrow
@onready var down_arrow: Button = $PanelContainer/MarginContainer/VBoxContainer/DownArrow
@onready var left_arrow: Button = $PanelContainer/MarginContainer/HBoxContainer/LeftArrow
@onready var right_arrow: Button = $PanelContainer/MarginContainer/HBoxContainer/RightArrow

func _ready() -> void:
	_camera_button_functionality()

	GlobalEventBus.camera_changed_state.connect(func(new_camera_state: GameStateResource.CAMERA_STATE) -> void:
		match (new_camera_state):
			GameStateResource.CAMERA_STATE.FORWARD:
				up_arrow.modulate = Color(0.0, 0.0, 0.0, 0.0)
				up_arrow.disabled = true
				down_arrow.modulate = Color(1.0, 1.0, 1.0, 1.0)
				down_arrow.disabled = false
				left_arrow.modulate = Color(0.0, 0.0, 0.0, 0.0)
				left_arrow.disabled = true
				right_arrow.modulate = Color(0.0, 0.0, 0.0, 0.0)
				right_arrow.disabled = true
			GameStateResource.CAMERA_STATE.PLAYSPACE:
				up_arrow.modulate = Color(1.0, 1.0, 1.0, 1.0)
				up_arrow.disabled = false
				down_arrow.modulate = Color(0.0, 0.0, 0.0, 0.0)
				down_arrow.disabled = true
				left_arrow.modulate = Color(1.0, 1.0, 1.0, 1.0)
				left_arrow.disabled = false
				right_arrow.modulate = Color(0.0, 0.0, 0.0, 0.0)
				right_arrow.disabled = true
			GameStateResource.CAMERA_STATE.BOOK:
				up_arrow.modulate = Color(0.0, 0.0, 0.0, 0.0)
				up_arrow.disabled = true
				down_arrow.modulate = Color(1.0, 1.0, 1.0, 1.0)
				down_arrow.disabled = false
				left_arrow.modulate = Color(0.0, 0.0, 0.0, 0.0)
				left_arrow.disabled = true
				right_arrow.modulate = Color(1.0, 1.0, 1.0, 1.0)
				right_arrow.disabled = false
			_:
				up_arrow.modulate = Color(0.0, 0.0, 0.0, 0.0)
				up_arrow.disabled = true
				down_arrow.modulate = Color(0.0, 0.0, 0.0, 0.0)
				down_arrow.disabled = true
				left_arrow.modulate = Color(0.0, 0.0, 0.0, 0.0)
				left_arrow.disabled = true
				right_arrow.modulate = Color(0.0, 0.0, 0.0, 0.0)
				right_arrow.disabled = true
	)

func _camera_button_functionality() -> void:
	up_arrow.pressed.connect(func() -> void:
		GlobalEventBus.signal_request_camera_change(GameStateResource.CAMERA_STATE.FORWARD)
	)
	down_arrow.pressed.connect(func() -> void:
		GlobalEventBus.signal_request_camera_change(GameStateResource.CAMERA_STATE.PLAYSPACE)
	)
	left_arrow.pressed.connect(func() -> void:
		GlobalEventBus.signal_request_camera_change(GameStateResource.CAMERA_STATE.BOOK)
	)
	right_arrow.pressed.connect(func() -> void:
		GlobalEventBus.signal_request_camera_change(GameStateResource.CAMERA_STATE.PLAYSPACE)
	)
