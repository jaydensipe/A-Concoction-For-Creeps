extends Trigger3D
class_name TriggerTeleport3D

@export_enum("BodyEntered", "BodyExited") var trigger_type: int = 0
@export var marker: Marker3D = null

func _ready() -> void:
	Helpers.require_instance_variables(get_path(), [marker])

	super()

	if (trigger_type == 0):
		trigger_entered.connect(func(body: Node3D) -> void:
			body.global_position = marker.global_position
		)
	else:
		trigger_exited.connect(func(body: Node3D) -> void:
			body.global_position = marker.global_position
		)
