extends Node
class_name Animations

@onready var music: Music = $"../Music"

# Assassin
@onready var assassin: Node = $Assassin
@onready var dagger_spawn: Marker3D = $Assassin/DaggerSpawn
@onready var dagger_move_book: Marker3D = $Assassin/DaggerMoveBook
@onready var knife_spawn_audio: AudioStreamPlayer3D = $Assassin/KnifeSpawnAudio
@onready var knife_swoosh_audio: AudioStreamPlayer3D = $Assassin/KnifeSwooshAudio
@onready var knife_impact_audio: AudioStreamPlayer3D = $Assassin/KnifeImpactAudio
const DAGGERMAIN = preload("res://assets/models/dagger/daggermain.tscn")

# Blinder
@onready var snap_audio: AudioStreamPlayer = $Blinder/SnapAudio

# Wraith
@onready var wraith_enter: AudioStreamPlayer = $Wraith/WraithEnter
@onready var wraith_music: AudioStreamPlayer = $Wraith/WraithMusic

func _ready() -> void:
		GlobalEventBus.shadow_finish_drink_animation.connect(_process_modifier_animation)
		GlobalEventBus.drink_create_success.connect(_process_modifier_animation.bind(true))

func _process_modifier_animation(reverse: bool = false) -> void:
	var current_state: LimboState = GameState.game_state.modifier_hsm.get_active_state()
	match (current_state.name):
		&"Assassin":
			_assassin_animation(reverse)
		&"Reverser":
			_reverser_animation(reverse)
		&"Blinder":
			_blinder_animation(reverse)
		&"Wraith":
			_wraith_animation(reverse)
		_:
			GlobalEventBus.signal_shadow_finish_modifier_animation()

	LogIt.custom("Processing %s animation!" % current_state.name, "ANIMATION", "dodgerblue")

func _assassin_animation(reverse: bool) -> void:
	if (!reverse):
		music._modifier_show_up()

		var dagger: Node3D = DAGGERMAIN.instantiate()
		dagger.scale = Vector3.ZERO
		dagger_spawn.add_child(dagger)
		knife_spawn_audio.play()

		var tween: Tween = create_tween().set_trans(Tween.TRANS_SPRING)
		tween.parallel().tween_property(dagger, "scale", Vector3(2.0, 2.0, 2.0), 0.5)
		tween.parallel().tween_callback(func() -> void: knife_spawn_audio.play())
		tween.tween_interval(0.05)
		tween.parallel().tween_property(dagger, "global_transform", dagger_move_book.global_transform, 0.2)
		tween.parallel().tween_callback(func() -> void: knife_swoosh_audio.play())
		tween.tween_callback(func() -> void: knife_impact_audio.play())
		tween.tween_interval(1.0)
		tween.tween_callback(func() -> void: GlobalEventBus.signal_shadow_finish_modifier_animation())
	else:
		music._modifier_leave()

func _reverser_animation(reverse: bool) -> void:
	if (!reverse):
		music._modifier_show_up(true)

		await get_tree().create_timer(1.0).timeout
		music.song_player.stream_paused = true
		music.reverse_song_player.play(music.song_player.stream.get_length() - music.song_player.get_playback_position())

		GlobalEventBus.signal_shadow_finish_modifier_animation()
	else:
		music._modifier_leave()

		music.song_player.stream_paused = false
		music.reverse_song_player.stop()

func _blinder_animation(reverse: bool) -> void:
	if (!reverse):
		music._modifier_show_up()

		snap_audio.play()
		await get_tree().create_timer(0.40).timeout
		GlobalEventBus.signal_shadow_finish_modifier_animation()
	else:
		music._modifier_leave()
		GlobalEventBus.signal_shader_toggle(ShaderModifier.SHADER_TYPES.GRAYSCALE)
		snap_audio.play()

func _wraith_animation(reverse: bool) -> void:
	if (!reverse):
		music._modifier_show_up()

		wraith_enter.play()
		music.song_player.stream_paused = true

		await get_tree().create_timer(1.0).timeout
		wraith_music.play()

		GlobalEventBus.signal_shadow_finish_modifier_animation()
	else:
		music._modifier_leave()
		music.song_player.stream_paused = false
		wraith_music.stop()
