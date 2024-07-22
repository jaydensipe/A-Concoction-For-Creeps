extends Node

#region Symbol Signals
signal lock_in()
func signal_lock_in() -> void:
	lock_in.emit()

signal clear_board()
func signal_clear_board() -> void:
	clear_board.emit()

signal activation_sphere_selected()
func signal_activation_sphere_selected(sphere_index: int) -> void:
	activation_sphere_selected.emit(sphere_index)

signal successful_symbol_match()
func signal_successful_symbol_match(ingredient: Ingredient, symbol: Array[int]) -> void:
	LogIt.custom("Symbol successfully matched: %s, tier %d" % [ingredient.ingredient_name, ingredient.tier], "SIGNAL", "green")
	successful_symbol_match.emit(ingredient, symbol)

signal failure_symbol_match()
func signal_failure_symbol_match(symbol: Array[int]) -> void:
	LogIt.custom("No symbol matches drawing!", "SIGNAL", "red")
	failure_symbol_match.emit(symbol)
#endregion

#region Drink Signals
signal successful_drink_create()
func signal_successful_drink_create() -> void:
	LogIt.custom("Created the correct drink!", "SIGNAL", "springgreen")
	successful_drink_create.emit()

signal failure_drink_create()
func signal_failure_drink_create() -> void:
	LogIt.custom("Failed to create correct drink!", "SIGNAL", "crimson")
	failure_drink_create.emit()

signal shadow_finish_drink_animation()
func signal_shadow_finish_drink_animation() -> void:
	LogIt.custom("Shadow animation finished!", "SIGNAL", "lightblue")
	shadow_finish_drink_animation.emit()
#endregion

#region Sanity Signals
signal penalized_sanity(amount: float)
func signal_penalized_sanity(amount: float) -> void:
	LogIt.custom("Penalized sanity by %f!" % amount, "SIGNAL", "darkorchid")
	penalized_sanity.emit(amount)

signal gain_sanity(amount: float)
func signal_gain_sanity(amount: float) -> void:
	LogIt.custom("Gained %f sanity!" % amount, "SIGNAL", "fuchsia")
	gain_sanity.emit(amount)
#endregion

#region Game Signals
signal start_game()
func signal_start_game() -> void:
	LogIt.custom("Starting Game!", "SIGNAL", "darkseagreen")
	start_game.emit()

signal end_game()
func signal_end_game() -> void:
	LogIt.custom("Ending Game!", "SIGNAL", "sandybrown")
	end_game.emit()

signal camera_changed_state(new_camera_state: Game.CAMERA_STATE)
func signal_camera_changed_state(new_camera_state: Game.CAMERA_STATE) -> void:
	camera_changed_state.emit(new_camera_state)
#endregion
