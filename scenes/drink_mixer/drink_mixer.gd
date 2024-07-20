extends Node3D

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
var _is_first_ingredient: bool = true

func _ready() -> void:
	GlobalEventBus.successful_symbol_match.connect(func(ingredient: Ingredient, symbol: Array[int]) -> void:
		var mat: BaseMaterial3D = mesh_instance_3d.get_surface_override_material(0)
		var color_of_ingredient: Color = Color.html("#%s" % ingredient.color)
		if (_is_first_ingredient):
			mat.albedo_color = color_of_ingredient
			_is_first_ingredient = false
		else:
			mat.albedo_color = mat.albedo_color.lerp(color_of_ingredient, 0.5)

		mesh_instance_3d.set_surface_override_material(0, mat)
	)

	GlobalEventBus.successful_drink_create.connect(func() -> void:
		_reset_drink_color()
	)

	GlobalEventBus.failure_drink_create.connect(func() -> void:
		_reset_drink_color()
	)

func _reset_drink_color() -> void:
	_is_first_ingredient = true
	var mat: BaseMaterial3D = mesh_instance_3d.get_surface_override_material(0)
	mat.albedo_color = Color(0.0, 0.0, 0.0, 0.0)
	mesh_instance_3d.set_surface_override_material(0, mat)
