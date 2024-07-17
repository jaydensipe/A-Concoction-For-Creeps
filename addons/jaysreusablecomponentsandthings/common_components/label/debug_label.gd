@tool
@icon("res://addons/jaysreusablecomponentsandthings/assets/icons/icon_debug_label.svg")
extends Node
class_name DebugLabel

@export var label_text: String = "" :
	set(value):
		label_text = value
		value_changed.emit()
@export_color_no_alpha var label_color: Color = Color(1, 1, 1, 1) :
	set(value):
		label_color = value
		value_changed.emit()
@export_group("Track Values")
@export var enabled: bool = false
@export var show_on_screen: bool = false
@export var property: String = ""
var _label: Node = null

signal value_changed

#func _ready() -> void:
	#DebugIt.global_debug_changed.connect(func(value: bool) -> void:
		#_label.visible = value
	#)

func _enter_tree() -> void:
	var parent: Node = get_parent()
	if (parent is Node2D):
		_label = Label.new()
	elif (parent is Node3D):
		_label = Label3D.new()
		_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED

	_update_label_values()
	value_changed.connect(func() -> void:
		_update_label_values()
	)

	parent.add_child.call_deferred(_label)

func _exit_tree() -> void:
	_label.queue_free()

func _physics_process(_delta: float) -> void:
	if (!enabled or Engine.is_editor_hint()): return
	var property_value: String = str(get_parent().get(property))

	if (show_on_screen):
		DebugIt.show_value_on_screen(property, property_value)
	else:
		label_text = property_value

func _update_label_values() -> void:
	_label.text = label_text
	_label.modulate = label_color
