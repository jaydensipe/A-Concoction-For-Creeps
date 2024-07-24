extends Node

@onready var game_state: GameStateResource = preload("res://resources/state/original_game_state.tres")

func _ready() -> void:
	_init_debug()

	GlobalEventBus.game_end.connect(_reset_game_state)

func _init_debug() -> void:
	var debug_box: DebugBoxContainer = DebugIt.create_debug_box("Game Stats", Color.BROWN)
	debug_box.add_button("End Tutorial", func() -> void: game_state.tutorial_complete = true)
	debug_box.add_button("End Intro", func() -> void: game_state.intro_complete = true)

func _reset_game_state() -> void:
	# Maybe skip tutorial by default?
	game_state.modifier_hsm.queue_free()
	game_state = ResourceLoader.load("res://resources/state/original_game_state.tres", "GameStateResource", ResourceLoader.CACHE_MODE_IGNORE_DEEP)

#region Modifier HSM Setup
func init_modifier_state_machine() -> void:
	game_state.modifier_hsm = LimboHSM.new()
	add_child(game_state.modifier_hsm)

	# Create states
	var none_modifier_state: LimboState = LimboState.new().named(&"None") \
		.call_on_enter(_on_enter_none).call_on_exit(_on_exit_none)
	var tutorial_modifier_state: LimboState = LimboState.new().named(&"Tutorial") \
		.call_on_enter(_on_enter_tutorial).call_on_update(_on_update_tutorial).call_on_exit(_on_exit_tutorial)
	var intro_modifier_state: LimboState = LimboState.new().named(&"Intro") \
		.call_on_enter(_on_enter_intro).call_on_update(_on_update_intro).call_on_exit(_on_exit_intro)

	# Modifiers
	var assassin_modifier_state: LimboState = LimboState.new().named(&"Assassin") \
		.call_on_enter(_on_enter_assassin).call_on_exit(_on_exit_assassin)
	var blinder_modifier_state: LimboState = LimboState.new().named(&"Blinder") \
		.call_on_enter(_on_enter_blinder).call_on_exit(_on_exit_blinder)
	var reverser_modifier_state: LimboState = LimboState.new().named(&"Reverser") \
		.call_on_enter(_on_enter_reverser)
	var wraith_modifier_state: LimboState = LimboState.new().named(&"Wraith") \
		.call_on_enter(_on_enter_wraith).call_on_exit(_on_exit_wraith)
	var thirsty_intro_modifier_state: LimboState = LimboState.new().named(&"Thirsty") \
		.call_on_enter(_on_enter_thirsty).call_on_update(_on_update_thirsty)

	# Add children
	game_state.modifier_hsm.add_child(none_modifier_state)
	game_state.modifier_hsm.add_child(tutorial_modifier_state)
	game_state.modifier_hsm.add_child(intro_modifier_state)
	game_state.modifier_hsm.add_child(assassin_modifier_state)
	game_state.modifier_hsm.add_child(blinder_modifier_state)
	game_state.modifier_hsm.add_child(reverser_modifier_state)
	game_state.modifier_hsm.add_child(wraith_modifier_state)
	game_state.modifier_hsm.add_child(thirsty_intro_modifier_state)

	# Add initial game state
	game_state.modifier_hsm.initial_state = tutorial_modifier_state

	# Add transitions
	game_state.modifier_hsm.add_transition(game_state.modifier_hsm.ANYSTATE, none_modifier_state, &"end_modifier")
	game_state.modifier_hsm.add_transition(tutorial_modifier_state, intro_modifier_state, &"trans_tut_to_intro")
	game_state.modifier_hsm.add_transition(thirsty_intro_modifier_state, intro_modifier_state, &"trans_thirsty_to_intro")
	game_state.modifier_hsm.add_transition(game_state.modifier_hsm.ANYSTATE, assassin_modifier_state, &"trans_assassin_state")
	game_state.modifier_hsm.add_transition(game_state.modifier_hsm.ANYSTATE, blinder_modifier_state, &"trans_blinder_state")
	game_state.modifier_hsm.add_transition(game_state.modifier_hsm.ANYSTATE, reverser_modifier_state, &"trans_reverser_state")
	game_state.modifier_hsm.add_transition(game_state.modifier_hsm.ANYSTATE, wraith_modifier_state, &"trans_wraith_state")
	game_state.modifier_hsm.add_transition(intro_modifier_state, thirsty_intro_modifier_state, &"trans_intro_to_thirsty_state")

	# Initialize HSM
	game_state.modifier_hsm.initialize(self)
	game_state.modifier_hsm.set_active(true)

	game_state.modifier_hsm.active_state_changed.connect(func(current: LimboState, _previous: LimboState) -> void:
		DebugIt.show_value_on_screen("Current Modifier", current.name)
	)

	DebugIt.show_value_on_screen("Current Modifier", game_state.modifier_hsm.get_active_state().name)
