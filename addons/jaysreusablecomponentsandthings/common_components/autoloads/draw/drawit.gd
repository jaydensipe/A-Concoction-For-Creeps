extends Node

# Code based on https://github.com/Ryan-Mirch/Line-and-Sphere-Drawing/blob/main/Draw3D.gd. Thank you!

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE

func draw_line_3d(from: Vector3, to: Vector3, color: Color = Color.RED, seconds_to_persist: float = 0.0) -> void:
	if (!DebugIt.is_global_debug_enabled): return

	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var immediate_mesh: ImmediateMesh = ImmediateMesh.new()
	var material: ORMMaterial3D = ORMMaterial3D.new()

	mesh_instance.mesh = immediate_mesh

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(from)
	immediate_mesh.surface_add_vertex(to)
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color

	instantiate_and_cleanup(mesh_instance, seconds_to_persist)

func draw_sphere_3d(position: Vector3, radius: float = 0.05, color: Color = Color.RED, seconds_to_persist: float = 0.0) -> void:
	if (!DebugIt.is_global_debug_enabled): return

	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var sphere_mesh: SphereMesh =  SphereMesh.new()
	var material: ORMMaterial3D = ORMMaterial3D.new()

	mesh_instance.mesh = sphere_mesh
	mesh_instance.position = position

	sphere_mesh.radius = radius
	sphere_mesh.height = radius * 2
	sphere_mesh.material = material

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color

	instantiate_and_cleanup(mesh_instance, seconds_to_persist)

func draw_wireframe_sphere_3d(position: Vector3, radius: float = 0.05, seconds_to_persist: float = 0.0) -> void:
	if (!DebugIt.is_global_debug_enabled): return

	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var sphere_shape: SphereShape3D =  SphereShape3D.new()

	sphere_shape.radius = radius

	mesh_instance.mesh = sphere_shape.get_debug_mesh()
	mesh_instance.position = position

	instantiate_and_cleanup(mesh_instance, seconds_to_persist)

func draw_box_3d(position: Vector3, size: Vector3, color: Color = Color.RED, seconds_to_persist: float = 0.0) -> void:
	if (!DebugIt.is_global_debug_enabled): return

	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var box_mesh: BoxMesh =  BoxMesh.new()
	var material: ORMMaterial3D = ORMMaterial3D.new()

	mesh_instance.mesh = box_mesh
	mesh_instance.position = position

	box_mesh.size = Vector3(size.x, size.y, size.z)
	box_mesh.material = material

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color

	instantiate_and_cleanup(mesh_instance, seconds_to_persist)

func draw_wireframe_box_3d(position: Vector3, size: Vector3, seconds_to_persist: float = 0.0) -> void:
	if (!DebugIt.is_global_debug_enabled): return

	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var box_shape: BoxShape3D =  BoxShape3D.new()

	box_shape.size = Vector3(size.x, size.y, size.z)

	mesh_instance.mesh = box_shape.get_debug_mesh()
	mesh_instance.position = position

	instantiate_and_cleanup(mesh_instance, seconds_to_persist)

func instantiate_and_cleanup(mesh_instance: MeshInstance3D, seconds_to_persist: float) -> void:
	var rendering_server: RID = RenderingServer.instance_create2(mesh_instance.mesh, get_viewport().get_camera_3d().get_world_3d().scenario)
	RenderingServer.instance_set_transform(rendering_server, mesh_instance.transform)
	RenderingServer.instance_geometry_set_cast_shadows_setting(rendering_server, RenderingServer.SHADOW_CASTING_SETTING_OFF)

	if (seconds_to_persist > 0.0):
		await get_tree().create_timer(seconds_to_persist, false).timeout

	mesh_instance.queue_free()
	RenderingServer.free_rid(rendering_server)
