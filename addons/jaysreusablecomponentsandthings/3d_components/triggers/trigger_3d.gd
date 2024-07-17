@icon("res://addons/jaysreusablecomponentsandthings/assets/icons/icon_trigger_3d.svg")
extends Area3D
class_name Trigger3D

@export_enum("Multiple", "Once") var trigger_variety: int = 0
var triggered: bool = false

signal trigger_entered(body: Node3D)
signal trigger_exited(body: Node3D)

func _ready() -> void:
	body_entered.connect(func(body: Node3D) -> void:
		# If trigger variety is once, return if already triggered
		if (trigger_variety == 1 and triggered): return

		trigger_entered.emit(body)
		triggered = true
	)

	body_exited.connect(func(body: Node3D) -> void:
		# If trigger variety is once, return if already triggered
		if (trigger_variety == 1 and triggered): return

		trigger_exited.emit(body)
		triggered = false
	)
