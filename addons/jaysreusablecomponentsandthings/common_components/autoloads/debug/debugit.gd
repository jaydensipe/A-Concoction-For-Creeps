extends Control

@onready var window: Window = %Window
@onready var debug: FlowContainer = %Debug
@onready var inspector: Inspector = %Inspector
@onready var debug_value_container: VBoxContainer = %DebugValueContainer
var is_global_debug_enabled: bool = false :
	set(value):
		is_global_debug_enabled = value
		global_debug_changed.emit(value)
var _debug_fly_cam_3d: FlyCamera = null
const DEBUG_BOX_CONTAINER = preload("res://addons/jaysreusablecomponentsandthings/common_components/autoloads/debug/debug_box/debug_box_container.tscn")

signal global_debug_changed(value: bool)

func _ready() -> void:
	_init_editor_debug_build_specifics()
	_init_default_debug_box_functionality()

func create_debug_box(title: StringName, background_color: Color = Color.GRAY) -> DebugBoxContainer:
	for debug_box: DebugBoxContainer in debug.get_children():
		# If a debug box with the same title already exists, combine
		if (debug_box.label.text == title):
			return debug_box

	var debug_box_container: DebugBoxContainer = DEBUG_BOX_CONTAINER.instantiate()
	debug_box_container.ready.connect(func() -> void:
		debug_box_container.label.text = title

		var style_box: StyleBox = debug_box_container.background.get_theme_stylebox("panel").duplicate()
		style_box.set("bg_color", background_color)
		debug_box_container.background.add_theme_stylebox_override("panel", style_box)
	)

	debug.add_child(debug_box_container)

	return debug_box_container

func register_in_inspector(node: Node, bit_flag: int, icon: Texture2D = inspector._fallback_icon) -> void:
	inspector._register_inspector(node, bit_flag, icon)

func show_value_on_screen(title: String, value: Variant) -> void:
	var found: Label = debug_value_container.find_child(title, true, false)
	if (found):
		found.text = "%s: %s" % [title, str(value)]
		found.name = title
	else:
		var label: Label = Label.new()
		label.text = "%s: %s" % [title, str(value)]
		label.name = title
		label.add_theme_font_size_override("font_size", 32)
		debug_value_container.add_child(label)

func _input(event: InputEvent) -> void:
	if (event is InputEventKey):
		if (event.is_action_pressed(&"debug")):
			if (!window.visible):
				window.visible = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _init_default_debug_box_functionality() -> void:
	var built_ins_box: DebugBoxContainer = create_debug_box("Built-Ins")
	built_ins_box.add_plus_minus_buton("Time Scale", Engine.time_scale, Engine.set_time_scale)
	built_ins_box.add_button("Switch Render Views", func() -> void:
		var vp: Viewport = get_viewport()
		vp.debug_draw = (vp.debug_draw + 1) % 26 as Viewport.DebugDraw

		LogIt.debug("Render View [url=https://docs.godotengine.org/en/stable/classes/class_viewport.html#enum-viewport-debugdraw](Documentation)[/url]: %s" % vp.debug_draw)
	)
	built_ins_box.add_toggle_button("Toggle Fullscreen", func() -> void:
		if (DisplayServer.window_get_mode(0) == DisplayServer.WINDOW_MODE_FULLSCREEN):
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	)
	built_ins_box.add_toggle_button("Toggle Fly Camera (3D)", func() -> void:
		if (is_instance_valid(_debug_fly_cam_3d)):
			_debug_fly_cam_3d.queue_free()
			return

		_debug_fly_cam_3d = FlyCamera.new()
		get_tree().current_scene.add_child(_debug_fly_cam_3d)

		var _current_cam: Camera3D = get_viewport().get_camera_3d()
		_debug_fly_cam_3d.global_position = _current_cam.global_position
		_debug_fly_cam_3d._prev_camera = _current_cam
		_debug_fly_cam_3d.make_current()
	).add_shortcut(KEY_V)
	built_ins_box.add_toggle_button("Toggle Debug", func() -> void:
		is_global_debug_enabled = !is_global_debug_enabled, is_global_debug_enabled)
	built_ins_box.add_toggle_button("Pause Game", func() -> void:
		get_tree().paused = !get_tree().paused
	)

func _init_editor_debug_build_specifics() -> void:
	if (OS.has_feature("debug")):
		is_global_debug_enabled = true
