extends Node
class_name ShaderModifier

@onready var grayscale: ColorRect = %Grayscale

enum SHADER_TYPES { GRAYSCALE }

func _ready() -> void:
	GlobalEventBus.shader_toggle.connect(func(shader_type: SHADER_TYPES) -> void:
		match (shader_type):
			SHADER_TYPES.GRAYSCALE:
				grayscale.visible = !grayscale.visible
	)
