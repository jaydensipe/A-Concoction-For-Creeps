extends Node3D
class_name MagicalTablet

func _physics_process(delta: float) -> void:
	if (!GameState.ready_to_take_order): return

	if (Input.is_action_pressed(&"mouse_primary_fire")):
		GameState.holding_mouse_button_down = true
	else:
		if (GameState.holding_mouse_button_down and !Game.is_board_empty()): GlobalEventBus.signal_lock_in()

		GameState.holding_mouse_button_down = false
