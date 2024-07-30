extends VBoxContainer

@onready var sanity_progress_bar: TextureProgressBar = %SanityProgressBar
@onready var sanity_amount: Label = %SanityAmount

func _process(_delta: float) -> void:
	sanity_progress_bar.value = GameState.game_state.sanity_level
	sanity_amount.text = "%d/100" % clampi(GameState.game_state.sanity_level, 0.0, 100.0)

func _on_sanity_progress_bar_mouse_entered() -> void:
	sanity_amount.show()

func _on_sanity_progress_bar_mouse_exited() -> void:
	sanity_amount.hide()
