extends Control

@onready var sanity_progress_bar: TextureProgressBar = %SanityProgressBar

func _process(_delta: float) -> void:
	sanity_progress_bar.value = GameState.game_state.sanity_level
