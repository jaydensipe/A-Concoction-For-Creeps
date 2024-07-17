extends Panel

const MONITOR = preload("res://addons/jaysreusablecomponentsandthings/common_components/autoloads/debug/monitor/monitor.tscn")

func _ready() -> void:
	add_child(MONITOR.instantiate())
