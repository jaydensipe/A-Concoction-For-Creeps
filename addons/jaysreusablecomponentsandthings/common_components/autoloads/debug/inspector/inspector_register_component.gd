@icon("res://addons/jaysreusablecomponentsandthings/assets/icons/icon_inspector_register.svg")
extends Node
class_name InspectorRegister

@export_flags("Scene Children", "Export Variables", "Script Variables") var show_properties: = 0x7

func _ready() -> void:
	DebugIt.register_in_inspector(get_parent(), show_properties)
