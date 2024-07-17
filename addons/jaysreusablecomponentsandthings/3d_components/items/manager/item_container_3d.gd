@icon("res://addons/jaysreusablecomponentsandthings/assets/icons/icon_fp_item_container_3d.svg")
extends Node3D
class_name ItemManager3D

@export var items: Array[PackedScene] = []
@onready var current_item: FPItem3D

func _ready() -> void:
	_init_empty_spots_to_null()

	current_item = items[0].instantiate() as FPItem3D
	add_child(current_item, true)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			switch_item(0)
		if event.keycode == KEY_2:
			switch_item(1)
		if event.keycode == KEY_3:
			switch_item(2)

func _init_empty_spots_to_null() -> void:
	items.resize(3)

func switch_item(index: int) -> void:
	if (!is_instance_valid(items[index])): return

	remove_child(current_item)

	current_item = items[index].instantiate() as FPItem3D
	add_child(current_item, true)
