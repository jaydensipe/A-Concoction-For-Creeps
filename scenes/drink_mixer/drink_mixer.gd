extends Node3D

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var slide_right_marker_3d: Marker3D = $SlideRightMarker3D
@onready var reset_position_marker_3d: Marker3D = $ResetPositionMarker3D
@onready var slide_left_marker_3d: Marker3D = $SlideLeftMarker3D
@onready var ingredient_spawn_point: Marker3D = $IngredientSpawnPoint
@onready var ingredient_move_to_mixer: Marker3D = $IngredientMoveToMixer
@onready var ingredient_move_to_drink: Marker3D = $IngredientMoveToDrink
@onready var _mat: BaseMaterial3D = mesh_instance_3d.get_surface_override_material(0)
var _is_first_ingredient: bool = true

signal finished_adding_ingredient()

func _ready() -> void:
	GlobalEventBus.ingredient_matches_wanted.connect(_add_ingredient_to_drink_and_change_color)
	GlobalEventBus.drink_create_success.connect(_mix_and_serve_drink_animation)
	GlobalEventBus.ingredient_match_failure.connect(func(_symbol: Array[int]) -> void: _reset_drink())
	GlobalEventBus.drink_create_failure.connect(_reset_drink)
	GlobalEventBus.shadow_finish_drink_animation.connect(_reset_drink)

func _reset_drink() -> void:
	_is_first_ingredient = true

	_mat.albedo_color = Color(0.0, 0.0, 0.0, 0.0)
	mesh_instance_3d.global_transform = global_transform
	mesh_instance_3d.set_surface_override_material(0, _mat)

func _add_ingredient_to_drink_and_change_color(ingredient: Ingredient) -> void:
	# Instantiate the ingredient model
	var model: Node3D = ingredient.model.instantiate()
	model.scale_object_local(Vector3(0.25, 0.25, 0.25))
	model.global_transform = ingredient_spawn_point.global_transform
	add_child(model)

	var tween: Tween = create_tween()
	tween.tween_property(model, ^"global_transform", ingredient_move_to_mixer.global_transform, 0.1).set_trans(Tween.TRANS_BACK)
	tween.tween_interval(0.25)
	tween.tween_property(model, ^"global_transform", ingredient_move_to_drink.global_transform, 0.2).set_trans(Tween.TRANS_BACK)
	tween.tween_callback(func() -> void:
		var color_of_ingredient: Color = Color.html("#%s" % ingredient.color)
		if (_is_first_ingredient):
			_mat.albedo_color = color_of_ingredient
			_is_first_ingredient = false
		else:
			_mat.albedo_color = _mat.albedo_color.lerp(color_of_ingredient, 0.5)

		model.queue_free()
		mesh_instance_3d.set_surface_override_material(0, _mat)
	)

func _mix_and_serve_drink_animation() -> void:
	# Slide to the right
	var tween: Tween = create_tween()
	tween.tween_interval(0.5)
	tween.tween_property(mesh_instance_3d, ^"global_position", \
		slide_right_marker_3d.global_position, 0.5).set_trans(Tween.TRANS_EXPO)
	tween.tween_interval(0.5)
	tween.tween_callback(func() -> void:mesh_instance_3d.global_transform = reset_position_marker_3d.global_transform)
	tween.tween_property(mesh_instance_3d, ^"global_position", \
		slide_left_marker_3d.global_position, 0.5).set_trans(Tween.TRANS_EXPO)
	tween.tween_interval(0.5)
	tween.tween_callback(GlobalEventBus.signal_shadow_finish_drink_animation)
