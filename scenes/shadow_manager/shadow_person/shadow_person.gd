extends Node3D
class_name ShadowPerson

@onready var speech_bubble: AnimatedSprite3D = $SpeechBubble
@onready var footstep_audio: AudioStreamPlayer3D = $FootstepAudio
@onready var ghost_audio: AudioStreamPlayer3D = $GhostAudio
@onready var eyes_low: MeshInstance3D = $ShadowMan/Eyes_low

signal waiting_at_table

func _ready() -> void:
	_init_shadow_person()
	GlobalEventBus.drink_create_success.connect(func() -> void: speech_bubble.hide())
	GlobalEventBus.camera_changed_state.connect(func(new_camera_state: GameStateResource.CAMERA_STATE) -> void:
		# Perhaps show speech bubble from book?
		if (new_camera_state == GameStateResource.CAMERA_STATE.BOOK):
			speech_bubble.hide()
		else:
			await get_tree().create_timer(0.15).timeout
			speech_bubble.show()
	)
	GlobalEventBus.modifier_changed.connect(func(current: LimboState, _previous: LimboState) -> void:
		match (current.name):
			&"Assassin":
				(eyes_low.get_surface_override_material(0) as StandardMaterial3D).emission = Color.PURPLE
			&"Reverser":
				(eyes_low.get_surface_override_material(0) as StandardMaterial3D).emission = Color.YELLOW
			&"Blinder":
				(eyes_low.get_surface_override_material(0) as StandardMaterial3D).emission = Color.WHITE
			&"Wraith":
				(eyes_low.get_surface_override_material(0) as StandardMaterial3D).emission = Color.RED
			&"Thirsty":
				(eyes_low.get_surface_override_material(0) as StandardMaterial3D).emission = Color.DARK_TURQUOISE
			_:
				(eyes_low.get_surface_override_material(0) as StandardMaterial3D).emission = Color.WHITE

	)

func _init_shadow_person() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, ^"position:z", position.z + 3.35, 0.75).as_relative().set_trans(Tween.TRANS_SPRING)
	footstep_audio.play()
	tween.tween_interval(0.25)
	tween.tween_callback(func() -> void: footstep_audio.play())
	tween.tween_property(self, ^"position:z", position.z + 3.35, 0.75).as_relative().set_trans(Tween.TRANS_SPRING)
	tween.tween_callback(func() -> void:
		footstep_audio.play()
	)
	tween.tween_interval(0.25)
	tween.tween_callback(func() -> void:
		speech_bubble.show()
		waiting_at_table.emit()
		ghost_audio.play()
	)
