@icon("res://addons/jaysreusablecomponentsandthings/assets/icons/icon_fp_camera_component_3d.svg")
extends Camera3D
class_name FPCameraComponent3D

# Camera controller settings and code used from: https://github.com/Btan2/Q_Move/. Thank you!

@export var character: PhysicsBody3D
@export var neck: Node3D

@export_group("Config")
@export var mouse_sensitivity: float = 3.0

@export_group("Item Config")
@export var item_container: ItemManager3D
@export var enable_idle: bool = true
var idle_time: float = 0.0
var idle_scale: float = 0.1
var idle_rot_scale: float = 0.5
var idle_pos_cycle: Vector3 = Vector3(2.0, 4.0, 0)
var idle_pos_level: Vector3 = Vector3(0.02, 0.045, 0)
var idle_rot_cycle: Vector3 = Vector3(1.0, 0.5, 1.25)
var idle_rot_level: Vector3 = Vector3(-1.5, 2, 1.5)

@export_group("Advanced Config")
@export_subgroup("Bob Config")
@export var enable_bob: bool = true
@export var bob_amount: float = 0.012
@export var bob_mode: BOB_TYPE = BOB_TYPE.VB_SIN
var _bob_times: Array = [0, 0, 0]
var _bob_dir_right: float = 0.0
var _bob_dir_forward: float = 0.0
var _bob_dir_up: float = 0.0
var bob_up: float = 0.5
var bob_cycle: float = 0.6
var Q_bobtime: float = 0.0
var Q_bob: float = 0.0
enum BOB_TYPE { VB_COS, VB_SIN, VB_COS2, VB_SIN2 }

var swayPos : Vector3 = Vector3.ZERO
var swayRot : Vector3 = Vector3.ZERO
var swayPos_offset : float = 0.12     # default: 0.12
var swayPos_max : float = 0.5       # default: 0.1
var swayPos_speed : float = 9.0       # default: 9.0
var swayRot_angle : float = 5.0      # default: 5.0   (old default: Vector3(5.0, 5.0, 2.0))
var swayRot_max : float = 15.0       # default: 15.0  (old default: Vector3(12.0, 12.0, 4.0))
var swayRot_speed : float = 5.0     # default: 10.0

@export_subgroup("Roll Config")
@export var enable_roll: bool = true
@export var roll_amount: float = 15.0
@export var roll_speed: float = 300.0

var mouse_move: Vector2 = Vector2.ZERO
var mouse_rotation_x: float = 0.0
var cam_pos: Vector3

func _ready() -> void:
	_init_input()

	cam_pos = transform.origin
	swayPos = item_container.current_item.viewmodel_origin

func _process(delta: float) -> void:
	#rotation_degrees = Vector3(mouse_rotation_x, 0, 0)
	transform.origin = cam_pos
	item_container.transform.origin = item_container.current_item.viewmodel_origin
	item_container.rotation_degrees = Vector3.ZERO

	# Apply velocity roll
	if (enable_roll): velocity_roll()

	view_model_sway()

	if character.velocity.length() <= 0.1:
		_bob_times = [0,0,0]
		Q_bobtime = 0.0

		view_model_idle()
	else:
		idle_time = 0.0

		if (character.is_on_floor()): add_bob()
		view_model_bob()

		if (enable_bob and character.is_on_floor()):
			view_bob_classic()

func _init_input() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Input.use_accumulated_input = false

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion):
		var viewport_transform: Transform2D = get_tree().root.get_final_transform()
		var motion: Vector2 = event.xformed_by(viewport_transform).relative
		motion *= 0.022 # Used from Source

		# this changes view bob amount, make sure to expose
		mouse_move = motion * 0.50
		mouse_rotation_x -= motion.y * mouse_sensitivity
		mouse_rotation_x = clamp(mouse_rotation_x, -89, 89)
		character.rotate_y(deg_to_rad(-motion.x * mouse_sensitivity))

func add_bob() -> void:
	_bob_dir_right = calc_bob(0.75, bob_mode, 0, _bob_dir_right)
	_bob_dir_up = calc_bob(1.50, bob_mode, 1, _bob_dir_up)
	_bob_dir_forward = calc_bob(1.00, bob_mode, 2, _bob_dir_forward)

var cl_bob : float = 0.01             # default: 0.01
var cl_bobup : float = 0.5            # default: 0.5
var cl_bobcycle : float = 0.9         # default: 0.8

