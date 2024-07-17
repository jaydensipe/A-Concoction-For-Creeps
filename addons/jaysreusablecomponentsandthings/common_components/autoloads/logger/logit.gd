extends RefCounted
class_name LogIt

# Simple logger implementation

static func debug(message: Variant) -> void:
	_display_log(message, "DEBUG", "white")

static func info(message: Variant) -> void:
	_display_log(message, "INFO", "cyan")

static func warn(message: Variant) -> void:
	_display_log(message, "WARN", "yellow")
	push_warning(message)

static func error(message: Variant, show_stack: bool = true) -> void:
	_display_log(message, "ERROR", "red")
	push_error(message)

	if (show_stack):
		print_stack()

static func custom(message: Variant, log_type: String, bbcode_color: String) -> void:
	_display_log(message, log_type, bbcode_color)

static func _display_log(message: Variant, log_level: StringName, bbcode_color: String) -> void:
	print_rich("%s %s [color=orange][b][%s][/b][/color] - [color=lightblue][u]%s[/u]:%s[/color] [indent][color=%s][%s][/color] %s" % [Time.get_date_string_from_system(), Time.get_time_string_from_system(), get_stack()[1]["source"], get_stack()[1]["function"], get_stack()[1]["line"], bbcode_color, log_level, str(message)])
