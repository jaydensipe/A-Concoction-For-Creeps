extends Node

signal activation_sphere_selected()
func signal_activation_sphere_selected(sphere_index: int) -> void:
	activation_sphere_selected.emit(sphere_index)

signal lock_in()
func signal_lock_in() -> void:
	lock_in.emit()

signal clear_board()
func signal_clear_board() -> void:
	clear_board.emit()

signal successful_symbol_match
func signal_successful_symbol_match(symbol_name: StringName, symbol_tier: int, symbol: Array[int]) -> void:
	LogIt.custom("Symbol successfully matched: %s, tier %d" % [symbol_name, symbol_tier], "SUCCESS", "green")
	successful_symbol_match.emit(symbol_name, symbol_tier, symbol)

signal failure_symbol_match
func signal_failure_symbol_match(symbol: Array[int]) -> void:
	LogIt.custom("Symbol match failed!", "FAILED", "red")
	failure_symbol_match.emit(symbol)
