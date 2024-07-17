@icon("res://addons/jaysreusablecomponentsandthings/assets/icons/icon_weapon_component.svg")
extends Node
class_name WeaponComponent

@export var _weapon_stats: WeaponStats
var _primary_held: bool = false
var _alternate_held: bool = false

signal primary_pressed()
signal alternate_pressed()
signal reload_pressed()
signal primary_stopped_pressing()
signal alternate_stopped_pressing()

func _ready() -> void:
	Helpers.require_instance_variables(get_path(), [_weapon_stats])

func _physics_process(_delta: float) -> void:
	if (_primary_held):
		primary_pressed.emit()

	if (_alternate_held):
		alternate_pressed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed(&"mouse_primary_fire")):
		_primary_held = true

	if (event.is_action_pressed(&"mouse_alternate_fire")):
		_alternate_held = true

	if (event.is_action_pressed(&"reload")):
		reload_pressed.emit()

	if (event.is_action_released(&"mouse_primary_fire")):
		primary_stopped_pressing.emit()
		_primary_held = false

	if (event.is_action_released(&"mouse_alternate_fire")):
		alternate_stopped_pressing.emit()
		_alternate_held = false

func get_stats() -> WeaponStats:
	return _weapon_stats
