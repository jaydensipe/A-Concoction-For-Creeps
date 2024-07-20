extends Node3D
class_name ShadowPerson

signal waiting_at_table

func _ready() -> void:
	get_tree().create_tween().tween_property(self, ^"global_position:z", global_position.z - 1.5, 1.0).set_trans(Tween.TRANS_CIRC) \
		.finished.connect(func() -> void: \
			waiting_at_table.emit()
		)
