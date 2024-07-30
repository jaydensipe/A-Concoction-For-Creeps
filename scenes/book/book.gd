extends Node3D

@onready var page_1_and_2: Sprite3D = $Book/Page1and2
@onready var page_3_and_4: Sprite3D = $Book/Page3and4
@onready var page_5_and_6: Sprite3D = $Book/Page5and6
@onready var page_7_and_8: Sprite3D = $Book/Page7and8
@onready var current_page: Sprite3D = page_1_and_2
@onready var current_page_index: int = 0
@onready var margin_container: MarginContainer = $MarginContainer
@onready var book_audio: AudioStreamPlayer = $BookAudio
@onready var animation_player: AnimationPlayer = $BookS/AnimationPlayer

func _ready() -> void:
	GlobalEventBus.camera_changed_state.connect(func(new_camera_state: GameStateResource.CAMERA_STATE) -> void:
		if (new_camera_state == GameStateResource.CAMERA_STATE.BOOK):
			current_page.show()
			margin_container.show()
			animation_player.play(&"Armature|BookOpen")
		else:
			current_page.hide()
			margin_container.hide()
	)

func _on_page_left_pressed() -> void:
	current_page.hide()

	if (current_page_index == 0):
		current_page_index = 3
	else:
		current_page_index -= 1

	_match_page()

func _on_page_right_pressed() -> void:
	current_page.hide()

	if (current_page_index == 3):
		current_page_index = 0
	else:
		current_page_index += 1

	_match_page()

func _match_page() -> void:
	book_audio.play()
	match (current_page_index):
		0:
			current_page = page_1_and_2
		1:
			current_page = page_3_and_4
		2:
			current_page = page_5_and_6
		3:
			current_page = page_7_and_8

	current_page.show()
