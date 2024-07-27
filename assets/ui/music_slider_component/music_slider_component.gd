extends Control

@onready var _music_bus: int = AudioServer.get_bus_index(&"Music")
@onready var h_slider: HSlider = $VBoxContainer/HSlider

func _ready() -> void:
	h_slider.value = db_to_linear(AudioServer.get_bus_volume_db(_music_bus))
	h_slider.max_value = db_to_linear(AudioServer.get_bus_volume_db(_music_bus))

func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(_music_bus, linear_to_db(value))
