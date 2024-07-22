extends Node3D
class_name Game

@onready var shadow_manager: ShadowManager = $ShadowManager
@onready var camera: Camera = $Camera
@onready var ui: Control = $UI

#region UI Preload
const MAIN_MENU = preload("res://assets/ui/main_menu/main_menu.tscn")
#endregion

func _ready() -> void:
	_init_debug()

	GlobalEventBus.lock_in.connect(_match_ingredient)
	GlobalEventBus.start_game.connect(start_game)
	GlobalEventBus.end_game.connect(end_game)
	GlobalEventBus.activation_sphere_selected.connect(_calculate_symbol_draw)

func _init_debug() -> void:
	var debug_box: DebugBoxContainer = DebugIt.create_debug_box("Game", Color.DODGER_BLUE)
	debug_box.add_button("Generate Correct Drink", func() -> void:
		GameState.game_state.concocted_drink = GameState.game_state.wanted_drink
		_concoct_drink()
	)
	debug_box.add_button("End Game", func() -> void:
		GlobalEventBus.signal_end_game()
	)

#region Game Logic
func _physics_process(delta: float) -> void:
	_calculate_sanity(delta)

func start_game() -> void:
	GameState.init_modifier_state_machine()
	shadow_manager.spawn_shadow_person()

func end_game() -> void:
	DebugIt.clear_debug_values_temp()

	get_tree().change_scene_to_file("res://scenes/game/game.tscn")
#endregion

#region Sanity Logic
static func penalize_sanity(amount: float) -> void:
	GameState.game_state.sanity_level -= amount
	GlobalEventBus.signal_penalized_sanity(amount)

static func gain_sanity(amount: float) -> void:
	GameState.game_state.sanity_level += amount
	GlobalEventBus.signal_gain_sanity(amount)

func _calculate_sanity(delta: float) -> void:
	if (!GameState.game_state.should_deplete_sanity): return

	# Do I need delta here?
	GameState.game_state.sanity_level -= GameState.game_state.difficulty_stats.sanity_depletion_rate * delta * 5.0
	GameState.game_state.sanity_level = clampf(GameState.game_state.sanity_level, 0.0, 100.0)
	if (GameState.game_state.sanity_level <= 0.0):
		GlobalEventBus.signal_end_game()
	DebugIt.show_value_on_screen("Sanity", GameState.game_state.sanity_level)
#endregion

#region Ingredients Logic
func _calculate_symbol_draw(sphere_index: int) -> void:
	# Ensure if this is our first activated symbol, we mark it as the start
	GameState.game_state.current_draw_index += 1
	if (is_board_empty()):
		GameState.game_state.current_symbol[sphere_index] = GameState.game_state.SYMBOL_STATES.START
	else:
		GameState.game_state.current_symbol[sphere_index] = GameState.game_state.current_draw_index

func _match_ingredient() -> void:
	var symbol_matches: bool = false
	for symbol: Array in GameState.game_state.ingredients.values():
		if (GameState.game_state.current_symbol == symbol):
			symbol_matches = true

			var ingredient: Ingredient = Utils.parse_ingredient(GameState.game_state.ingredients.find_key(symbol))
			GlobalEventBus.signal_successful_symbol_match(ingredient, GameState.game_state.current_symbol)
			_add_drink_ingredient(ingredient)

	if (!symbol_matches):
		# TODO: Tweak this value
		if (GameState.game_state.current_draw_index > 2):
			Game.penalize_sanity(GameState.game_state.difficulty_stats.sanity_wrong_symbol)
			GlobalEventBus.signal_failure_symbol_match(GameState.game_state.current_symbol)
			_clear_drink()

	_clear_symbol()

func _add_drink_ingredient(ingredient: Ingredient) -> void:
	GameState.game_state.concocted_drink.append(ingredient.ingredient_name)
	DebugIt.show_value_on_screen("Concocted Drink", str(GameState.game_state.concocted_drink))

	# Checks if ingredient at position is correct, if not clear the current concocted drink
	_verify_ingredient()

	# If the length of our concocted drink matches our wanted drink, we successfully made a drink
	if (len(GameState.game_state.concocted_drink) == len(GameState.game_state.wanted_drink)):
		_concoct_drink()

func _concoct_drink() -> void:
	# We always create a successful drink
	# TODO: Tweak this value
	Game.gain_sanity(GameState.game_state.difficulty_stats.sanity_correct_drink)
	GlobalEventBus.signal_successful_drink_create()
	camera.move_camera_forward(true)

	_reset_for_next_customer()

func _verify_ingredient() -> void:
	var added_ingredient_index: int = len(GameState.game_state.concocted_drink) - 1

	# Jayden, if you crash here, it's because nobody has ordered anything yet, dumby!
	if (GameState.game_state.concocted_drink[added_ingredient_index] != GameState.game_state.wanted_drink[added_ingredient_index]):
		_clear_symbol()
		_clear_drink()

		Game.penalize_sanity(GameState.game_state.difficulty_stats.sanity_wrong_ingredient)
		GlobalEventBus.signal_failure_drink_create()

func _clear_symbol() -> void:
	GameState.game_state.current_symbol = GameState.game_state.empty_symbol.duplicate()
	GameState.game_state.current_draw_index = 0

	GlobalEventBus.signal_clear_board()

func _clear_drink() -> void:
	GameState.game_state.concocted_drink = []
	DebugIt.show_value_on_screen("Concocted Drink", str(GameState.game_state.concocted_drink))

func _clear_wanted_drink() -> void:
	GameState.game_state.wanted_drink = []
	DebugIt.show_value_on_screen("Wanted Drink", str(GameState.game_state.wanted_drink))

func _reset_for_next_customer() -> void:
	_clear_drink()
	_clear_wanted_drink()
	_clear_symbol()

static func generate_wanted_drink() -> void:
	# Always have a min of two ingredients
	var random_amount_of_ingredients: int = randi_range(GameState.game_state.difficulty_stats.min_amount_of_ingredients, GameState.game_state.difficulty_stats.max_amount_of_ingredients)
	var counter: int = 0

	while (counter < random_amount_of_ingredients):
		GameState.game_state.wanted_drink.append(Utils.picked_weighted_ingredient().ingredient_name)
		counter += 1

	Camera.switch_camera_state(GameStateResource.CAMERA_STATE.FORWARD)
	DebugIt.show_value_on_screen("Wanted Drink", str(GameState.game_state.wanted_drink))


static func is_board_empty() -> bool:
	return GameState.game_state.current_symbol == GameState.game_state.empty_symbol
#endregion

static func generate_modifier_chance() -> void:
	var random_gen: int = randi() % 100
	if (random_gen <= GameState.game_state.difficulty_stats.base_percent_chance_of_modifier):
		print("should generate modifier")
	pass
