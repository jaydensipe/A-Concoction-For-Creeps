extends Node
class_name Camera

@onready var camera_3d: Camera3D = $Camera3D
@onready var forward_marker_3d: Marker3D = $ForwardMarker3D
@onready var play_space_marker_3d: Marker3D = $PlaySpaceMarker3D
@onready var book_marker_3d: Marker3D = $BookMarker3D
@export var camera_tween_speed: float = 0.3

func _physics_process(_delta: float) -> void:
	_camera_controls()

	GlobalEventBus.request_camera_change.connect(func(new_camera_state: GameStateResource.CAMERA_STATE) -> void:
		match(new_camera_state):
			GameStateResource.CAMERA_STATE.FORWARD:
				move_camera_forward()
			GameStateResource.CAMERA_STATE.DISABLED:
				move_camera_forward(true)
			GameStateResource.CAMERA_STATE.PLAYSPACE:
				move_camera_to_playspace()
			GameStateResource.CAMERA_STATE.BOOK:
				move_camera_to_book()
	)

func _camera_controls() -> void:
	if (GameState.game_state.camera_state == GameStateResource.CAMERA_STATE.DISABLED): return

	if (Input.is_action_just_pressed(&"move_forward")):
		move_camera_forward()

	if (Input.is_action_just_pressed(&"move_backward") or Input.is_action_just_pressed(&"jump")):
		move_camera_to_playspace()

	if (Input.is_action_just_pressed(&"move_left")):
		move_camera_to_book()

	if (Input.is_action_just_pressed(&"move_right")):
		move_camera_to_playspace()

func move_camera_forward(disable: bool = false) -> void:
	if (GameState.game_state.camera_state == GameStateResource.CAMERA_STATE.FORWARD or GameState.game_state.camera_state == GameStateResource.CAMERA_STATE.BOOK): return

	create_tween().tween_property(camera_3d, "global_transform", forward_marker_3d.global_transform, camera_tween_speed)
	_switch_camera_state(GameStateResource.CAMERA_STATE.DISABLED if disable else GameStateResource.CAMERA_STATE.FORWARD)

func move_camera_to_playspace() -> void:
	if (GameState.game_state.camera_state == GameStateResource.CAMERA_STATE.BOOK):
		create_tween().tween_property(camera_3d, "global_transform", play_space_marker_3d.global_transform, camera_tween_speed)
	else:
		if (GameState.game_state.camera_state != GameStateResource.CAMERA_STATE.PLAYSPACE):
			create_tween().tween_property(camera_3d, "global_transform", play_space_marker_3d.global_transform, camera_tween_speed)
	_switch_camera_state(GameStateResource.CAMERA_STATE.PLAYSPACE)

func move_camera_to_book() -> void:
	if (GameState.game_state.camera_state == GameStateResource.CAMERA_STATE.PLAYSPACE and GameState.game_state.camera_state != GameStateResource.CAMERA_STATE.BOOK and GameState.game_state.can_look_at_book):
		create_tween().tween_property(camera_3d, "global_transform", book_marker_3d.global_transform, camera_tween_speed)
		_switch_camera_state(GameStateResource.CAMERA_STATE.BOOK)

func _switch_camera_state(camera_state: GameStateResource.CAMERA_STATE) -> void:
	GameState.game_state.camera_state = camera_state

	GlobalEventBus.signal_camera_changed_state(camera_state)
