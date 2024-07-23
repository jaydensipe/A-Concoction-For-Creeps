extends Node
class_name Utils

static var _ingredient_list: Array[Ingredient] = []


static func print_symbol(symbol: Array) -> void:
	print("%d %d %d" % [symbol[0], symbol[1], symbol[2]])
	print("%d %d %d" % [symbol[3], symbol[4], symbol[5]])
	print("%d %d %d \n" % [symbol[6], symbol[7], symbol[8]])

static func parse_ingredient(ingredient_name: StringName) -> Ingredient:
	var ingredient: Ingredient = Ingredient.new()
	var split: PackedStringArray = ingredient_name.split(":", true)
	ingredient.ingredient_name = split[0]
	ingredient.tier = int(split[1])
	ingredient.color = split[2]

	return ingredient

static func pick_random_ingredient_with_tier(tier: int) -> Ingredient:
	# Cache ingredient list
	if (_ingredient_list.is_empty()):
		for key: String in GameState.game_state.ingredients:
			_ingredient_list.append(parse_ingredient(key))

	return _ingredient_list.filter(func(ingredient: Ingredient) -> bool: return ingredient.tier == tier).pick_random()

static func picked_weighted_ingredient() -> Ingredient:
	var index: int = 1
	for key: int in GameState.game_state.difficulty_stats.tier_ingredient_percent_chance.ingredient_chance.values():
		for num: int in key:
			GameState.game_state.weighted_ingredient_spawn_array.append(index)
		index += 1

	return pick_random_ingredient_with_tier(GameState.game_state.weighted_ingredient_spawn_array.pick_random())

static func picked_weighted_modifier() -> StringName:
	var index: int = 1
	for key: int in GameState.game_state.difficulty_stats.per_modifier_percent_chance.modifier_chance.values():
		for num: int in key:
			GameState.game_state.weighted_modifier_array.append(index)
		index += 1

	return GameState.game_state.difficulty_stats.per_modifier_percent_chance.modifier_chance.keys()[GameState.game_state.weighted_modifier_array.pick_random() - 1]
