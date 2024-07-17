@icon("res://addons/jaysreusablecomponentsandthings/assets/icons/icon_reverb_handler_3d.svg")
extends Node3D
class_name ReverbHandler3D

# Based on https://youtu.be/BrUQdd96qzk.

@export var audio_bus_name: String
@export var max_raycasts: int = 12
@export var max_ray_range: float = 500.0
@export_group("Reverb")
@export var wetness_subtract: float = 3.0
@export var max_wetness: float = 0.5
@export var room_size_scalar: float = 2.75
@export var lerp_speed: float = 5.0
@export_group("Debug")
@export var show_debug: bool = false

@onready var _applied_audio_bus_index: int = AudioServer.get_bus_index(audio_bus_name)
@onready var _bus_effect_index: int = AudioServer.get_bus_effect_count(_applied_audio_bus_index)
var _reverb_effect: AudioEffectReverb
var _hit_lengths: PackedFloat32Array = []

func _ready() -> void:
	_init_reverb_effect()

	_hit_lengths.resize(max_raycasts)

func _init_reverb_effect() -> void:
	AudioServer.add_bus_effect(_applied_audio_bus_index, AudioEffectReverb.new(), _bus_effect_index)
	_reverb_effect = AudioServer.get_bus_effect(_applied_audio_bus_index, _bus_effect_index)

func _physics_process(delta: float) -> void:
	# Shoot rays in random direction
	for ray in range(max_raycasts):
		var result: Dictionary = RaycastIt.ray_3d(global_transform, Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(randf_range(-360, 360))).rotated(Vector3.LEFT, deg_to_rad(randf_range(-360, 360))), max_ray_range, show_debug)

		if (result):
			_hit_lengths[ray] = global_position.distance_squared_to(result["position"])
		else:
			_hit_lengths[ray] = -1.0

	# Scale room size and wetness based on ray lengths
	var room_size: float = 0.0
	var wetness: float = 1.0
	for length: float in _hit_lengths:
		if (length != -1):
			room_size += (length / max_ray_range) / float(_hit_lengths.size()) * room_size_scalar
			room_size = min(room_size, 1.0)
		else:
			wetness -= wetness_subtract / float(_hit_lengths.size())
			wetness = max(wetness, 0.0)

	# Add damping based off of hit material?
	_reverb_effect.wet =  lerp(_reverb_effect.wet, wetness * max_wetness, delta * lerp_speed)
	_reverb_effect.room_size =  lerp(_reverb_effect.room_size, room_size, delta * lerp_speed)
