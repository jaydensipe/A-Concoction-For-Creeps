extends Node3D
class_name Game

#region Camera Variables

@onready var main_camera: Camera3D = get_viewport().get_camera_3d()
@onready var camera_animations: AnimationPlayer = $Camera/CameraAnimations
static var _camera_state: CAMERA_STATE = CAMERA_STATE.FORWARD
enum CAMERA_STATE { FORWARD, PLAYSPACE, BOOK }
#endregion

#region Ingredient & Symbol Variables
class Ingredient:
	var ingredient_name: StringName
	var tier: int

const MAX_AMOUNT_OF_INGREDIENTS: int = 2
enum SYMBOL_STATES {EMPTY, START, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE}
static var empty_symbol: Array[int] = [SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, \
								SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, \
								SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY]
static var current_symbol: Array[int] = [SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, \
								SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, \
								SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY]
static var ingredients: Dictionary = {
	"flamefern:1": [SYMBOL_STATES.START, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.TWO, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.THREE, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY],

	"skiverwing_feathers:1": [SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.START, SYMBOL_STATES.TWO, SYMBOL_STATES.THREE, \
				SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY],

	"sackfruit:1": [SYMBOL_STATES.EMPTY, SYMBOL_STATES.THREE, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.EMPTY, SYMBOL_STATES.TWO, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.START, SYMBOL_STATES.EMPTY, SYMBOL_STATES.FOUR],

	"imbued_salt:1": [SYMBOL_STATES.START, SYMBOL_STATES.EMPTY, SYMBOL_STATES.FOUR, \
				SYMBOL_STATES.EMPTY, SYMBOL_STATES.TWO, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.EMPTY, SYMBOL_STATES.THREE, SYMBOL_STATES.EMPTY],

	"harpberry_cluster:2": [SYMBOL_STATES.THREE, SYMBOL_STATES.FOUR, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.FIVE, SYMBOL_STATES.TWO, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.START, SYMBOL_STATES.SIX, SYMBOL_STATES.EMPTY],

	"poppletop_mushroom:2": [SYMBOL_STATES.FIVE, SYMBOL_STATES.FOUR, SYMBOL_STATES.THREE, \
				SYMBOL_STATES.EMPTY, SYMBOL_STATES.TWO, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.START, SYMBOL_STATES.EMPTY, SYMBOL_STATES.SIX],

	"dragon_dewdrop:2": [SYMBOL_STATES.START, SYMBOL_STATES.EMPTY, SYMBOL_STATES.SIX, \
				SYMBOL_STATES.EMPTY, SYMBOL_STATES.TWO, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.FIVE, SYMBOL_STATES.FOUR, SYMBOL_STATES.THREE],

	"bundled_ragweed:2": [SYMBOL_STATES.START, SYMBOL_STATES.FOUR, SYMBOL_STATES.SEVEN, \
				SYMBOL_STATES.TWO, SYMBOL_STATES.FIVE, SYMBOL_STATES.EIGHT, \
				SYMBOL_STATES.THREE, SYMBOL_STATES.SIX, SYMBOL_STATES.NINE],

	"wolpertinger_spit:3": [SYMBOL_STATES.START, SYMBOL_STATES.FOUR, SYMBOL_STATES.FIVE, \
				SYMBOL_STATES.THREE, SYMBOL_STATES.TWO, SYMBOL_STATES.SIX, \
				SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.SEVEN],

	"aged_hydra_skin:3": [SYMBOL_STATES.EMPTY, SYMBOL_STATES.TWO, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.START, SYMBOL_STATES.FIVE, SYMBOL_STATES.THREE, \
				SYMBOL_STATES.SIX, SYMBOL_STATES.FOUR, SYMBOL_STATES.EMPTY],

	"siren_eye:3": [SYMBOL_STATES.FIVE, SYMBOL_STATES.FOUR, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.START, SYMBOL_STATES.SIX, SYMBOL_STATES.THREE, \
				SYMBOL_STATES.EMPTY, SYMBOL_STATES.TWO, SYMBOL_STATES.EMPTY],

	"coiled_fearworm:3": [SYMBOL_STATES.TWO, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.START, SYMBOL_STATES.THREE, SYMBOL_STATES.SIX, \
				SYMBOL_STATES.FOUR, SYMBOL_STATES.FIVE, SYMBOL_STATES.SEVEN],
}
static var wanted_drink: Array[StringName] = []
static var concocted_drink: Array[StringName] = []
static var current_draw_index: int = 0
#endregion

