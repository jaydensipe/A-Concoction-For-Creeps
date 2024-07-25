extends Node3D
class_name MagicalTablet

@onready var fail_sound: AudioStreamPlayer = $FailSound
@onready var success_sound: AudioStreamPlayer = $SuccessSound

func _ready() -> void:
	GlobalEventBus.ingredient_match_failure.connect(func(symbol: Array[int]) -> void:
		fail_sound.play()
	)
	GlobalEventBus.drink_create_failure.connect(func() -> void:
		fail_sound.play()
	)
	GlobalEventBus.ingredient_matches_wanted.connect(func(ingredient: Ingredient) -> void:
		success_sound.pitch_scale = 0.95 + (GameState.game_state.current_correct_ingredient_count * 0.15)
		success_sound.play()
	)

func _physics_process(_delta: float) -> void:
	if (!GameState.game_state.ready_to_take_order): return

	if (Input.is_action_pressed(&"mouse_primary_fire")):
		GameState.game_state.holding_mouse_button_down = true
	else:
		if (GameState.game_state.holding_mouse_button_down and !Game.is_board_empty()): GlobalEventBus.signal_symbol_lock_in()

		GameState.game_state.holding_mouse_button_down = false
