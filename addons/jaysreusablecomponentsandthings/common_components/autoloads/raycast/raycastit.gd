extends Node

func ray_from_camera_3d(max_distance: float = 1.0, camera: Camera3D = get_viewport().get_camera_3d(), show_debug: bool = false, debug_stay_time: float = 0.1, exclusions: Array[RID] = [], collide_with_bodies: bool = true, collide_with_areas: bool = false, collision_mask: int = 0xFFFFFFFF) -> Dictionary:
	var world: World3D = camera.get_world_3d()
	var center_of_camera: Vector2 = get_viewport().get_window().size / 2
	var ray_origin: Vector3 = camera.project_ray_origin(center_of_camera)
	var ray_dir: Vector3 = camera.project_ray_normal(center_of_camera) * max_distance
	var ray_end: Vector3 = ray_origin + ray_dir
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.exclude = exclusions
	query.collision_mask = collision_mask
	query.collide_with_bodies = collide_with_bodies
	query.collide_with_areas = collide_with_areas

	var result: Dictionary = world.direct_space_state.intersect_ray(query)
	if (show_debug):
		DrawIt.draw_line_3d(ray_origin, ray_end, Color.GREEN if result.is_empty() else Color.RED, debug_stay_time)
		if (!result.is_empty()):
			DrawIt.draw_wireframe_sphere_3d(result["position"], 0.25, debug_stay_time)

	return result

func ray_3d(from: Transform3D, to: Vector3, max_distance: float = 1.0, show_debug: bool = false, debug_stay_time: float = 0.1, exclusions: Array[RID] = [], collide_with_bodies: bool = true, collide_with_areas: bool = false, collision_mask: int = 0xFFFFFFFF) -> Dictionary:
	var world: World3D = get_viewport().get_camera_3d().get_world_3d()
	var origin: Vector3 = from.origin
	var destination: Vector3 = from * (to * max_distance)
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, destination)
	query.exclude = exclusions
	query.collision_mask = collision_mask
	query.collide_with_bodies = collide_with_bodies
	query.collide_with_areas = collide_with_areas

	var result: Dictionary = world.direct_space_state.intersect_ray(query)
	if (show_debug):
		DrawIt.draw_line_3d(origin, destination, Color.GREEN if result.is_empty() else Color.RED, debug_stay_time)
		if (!result.is_empty()):
			DrawIt.draw_wireframe_sphere_3d(result["position"], 0.25, debug_stay_time)

	return result
