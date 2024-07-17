@icon("res://addons/jaysreusablecomponentsandthings/assets/icons/icon_decal_spawn_component_3d.svg")
extends SpawnBase
class_name DecalSpawnComponent3D

@export var decal_scene: PackedScene
@onready var _decal: Decal = decal_scene.instantiate()

func _ready() -> void:
	Helpers.require_instance_variables(get_path(), [decal_scene])

func spawn_decal_at_transfrom(normal: Vector3, spawn_transform: Transform3D) -> void:
	await _check_spawn_delay()

	var decal_rid: RID = RenderingServer.decal_create()
	var rendering_server: RID = RenderingServer.instance_create2(decal_rid, get_viewport().get_camera_3d().get_world_3d().scenario)

	# Ensure instance uses normal from spawn
	if (normal != Vector3.UP and normal != Vector3.DOWN):
		spawn_transform = spawn_transform.looking_at(spawn_transform.origin + normal)
		spawn_transform = spawn_transform.rotated_local(Vector3.RIGHT, 90)

	# Create Decal instance from scene using RenderingServer
	RenderingServer.instance_set_transform(rendering_server, spawn_transform)
	RenderingServer.decal_set_albedo_mix(decal_rid, _decal.albedo_mix)
	RenderingServer.decal_set_cull_mask(decal_rid, _decal.cull_mask)
	RenderingServer.decal_set_distance_fade(decal_rid, _decal.distance_fade_enabled, _decal.distance_fade_begin, _decal.distance_fade_length)
	RenderingServer.decal_set_emission_energy(decal_rid, _decal.emission_energy)
	RenderingServer.decal_set_fade(decal_rid, _decal.upper_fade, _decal.lower_fade)
	RenderingServer.decal_set_modulate(decal_rid, _decal.modulate)
	RenderingServer.decal_set_normal_fade(decal_rid, _decal.normal_fade)
	RenderingServer.decal_set_size(decal_rid, _decal.size)
	RenderingServer.decal_set_texture(decal_rid, RenderingServer.DECAL_TEXTURE_ALBEDO, _decal.texture_albedo.get_rid())
	#RenderingServer.decal_set_texture(decal_rid, RenderingServer.DECAL_TEXTURE_EMISSION, _decal.texture_emission.get_rid())
	#RenderingServer.decal_set_texture(decal_rid, RenderingServer.DECAL_TEXTURE_NORMAL, _decal.texture_normal.get_rid())
	#RenderingServer.decal_set_texture(decal_rid, RenderingServer.DECAL_TEXTURE_ORM, _decal.texture_orm.get_rid())

	_check_delete_timer_rid(decal_rid)
