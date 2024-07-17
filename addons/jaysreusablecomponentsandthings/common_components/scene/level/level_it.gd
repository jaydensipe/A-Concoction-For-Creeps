extends Node

enum DELETE_TYPE {
	QUEUE_FREE,
	REMOVE_CHILD,
	NONE
}

@export var level_dictionary: Dictionary = {}
var current_level_name: StringName = "fps_example"

signal finished_loading

func _ready() -> void:
	_parse_file_system_for_levels()
	print(level_dictionary)

func load_level_by_name(level_name: StringName, delete_type: DELETE_TYPE = DELETE_TYPE.NONE) -> void:
	_load_level(level_name, delete_type)

func _parse_file_system_for_levels() -> void:
	var level_path: String = "res://addons/jaysreusablecomponentsandthings/example_scenes/levels/%s"
	var level_directory: DirAccess = DirAccess.open("res://addons/jaysreusablecomponentsandthings/example_scenes/levels/")
	if (level_directory):
		level_directory.list_dir_begin()
		var file_name: String = level_directory.get_next()
		while (file_name != ""):
			if level_directory.current_is_dir():
				pass
			else:
				level_dictionary[file_name.left(-5)] = level_path % file_name
			file_name = level_directory.get_next()
	else:
		LogIt.error("Failed to parse level directory. Ensure correct level directory is set!")


#func load_level_by_index(index: int, delete_type: DELETE_TYPE = DELETE_TYPE.NONE) -> void:
	#current_level_index = index
#
	#_load_level(delete_type, index)
#
#func load_next_level(delete_type: DELETE_TYPE = DELETE_TYPE.QUEUE_FREE) -> void:
	#current_level_index += 1
#
	#if (current_level_index >= levels.size()):
		#current_level_index -= 1
#
	#_load_level(delete_type)

func _load_level(name: StringName, delete_type: DELETE_TYPE) -> void:
	match delete_type:
		DELETE_TYPE.QUEUE_FREE:
			get_tree().get_first_node_in_group(current_level_name).queue_free()
		DELETE_TYPE.REMOVE_CHILD:
			remove_child(get_tree().get_first_node_in_group(current_level_name))
		DELETE_TYPE.NONE:
			pass
		_:
			pass

	# Add level to SceneTree
	var scene: PackedScene = await SceneIt.load_packed_scene_by_resource_path(level_dictionary[name])
	current_level_name = name

	var level: Node = scene.instantiate()
	level.add_to_group(name, true)
	add_child(level)

	finished_loading.emit()
