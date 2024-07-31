extends Node

#region Symbol & Ingredient Signals
# Lets go of mouse and locks symbol in.
signal symbol_lock_in()
func signal_symbol_lock_in() -> void:
	symbol_lock_in.emit()

# Clears symbol playspace.
signal symbol_clear()
func signal_symbol_clear() -> void:
	symbol_clear.emit()

# A symbol stone was selected and activated.
signal symbol_stone_selected(stone_index: int)
func signal_symbol_stone_selected(stone_index: int) -> void:
	symbol_stone_selected.emit(stone_index)

# Drawn symbol matches an ingredient.
signal ingredient_match_success(ingredient: Ingredient)
func signal_ingredient_match_success(ingredient: Ingredient) -> void:
	LogIt.custom("Ingredient successfully matched: %s, tier %d" % [ingredient.ingredient_name, ingredient.tier], "SYMBOL", "green")
	ingredient_match_success.emit(ingredient)

# Drawn symbol matches the currently wanted ingredient.
signal ingredient_matches_wanted(ingredient: Ingredient)
func signal_ingredient_matches_wanted(ingredient: Ingredient) -> void:
	ingredient_matches_wanted.emit(ingredient)

# Drawn symbol does not match any ingredient.
signal ingredient_match_failure(symbol: Array[int])
func signal_ingredient_match_failure(symbol: Array[int]) -> void:
	LogIt.custom("No symbol matches drawing!", "SYMBOL", "red")
	ingredient_match_failure.emit(symbol)
#endregion

#region Drink Signals
# Fired when a drink is generated.
signal drink_generated(drink: Array[Ingredient])
func signal_drink_generated(drink: Array[Ingredient]) -> void:
	drink_generated.emit(drink)

# Drink has been successfully made.
signal drink_create_success()
func signal_drink_create_success() -> void:
	LogIt.custom("Created the correct drink!", "DRINK", "springgreen")
	drink_create_success.emit()

# Drink has been fucked up.
signal drink_create_failure()
func signal_drink_create_failure() -> void:
	LogIt.custom("Failed to create correct drink!", "DRINK", "crimson")
	drink_create_failure.emit()
#endregion

#region Shadow Signals
# Shadow finishes the set modifier animation.
signal shadow_finish_modifier_animation()
func signal_shadow_finish_modifier_animation() -> void:
	shadow_finish_modifier_animation.emit()

# Shadow finishes his drinking animation.
signal shadow_finish_drink_animation()
func signal_shadow_finish_drink_animation() -> void:
	LogIt.custom("Shadow animation finished!", "SHADOW", "lightblue")
	shadow_finish_drink_animation.emit()

signal modifier_changed(current: LimboState, _previous: LimboState)
func signal_modifier_changed(current: LimboState, _previous: LimboState) -> void:
	LogIt.custom("Modifier changed to %s from %s!" % [current.name, _previous.name], "MODIFIER", "chocolate")
	modifier_changed.emit(current, _previous)

signal assassin_let_go()
func signal_assassin_let_go() -> void:
	assassin_let_go.emit()
#endregion

#region Sanity Signals
# Penalize sanity by an amount.
signal sanity_penalize(amount: float)
func signal_sanity_penalize(amount: float) -> void:
	LogIt.custom("Penalized sanity by %f!" % amount, "SANITY", "darkorchid")
	sanity_penalize.emit(amount)

# Gain sanity by an amount.
signal sanity_gain(amount: float)
func signal_sanity_gain(amount: float) -> void:
	LogIt.custom("Gained %f sanity!" % amount, "SANITY", "fuchsia")
	sanity_gain.emit(amount)
#endregion

#region Game Signals
# Starts the game.
signal game_start()
func signal_game_start() -> void:
	LogIt.custom("Starting Game!", "GAME", "darkseagreen")
	game_start.emit()

# Ends the game.
signal game_end()
func signal_game_end() -> void:
	LogIt.custom("Ending Game!", "GAME", "sandybrown")
	game_end.emit()
#endregion

#region Camera Signals
# Fires when the camera changes state.
signal camera_changed_state(new_camera_state: GameStateResource.CAMERA_STATE)
func signal_camera_changed_state(new_camera_state: GameStateResource.CAMERA_STATE) -> void:
	camera_changed_state.emit(new_camera_state)

# Requests the camera state to be switched.
signal request_camera_change(new_camera_state: GameStateResource.CAMERA_STATE)
func signal_request_camera_change(new_camera_state: GameStateResource.CAMERA_STATE) -> void:
	request_camera_change.emit(new_camera_state)
#endregion

#region Shader Signals
# Toggles a shader.
signal shader_toggle(shader_type: ShaderModifier.SHADER_TYPES)
func signal_shader_toggle(shader_type: ShaderModifier.SHADER_TYPES) -> void:
	print("SHADER TOGGLING")
	shader_toggle.emit(shader_type)
#endregion
