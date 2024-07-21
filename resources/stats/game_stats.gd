extends Resource
class_name GameStatsResource

@export_group("Modifiers")
@export var base_percent_chance_of_modifier: float = 15.0
@export var per_modifier_percent_chance: ModifierStats

@export_group("Ingredients")
@export var tier_ingredient_percent_chance: IngredientStats
@export var max_amount_of_ingredients: int = 10
@export var min_amount_of_ingredients: int = 2

@export_group("Sanity")
@export var sanity_depletion_rate: float = 0.01
@export var sanity_multiplier: float = 1.0
