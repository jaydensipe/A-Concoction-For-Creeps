extends Control

@onready var grid_container: GridContainer = $GridContainer
const ARROW = preload("res://assets/models/ingredients/icons/arrow.tscn")
const CHECKMARK = preload("res://assets/ui/checkmark/checkmark.tscn")
var _checkmarks: Array[TextureRect] = []
var _icons: Array[TextureRect] = []
var _arrows: Array[TextureRect] = []

func _ready() -> void:
	GlobalEventBus.drink_generated.connect(func(drink: Array[Ingredient]) -> void:
		for child: TextureRect in grid_container.get_children():
			child.queue_free()

		var temp_drink: Array[Ingredient] = drink.duplicate()

		# Wraith drink icons for Wraith
		if (GameState.game_state.modifier_hsm.get_active_state().name == &"Wraith"):
			temp_drink = [temp_drink[0]]

		# Reverse drink icons for Reverser
		if (GameState.game_state.modifier_hsm.get_active_state().name == &"Reverser"):
			temp_drink.reverse()

		for ingredient: Ingredient in temp_drink:
			if (len(_icons) > 0):
				var arrow: TextureRect = ARROW.instantiate()
				if (GameState.game_state.modifier_hsm.get_active_state().name == &"Reverser"):
					arrow.flip_h = true
					arrow.modulate = Color("#22347c")
				else:
					arrow.modulate = Color("#7c2222")
				_arrows.append(arrow)
				grid_container.add_child(arrow)

			var icon: TextureRect = ingredient.icon.duplicate() as TextureRect
			_icons.append(icon)
			grid_container.add_child(icon)

		if (GameState.game_state.modifier_hsm.get_active_state().name == &"Reverser"):
			_icons.reverse()
			_arrows.reverse()
	)

	GlobalEventBus.ingredient_matches_wanted.connect(func(_ingredient: Ingredient) -> void:
		var checkmark: TextureRect = CHECKMARK.instantiate()
		var icon: TextureRect = _icons[(GameState.game_state.current_correct_ingredient_count - 1)]
		if (len(_arrows) != GameState.game_state.current_correct_ingredient_count - 1):
			var arrow: TextureRect = _arrows[(GameState.game_state.current_correct_ingredient_count - 1)]
			arrow.modulate = Color(0.75, 0.75, 0.75, 0.75)
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

		for arrow: TextureRect in _arrows:
			if (GameState.game_state.modifier_hsm.get_active_state().name == &"Reverser"):
				arrow.modulate = Color("#22347c")
			else:
				arrow.modulate = Color("#7c2222")
	)

	GlobalEventBus.ingredient_match_failure.connect(func(_symbol: Array[int]) -> void:
		for checkmark: TextureRect in _checkmarks:
			checkmark.queue_free()
		_checkmarks.clear()

		for icon: TextureRect in _icons:
			icon.modulate = Color(1.0, 1.0, 1.0, 1.0)

		for arrow: TextureRect in _arrows:
			if (GameState.game_state.modifier_hsm.get_active_state().name == &"Reverser"):
				arrow.modulate = Color("#22347c")
			else:
				arrow.modulate = Color("#7c2222")
	)
