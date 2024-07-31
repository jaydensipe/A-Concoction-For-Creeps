extends Node3D
class_name Game

@onready var shadow_manager: ShadowManager = $ShadowManager
@onready var camera: Camera = $Camera
@onready var ui: CanvasLayer = $UI

#region UI Preload
const DEATH_SCREEN = preload("res://assets/ui/screen_wipe/death_screen.tscn")
const GAME_MENU = preload("res://assets/ui/game_menu/game_menu.tscn")
#endregion

func _ready() -> void:
	#_init_debug()

	GlobalEventBus.symbol_lock_in.connect(_match_ingredient)
	GlobalEventBus.symbol_clear.connect(_clear_symbol)
	GlobalEventBus.symbol_stone_selected.connect(_calculate_symbol_draw)
	GlobalEventBus.ingredient_match_success.connect(_add_drink_ingredient)
	GlobalEventBus.ingredient_match_failure.connect(_fail_drink_ingredient)
	GlobalEventBus.ingredient_matches_wanted.connect(_add_wanted_ingredient)
	GlobalEventBus.drink_generated.connect(_generated_drink)
	GlobalEventBus.drink_create_success.connect(_concoct_drink)
	GlobalEventBus.drink_create_failure.connect(_fail_drink)
	GlobalEventBus.sanity_penalize.connect(_penalize_sanity)
	GlobalEventBus.sanity_gain.connect(_gain_sanity)
	GlobalEventBus.game_start.connect(start_game)
	GlobalEventBus.game_end.connect(end_game)

#func _init_debug() -> void:
	#var debug_box: DebugBoxContainer = DebugIt.create_debug_box("Game", Color.DODGER_BLUE)
	#debug_box.add_button("Generate Correct Drink", func() -> void:
		#GameState.game_state.concocted_drink = GameState.game_state.wanted_drink
		#GlobalEventBus.signal_drink_create_success()
	#)
	#debug_box.add_button("End Game", func() -> void:
		#GlobalEventBus.signal_game_end()
	#)

#region Game Logic
func _physics_process(_delta: float) -> void:
	_calculate_sanity()

func start_game() -> void:
	GameState.init_modifier_state_machine()

	ui.add_child(GAME_MENU.instantiate())
	shadow_manager.spawn_shadow_person(true)

func end_game() -> void:
	#DebugIt.clear_debug_values_temp()

	ui.add_child(DEATH_SCREEN.instantiate())
#endregion

#region Sanity Logic
func _penalize_sanity(amount: float) -> void:
	GameState.game_state.sanity_level -= amount

func _gain_sanity(amount: float) -> void:
	GameState.game_state.sanity_level += amount

func _calculate_sanity() -> void:
	if (!GameState.game_state.should_deplete_sanity or !GameState.game_state.ready_to_take_order): return

	GameState.game_state.sanity_level -= GameState.game_state.difficulty_stats.sanity_depletion_rate
	GameState.game_state.sanity_level = clampf(GameState.game_state.sanity_level, 0.0, 100.0)
	#DebugIt.show_value_on_screen("Sanity", GameState.game_state.sanity_level)

	# End game if less than 0
	if (GameState.game_state.sanity_level <= 0.0):
		GlobalEventBus.signal_game_end()
#endregion

#region Drink & Ingredients Logic
func _calculate_symbol_draw(stone_index: int) -> void:
	# Ensure if this is our first activated symbol, we mark it as the start
	GameState.game_state.current_draw_index += 1
	if (is_board_empty()):
		GameState.game_state.current_symbol[stone_index] = GameState.game_state.SYMBOL_STATES.START
	else:
		GameState.game_state.current_symbol[stone_index] = GameState.game_state.current_draw_index

func _match_ingredient() -> void:
	var symbol_matches: bool = false
	for symbol: Array in GameState.game_state.ingredients.values():
		if (GameState.game_state.current_symbol == symbol):
			symbol_matches = true

			GlobalEventBus.signal_ingredient_match_success(Utils.parse_ingredient(GameState.game_state.ingredients.find_key(symbol)))
			break

	if (!symbol_matches):
		if (GameState.game_state.current_draw_index > 2):
			GlobalEventBus.signal_ingredient_match_failure(GameState.game_state.current_symbol)

	GlobalEventBus.signal_symbol_clear()

