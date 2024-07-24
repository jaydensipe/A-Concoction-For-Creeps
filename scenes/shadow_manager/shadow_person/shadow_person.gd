extends Node3D
class_name ShadowPerson

@onready var speech_bubble: AnimatedSprite3D = $SpeechBubble

signal waiting_at_table

func _ready() -> void:
	_init_shadow_person()

func _init_shadow_person() -> void:
	create_tween().tween_property(self, ^"global_position:z", global_position.z - 1.5, 1.75).set_trans(Tween.TRANS_CIRC) \
		.finished.connect(func() -> void:
			GameState.game_state.ready_to_take_order = true
			speech_bubble.show()
			waiting_at_table.emit() \
		)

func _exit_tree() -> void:
	GameState.game_state.ready_to_take_order = false