@onready var shadow_manager: ShadowManager = $ShadowManager

func _ready() -> void:
	shadow_manager.spawn_shadow_person()

	GlobalEventBus.activation_sphere_selected.connect(func(sphere_index: int) -> void:
		# Ensure if this is our first activated symbol, we mark it as the start
		current_draw_index += 1

		if (is_board_empty()):
			current_symbol[sphere_index] = SYMBOL_STATES.START
		else:
			current_symbol[sphere_index] = current_draw_index
	)

	GlobalEventBus.lock_in.connect(_match_ingredient)

func _physics_process(delta: float) -> void:
	_camera_controls()

#region Game State
func _match_ingredient() -> void:
	var symbol_matches: bool = false
	for symbol: Array in ingredients.values():
		if (current_symbol.hash() == symbol.hash()):
			symbol_matches = true

			var ingredient: Ingredient = Utils.parse_ingredient_name_and_tier(ingredients.find_key(symbol))
			GlobalEventBus.signal_successful_symbol_match(ingredient, current_symbol)
			_add_drink_ingredient(ingredient)

	if (!symbol_matches):
		GlobalEventBus.signal_failure_symbol_match(current_symbol)

	_clear_symbol()

func _add_drink_ingredient(ingredient: Ingredient) -> void:
	concocted_drink.append(ingredient.ingredient_name)
	DebugIt.show_value_on_screen("Concocted Drink", str(concocted_drink))

	# Checks if ingredient at position is correct, if not clear the current concocted drink
	_verify_ingredient()

	# If the length of our concocted drink matches our wanted drink, we successfully made a drink
	if (len(concocted_drink) == len(wanted_drink)):
		_concoct_drink()

func _concoct_drink() -> void:
	LogIt.custom("Concocted drink with ingredients: %s" % str(concocted_drink), "CONCONT", "PURPLE")
	LogIt.custom("Wanted drink with ingredients: %s" % str(wanted_drink), "CONCONT", "PURPLE")

	# We always create a successful drink
	LogIt.custom("Created the correct drink!", "VERIFY", "springgreen")
	GlobalEventBus.signal_successful_drink_create()

	_reset_for_next_customer()

	#_verify_drink()

#func _verify_drink() -> void:
	#if (wanted_drink.hash() == concocted_drink.hash()):
		#LogIt.custom("Created the correct drink!", "VERIFY", "springgreen")
		#GlobalEventBus.signal_successful_drink_create()
	#else:
		#LogIt.custom("Failed to create correct drink!", "VERIFY", "crimson")
		#GlobalEventBus.signal_failure_drink_create()
#
	#_reset_for_next_customer()

func _verify_ingredient() -> void:
	var added_ingredient_index: int = len(concocted_drink) - 1

	# Jayden, if you crash here, it's because nobody has ordered anything yet, dumby!
	if (concocted_drink[added_ingredient_index] != wanted_drink[added_ingredient_index]):
		_clear_symbol()
		_clear_drink()

func _clear_symbol() -> void:
	current_symbol = empty_symbol.duplicate()
	current_draw_index = 0

	GlobalEventBus.signal_clear_board()

func _clear_drink() -> void:
	concocted_drink = []
	DebugIt.show_value_on_screen("Concocted Drink", str(concocted_drink))

func _clear_wanted_drink() -> void:
	wanted_drink = []
	DebugIt.show_value_on_screen("Wanted Drink", str(wanted_drink))

func _reset_for_next_customer() -> void:
	_clear_drink()
	_clear_wanted_drink()
	_clear_symbol()

static func generate_wanted_drink() -> void:
	# Always have a min of two ingredients
	var random_amount_of_ingredients: int = randi() % MAX_AMOUNT_OF_INGREDIENTS + 2

	var counter: int = 0
	while (counter < random_amount_of_ingredients):
		wanted_drink.append(Utils.parse_ingredient_name_and_tier(ingredients.keys().pick_random()).ingredient_name)
		counter += 1

	LogIt.custom("Generated wanted drink: %s" % [str(wanted_drink)], "DRINK", "orange")
	DebugIt.show_value_on_screen("Wanted Drink", str(wanted_drink))

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
