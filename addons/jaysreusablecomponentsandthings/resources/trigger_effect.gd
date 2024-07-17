extends Resource
class_name TriggerEffect

@export_enum("BodyEnteredPropogate", "BodyExitedPropogate", "BodyEnteredNode", "BodyExitedNode") var trigger_type: int
@export var method_to_call: String
