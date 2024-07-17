@icon("res://addons/jaysreusablecomponentsandthings/assets/icons/icon_interaction_component.svg")
extends InteractionBase
class_name FPInteractionComponent

@export_group("Config")
@export var interact_range: float = 2.5
@export_group("Debug")
@export var show_debug: bool = false
var _ray_hit: Dictionary = {}

func _unhandled_key_input(event: InputEvent) -> void:
	if (event is InputEventKey):
		if (event.is_action_pressed(&"interact") and _hovering_interactable):
			(_ray_hit["collider"] as TriggerInteract3D).pressed()

func _physics_process(_delta: float) -> void:
	_ray_hit = RaycastIt.ray_from_camera_3d(interact_range, get_viewport().get_camera_3d(), show_debug, 0.01, [owner], true, true)

	if (!_ray_hit.is_empty() and _ray_hit["collider"] is TriggerInteract3D):
		_hovering_interactable = true

		if (!is_instance_valid(_current_hovered_interactable)):
			hovered_interactable.emit(_current_hovered_interactable)

		_current_hovered_interactable = _ray_hit["collider"]
	else:
		if (is_instance_valid(_current_hovered_interactable)):
			stopped_hovering.emit(_current_hovered_interactable)

		_current_hovered_interactable = null
		_hovering_interactable = false
