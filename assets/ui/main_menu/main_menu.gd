extends Control

@onready var play_button: Button = %PlayButton
@onready var check_button: CheckButton = %CheckButton
@onready var call_bell_audio: AudioStreamPlayer = $CallBellAudio

func _ready() -> void:
	play_button.pressed.connect(_start_game_press)
	check_button.pressed.connect(func() -> void:
		GameState.game_state.skip_intro = check_button.button_pressed
	)

func _start_game_press() -> void:
	ResonateIt.play_audio(call_bell_audio)
	GlobalEventBus.signal_game_start()
	queue_free()
