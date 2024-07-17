extends Marker3D
class_name SpawnBase

@export_group("Config")
@export var enable_delay: bool = false
@export_range(0, 60, 0.1, "suffix:s") var spawn_delay_time: float = 0.0
@export var enable_delete: bool = false
@export_range(0, 60, 0.1, "suffix:s") var delete_time: float = 0.0

@export_subgroup("Randomization")
@export var randomize_x: bool = false
@export var randomize_y: bool = false
@export var randomize_z: bool = false

func _check_delete_timer(instance: Node3D) -> void:
	if (enable_delete):
		get_tree().create_timer(delete_time).timeout.connect(func() -> void: instance.queue_free())

func _check_delete_timer_rid(rid: RID) -> void:
	if (enable_delete):
		get_tree().create_timer(delete_time).timeout.connect(func() -> void: RenderingServer.free_rid(rid))

func _check_spawn_delay() -> void:
	if (enable_delay):
		await get_tree().create_timer(spawn_delay_time).timeout

func _check_randomize_position(instance: Node3D) -> Node3D:
	if (randomize_x):
		instance.rotation_degrees = Vector3(randf_range(0, 360), 0.0, 0.0)
	if (randomize_y):
		instance.rotation_degrees = Vector3(0.0, randf_range(0, 360), 0.0)
	if (randomize_z):
		instance.rotation_degrees = Vector3(0.0, 0.0, randf_range(0, 360))

	return instance