func calc_bob (freqmod: float, mode: BOB_TYPE, bob_i: int, bob: float) -> float:
	var cycle : float
	var vel : Vector3

	_bob_times[bob_i] += get_process_delta_time() * freqmod
	cycle = _bob_times[bob_i] - int( _bob_times[bob_i] / cl_bobcycle ) * cl_bobcycle
	cycle /= cl_bobcycle

	if cycle < cl_bobup:
		cycle = PI * cycle / cl_bobup
	else:
		cycle = PI + PI * ( cycle - cl_bobup)/( 1.0 - cl_bobup)

	vel = character.velocity
	bob = sqrt(vel[0] * vel[0] + vel[2] * vel[2]) * cl_bob

	if mode == BOB_TYPE.VB_SIN:
		bob = bob * 0.3 + bob * 0.7 * sin(cycle)
	elif mode == BOB_TYPE.VB_COS:
		bob = bob * 0.3 + bob * 0.7 * cos(cycle)
	elif mode == BOB_TYPE.VB_SIN2:
		bob = bob * 0.3 + bob * 0.7 * sin(cycle) * sin(cycle)
	elif mode == BOB_TYPE.VB_COS2:
		bob = bob * 0.3 + bob * 0.7 * cos(cycle) * cos(cycle)
	bob = clamp(bob, -7, 4)

	return bob

func velocity_roll() -> void:
	var side: float

	side = calc_roll(character.velocity, roll_amount, roll_speed) * 4
	print(side)
	rotation_degrees.z += side
	print(rotation_degrees.z)
	item_container.rotation_degrees.z += side

func calc_roll(velocity: Vector3, angle: float, speed: float) -> float:
	var s: float
	var side: float

	side = velocity.dot(-global_transform.basis.x)
	s = sign(side)
	side = abs(side)

	if (side < speed):
		side = side * angle / speed;
	else:
		side = angle;

	return side * s

func calc_bob_classic() -> float:
	var vel : Vector3
	var cycle : float

	Q_bobtime += get_process_delta_time()
	cycle = Q_bobtime - int(Q_bobtime / bob_cycle) * bob_cycle
	cycle /= bob_cycle
	if cycle < bob_up:
		cycle = PI * cycle / bob_up
	else:
		cycle = PI + PI * (cycle - bob_up) / (1.0 - bob_up)

	vel = character.velocity
	Q_bob = sqrt(vel[0] * vel[0] + vel[2] * vel[2]) * bob_amount
	Q_bob = Q_bob * 0.3 + Q_bob * 0.7 * sin(cycle)
	Q_bob = clamp(Q_bob, -7.0, 4.0)

	return Q_bob

func view_model_idle() -> void:
	idle_time += get_process_delta_time()

	for i in range(3):
		item_container.transform.origin[i] += idle_scale * sin(idle_time * idle_pos_cycle[i]) * idle_pos_level[i]
		item_container.rotation_degrees[i] += idle_rot_scale * sin(idle_time * idle_rot_cycle[i]) * idle_rot_level[i]

func view_bob_classic() -> void:
	transform.origin[1] += calc_bob_classic()

func view_model_bob() -> void:
	for i in range(3):
		item_container.transform.origin[i] += _bob_dir_right * 0.25 * transform.basis.x[i]
		item_container.transform.origin[i] += _bob_dir_up * 0.125 * transform.basis.y[i]
		item_container.transform.origin[i] += _bob_dir_forward * 0.06125 * transform.basis.z[i]

func view_model_sway() -> void:
	var pos : Vector3
	var rot : Vector3

	if mouse_move == null:
		mouse_move = mouse_move.lerp(Vector2.ZERO, 1 * get_process_delta_time())
		return

	pos = Vector3.ZERO
	pos.x = clamp(-mouse_move.x * swayPos_offset, -swayPos_max, swayPos_max)
	pos.y = clamp(mouse_move.y * swayPos_offset, -swayPos_max, swayPos_max)
	swayPos = lerp(swayPos, pos, swayPos_speed * get_process_delta_time())
	item_container.transform.origin += swayPos

	rot = Vector3.ZERO
	rot.x = clamp(-mouse_move.y * swayRot_angle, -swayRot_max, swayRot_max)
	rot.z = clamp(mouse_move.x * swayRot_angle, -swayRot_max/3, swayRot_max/3)
	rot.y = clamp(-mouse_move.x * swayRot_angle, -swayRot_max, swayRot_max)
	swayRot = lerp(swayRot, rot, swayRot_speed * get_process_delta_time())
