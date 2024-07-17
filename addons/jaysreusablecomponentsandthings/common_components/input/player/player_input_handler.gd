@icon("res://addons/jaysreusablecomponentsandthings/assets/icons/icon_player_input_handler.svg")
extends Node
class_name PlayerInputHandler

@onready var movement_component: MovementComponent3D = get_parent() as MovementComponent3D
@export_group("Debug")
@export var show_debug: bool = false
var input_dir: Vector3 = Vector3.ZERO

func _ready() -> void:
	if (show_debug):
		var player_debug_box: DebugBoxContainer = DebugIt.create_debug_box(&"Player Movement", Color.INDIAN_RED)
		#player_debug_box.add_toggle_button("Toggle Noclip", _debug_noclip)
		player_debug_box.add_toggle_button("Disable Movement", func() -> void: movement_component.disable_movement = !movement_component.disable_movement)

func _physics_process(_delta: float) -> void:
	apply_player_input_direction()

	# Checks for jump
	if (Input.is_action_just_pressed(&"jump")):
		movement_component.jump()

	# Checks for sprint
	if (Input.is_action_pressed(&"sprint")):
		movement_component.sprint()

	# Checks for crouch
	if (Input.is_action_pressed(&"crouch")):
		movement_component.crouch()

func apply_player_input_direction() -> void:
	movement_component.input_dir = Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_backward")
