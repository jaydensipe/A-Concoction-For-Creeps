extends Node3D

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var TEXTURE_ACTIVATED: Resource = preload("res://scenes/activation_sphere/texture_activated.tres")
@onready var TEXTURE_FIRST: Resource = preload("res://scenes/activation_sphere/texture_first.tres")
@onready var TEXTURE_WAITING: Resource = preload("res://scenes/activation_sphere/texture_waiting.tres")
@onready var activated: bool = false

func _ready() -> void:
	_clear()

	GlobalEventBus.clear_board.connect(_clear)

func _clear() -> void:
	activated = false
	mesh_instance_3d.material_override = TEXTURE_WAITING

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if (activated or !GameState.holding_mouse_button_down or Game._camera_state != Game.CAMERA_STATE.PLAYSPACE): return

	activated = true
	if (Game.is_board_empty()):
		mesh_instance_3d.material_override = TEXTURE_FIRST
	else:
		mesh_instance_3d.material_override = TEXTURE_ACTIVATED

	GlobalEventBus.signal_activation_sphere_selected(get_index())
