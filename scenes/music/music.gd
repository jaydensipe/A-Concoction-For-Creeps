extends Node
class_name Music

@onready var _music_bus: int = AudioServer.get_bus_index(&"Music")
@onready var song_player: AudioStreamPlayer3D = $SongPlayer
@onready var reverse_song_player: AudioStreamPlayer3D = $ReverseSongPlayer

func _ready() -> void:
	GlobalEventBus.game_start.connect(_effect_remove)
	GlobalEventBus.game_end.connect(_effect_add)

func _effect_add() -> void:
	var lpf: AudioEffectLowPassFilter = AudioServer.get_bus_effect(_music_bus, 0)
	var pitch_shift: AudioEffectPitchShift = AudioServer.get_bus_effect(_music_bus, 1)
	var tween: Tween = create_tween().set_parallel()
	tween.tween_property(lpf, "cutoff_hz", 400.0, 2.0)
	tween.tween_property(pitch_shift, "pitch_scale", 0.5, 2.0)

func _effect_remove() -> void:
	var lpf: AudioEffectLowPassFilter = AudioServer.get_bus_effect(_music_bus, 0)
	var pitch_shift: AudioEffectPitchShift = AudioServer.get_bus_effect(_music_bus, 1)
	var tween: Tween = create_tween().set_parallel()
	tween.tween_property(lpf, "cutoff_hz", 10000.0, 3.0)
	tween.tween_property(pitch_shift, "pitch_scale", 1.0, 2.0)

func _modifier_show_up(reverser: bool = false) -> void:
	var lpf: AudioEffectLowPassFilter = AudioServer.get_bus_effect(_music_bus, 0)
	var pitch_shift: AudioEffectPitchShift = AudioServer.get_bus_effect(_music_bus, 1)
	var tween: Tween = create_tween().set_parallel()
	tween.tween_property(lpf, "cutoff_hz", 800.0 if reverser else 1000.0, 1.0)
	if (reverser):
		tween.tween_property(pitch_shift, "pitch_scale", 0.6, 2.0)

func _modifier_leave() -> void:
	var lpf: AudioEffectLowPassFilter = AudioServer.get_bus_effect(_music_bus, 0)
	var pitch_shift: AudioEffectPitchShift = AudioServer.get_bus_effect(_music_bus, 1)
	var tween: Tween = create_tween().set_parallel()
	tween.tween_property(lpf, "cutoff_hz", 10000.0, 2.0)
	tween.tween_property(pitch_shift, "pitch_scale", 1.0, 2.0)
