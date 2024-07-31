extends Control

@onready var modifier_component: TextureRect = %ModifierComponent
@onready var modifier_desc: RichTextLabel = %ModifierDesc

func _ready() -> void:
	var tween: Tween = create_tween().set_loops().set_trans(Tween.TRANS_CIRC)
	tween.tween_property(modifier_component, "custom_minimum_size", Vector2(168, 168), 1.0)
	tween.tween_property(modifier_component, "custom_minimum_size", Vector2(156, 156), 1.0)

	GlobalEventBus.modifier_changed.connect(func(current: LimboState, _previous: LimboState) -> void:
		modifier_component.show()
		match (current.name):
			&"Assassin":
				modifier_component.texture = preload("res://assets/ui/modifier_component/icons/assassin.png")
				modifier_desc.text = "[center]The Assassin prevents you from studying your ingredient book.[/center]"
			&"Reverser":
				modifier_component.texture = preload("res://assets/ui/modifier_component/icons/reverser.png")
				modifier_desc.text = "[center]The Reverser flips your ingredient crafting order.[/center]"
			&"Blinder":
				modifier_component.texture = preload("res://assets/ui/modifier_component/icons/blinder.png")
				modifier_desc.text = "[center]The Blinder inverts the colors within your eyes.[/center]"
			&"Wraith":
				modifier_component.texture = preload("res://assets/ui/modifier_component/icons/wraith.png")
				modifier_desc.text = "[center]The Wraith kills you quickly if you do not concoct his order with haste.[/center]"
			&"Thirsty":
				modifier_component.texture = preload("res://assets/ui/modifier_component/icons/thirsty.png")
				modifier_desc.text = "[center]The Thirsty modifier adds 1 extra ingredient.[/center]"
			_:
				modifier_component.hide()

	)

func _on_modifier_component_mouse_entered() -> void:
	modifier_desc.show()

func _on_modifier_component_mouse_exited() -> void:
	modifier_desc.hide()
