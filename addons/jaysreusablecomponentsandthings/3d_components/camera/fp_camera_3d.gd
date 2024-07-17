extends Camera3D
class_name FPCamera3D

# Inspiration and some code from https://github.com/Btan2/Q_Move. Thank you!
# TODO: Add viewmodel sway, bob, idle and roll, also differentiate viewmodel from actual node.

@export var head: Head
@export var character: CharacterBody3D

@export_group("Config")
@export var camera_config: CameraConfig

var _mouse_rotation_x: float = 0.0
var _time_bob: float = 0.0
@onready var _current_fov: float = self.fov

func _ready() -> void:
	Helpers.require_instance_variables(get_path(), [head, character, camera_config])

	_init_input()

func _process(_delta: float) -> void:
	head.rotation_degrees = Vector3(_mouse_rotation_x, 0, 0)
	_process_velocity_roll()

func _physics_process(delta: float) -> void:
	_process_head_bob(delta)
	#_process_velocity_fov_change(delta)

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion):
		var viewport_transform: Transform2D = get_tree().root.get_final_transform()
		var motion: Vector2 = event.xformed_by(viewport_transform).relative
		motion *= 0.022 # Used from Source

		_mouse_rotation_x -= motion.y * camera_config.mouse_sensitivity
		_mouse_rotation_x = clamp(_mouse_rotation_x, -89, 89)
		character.rotate_y(deg_to_rad(-motion.x * camera_config.mouse_sensitivity))

func _init_input() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Input.use_accumulated_input = false

func _process_velocity_fov_change(delta: float) -> void:
	fov *= character.velocity.length_squared() * delta * 1.2
	fov = clampf(fov, _current_fov, fov * 1.5)

func _process_head_bob(delta: float) -> void:
	if (!character.is_on_floor() or !camera_config.enable_bob): return

	_time_bob += delta + character.velocity.length() * 0.005
	transform.origin = _calc_head_bob()

func _calc_head_bob() -> Vector3:
	var bob_pos: Vector3 = Vector3.ZERO
	bob_pos.y = sin(_time_bob * camera_config.bob_frequency) * camera_config.bob_amplitude
	bob_pos.x = cos(_time_bob * camera_config.bob_frequency / 2) * camera_config.bob_amplitude

	return bob_pos

func _process_velocity_roll() -> void:
	if (!camera_config.enable_roll): return

	var side: float

	side = _calc_roll(character.velocity, camera_config.roll_amount, camera_config.roll_speed)
	head.rotation_degrees.z += side

func _calc_roll(velocity: Vector3, angle: float, speed: float) -> float:
	var s: float
	var side: float

	side = velocity.dot(-get_global_transform().basis.x)
	s = sign(side)
	side = abs(side)

	if (side < speed):
		side = side * angle / speed;
	else:
		side = angle;

	return side * s
