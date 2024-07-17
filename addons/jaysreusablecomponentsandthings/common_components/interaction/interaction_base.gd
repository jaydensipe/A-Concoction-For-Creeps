extends Node
class_name InteractionBase

var _hovering_interactable: bool = false
var _current_hovered_interactable: TriggerInteract3D = null

@warning_ignore("unused_signal")
signal hovered_interactable(interactable: TriggerInteract3D)
@warning_ignore("unused_signal")
signal stopped_hovering(interactable: TriggerInteract3D)

func is_hovering_interactable() -> bool:
	return _hovering_interactable

func get_current_hovered_interactable() -> TriggerInteract3D:
	return _current_hovered_interactable
