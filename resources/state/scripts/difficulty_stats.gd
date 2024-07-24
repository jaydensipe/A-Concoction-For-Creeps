extends Resource
class_name DifficultyStats

# These change based on game "difficulty".

@export_group("Modifiers")
@export var base_percent_chance_of_modifier: float = 15.0
@export var per_modifier_percent_chance: ModifierStats

@export_group("Ingredients")
@export var tier_ingredient_percent_chance: IngredientStats
@export var max_amount_of_ingredients: int = 10
@export var min_amount_of_ingredients: int = 2

@export_group("Sanity")
@export var sanity_depletion_rate: float = 0.01
@export_subgroup("Wrong")
@export var sanity_wrong_symbol: float = 10.0
@export var sanity_wrong_ingredient: float = 15.0
@export_subgroup("Correct")
@export var sanity_correct_drink: float = 30.0
@export var sanity_correct_ingredient: float = 5.0
