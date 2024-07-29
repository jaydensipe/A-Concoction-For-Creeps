extends Control

@onready var grid_container: GridContainer = $GridContainer
const ARROW = preload("res://assets/models/ingredients/icons/arrow.tscn")
const CHECKMARK = preload("res://assets/ui/checkmark/checkmark.tscn")
var _amount_of_icons: int = 0
var _checkmarks: Array[TextureRect] = []
var _icons: Array[TextureRect] = []

# TODO: Reverser

func _ready() -> void:
	GlobalEventBus.drink_generated.connect(func(drink: Array[Ingredient]) -> void:
		for child: TextureRect in grid_container.get_children():
			child.queue_free()
			_amount_of_icons = 0

		var temp_drink: Array[Ingredient] = drink.duplicate()
		if (GameState.game_state.modifier_hsm.get_active_state().name == &"Reverser"):
			temp_drink.reverse()

		for ingredient: Ingredient in temp_drink:
			if (_amount_of_icons > 0):
				var arrow: TextureRect = ARROW.instantiate()
				if (GameState.game_state.modifier_hsm.get_active_state().name == &"Reverser"):
					arrow.flip_h = true
					arrow.modulate = Color("#22347c")
				else:
					arrow.modulate = Color("#7c2222")
				grid_container.add_child(arrow)

			var icon: TextureRect = ingredient.icon.duplicate() as TextureRect
			_icons.append(icon)
			grid_container.add_child(icon)
			_amount_of_icons += 1
	)

	GlobalEventBus.ingredient_matches_wanted.connect(func(ingredient: Ingredient) -> void:
		var checkmark: TextureRect = CHECKMARK.instantiate()
		var icon: TextureRect = grid_container.get_children()[(GameState.game_state.current_correct_ingredient_count - 1) * 2]
		checkmark.global_position = icon.global_position
		icon.modulate = Color(0.75, 0.75, 0.75, 0.75)
		checkmark.scale = Vector2(0.35, 0.35)

		add_child(checkmark)
		_checkmarks.append(checkmark)
	)

	GlobalEventBus.drink_create_failure.connect(func() -> void:
		for checkmark: TextureRect in _checkmarks:
			checkmark.queue_free()
		_checkmarks.clear()

		for icon: TextureRect in _icons:
			icon.modulate = Color(1.0, 1.0, 1.0, 1.0)
	)

	GlobalEventBus.ingredient_match_failure.connect(func(symbol: Array[int]) -> void:
		for checkmark: TextureRect in _checkmarks:
			checkmark.queue_free()
		_checkmarks.clear()

		for icon: TextureRect in _icons:
			icon.modulate = Color(1.0, 1.0, 1.0, 1.0)
	)
