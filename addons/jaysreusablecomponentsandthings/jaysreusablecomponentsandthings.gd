@tool
extends EditorPlugin

# Used https://usefulicons.com/ for icons

# Node: R: 224, G: 224, B: 224
# Node2D: R: 141, G: 165, B: 243
# Node3D: R: 252, G: 127, B: 127
# Control: R: 142, G: 239, B: 151

# Custom Icon Colors:
# Trigger: R: 252, G: 191, B: 126

# TODO: Add detailed loading steps/unloading for each component/system

var toolbox_panel: Control = preload("res://addons/jaysreusablecomponentsandthings/editor/toolbox/toolbox.tscn").instantiate()
var _default_keybinds: Array[Dictionary] = [
	{
		action = &"move_forward",
		key = KEY_W
	},
	{
		action = &"move_backward",
		key = KEY_S
	},
	{
		action = &"move_left",
		key = KEY_A
	},
	{
		action = &"move_right",
		key = KEY_D
	},
	{
		action = &"jump",
		key = KEY_SPACE
	},
		{
		action = &"sprint",
		key = KEY_SHIFT
	},
		{
		action = &"crouch",
		key = KEY_CTRL
	},
		{
		action = &"debug",
		key = KEY_F1
	},
		{
		action = &"interact",
		key = KEY_E
	},
		{
		action = &"mouse_primary_fire",
		key = MOUSE_BUTTON_LEFT
	},
		{
		action = &"mouse_alternate_fire",
		key = MOUSE_BUTTON_RIGHT
	},
		{
		action = &"reload",
		key = KEY_R
	}
]
static var _enabled_color: StringName = "jays_reusable_components/default_colors/enabled"
static var _disabled_color: StringName = "jays_reusable_components/default_colors/disabled"
static var _highlight_color: StringName = "jays_reusable_components/default_colors/highlight"

func _enable_plugin() -> void:
	_init_default_keybinds()

func _disable_plugin() -> void:
	_remove_default_keybinds()
	_remove_project_settings()

func _init_default_keybinds() -> void:
	print(_default_keybinds)
	for keybind: Dictionary in _default_keybinds:
		var key: InputEventWithModifiers
		if (keybind["action"].left(5) == &"mouse"):
			key = InputEventMouseButton.new()
			key.button_index = keybind["key"]
		elif (keybind["key"] is Key):
			key = InputEventKey.new()
			key.physical_keycode = keybind["key"]

		var input: Dictionary = {
			"deadzone": 0.5,
			"events": [
				key
			]
		}

		ProjectSettings.set_setting('input/%s' % keybind["action"], input)
	ProjectSettings.save()

func _remove_default_keybinds() -> void:
	for keybind: Dictionary in _default_keybinds:
		ProjectSettings.set_setting('input/%s' % keybind["action"], null)
	ProjectSettings.save()

func _init_project_settings() -> void:
	# Enabled color setting
	if (!ProjectSettings.has_setting(_enabled_color)):
		ProjectSettings.set_setting(_enabled_color, Color.GREEN)
	ProjectSettings.set_initial_value(_enabled_color, Color.GREEN)
	ProjectSettings.set_as_basic(_enabled_color, true)
	var _enabled_color_property_info: Dictionary = {
		"name": _enabled_color,
		"type": TYPE_COLOR
	}
	ProjectSettings.add_property_info(_enabled_color_property_info)

	# Disabled color setting
	if (!ProjectSettings.has_setting(_disabled_color)):
		ProjectSettings.set_setting(_disabled_color, Color.RED)
	ProjectSettings.set_initial_value(_disabled_color, Color.RED)
	ProjectSettings.set_as_basic(_disabled_color, true)
	var _disabled_color_property_info: Dictionary = {
		"name": _disabled_color,
		"type": TYPE_COLOR
	}
	ProjectSettings.add_property_info(_disabled_color_property_info)

	# Highlight color setting
	if (!ProjectSettings.has_setting(_highlight_color)):
		ProjectSettings.set_setting(_highlight_color, Color.CORAL)
	ProjectSettings.set_initial_value(_highlight_color, Color.CORAL)
	ProjectSettings.set_as_basic(_highlight_color, true)
	var _highlight_color_property_info: Dictionary = {
		"name": _highlight_color,
		"type": TYPE_COLOR
	}
	ProjectSettings.add_property_info(_highlight_color_property_info)

	ProjectSettings.save()

func _remove_project_settings() -> void:
	# Gets rid of custom project settings

	ProjectSettings.set_setting(_enabled_color, null)
	ProjectSettings.set_setting(_disabled_color, null)

func _enter_tree() -> void:
	print_rich("[b]Jay's Reusable Components and Things [v%s][/b] has loaded [color=green]successfully![/color]" % get_plugin_version())

	# Create custom project settings
	_init_project_settings()

	# Add autoload singletons
	add_autoload_singleton(&"DrawIt", "res://addons/jaysreusablecomponentsandthings/common_components/autoloads/draw/drawit.gd")
	add_autoload_singleton(&"DebugIt", "res://addons/jaysreusablecomponentsandthings/common_components/autoloads/debug/debugit.tscn")
	add_autoload_singleton(&"LevelIt", "res://addons/jaysreusablecomponentsandthings/common_components/scene/level/level_it.gd")
	add_autoload_singleton(&"RaycastIt", "res://addons/jaysreusablecomponentsandthings/common_components/autoloads/raycast/raycastit.gd")
	add_autoload_singleton(&"ResonateIt", "res://addons/jaysreusablecomponentsandthings/common_components/autoloads/audio/resonateit.gd")
	add_autoload_singleton(&"SceneIt", "res://addons/jaysreusablecomponentsandthings/common_components/scene/scene_it.gd")

	# Add Toolbox to bottom panel
	add_control_to_bottom_panel(toolbox_panel, &"Toolbox")

func _exit_tree() -> void:
	# Remove autoload singletons
	remove_autoload_singleton(&"DrawIt")
	remove_autoload_singleton(&"DebugIt")
	remove_autoload_singleton(&"LevelIt")
	remove_autoload_singleton(&"RaycastIt")
	remove_autoload_singleton(&"ResonateIt")
	remove_autoload_singleton(&"SceneIt")

	# Remove Toolbox from bottom panel
	remove_control_from_bottom_panel(toolbox_panel)
