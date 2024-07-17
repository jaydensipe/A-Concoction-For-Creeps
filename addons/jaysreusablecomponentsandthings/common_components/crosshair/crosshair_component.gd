@icon("res://addons/jaysreusablecomponentsandthings/assets/icons/icon_crosshair_component.svg")
extends Control
class_name CrosshairComponent

@export_enum("First Person", "Follow Cursor W.I.P") var crosshair_type: int
@export var default_crosshair: Crosshair
@export_group("Config")
@export_range(0.0, 10.0) var tween_time: float = 0.15
var _crosshair_sprite: Sprite2D

func _ready() -> void:
	Helpers.require_instance_variables(get_path(), [default_crosshair])

	if (crosshair_type == 0):
		set_anchors_preset(Control.PRESET_CENTER, true)
		mouse_filter = MOUSE_FILTER_IGNORE

	_crosshair_sprite = Sprite2D.new()
	_crosshair_sprite.texture = default_crosshair.texture
	_crosshair_sprite.scale = Vector2(default_crosshair.scale, default_crosshair.scale)
	add_child(_crosshair_sprite)

func switch_crosshair(crosshair_texture: Texture2D, crosshair_scale: float) -> void:
	await create_tween().tween_property(self, "modulate:a", 0.0, tween_time).finished

	create_tween().tween_property(self, "modulate:a", 1.0, tween_time)
	_crosshair_sprite.texture = crosshair_texture
	_crosshair_sprite.scale = Vector2(crosshair_scale, crosshair_scale)

func reset_to_normal_crosshair() -> void:
	switch_crosshair(default_crosshair.texture, default_crosshair.scale)
