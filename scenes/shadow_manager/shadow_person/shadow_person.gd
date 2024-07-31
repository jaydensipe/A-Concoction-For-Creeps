extends Node3D
class_name ShadowPerson

@onready var bone_attachment_3d: BoneAttachment3D = $Shadowman_Anims/rig/Skeleton3D/BoneAttachment3D
@onready var speech_bubble: AnimatedSprite3D = $SpeechBubble
@onready var footstep_audio: AudioStreamPlayer3D = $FootstepAudio
@onready var ghost_audio: AudioStreamPlayer3D = $GhostAudio
@onready var grab_audio: AudioStreamPlayer3D = $GrabAudio
@onready var eyes_low: MeshInstance3D = $Shadowman_Anims/rig/Skeleton3D/Eyes
@onready var animation_player: AnimationPlayer = $Shadowman_Anims/AnimationPlayer
@onready var cup_in_hand: MeshInstance3D = $Shadowman_Anims/rig/Skeleton3D/Cup_InHand/Cup_InHand
@onready var eyes: MeshInstance3D = $Shadowman_Anims/rig/Skeleton3D/Eyes

const BLINDFOLD = preload("res://assets/models/hats/blindfold/blindfold.tscn")
const CROWN = preload("res://assets/models/hats/crown/crown.tscn")
const HOOD = preload("res://assets/models/hats/hood/hood.tscn")
const TOPHAT = preload("res://assets/models/hats/tophat/tophat.tscn")

var _beaten: bool = false

signal waiting_at_table

func _ready() -> void:
	_init_shadow_person()
	GlobalEventBus.drink_create_success.connect(func() -> void:
		_beaten = true
		speech_bubble.hide()

		if (GameState.game_state.assassin_let_go):
			var tween: Tween = create_tween()
			tween.tween_property(self, ^"position:z", position.z - 2.9, 0.8).as_relative().set_trans(Tween.TRANS_SPRING)
			footstep_audio.play()
			tween.tween_interval(0.25)
			tween.tween_callback(func() -> void: footstep_audio.play())
			tween.tween_property(self, ^"position:z", position.z - 2.9, 0.8).as_relative().set_trans(Tween.TRANS_SPRING)
			tween.tween_callback(func() -> void: footstep_audio.play())
		else:
			await get_tree().create_timer(4.5).timeout
			animation_player.speed_scale = 1.75
			animation_player.play(&"rig|Cheers_02")
			await get_tree().create_timer(0.72).timeout
			cup_in_hand.show()
			grab_audio.play()
			await get_tree().create_timer(1.0).timeout
			footstep_audio.play()
			await get_tree().create_timer(1.0).timeout
			footstep_audio.play()
	)
	GlobalEventBus.camera_changed_state.connect(func(new_camera_state: GameStateResource.CAMERA_STATE) -> void:
		# Perhaps show speech bubble from book?
		if (new_camera_state == GameStateResource.CAMERA_STATE.BOOK):
			speech_bubble.hide()
		else:
			if (!_beaten):
				speech_bubble.show()
				await get_tree().create_timer(0.15).timeout
	)

	animation_player.animation_finished.connect(func(anim_name: StringName) -> void:
		if (anim_name == &"rig|StepUp"):
			animation_player.speed_scale = 1.1
			animation_player.play(&"rig|Idle_Breathe")
	)

func _init_shadow_person() -> void:
	match (GameState.game_state.modifier_hsm.get_active_state().name):
			&"Assassin":
				var hat: Node3D = HOOD.instantiate()
				bone_attachment_3d.add_child(hat)
				hat.scale = Vector3(0.009, 0.009, 0.009)
				hat.position = Vector3(0.0, -0.016, 0.0)
				(eyes_low.material_override as StandardMaterial3D).emission = Color.PURPLE
			&"Reverser":
				var hat: Node3D = TOPHAT.instantiate()
				bone_attachment_3d.add_child(hat)
				hat.scale = Vector3(0.009, 0.009, 0.009)
				hat.position = Vector3(0.0, -0.016, 0.0)
				(eyes_low.material_override as StandardMaterial3D).emission = Color.ROYAL_BLUE
			&"Blinder":
				var hat: Node3D = BLINDFOLD.instantiate()
				bone_attachment_3d.add_child(hat)
				hat.scale = Vector3(0.01, 0.01, 0.01)
				hat.position = Vector3(0.0, -0.018, 0.0)
				(eyes_low.material_override as StandardMaterial3D).emission = Color.BLACK
			&"Wraith":
				var hat: Node3D = CROWN.instantiate()
				bone_attachment_3d.add_child(hat)
				hat.scale = Vector3(0.009, 0.009, 0.009)
				hat.position = Vector3(0.0, -0.016, 0.0)
				(eyes_low.material_override as StandardMaterial3D).emission = Color.RED
			&"Thirsty":
				(eyes_low.material_override as StandardMaterial3D).emission = Color.ORANGE
			_:
				pass

	var tween: Tween = create_tween()
	tween.tween_callback(func() -> void:
		animation_player.speed_scale = 1.2
		animation_player.play(&"rig|StepUp")
	)
	tween.tween_property(self, ^"position:z", position.z + 2.9, 0.75).as_relative().set_trans(Tween.TRANS_SPRING)
	footstep_audio.play()
	tween.tween_interval(0.25)
	tween.tween_callback(func() -> void: footstep_audio.play())
	tween.tween_property(self, ^"position:z", position.z + 2.9, 0.75).as_relative().set_trans(Tween.TRANS_SPRING)
	tween.tween_callback(func() -> void: footstep_audio.play())
	tween.tween_interval(0.25)
	tween.tween_callback(func() -> void:
		speech_bubble.show()
		waiting_at_table.emit()
		ghost_audio.play()
	)
