extends RefCounted
class_name Helpers

static func require_instance_variables(node_path: NodePath, instances: Array[Variant]) -> void:
	for instance: Variant in instances:
		assert(is_instance_valid(instance), "❗A REQUIRED instance variable is null at %s. Ensure value(s) are set!" % [str(node_path)])
