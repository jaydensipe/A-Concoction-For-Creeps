extends Node3D
class_name MagicalTablet

var holding_m1: bool = false

func _physics_process(delta: float) -> void:
	if (Input.is_action_pressed(&"mouse_primary_fire")):
		holding_m1 = true
	else:
		if (holding_m1 and !Game.is_board_empty()): GlobalEventBus.signal_lock_in()

		holding_m1 = false
