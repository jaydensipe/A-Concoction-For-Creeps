extends Trigger3D
class_name TriggerSoundscape3D

@export var spatial_audio: SpatialAudioStreamPlayer3D
@export_range(0, 10, 0.05, "suffix:s") var fade_time: float = 0.5
@export_group("Exterior")
@export var exterior_soundscape: TriggerSoundscape3D
@export_range(0, 100, 0.05, "suffix:dB") var reduction_db: float = 10.0
@export_range(0, 10, 0.05, "suffix:s") var exterior_fade_time: float = 1.0
var _playback_position: float = 0.0

func _ready() -> void:
	Helpers.require_instance_variables(get_path(), [spatial_audio])

	super()

	trigger_entered.connect(func(_body: Node3D) -> void:
		if (is_instance_valid(exterior_soundscape)):
			# Enable LPF on soundscape to diminish outdoor noise
			AudioServer.set_bus_effect_enabled(spatial_audio.bus_index, 0, true)

			# Reduce outdoor volume by reduction value
			create_tween().tween_property(exterior_soundscape.spatial_audio, "volume_db", exterior_soundscape.spatial_audio.volume_db - reduction_db, exterior_fade_time)

		create_tween().tween_property(spatial_audio, "volume_db", 0.0, fade_time)
		spatial_audio.play(_playback_position)
	)

	trigger_exited.connect(func(_body: Node3D) -> void:
		if (is_instance_valid(exterior_soundscape)):
			# Disable LPF on soundscape
			AudioServer.set_bus_effect_enabled(spatial_audio.bus_index, 0, false)

			# Reset reduced outdoor volume
			create_tween().tween_property(exterior_soundscape.spatial_audio, "volume_db", exterior_soundscape.spatial_audio.volume_db + reduction_db, exterior_fade_time)

		await create_tween().tween_property(spatial_audio, "volume_db", -80.0, fade_time).finished
		_playback_position = spatial_audio.get_playback_position()
		spatial_audio.stream_paused = true
	)
