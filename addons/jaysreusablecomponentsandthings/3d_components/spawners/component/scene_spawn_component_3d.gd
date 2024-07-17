@icon("res://addons/jaysreusablecomponentsandthings/assets/icons/icon_scene_spawn_component_3d.svg")
extends SpawnBase
class_name SceneSpawnComponent3D

# Logic used from https://github.com/uheartbeast/Galaxy-Defiance. Thank you!

@export var scene: PackedScene

func _ready() -> void:
	Helpers.require_instance_variables(get_path(), [scene])

func spawn_at_location(spawn_position: Vector3 = global_position, parent: Node = get_tree().current_scene) -> Node3D:
	await _check_spawn_delay()

	var instance: Node3D = scene.instantiate()
	parent.add_child(instance)
	instance.position = spawn_position
	instance = _check_randomize_position(instance)

	_check_delete_timer(instance)

	return instance

func spawn_at_location_with_transform(spawn_transform: Transform3D = global_transform, parent: Node = get_tree().current_scene) -> Node3D:
	await _check_spawn_delay()

	var instance: Node3D = scene.instantiate()
	parent.add_child(instance)
	instance.transform = spawn_transform
	instance = _check_randomize_position(instance)

	_check_delete_timer(instance)

	return instance

func spawn_at_location_with_normal(normal: Vector3, spawn_position: Vector3 = global_position, parent: Node = get_tree().current_scene) -> Node3D:
	await _check_spawn_delay()

	var instance: Node3D = scene.instantiate()
	parent.add_child(instance)
	instance.position = spawn_position

	# Ensure instance uses normal from spawn position
	if (normal != Vector3.UP and normal != Vector3.DOWN):
		instance.look_at(spawn_position + normal)
		instance.rotate_object_local(Vector3.RIGHT, 90)

	_check_delete_timer(instance)

	return instance
