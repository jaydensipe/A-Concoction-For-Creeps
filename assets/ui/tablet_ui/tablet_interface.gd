extends Control

func _on_area_2d_mouse_entered() -> void:
		LogIt.info("yeah!@")

func _unhandled_input(event: InputEvent) -> void:
	print("asdsad")

func _on_mouse_entered() -> void:
	print("asdsad")

func convert_coordinates(position: Vector3) -> void:
	pass


func _on_circle_1_mouse_entered() -> void:
	print("asdsad")
