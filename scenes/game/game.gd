extends Node3D
class_name Game

@onready var shadow_manager: ShadowManager = $ShadowManager

#region Camera Variables
@onready var main_camera: Camera3D = get_viewport().get_camera_3d()
@onready var camera_animations: AnimationPlayer = $Camera/CameraAnimations
enum CAMERA_STATE { FORWARD, PLAYSPACE, BOOK, DISABLED }
static var _camera_state: CAMERA_STATE = CAMERA_STATE.DISABLED
#endregion

#region UI Variables
@onready var ui: Control = $UI
const MAIN_MENU = preload("res://assets/ui/main_menu/main_menu.tscn")
#endregion

func _ready() -> void:
	GlobalEventBus.activation_sphere_selected.connect(func(sphere_index: int) -> void:
		# Ensure if this is our first activated symbol, we mark it as the start
		GameState.current_draw_index += 1
		if (is_board_empty()):
			GameState.current_symbol[sphere_index] = GameState.SYMBOL_STATES.START
		else:
			GameState.current_symbol[sphere_index] = GameState.current_draw_index
	)

	GlobalEventBus.lock_in.connect(_match_ingredient)
	GlobalEventBus.start_game.connect(start_game)
	GlobalEventBus.end_game.connect(end_game)

func _init_debug() -> void:
	var debug_box: DebugBoxContainer = DebugIt.create_debug_box("Game", Color.DODGER_BLUE)
	debug_box.add_button("Generate Correct Drink", func() -> void:
		GameState.concocted_drink = GameState.wanted_drink
		_concoct_drink()
	)

#region Game Logic
func _physics_process(delta: float) -> void:
	_camera_controls()
	_calculate_sanity()

func start_game() -> void:
	GameState.init_modifier_state_machine()

	_init_debug()
	shadow_manager.spawn_shadow_person()

func end_game() -> void:
	ui.add_child(MAIN_MENU.instantiate())
	#get_tree().reload_current_scene()

func restart_game() -> void:
	pass
#endregion

#region Sanity Logic
static func penalize_sanity(amount: float) -> void:
	GameState.sanity_level -= amount
	GlobalEventBus.signal_penalized_sanity(amount)

static func gain_sanity(amount: float) -> void:
	GameState.sanity_level += amount
	GlobalEventBus.signal_gain_sanity(amount)

func _calculate_sanity() -> void:
	if (!GameState.should_deplete_sanity): return

	GameState.sanity_level -= GameState.game_stats.sanity_depletion_rate
	GameState.sanity_level = clampf(GameState.sanity_level, 0.0, 100.0)
	if (GameState.sanity_level <= 0.0):
		GlobalEventBus.signal_end_game()
	DebugIt.show_value_on_screen("Sanity", GameState.sanity_level)
#endregion

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
		# TODO: Tweak this value
		if (GameState.current_draw_index > 2):
			Game.penalize_sanity(GameState.game_stats.sanity_wrong_symbol)
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
	# We always create a successful drink
	# TODO: Tweak this value
	Game.gain_sanity(GameState.game_stats.sanity_correct_drink)
	GlobalEventBus.signal_successful_drink_create()
	camera_animations.play_backwards(&"look_at_playspace")
	switch_camera_state(CAMERA_STATE.DISABLED)

	_reset_for_next_customer()

func _verify_ingredient() -> void:
	var added_ingredient_index: int = len(GameState.concocted_drink) - 1

	# Jayden, if you crash here, it's because nobody has ordered anything yet, dumby!
	if (GameState.concocted_drink[added_ingredient_index] != GameState.wanted_drink[added_ingredient_index]):
		_clear_symbol()
		_clear_drink()

		Game.penalize_sanity(GameState.game_stats.sanity_wrong_ingredient)
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
	var random_amount_of_ingredients: int = randi_range(GameState.game_stats.min_amount_of_ingredients, GameState.game_stats.max_amount_of_ingredients)

	var counter: int = 0

	while (counter < random_amount_of_ingredients):
		GameState.wanted_drink.append(Utils.picked_weighted_ingredient().ingredient_name)
		counter += 1

	DebugIt.show_value_on_screen("Wanted Drink", str(GameState.wanted_drink))
	switch_camera_state(CAMERA_STATE.FORWARD)

static func is_board_empty() -> bool:
	return GameState.current_symbol.hash() == GameState.empty_symbol.hash()
#endregion

#region Camera Logic
func _camera_controls() -> void:
	if (_camera_state == CAMERA_STATE.DISABLED): return

	if (Input.is_action_just_pressed(&"move_forward")):
		if (_camera_state == CAMERA_STATE.FORWARD or _camera_state == CAMERA_STATE.BOOK): return

		camera_animations.play_backwards(&"look_at_playspace")
		switch_camera_state(CAMERA_STATE.FORWARD)

	if (Input.is_action_just_pressed(&"move_backward") or Input.is_action_just_pressed(&"jump")):
		if (_camera_state == CAMERA_STATE.BOOK):
			camera_animations.play_backwards(&"look_at_book_from_playspace")
		else:
			if (_camera_state != CAMERA_STATE.PLAYSPACE):
				camera_animations.play(&"look_at_playspace")
		switch_camera_state(CAMERA_STATE.PLAYSPACE)

	if (Input.is_action_just_pressed(&"move_left")):
		if (_camera_state == CAMERA_STATE.PLAYSPACE and _camera_state != CAMERA_STATE.BOOK and GameState.can_look_at_book):
			camera_animations.play(&"look_at_book_from_playspace")
			switch_camera_state(CAMERA_STATE.BOOK)

	if (Input.is_action_just_pressed(&"move_right")):
		if (_camera_state == CAMERA_STATE.BOOK):
			camera_animations.play_backwards(&"look_at_book_from_playspace")
			switch_camera_state(CAMERA_STATE.PLAYSPACE)

	if (Input.is_action_just_pressed(&"mouse_primary_fire")):
		pass

static func switch_camera_state(camera_state: CAMERA_STATE) -> void:
	_camera_state = camera_state

	GlobalEventBus.signal_camera_changed_state(camera_state)
#endregion