func _add_drink_ingredient(ingredient: Ingredient) -> void:
	GameState.game_state.concocted_drink.append(ingredient)
	#DebugIt.show_value_on_screen("Concocted Drink", str(GameState.game_state.concocted_drink))

	# Checks if ingredient at position is correct, if not clear the current concocted drink
	_verify_ingredient()

	# If the length of our concocted drink matches our wanted drink, we successfully made a drink
	if (len(GameState.game_state.concocted_drink) == len(GameState.game_state.wanted_drink)):
		GlobalEventBus.signal_drink_create_success()

func _fail_drink_ingredient(_symbol: Array[int]) -> void:
	GlobalEventBus.signal_sanity_penalize(GameState.game_state.difficulty_stats.sanity_wrong_symbol)
	_clear_drink()

func _add_wanted_ingredient(_ingredient: Ingredient) -> void:
	GlobalEventBus.signal_sanity_gain(GameState.game_state.difficulty_stats.sanity_correct_ingredient)
	GameState.game_state.current_correct_ingredient_count += 1

func _concoct_drink() -> void:
	camera.move_camera_forward(true)

	_clear_drink()
	_clear_wanted_drink()

	#GameState.game_state.modifier_hsm.dispatch(&"end_modifier")
	GameState.game_state.ready_to_take_order = false
	GlobalEventBus.signal_symbol_clear()

	if (!GameState.game_state.assassin_let_go):
		GlobalEventBus.signal_sanity_gain(GameState.game_state.difficulty_stats.sanity_correct_drink)

func _fail_drink() -> void:
	_clear_drink()
	GlobalEventBus.signal_symbol_clear()
	GlobalEventBus.signal_sanity_penalize(GameState.game_state.difficulty_stats.sanity_wrong_ingredient)

func _verify_ingredient() -> void:
	var added_ingredient_index: int = len(GameState.game_state.concocted_drink) - 1

	# Jayden, if you crash here, it's because nobody has ordered anything yet, dumby!
	if (GameState.game_state.concocted_drink[added_ingredient_index].ingredient_name != GameState.game_state.wanted_drink[added_ingredient_index].ingredient_name):
		GlobalEventBus.signal_drink_create_failure()
	else:
		GlobalEventBus.signal_ingredient_matches_wanted(GameState.game_state.concocted_drink[added_ingredient_index])

func _clear_symbol() -> void:
	GameState.game_state.current_symbol = GameState.game_state.empty_symbol.duplicate()
	GameState.game_state.current_draw_index = 0

func _clear_drink() -> void:
	GameState.game_state.concocted_drink = []
	GameState.game_state.current_correct_ingredient_count = 0
	#DebugIt.show_value_on_screen("Concocted Drink", str(GameState.game_state.concocted_drink))

func _clear_wanted_drink() -> void:
	GameState.game_state.wanted_drink = []
	#DebugIt.show_value_on_screen("Wanted Drink", str(GameState.game_state.wanted_drink))

func _generated_drink(_drink: Array[Ingredient]) -> void:
	GlobalEventBus.signal_request_camera_change(GameStateResource.CAMERA_STATE.FORWARD)
	#DebugIt.show_value_on_screen("Wanted Drink", drink)

static func generate_wanted_drink() -> void:
	# Always have a min of two ingredients
	var random_amount_of_ingredients: int = randi_range(GameState.game_state.difficulty_stats.min_amount_of_ingredients, GameState.game_state.difficulty_stats.max_amount_of_ingredients)
	var counter: int = 0

	# Add random ingredients to array
	while (counter < random_amount_of_ingredients):
		GameState.game_state.wanted_drink.append(Utils.picked_weighted_ingredient())
		counter += 1

	GlobalEventBus.signal_drink_generated(GameState.game_state.wanted_drink)

static func is_board_empty() -> bool:
	return GameState.game_state.current_symbol == GameState.game_state.empty_symbol
#endregion

#region Modifier Logic
static func generate_modifier_chance() -> void:
	if (!GameState.game_state.intro_complete): return

	var random_gen: int = randi() % 100
	if (random_gen <= GameState.game_state.difficulty_stats.base_percent_chance_of_modifier):
		GameState.game_state.modifier_hsm.dispatch(Utils.picked_weighted_modifier())
	else:
		GameState.game_state.modifier_hsm.dispatch(&"end_modifier")
#endregion
