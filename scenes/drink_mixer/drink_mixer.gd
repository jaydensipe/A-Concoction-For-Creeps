extends Node3D

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var slide_right_marker_3d: Marker3D = $SlideRightMarker3D
@onready var reset_position_marker_3d: Marker3D = $ResetPositionMarker3D
@onready var slide_left_marker_3d: Marker3D = $SlideLeftMarker3D
@onready var ingredient_spawn_point: Marker3D = $IngredientSpawnPoint
@onready var ingredient_move_to_mixer: Marker3D = $IngredientMoveToMixer
@onready var ingredient_move_to_drink: Marker3D = $IngredientMoveToDrink
@onready var glass_start_audio: AudioStreamPlayer3D = $MeshInstance3D/GlassStartAudio
@onready var shake_audio: AudioStreamPlayer3D = $MeshInstance3D/ShakeAudio
@onready var glass_end_audio: AudioStreamPlayer3D = $MeshInstance3D/GlassEndAudio
@onready var drip_audio: AudioStreamPlayer3D = $MeshInstance3D/DripAudio

@onready var _mat: BaseMaterial3D = mesh_instance_3d.get_surface_override_material(0)
var _is_first_ingredient: bool = true

func _ready() -> void:
	GlobalEventBus.ingredient_matches_wanted.connect(_add_ingredient_to_drink_and_change_color)
	GlobalEventBus.drink_create_success.connect(_mix_and_serve_drink_animation)
	GlobalEventBus.ingredient_match_failure.connect(func(_symbol: Array[int]) -> void: _reset_drink())
	GlobalEventBus.drink_create_failure.connect(_reset_drink)
	GlobalEventBus.shadow_finish_drink_animation.connect(_reset_drink)

func _reset_drink() -> void:
	_is_first_ingredient = true

	_mat.albedo_color = Color(0.0, 0.0, 0.0, 0.0)
	mesh_instance_3d.global_transform = ingredient_move_to_drink.global_transform
	mesh_instance_3d.set_surface_override_material(0, _mat)

func _add_ingredient_to_drink_and_change_color(ingredient: Ingredient) -> void:
	# Instantiate the ingredient model
	var model: Node3D = ingredient.model.instantiate()
	add_child(model)
	model.global_transform = ingredient_spawn_point.global_transform

	# Animate model going into drink
	var tween: Tween = create_tween().set_trans(Tween.TRANS_BACK)
	tween.tween_interval(0.15)
	tween.tween_property(model, ^"position:y", position.y + 0.5, 0.3).as_relative()
	tween.tween_interval(0.15)
	tween.tween_property(model, ^"global_position", ingredient_move_to_mixer.global_position, 0.3)
	tween.tween_interval(0.15)
	tween.parallel().tween_property(model, ^"global_position", ingredient_move_to_drink.global_position, 0.3)
	tween.parallel().tween_property(model, ^"scale", Vector3.ZERO, 0.3)
	tween.tween_callback(func() -> void:
		var color_of_ingredient: Color = Color.html("#%s" % ingredient.color)
		drip_audio.play()
		if (_is_first_ingredient):
			_mat.albedo_color = color_of_ingredient
			_is_first_ingredient = false
		else:
			_mat.albedo_color = _mat.albedo_color.lerp(color_of_ingredient, 0.5)

		model.queue_free()
		mesh_instance_3d.set_surface_override_material(0, _mat)
	)

func _mix_and_serve_drink_animation() -> void:
	await get_tree().create_timer(1.5).timeout

	# Slide to the right
	var tween: Tween = create_tween()
	tween.tween_interval(0.5)
	tween.parallel().tween_callback(func() -> void: glass_start_audio.play())
	tween.parallel().tween_property(mesh_instance_3d, ^"global_position", \
		slide_right_marker_3d.global_position, 0.5).set_trans(Tween.TRANS_EXPO)
	tween.tween_interval(0.5)
	tween.tween_callback(func() -> void: shake_audio.play())
	tween.tween_interval(1.0)
	tween.tween_callback(func() -> void: mesh_instance_3d.global_transform = reset_position_marker_3d.global_transform)
	tween.tween_interval(0.5)
	tween.parallel().tween_callback(func() -> void: glass_end_audio.play())
	tween.parallel().tween_property(mesh_instance_3d, ^"global_position", \
		slide_left_marker_3d.global_position, 1.5).set_trans(Tween.TRANS_EXPO)
	tween.tween_interval(0.5)
	tween.tween_callback(GlobalEventBus.signal_shadow_finish_drink_animation)