#endregion

#region None Modifier
func _on_enter_none() -> void:
	game_state.difficulty_stats = preload("res://resources/state/base_difficulty_stats.tres")
	game_state.should_deplete_sanity = true

func _on_exit_none() -> void:
	pass
#endregion

#region Tutorial Modifier
func _on_enter_tutorial() -> void:
	game_state.should_deplete_sanity = false

	if (game_state.skip_intro):
		game_state.modifier_hsm.dispatch(&"end_modifier")

func _on_update_tutorial(_delta: float) -> void:
	if (game_state.tutorial_complete or game_state.customers_served >= 1):
		game_state.modifier_hsm.dispatch(&"trans_tut_to_intro")

func _on_exit_tutorial() -> void:
	game_state.tutorial_complete = true
	game_state.should_deplete_sanity = true
#endregion

#region Intro Modifier
func _on_enter_intro() -> void:
	game_state.difficulty_stats = preload("res://resources/state/intro_difficulty_stats.tres")

func _on_update_intro(_delta: float) -> void:
	if (game_state.intro_complete or game_state.customers_served >= game_state.min_amount_of_customers_served_before_intro_over):
		game_state.modifier_hsm.dispatch(&"end_modifier")

	if (game_state.customers_served == game_state.customer_intro_thirsty_modifier):
		game_state.modifier_hsm.dispatch(&"trans_intro_to_thirsty_state")

func _on_exit_intro() -> void:
	game_state.intro_complete = true
#endregion

#region Thirsty (Intro) Modifier
func _on_enter_thirsty() -> void:
	game_state.difficulty_stats.max_amount_of_ingredients = 4
	game_state.difficulty_stats.min_amount_of_ingredients = 4

func _on_update_thirsty(_delta: float) -> void:
	if (game_state.customers_served >= game_state.customer_intro_thirsty_modifier + 1):
		game_state.modifier_hsm.dispatch(&"trans_thirsty_to_intro")
#endregion

#region Assassin Modifier
func _on_enter_assassin() -> void:
	game_state.can_look_at_book = false

func _on_exit_assassin() -> void:
	game_state.can_look_at_book = true
#endregion

#region Blinder Modifier
func _on_enter_blinder() -> void:
	GlobalEventBus.signal_shader_toggle(ShaderModifier.SHADER_TYPES.GRAYSCALE)

func _on_exit_blinder() -> void:
	GlobalEventBus.signal_shader_toggle(ShaderModifier.SHADER_TYPES.GRAYSCALE)
#endregion

#region Reverser Modifier
func _on_enter_reverser() -> void:
	GlobalEventBus.drink_generated.connect(func(drink: Array[Ingredient]) -> void:
		drink.reverse()
		GameState.game_state.wanted_drink = drink
	)
#endregion

#region Wraith Modifier
func _on_enter_wraith() -> void:
	var timer: SceneTreeTimer = get_tree().create_timer(5.0, false)
	GlobalEventBus.drink_create_success.connect(func() -> void:
		game_state.wraith_has_completed_ingredient = true
	)

	GlobalEventBus.drink_generated.connect(func(drink: Array[Ingredient]) -> void:
		GameState.game_state.wanted_drink = [drink[0]]
	)

	timer.timeout.connect(func() -> void:
		if (game_state.wraith_has_completed_ingredient):
			pass
		else:
			GlobalEventBus.signal_game_end()
	)

func _on_exit_wraith() -> void:
	game_state.wraith_has_completed_ingredient = false
#endregion
