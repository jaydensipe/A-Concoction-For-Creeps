extends Node

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
