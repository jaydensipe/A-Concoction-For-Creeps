extends Trigger3D
class_name TriggerFunction3D

@export var node: Node = null
@export var triggers: Array[TriggerEffect]

func _ready() -> void:
	Helpers.require_instance_variables(get_path(), [node])

	super()

	for trigger: TriggerEffect in triggers:
		match (trigger.trigger_type):
			0:
				trigger_entered.connect(func(body: Node3D) -> void:
					body.propagate_call(trigger.method_to_call)
				)
			1:
				trigger_exited.connect(func(body: Node3D) -> void:
					body.propagate_call(trigger.method_to_call)
				)
			2:
				assert(node != null, "Ensure Node is not null if trying to use a Node Trigger Effect.")
				trigger_entered.connect(func(body: Node3D) -> void:
					node.call(trigger.method_to_call)
				)
			3:
				assert(node != null, "Ensure Node is not null if trying to use a Node Trigger Effect.")
				trigger_exited.connect(func(body: Node3D) -> void:
					node.call(trigger.method_to_call)
				)
