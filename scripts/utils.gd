extends RefCounted
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
	ingredient.model = Utils.match_ingredient_model(split[0])
	ingredient.icon = Utils.match_ingredient_icon(split[0])

	return ingredient

static func match_ingredient_model(ingredient_name: StringName) -> PackedScene:
	var model: PackedScene = null
	match (ingredient_name):
		&"flamefern":
			model = load("res://assets/models/ingredients/meshes/flamefern.tscn")
		&"frostfern":
			model = load("res://assets/models/ingredients/meshes/frostfern.tscn")
		&"faefern":
			model = load("res://assets/models/ingredients/meshes/faefern.tscn")
		&"skiverwing_feathers":
			model = load("res://assets/models/ingredients/meshes/skiverwing_feather_stack.tscn")
		&"blood_feather":
			model = load("res://assets/models/ingredients/meshes/blood_feather_stack.tscn")
		&"harpy_feather":
			model = load("res://assets/models/ingredients/meshes/harpy_feather_stack.tscn")
		&"sackfruit":
			model = load("res://assets/models/ingredients/meshes/sackfruit.tscn")
		&"imbued_salt":
			model = load("res://assets/models/ingredients/meshes/imbued_salt.tscn")
		&"harpberry_cluster":
			model = load("res://assets/models/ingredients/meshes/berry_cluster.tscn")
		&"baobulb_cluster":
			model = load("res://assets/models/ingredients/meshes/baobulb_cluster.tscn")
		&"poppletop_mushroom":
			model = load("res://assets/models/ingredients/meshes/poppletop_mushroom.tscn")
		&"dragon_dewdrop":
			model = load("res://assets/models/ingredients/meshes/dragon_dewdrop.tscn")
		&"bundled_ragweed":
			model = load("res://assets/models/ingredients/meshes/bundled_ragweed.tscn")
		&"wolpertinger_antler":
			model = load("res://assets/models/ingredients/meshes/wolpertinger_antler.tscn")
		&"aged_hydra_skin":
			model = load("res://assets/models/ingredients/meshes/aged_hydra_skin.tscn")
		&"siren_eye":
			model = load("res://assets/models/ingredients/meshes/siren_eye.tscn")
		&"coiled_gloworm":
			model = load("res://assets/models/ingredients/meshes/coiled_gloworm.tscn")
		_:
			model = load("res://assets/models/ingredients/meshes/goop.tscn")

	return model

