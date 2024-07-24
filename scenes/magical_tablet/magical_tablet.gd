extends Node3D
class_name MagicalTablet

func _physics_process(_delta: float) -> void:
	if (!GameState.game_state.ready_to_take_order): return

	if (Input.is_action_pressed(&"mouse_primary_fire")):
		GameState.game_state.holding_mouse_button_down = true
	else:
		if (GameState.game_state.holding_mouse_button_down and !Game.is_board_empty()): GlobalEventBus.signal_symbol_lock_in()

		GameState.game_state.holding_mouse_button_down = false
