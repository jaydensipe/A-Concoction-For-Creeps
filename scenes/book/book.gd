extends Node3D

@onready var page_left: MeshInstance3D = $BookS/Armature/Skeleton3D/PageLeft
@onready var page_right: MeshInstance3D = $BookS/Armature/Skeleton3D/PageRight
@onready var margin_container: MarginContainer = $MarginContainer
@onready var book_audio: AudioStreamPlayer = $BookAudio
@onready var animation_player: AnimationPlayer = $BookS/AnimationPlayer
@onready var current_page_index: int = 0
@onready var omni_light_3d: OmniLight3D = $BookS/AnimationPlayer/OmniLight3D
@onready var book_open_audio: AudioStreamPlayer = $BookOpenAudio
const PAGE_01_GUIDE = preload("res://assets/ui/book/page_01_guide.png")
const PAGE_02_FERNS = preload("res://assets/ui/book/page_02_ferns.png")
const PAGE_03_FEATHERS = preload("res://assets/ui/book/page_03_feathers.png")
const PAGE_04_PTDBR = preload("res://assets/ui/book/page_04_ptdbr.png")
const PAGE_05_ISS = preload("res://assets/ui/book/page_05_iss.png")
const PAGE_06_CLUSTER = preload("res://assets/ui/book/page_06_cluster.png")
const PAGE_07_WAASH = preload("res://assets/ui/book/page_07_waash.png")
const PAGE_08_SECG = preload("res://assets/ui/book/page_08_secg.png")
var _open: bool = false

func _ready() -> void:
	GlobalEventBus.camera_changed_state.connect(func(new_camera_state: GameStateResource.CAMERA_STATE) -> void:
		if (new_camera_state == GameStateResource.CAMERA_STATE.BOOK):
			margin_container.show()
			animation_player.play(&"Armature|BookOpen")
			omni_light_3d.visible = true
			_open = true
			book_open_audio.play()
		else:
			margin_container.hide()
			if (_open):
				animation_player.play_backwards(&"Armature|BookOpen")
				_open = false
				await get_tree().create_timer(0.4).timeout
				omni_light_3d.visible = false
	)

func _on_page_left_pressed() -> void:

	if (current_page_index == 0):
		current_page_index = 3
	else:
		current_page_index -= 1

	_match_page()

func _on_page_right_pressed() -> void:
	if (current_page_index == 3):
		current_page_index = 0
	else:
		current_page_index += 1

	_match_page()

func _match_page() -> void:
	book_audio.play()
	match (current_page_index):
		0:
			(page_left.material_override as StandardMaterial3D).albedo_texture = PAGE_01_GUIDE
			(page_right.material_override as StandardMaterial3D).albedo_texture = PAGE_02_FERNS
		1:
			(page_left.material_override as StandardMaterial3D).albedo_texture = PAGE_03_FEATHERS
			(page_right.material_override as StandardMaterial3D).albedo_texture = PAGE_04_PTDBR
		2:
			(page_left.material_override as StandardMaterial3D).albedo_texture = PAGE_05_ISS
			(page_right.material_override as StandardMaterial3D).albedo_texture = PAGE_06_CLUSTER
		3:
			(page_left.material_override as StandardMaterial3D).albedo_texture = PAGE_07_WAASH
			(page_right.material_override as StandardMaterial3D).albedo_texture = PAGE_08_SECG
