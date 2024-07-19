extends Node3D
class_name Game

#region Camera Variables

@onready var main_camera: Camera3D = get_viewport().get_camera_3d()
@onready var camera_animations: AnimationPlayer = $Camera/CameraAnimations
static var _camera_state: CAMERA_STATE = CAMERA_STATE.FORWARD
enum CAMERA_STATE { FORWARD, PLAYSPACE, BOOK }
#endregion

#region Symbol Variables
enum SYMBOL_STATES {EMPTY, START, REQUIRED}
static var wanted_symbol: Array[StringName] = []
static var empty_symbol: Array[int] = [SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, \
								SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, \
								SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY]
static var current_symbol: Array[int] = [SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, \
								SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, \
								SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY]
static var symbols: Dictionary = {
	"hiviticus:1": [SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.REQUIRED, \
				SYMBOL_STATES.EMPTY, SYMBOL_STATES.REQUIRED, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.START, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY],

	"adoolafus:1": [SYMBOL_STATES.EMPTY, SYMBOL_STATES.START, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.EMPTY, SYMBOL_STATES.REQUIRED, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.EMPTY, SYMBOL_STATES.REQUIRED, SYMBOL_STATES.EMPTY],
}
#endregion

func _ready() -> void:
	GlobalEventBus.activation_sphere_selected.connect(func(sphere_index: int) -> void:
		# Ensure if this is our first activated symbol, we mark it as the start.
		if (is_board_empty()):
			current_symbol[sphere_index] = SYMBOL_STATES.START
		else:
			current_symbol[sphere_index] = SYMBOL_STATES.REQUIRED
	)

	GlobalEventBus.lock_in.connect(_match_symbol)

func _physics_process(delta: float) -> void:
	_camera_controls()

#region Game State
func _match_symbol() -> void:
	var symbol_matches: bool = false
	for symbol: Array in symbols.values():
		if (current_symbol.hash() == symbol.hash()):
			symbol_matches = true

			var symbol_name: PackedStringArray = Utils.parse_symbol_name_and_tier(symbols.find_key(symbol))
			GlobalEventBus.signal_successful_symbol_match(symbol_name[0], int(symbol_name[1]), current_symbol)

	if (!symbol_matches):
		GlobalEventBus.signal_failure_symbol_match(current_symbol)

	_clear_symbol()


func _clear_symbol() -> void:
	current_symbol = empty_symbol.duplicate()

	GlobalEventBus.signal_clear_board()

static func is_board_empty() -> bool:
	return current_symbol.hash() == empty_symbol.hash()
#endregion

#region Camera State
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
#endregion
