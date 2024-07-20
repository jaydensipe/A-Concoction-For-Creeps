extends Resource
class_name GameStatsResource


@export_group("Modifiers")
@export var base_percent_chance_of_modifier: float = 20.0
@export var per_modifier_percent_chance: ModifierStats

@export_group("Ingredients")
@export var tier_ingredient_percent_chance: IngredientStats
