extends Control

@onready var info_v_box_container: VBoxContainer = %InfoVBoxContainer
@onready var label: Label = $InfoVBoxContainer/Label
@onready var customer_label: Label = $InfoVBoxContainer/CustomerLabel
@onready var button: Button = $InfoVBoxContainer/Button
@onready var bass_lose: AudioStreamPlayer = $BassLose

func _on_death_animated_sprite_animation_finished() -> void:
	_show_death_screen_information()
	customer_label.text = "Customers Served: %d" % GameState._save_customers_death_screen

func _show_death_screen_information() -> void:
	info_v_box_container.show()
	var tween: Tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(func() -> void: label.modulate = Color(1.0, 1.0, 1.0, 1.0))
	tween.tween_interval(1.0)
	tween.tween_callback(func() -> void: customer_label.modulate = Color(1.0, 1.0, 1.0, 1.0))
	tween.tween_interval(1.0)
	tween.parallel().tween_callback(func() -> void: button.modulate = Color(1.0, 1.0, 1.0, 1.0))
	tween.parallel().tween_callback(func() -> void: bass_lose.play())

func _on_button_pressed() -> void:
	get_tree().reload_current_scene()
