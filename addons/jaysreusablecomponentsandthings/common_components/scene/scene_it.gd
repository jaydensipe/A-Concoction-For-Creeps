extends Node

const TEMPLATE_LOAD_SCREEN = preload("res://addons/jaysreusablecomponentsandthings/assets/templates/ui/load_screen/load_screen_template.tscn")

var load_progress: Array[int] = []
var _scene_path: String = ""

signal scene_loaded

func load_packed_scene_by_resource_path(resource_path: String) -> Resource:
	var loaded_scene: LoadScreenTemplate = TEMPLATE_LOAD_SCREEN.instantiate()
	get_tree().root.add_child(loaded_scene)

	# Begin threaded load request
	_scene_path = resource_path
	ResourceLoader.load_threaded_request(_scene_path)

	await loaded_scene.press_any_key_pressed

	get_tree().root.remove_child(loaded_scene)

	return ResourceLoader.load_threaded_get(_scene_path)

func _process(delta: float) -> void:
	var scene_load_status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(_scene_path, load_progress)
	if (scene_load_status == ResourceLoader.THREAD_LOAD_LOADED):
		scene_loaded.emit()
