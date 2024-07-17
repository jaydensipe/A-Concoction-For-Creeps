extends AudioStreamPlayer3D
class_name SpatialAudioStreamPlayer3D

# Created with help from https://youtu.be/mHokBQyB_08. Thanks!

@export_enum("Spatial", "Soundscape") var sound_type: int = 0
@export_enum("Single Raycast", "Multi-Raycast") var occlusion_type: int = 0
@export_flags_3d_physics var static_geometry_layers: int
@onready var _current_bus_index: int = AudioServer.bus_count
@onready var _current_bus_name: StringName = "SpatialBus#%d" % _current_bus_index
@onready var _single_raycast_3d: RayCast3D
var _lpf_effect: AudioEffectLowPassFilter

func _ready() -> void:
	match (sound_type):
		0:
			_init_bus()
			if (occlusion_type == 0):
				_init_single_ray()
		1:
			attenuation_model = ATTENUATION_DISABLED
			panning_strength = 0.0

func _physics_process(_delta: float) -> void:
	if (sound_type == 1): return

	match (occlusion_type):
		0:
			_process_single_ray()
		1:
			_process_multi_ray()

func _init_bus() -> void:
	AudioServer.add_bus(_current_bus_index)
	AudioServer.set_bus_name(_current_bus_index, _current_bus_name)
	AudioServer.set_bus_send(_current_bus_index, bus)
	AudioServer.add_bus_effect(_current_bus_index, AudioEffectLowPassFilter.new(), 0)
	_lpf_effect = AudioServer.get_bus_effect(_current_bus_index, 0)

	bus = _current_bus_name

func _init_single_ray() -> void:
	_single_raycast_3d = RayCast3D.new()
	_single_raycast_3d.collision_mask = static_geometry_layers

	add_child(_single_raycast_3d)

func _process_single_ray() -> void:
	_single_raycast_3d.target_position = to_local(get_viewport().get_camera_3d().global_position)

	if (_single_raycast_3d.is_colliding()):
		var _min_cutoff: float = 5000.0
		_lpf_effect.cutoff_hz = lerpf(_lpf_effect.cutoff_hz, max(1000, _min_cutoff - (_single_raycast_3d.get_collision_point().distance_squared_to(to_local(get_viewport().get_camera_3d().global_position))) * 20.0), get_physics_process_delta_time() * 2.0)
	else:
		_lpf_effect.cutoff_hz =  lerpf(_lpf_effect.cutoff_hz, 20000.0, get_physics_process_delta_time() * 2.0)

func _process_multi_ray() -> void:
	var cam_position: Vector3 = to_local(get_tree().get_nodes_in_group("player")[0].global_position)
	RaycastIt.ray_3d(global_transform, cam_position, 1.0, true, 0.01)

	var left_cam_position: Vector3 = to_local(get_tree().get_nodes_in_group("player")[0].global_transform.origin + get_tree().get_nodes_in_group("player")[0].global_basis.x * 2.0)
	RaycastIt.ray_3d(global_transform, left_cam_position, 1.0, true, 0.01)

	var right_cam_position: Vector3 = to_local(get_tree().get_nodes_in_group("player")[0].global_transform.origin - get_tree().get_nodes_in_group("player")[0].global_basis.x * 2.0)
	RaycastIt.ray_3d(global_transform, right_cam_position, 1.0, true, 0.01)
