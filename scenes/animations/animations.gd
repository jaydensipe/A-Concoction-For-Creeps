extends Node
class_name Animations

func _ready() -> void:
		GlobalEventBus.shadow_finish_drink_animation.connect(_process_modifier_animation)

func _process_modifier_animation() -> void:
	var current_state: LimboState = GameState.game_state.modifier_hsm.get_active_state()
	match (current_state.name):
		&"Assassin":
			_assassin_animation()
		_:
			GlobalEventBus.signal_shadow_finish_modifier_animation()

	LogIt.custom("Processing %s animation!" % current_state.name, "ANIMATION", "dodgerblue")

func _assassin_animation(remove: bool = false) -> void:
	await get_tree().create_timer(10.0).timeout

	GlobalEventBus.signal_shadow_finish_modifier_animation()
