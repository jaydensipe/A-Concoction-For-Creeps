extends Node3D
class_name Game

@onready var shadow_manager: ShadowManager = $ShadowManager

#region Camera Variables
@onready var main_camera: Camera3D = get_viewport().get_camera_3d()
@onready var camera_animations: AnimationPlayer = $Camera/CameraAnimations
enum CAMERA_STATE { FORWARD, PLAYSPACE, BOOK }
static var _camera_state: CAMERA_STATE = CAMERA_STATE.FORWARD
#endregion

func _ready() -> void:
	shadow_manager.spawn_shadow_person()

	GlobalEventBus.activation_sphere_selected.connect(func(sphere_index: int) -> void:
		# Ensure if this is our first activated symbol, we mark it as the start
		GameState.current_draw_index += 1

		if (is_board_empty()):
			GameState.current_symbol[sphere_index] = GameState.SYMBOL_STATES.START
		else:
			GameState.current_symbol[sphere_index] = GameState.current_draw_index
	)

	GlobalEventBus.lock_in.connect(_match_ingredient)

func _physics_process(delta: float) -> void:
	_camera_controls()

#region Ingredients Logic
func _match_ingredient() -> void:
	var symbol_matches: bool = false
	for symbol: Array in GameState.ingredients.values():
		if (GameState.current_symbol.hash() == symbol.hash()):
			symbol_matches = true

			var ingredient: Ingredient = Utils.parse_ingredient(GameState.ingredients.find_key(symbol))
			GlobalEventBus.signal_successful_symbol_match(ingredient, GameState.current_symbol)
			_add_drink_ingredient(ingredient)

	if (!symbol_matches):
		GlobalEventBus.signal_failure_symbol_match(GameState.current_symbol)
		_clear_drink()

	_clear_symbol()

func _add_drink_ingredient(ingredient: Ingredient) -> void:
	GameState.concocted_drink.append(ingredient.ingredient_name)
	DebugIt.show_value_on_screen("Concocted Drink", str(GameState.concocted_drink))

	# Checks if ingredient at position is correct, if not clear the current concocted drink
	_verify_ingredient()

	# If the length of our concocted drink matches our wanted drink, we successfully made a drink
	if (len(GameState.concocted_drink) == len(GameState.wanted_drink)):
		_concoct_drink()

func _concoct_drink() -> void:
	LogIt.custom("Concocted drink with ingredients: %s" % str(GameState.concocted_drink), "CONCONT", "PURPLE")
	LogIt.custom("Wanted drink with ingredients: %s" % str(GameState.wanted_drink), "CONCONT", "PURPLE")

	# We always create a successful drink
	GlobalEventBus.signal_successful_drink_create()

	_reset_for_next_customer()

func _verify_ingredient() -> void:
	var added_ingredient_index: int = len(GameState.concocted_drink) - 1

	# Jayden, if you crash here, it's because nobody has ordered anything yet, dumby!
	if (GameState.concocted_drink[added_ingredient_index] != GameState.wanted_drink[added_ingredient_index]):
		_clear_symbol()
		_clear_drink()

		GlobalEventBus.signal_failure_drink_create()

func _clear_symbol() -> void:
	GameState.current_symbol = GameState.empty_symbol.duplicate()
	GameState.current_draw_index = 0

	GlobalEventBus.signal_clear_board()

func _clear_drink() -> void:
	GameState.concocted_drink = []
	DebugIt.show_value_on_screen("Concocted Drink", str(GameState.concocted_drink))

func _clear_wanted_drink() -> void:
	GameState.wanted_drink = []
	DebugIt.show_value_on_screen("Wanted Drink", str(GameState.wanted_drink))

func _reset_for_next_customer() -> void:
	_clear_drink()
	_clear_wanted_drink()
	_clear_symbol()

static func generate_wanted_drink() -> void:
	# Always have a min of two ingredients
	var random_amount_of_ingredients: int = randi() % GameState.max_amount_of_ingredients + 2

	var counter: int = 0
	while (counter < random_amount_of_ingredients):
		GameState.wanted_drink.append(Utils.parse_ingredient(GameState.ingredients.keys().pick_random()).ingredient_name)
		counter += 1

	LogIt.custom("Generated wanted drink: %s" % [str(GameState.wanted_drink)], "DRINK", "orange")
	DebugIt.show_value_on_screen("Wanted Drink", str(GameState.wanted_drink))

static func is_board_empty() -> bool:
	return GameState.current_symbol.hash() == GameState.empty_symbol.hash()
#endregion

#region Camera Logic
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
		if (_camera_state == CAMERA_STATE.PLAYSPACE and _camera_state != CAMERA_STATE.BOOK and GameState.can_look_at_book):
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
