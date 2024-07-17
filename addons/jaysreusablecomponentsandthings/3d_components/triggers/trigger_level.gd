extends Trigger3D
class_name TriggerLevel3D

@export_enum("BodyEntered", "BodyExited") var trigger_type: int = 0
@export var level_name: StringName

func _ready() -> void:
	super()

	if (trigger_type == 0):
		trigger_entered.connect(func(body: Node3D) -> void:
			LevelIt.load_level_by_name(level_name, LevelIt.DELETE_TYPE.QUEUE_FREE)
		)
	else:
		trigger_exited.connect(func(body: Node3D) -> void:
			LevelIt.load_level_by_name(level_name, LevelIt.DELETE_TYPE.QUEUE_FREE)
		)
