extends Node3D
class_name FPItem3D

@export var viewmodel_origin: Vector3 = Vector3(0.0, 0.0, 0.0) :
	set(value):
		transform.origin = value
		viewmodel_origin = value
