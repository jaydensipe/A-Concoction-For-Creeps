extends Node3D
class_name ShadowPerson

@onready var speech_bubble: AnimatedSprite3D = $SpeechBubble
@onready var footstep_audio: AudioStreamPlayer3D = $FootstepAudio

signal waiting_at_table

func _ready() -> void:
	_init_shadow_person()

func _init_shadow_person() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, ^"position:z", position.z + 3.35, 0.75).as_relative().set_trans(Tween.TRANS_SPRING)
	footstep_audio.play()
	tween.tween_interval(0.25)
	tween.tween_callback(func() -> void: footstep_audio.play())
	tween.tween_property(self, ^"position:z", position.z + 3.35, 0.75).as_relative().set_trans(Tween.TRANS_SPRING)
	tween.tween_callback(func() -> void:
		footstep_audio.play()
		speech_bubble.show()
		waiting_at_table.emit()
	)
