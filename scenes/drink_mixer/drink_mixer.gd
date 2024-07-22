extends Node3D

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var slide_right_marker_3d: Marker3D = $SlideRightMarker3D
@onready var reset_position_marker_3d: Marker3D = $ResetPositionMarker3D
@onready var slide_left_marker_3d: Marker3D = $SlideLeftMarker3D
@onready var _mat: BaseMaterial3D = mesh_instance_3d.get_surface_override_material(0)
var _is_first_ingredient: bool = true

func _ready() -> void:
	GlobalEventBus.successful_symbol_match.connect(func(ingredient: Ingredient, symbol: Array[int]) -> void:
		var color_of_ingredient: Color = Color.html("#%s" % ingredient.color)
		if (_is_first_ingredient):
			_mat.albedo_color = color_of_ingredient
			_is_first_ingredient = false
		else:
			_mat.albedo_color = _mat.albedo_color.lerp(color_of_ingredient, 0.5)

		mesh_instance_3d.set_surface_override_material(0, _mat)
	)

	GlobalEventBus.successful_drink_create.connect(func() -> void:
		#var mat: BaseMaterial3D = mesh_instance_3d.get_surface_override_material(0)
		#mat.albedo_color = Color.GREEN
		#mesh_instance_3d.set_surface_override_material(0, mat)
		_mix_and_serve_drink_animation()
	)

	GlobalEventBus.failure_symbol_match.connect(func(symbol: Array[int]) -> void:
		_reset_drink()
	)

	GlobalEventBus.failure_drink_create.connect(func() -> void:
		_reset_drink()
	)

func _reset_drink() -> void:
	_is_first_ingredient = true

	mesh_instance_3d.global_transform = global_transform
	_mat.albedo_color = Color(0.0, 0.0, 0.0, 0.0)
	mesh_instance_3d.set_surface_override_material(0, _mat)

func _mix_and_serve_drink_animation() -> void:
	# Slide to the right
	await create_tween().tween_property(mesh_instance_3d, ^"global_position", \
		slide_right_marker_3d.global_position, 0.5).set_trans(Tween.TRANS_EXPO).finished

	# Mix and slide back to the left
	await get_tree().create_timer(0.5).timeout
	mesh_instance_3d.global_transform = reset_position_marker_3d.global_transform
	await create_tween().tween_property(mesh_instance_3d, ^"global_position", \
		slide_left_marker_3d.global_position, 0.5).set_trans(Tween.TRANS_EXPO).finished

	# Give time to drink
	await get_tree().create_timer(0.5).timeout

	GlobalEventBus.signal_shadow_finish_drink_animation()
	_reset_drink()
