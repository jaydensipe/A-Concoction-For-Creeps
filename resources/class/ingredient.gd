extends Resource
class_name Ingredient

var ingredient_name: StringName
var tier: int
var color: String
var model: PackedScene
var icon: TextureRect

func _to_string() -> String:
	return ingredient_name
