extends Node3D
class_name ShadowPerson

signal waiting_at_table

func _ready() -> void:
	_init_shadow_person()

func _init_shadow_person() -> void:
	get_tree().create_tween().tween_property(self, ^"global_position:z", global_position.z - 1.5, 1.0).set_trans(Tween.TRANS_CIRC) \
		.finished.connect(func() -> void:
			GameState.ready_to_take_order = true
			waiting_at_table.emit() \
		)

func _exit_tree() -> void:
	GameState.ready_to_take_order = false