static func match_ingredient_icon(ingredient_name: StringName) -> TextureRect:
	var texture: TextureRect = TextureRect.new()
	texture.texture = AnimatedTexture.new()
	texture.texture.frames = 3
	texture.texture.set_frame_duration(0, 0.1)
	texture.texture.set_frame_duration(1, 0.1)
	texture.texture.set_frame_duration(2, 0.1)
	texture.expand_mode = TextureRect.EXPAND_FIT_HEIGHT
	texture.size_flags_horizontal = 0x3

	match (ingredient_name):
		&"flamefern":
			texture.texture.set_frame_texture(0, preload("res://assets/models/ingredients/icons/flamefern/order_flamefern_1.png"))
			texture.texture.set_frame_texture(1, preload("res://assets/models/ingredients/icons/flamefern/order_flamefern_2.png"))
			texture.texture.set_frame_texture(2, preload("res://assets/models/ingredients/icons/flamefern/order_flamefern_3.png"))
		&"frostfern":
			texture.texture.set_frame_texture(0, preload("res://assets/models/ingredients/icons/frostfern/order_frostfern_1.png"))
			texture.texture.set_frame_texture(1, preload("res://assets/models/ingredients/icons/frostfern/order_frostfern_2.png"))
			texture.texture.set_frame_texture(2, preload("res://assets/models/ingredients/icons/frostfern/order_frostfern_3.png"))
		&"faefern":
			texture.texture.set_frame_texture(0, preload("res://assets/models/ingredients/icons/faefern/faefern_order_1.png"))
			texture.texture.set_frame_texture(1, preload("res://assets/models/ingredients/icons/faefern/faefern_order_2.png"))
			texture.texture.set_frame_texture(2, preload("res://assets/models/ingredients/icons/faefern/faefern_order_3.png"))
		&"skiverwing_feathers":
			texture.texture.set_frame_texture(0, preload("res://assets/models/ingredients/icons/skiverwing/order_skiverwing_1.png"))
			texture.texture.set_frame_texture(1, preload("res://assets/models/ingredients/icons/skiverwing/order_skiverwing_2.png"))
			texture.texture.set_frame_texture(2, preload("res://assets/models/ingredients/icons/skiverwing/order_skiverwing_3.png"))
		&"blood_feather":
			texture.texture.set_frame_texture(0, preload("res://assets/models/ingredients/icons/blood/order_blood_1.png"))
			texture.texture.set_frame_texture(1, preload("res://assets/models/ingredients/icons/blood/order_blood_2.png"))
			texture.texture.set_frame_texture(2, preload("res://assets/models/ingredients/icons/blood/order_blood_3.png"))
		&"harpy_feather":
			texture.texture.set_frame_texture(0, preload("res://assets/models/ingredients/icons/harpy/order_harpy_1.png"))
			texture.texture.set_frame_texture(1, preload("res://assets/models/ingredients/icons/harpy/order_harpy_2.png"))
			texture.texture.set_frame_texture(2, preload("res://assets/models/ingredients/icons/harpy/order_harpy_3.png"))
		&"sackfruit":
			texture.texture.set_frame_texture(0, preload("res://assets/models/ingredients/icons/sackfruit/order_sackfruit_1.png"))
			texture.texture.set_frame_texture(1, preload("res://assets/models/ingredients/icons/sackfruit/order_sackfruit_2.png"))
			texture.texture.set_frame_texture(2, preload("res://assets/models/ingredients/icons/sackfruit/order_sackfruit_3.png"))
		&"imbued_salt":
			texture.texture.set_frame_texture(0, preload("res://assets/models/ingredients/icons/salt/order_salt_1.png"))
			texture.texture.set_frame_texture(1, preload("res://assets/models/ingredients/icons/salt/order_salt_2.png"))
			texture.texture.set_frame_texture(2, preload("res://assets/models/ingredients/icons/salt/order_salt_3.png"))
		&"harpberry_cluster":
			texture.texture.set_frame_texture(0, preload("res://assets/models/ingredients/icons/harpberry/order_harpberry_1.png"))
			texture.texture.set_frame_texture(1, preload("res://assets/models/ingredients/icons/harpberry/order_harpberry_2.png"))
			texture.texture.set_frame_texture(2, preload("res://assets/models/ingredients/icons/harpberry/order_harpberry_3.png"))
		&"baobulb_cluster":
			texture.texture.set_frame_texture(0, preload("res://assets/models/ingredients/icons/baobulb/order_baobulb_1.png"))
			texture.texture.set_frame_texture(1, preload("res://assets/models/ingredients/icons/baobulb/order_baobulb_2.png"))
			texture.texture.set_frame_texture(2, preload("res://assets/models/ingredients/icons/baobulb/order_baobulb_3.png"))
		&"poppletop_mushroom":
			texture.texture.set_frame_texture(0, preload("res://assets/models/ingredients/icons/poppletop/order_poppletop_1.png"))
			texture.texture.set_frame_texture(1, preload("res://assets/models/ingredients/icons/poppletop/order_poppletop_2.png"))
			texture.texture.set_frame_texture(2, preload("res://assets/models/ingredients/icons/poppletop/order_poppletop_3.png"))
		&"dragon_dewdrop":
			texture.texture.set_frame_texture(0, preload("res://assets/models/ingredients/icons/dewdrop/order_dewdrop_1.png"))
			texture.texture.set_frame_texture(1, preload("res://assets/models/ingredients/icons/dewdrop/order_dewdrop_2.png"))
			texture.texture.set_frame_texture(2, preload("res://assets/models/ingredients/icons/dewdrop/order_dewdrop_3.png"))
		&"bundled_ragweed":
			texture.texture.set_frame_texture(0, preload("res://assets/models/ingredients/icons/ragweed/order_ragweed_1.png"))
			texture.texture.set_frame_texture(1, preload("res://assets/models/ingredients/icons/ragweed/order_ragweed_2.png"))
			texture.texture.set_frame_texture(2, preload("res://assets/models/ingredients/icons/ragweed/order_ragweed_3.png"))
		&"wolpertinger_antler":
			texture.texture.set_frame_texture(0, preload("res://assets/models/ingredients/icons/antler/order_antler_1.png"))
			texture.texture.set_frame_texture(1, preload("res://assets/models/ingredients/icons/antler/order_antler_2.png"))
			texture.texture.set_frame_texture(2, preload("res://assets/models/ingredients/icons/antler/order_antler_3.png"))
		&"aged_hydra_skin":
			texture.texture.set_frame_texture(0, preload("res://assets/models/ingredients/icons/skin/order_skin_1.png"))
			texture.texture.set_frame_texture(1, preload("res://assets/models/ingredients/icons/skin/order_skin_2.png"))
			texture.texture.set_frame_texture(2, preload("res://assets/models/ingredients/icons/skin/order_skin_3.png"))
		&"siren_eye":
			texture.texture.set_frame_texture(0, preload("res://assets/models/ingredients/icons/siren/order_siren_1.png"))
			texture.texture.set_frame_texture(1, preload("res://assets/models/ingredients/icons/siren/order_siren_2.png"))
			texture.texture.set_frame_texture(2, preload("res://assets/models/ingredients/icons/siren/order_siren_3.png"))
		&"coiled_gloworm":
			texture.texture.set_frame_texture(0, preload("res://assets/models/ingredients/icons/gloworm/order_gloworm_1.png"))
			texture.texture.set_frame_texture(1, preload("res://assets/models/ingredients/icons/gloworm/order_gloworm_2.png"))
			texture.texture.set_frame_texture(2, preload("res://assets/models/ingredients/icons/gloworm/order_gloworm_3.png"))
		_:
			texture.texture.set_frame_texture(0, preload("res://assets/models/ingredients/icons/flamefern/order_flamefern_1.png"))
			texture.texture.set_frame_texture(1, preload("res://assets/models/ingredients/icons/flamefern/order_flamefern_2.png"))
			texture.texture.set_frame_texture(2, preload("res://assets/models/ingredients/icons/flamefern/order_flamefern_3.png"))

	return texture

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
