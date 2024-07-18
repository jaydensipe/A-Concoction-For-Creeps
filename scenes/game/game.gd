extends Node3D

@onready var main_camera: Camera3D = get_viewport().get_camera_3d()
@onready var camera_animations: AnimationPlayer = $Camera/CameraAnimations
var _camera_state: CAMERA_STATE = CAMERA_STATE.FORWARD
enum CAMERA_STATE { FORWARD, PLAYSPACE, BOOK }

func _physics_process(delta: float) -> void:
	_camera_controls()

func _camera_controls() -> void:
	if (Input.is_action_just_pressed(&"move_forward")):
		if (_camera_state == CAMERA_STATE.FORWARD or _camera_state == CAMERA_STATE.BOOK): return

		camera_animations.play_backwards(&"look_at_playspace")
		_switch_camera_state(CAMERA_STATE.FORWARD)

	if (Input.is_action_just_pressed(&"move_backward") or Input.is_action_just_pressed(&"jump")):
		if (_camera_state == CAMERA_STATE.BOOK):
			camera_animations.play_backwards(&"look_at_book_from_playspace")
		else:
			if (_camera_state != CAMERA_STATE.PLAYSPACE):
				camera_animations.play(&"look_at_playspace")
		_switch_camera_state(CAMERA_STATE.PLAYSPACE)

	if (Input.is_action_just_pressed(&"move_left")):
		if (_camera_state == CAMERA_STATE.PLAYSPACE and _camera_state != CAMERA_STATE.BOOK):
			camera_animations.play(&"look_at_book_from_playspace")
			_switch_camera_state(CAMERA_STATE.BOOK)

	if (Input.is_action_just_pressed(&"move_right")):
		if (_camera_state == CAMERA_STATE.BOOK):
			camera_animations.play_backwards(&"look_at_book_from_playspace")
			_switch_camera_state(CAMERA_STATE.PLAYSPACE)

	if (Input.is_action_just_pressed(&"mouse_primary_fire")):
		pass

func _switch_camera_state(camera_state: CAMERA_STATE) -> void:
	_camera_state = camera_state
