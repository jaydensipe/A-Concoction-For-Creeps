extends Node
class_name Utils

static func print_symbol(symbol: Array) -> void:
	print("%d %d %d" % [symbol[0], symbol[1], symbol[2]])
	print("%d %d %d" % [symbol[3], symbol[4], symbol[5]])
	print("%d %d %d \n" % [symbol[6], symbol[7], symbol[8]])

static func parse_ingredient_name_and_tier(ingredient_name: StringName) -> Game.Ingredient:
	var ingredient: Game.Ingredient = Game.Ingredient.new()
	var split: PackedStringArray = ingredient_name.split(":", true)
	ingredient.ingredient_name = split[0]
	ingredient.tier = int(split[1])

	return ingredient
