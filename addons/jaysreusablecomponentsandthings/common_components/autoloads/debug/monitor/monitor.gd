extends MarginContainer

@onready var frame_label: Label = $VBoxContainer/GridContainer/FrameLabel
@onready var frame_text: Label = $VBoxContainer/GridContainer/FrameText
@onready var cpu_ms_label: Label = $VBoxContainer/GridContainer/CpuMsLabel
@onready var gpu_ms_label: Label = $VBoxContainer/GridContainer/GpuMsLabel
@onready var gpu_ms_text: Label = $VBoxContainer/GridContainer/GpuMsText
@onready var cpu_ms_text: Label = $VBoxContainer/GridContainer/CpuMsText
@onready var engine_version_text: Label = $VBoxContainer/VBoxContainer/EngineVersionText
@onready var graphics_text: Label = $VBoxContainer/VBoxContainer/GraphicsText
@onready var processor_text: Label = $VBoxContainer/VBoxContainer/ProcessorText
@onready var os_text: Label = $VBoxContainer/VBoxContainer/OSText
@onready var ram_usage_label: Label = $VBoxContainer/GridContainer/RamUsageLabel
@onready var ram_usage_text: Label = $VBoxContainer/GridContainer/RamUsageText

func _ready() -> void:
	RenderingServer.viewport_set_measure_render_time(get_viewport().get_viewport_rid(), true)
	cpu_ms_label.text = "CPU (%s):" % Engine.get_architecture_name()
	engine_version_text.text = "Godot %s" % Engine.get_version_info()["string"]
	processor_text.text = OS.get_processor_name()
	graphics_text.text = RenderingServer.get_video_adapter_name()

func _process(_delta: float) -> void:
	var viewport_rid: RID = get_viewport().get_viewport_rid()

	var _fps: float = Engine.get_frames_per_second()
	if (_fps >= 60.0):
		frame_label.label_settings.font_color = Color.GREEN
		frame_text.label_settings.font_color = Color.GREEN
	elif (_fps >= 30.0 and _fps < 60.0):
		frame_label.label_settings.font_color = Color.YELLOW
		frame_text.label_settings.font_color =  Color.YELLOW
	else:
		frame_label.label_settings.font_color =  Color.RED
		frame_text.label_settings.font_color = Color.RED

	frame_text.text = "%d fps" % _fps
	cpu_ms_text.text = "%.2f ms" % RenderingServer.viewport_get_measured_render_time_cpu(viewport_rid)
	gpu_ms_text.text = "%.2f ms" % RenderingServer.viewport_get_measured_render_time_gpu(viewport_rid)
	os_text.text = "%s %s" % [OS.get_name(), OS.get_version()]

	@warning_ignore("integer_division")
	var _physical_mem: int = OS.get_memory_info()['physical'] / (1024 * 1024)
	@warning_ignore("integer_division")
	var _used_mem: int = OS.get_static_memory_usage() / (1024 * 1024)
	@warning_ignore("integer_division")
	ram_usage_label.text = "RAM Usage (%.2f%%):" % ((_used_mem / _physical_mem) * 100.0)
	ram_usage_text.text = "%d / %d (mb)" % [_used_mem, _physical_mem]

func _on_button_pressed() -> void:
	DisplayServer.clipboard_set("%s \n %s %s \n %s %s \n %s %s \n %s / %s / %s / %s" % [frame_text.text, cpu_ms_label.text, cpu_ms_text.text, gpu_ms_label.text, gpu_ms_text.text, ram_usage_label.text, ram_usage_text.text, engine_version_text.text, graphics_text.text, processor_text.text, os_text.text])
