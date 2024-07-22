extends Control

@onready var play_button: Button = %PlayButton
@onready var check_button: CheckButton = %CheckButton

func _ready() -> void:
	play_button.pressed.connect(_start_game_press)
	check_button.pressed.connect(func() -> void:
		GameState.game_state.skip_intro = check_button.button_pressed
	)

func _start_game_press() -> void:
	GlobalEventBus.signal_start_game()
	queue_free()
