extends Resource
class_name GameStateResource

#region Game State
var difficulty_stats: DifficultyStats = preload("res://resources/state/tutorial_difficulty_stats.tres")
var modifier_hsm: LimboHSM
var customers_served: int = 0
var ready_to_take_order: bool = false
var holding_mouse_button_down: bool = false
var can_look_at_book: bool = true
var skip_intro: bool = false
var min_amount_of_customers_served_before_intro_over: int = 5
var tutorial_complete: bool = false
var intro_complete: bool = false
var should_deplete_sanity: bool = false
var sanity_level: float = 100.0
enum CAMERA_STATE { FORWARD, PLAYSPACE, BOOK, DISABLED }
var camera_state: CAMERA_STATE = CAMERA_STATE.DISABLED
var weighted_ingredient_spawn_array: Array[int] = []
var weighted_modifier_array: Array[int] = []
#endregion

#region Ingredient & Symbol Variables
enum SYMBOL_STATES {EMPTY, START, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE}
var empty_symbol: Array[int] = [SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, \
								SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, \
								SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY]
var current_symbol: Array[int] = [SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, \
								SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, \
								SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY]
var ingredients: Dictionary = {
	"flamefern:1:ff5027": [SYMBOL_STATES.START, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.TWO, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.THREE, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY],

	"frostfern:1:007cff": [SYMBOL_STATES.EMPTY, SYMBOL_STATES.START, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.EMPTY, SYMBOL_STATES.TWO, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.EMPTY, SYMBOL_STATES.THREE, SYMBOL_STATES.EMPTY],

	"grassfern:1:00ff8f": [SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.START, \
				SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.TWO, \
				SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.THREE],

	"skiverwing_feathers:1:eae4ed": [SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.START, SYMBOL_STATES.TWO, SYMBOL_STATES.THREE, \
				SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY],

	"skiverwing_feather_bot:1:eae4ed": [SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.START, SYMBOL_STATES.TWO, SYMBOL_STATES.THREE],

	"skiverwing_feather_top:1:eae4ed": [SYMBOL_STATES.START, SYMBOL_STATES.TWO, SYMBOL_STATES.THREE, \
				SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY],

	"sackfruit:1:409aff": [SYMBOL_STATES.EMPTY, SYMBOL_STATES.THREE, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.EMPTY, SYMBOL_STATES.TWO, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.START, SYMBOL_STATES.EMPTY, SYMBOL_STATES.FOUR],

	"imbued_salt:1:ffeb0d": [SYMBOL_STATES.START, SYMBOL_STATES.EMPTY, SYMBOL_STATES.FOUR, \
				SYMBOL_STATES.EMPTY, SYMBOL_STATES.TWO, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.EMPTY, SYMBOL_STATES.THREE, SYMBOL_STATES.EMPTY],

	"harpberry_cluster:2:ff2c76": [SYMBOL_STATES.THREE, SYMBOL_STATES.FOUR, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.FIVE, SYMBOL_STATES.TWO, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.START, SYMBOL_STATES.SIX, SYMBOL_STATES.EMPTY],

	"poppletop_mushroom:2:ff88f8": [SYMBOL_STATES.FIVE, SYMBOL_STATES.FOUR, SYMBOL_STATES.THREE, \
				SYMBOL_STATES.EMPTY, SYMBOL_STATES.TWO, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.START, SYMBOL_STATES.EMPTY, SYMBOL_STATES.SIX],

	"dragon_dewdrop:2:ff9f40": [SYMBOL_STATES.START, SYMBOL_STATES.EMPTY, SYMBOL_STATES.SIX, \
				SYMBOL_STATES.EMPTY, SYMBOL_STATES.TWO, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.FIVE, SYMBOL_STATES.FOUR, SYMBOL_STATES.THREE],

	"bundled_ragweed:2:93ea5f": [SYMBOL_STATES.START, SYMBOL_STATES.FOUR, SYMBOL_STATES.SEVEN, \
				SYMBOL_STATES.TWO, SYMBOL_STATES.FIVE, SYMBOL_STATES.EIGHT, \
				SYMBOL_STATES.THREE, SYMBOL_STATES.SIX, SYMBOL_STATES.NINE],

	"wolpertinger_spit:3:c0faff": [SYMBOL_STATES.START, SYMBOL_STATES.FOUR, SYMBOL_STATES.FIVE, \
				SYMBOL_STATES.THREE, SYMBOL_STATES.TWO, SYMBOL_STATES.SIX, \
				SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.SEVEN],

	"aged_hydra_skin:3:20aba9": [SYMBOL_STATES.EMPTY, SYMBOL_STATES.TWO, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.START, SYMBOL_STATES.FIVE, SYMBOL_STATES.THREE, \
				SYMBOL_STATES.SIX, SYMBOL_STATES.FOUR, SYMBOL_STATES.EMPTY],

	"siren_eye:3:9c34fd": [SYMBOL_STATES.FIVE, SYMBOL_STATES.FOUR, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.START, SYMBOL_STATES.SIX, SYMBOL_STATES.THREE, \
				SYMBOL_STATES.EMPTY, SYMBOL_STATES.TWO, SYMBOL_STATES.EMPTY],

	"coiled_fearworm:3:ffedc7": [SYMBOL_STATES.TWO, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.START, SYMBOL_STATES.THREE, SYMBOL_STATES.SIX, \
				SYMBOL_STATES.FOUR, SYMBOL_STATES.FIVE, SYMBOL_STATES.SEVEN],
}
var wanted_drink: Array[StringName] = []
var concocted_drink: Array[StringName] = []
var current_draw_index: int = 0
#endregion
