extends Node

#region Game State
var holding_mouse_button_down: bool = false
var is_tutorial: bool = false
var skip_tutorial: bool = false
var min_amount_of_customers_served_before_intro_over: int = 10
var can_look_at_book: bool = true
var ready_to_take_order: bool = false
var customers_served: int = 0
var sanity_level: float = 0.0
var max_amount_of_ingredients: int = 2
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

	"skiverwing_feathers:1:eae4ed": [SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, SYMBOL_STATES.EMPTY, \
				SYMBOL_STATES.START, SYMBOL_STATES.TWO, SYMBOL_STATES.THREE, \
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

#region Modifier Variables
var modifier_hsm: LimboHSM
#endregion

func _ready() -> void:
	_init_modifier_state_machine()

#region Modifier HSM Setup
func _init_modifier_state_machine() -> void:
	modifier_hsm = LimboHSM.new()
	add_child(modifier_hsm)

	# Create states
	var none_modifier_state: LimboState = LimboState.new().named(&"None")
	var intro_modifier_state: LimboState = LimboState.new().named(&"Intro") \
		.call_on_enter(_on_enter_intro).call_on_exit(_on_exit_intro)
	var assassin_modifier_state: LimboState = LimboState.new().named(&"Assassin") \
		.call_on_enter(_on_enter_assassin).call_on_exit(_on_exit_assassin)

	# Add children
	modifier_hsm.add_child(none_modifier_state)
	modifier_hsm.add_child(intro_modifier_state)
	modifier_hsm.add_child(assassin_modifier_state)

	# Add initial game state
	if (!skip_tutorial):
		modifier_hsm.initial_state = intro_modifier_state
	else:
		modifier_hsm.initial_state = none_modifier_state

	# Add transitions
	modifier_hsm.add_transition(modifier_hsm.ANYSTATE, none_modifier_state, &"end_modifier")
	modifier_hsm.add_transition(none_modifier_state, assassin_modifier_state, &"trans_assassin_state")

	# Initialize HSM
	modifier_hsm.initialize(self)
	modifier_hsm.set_active(true)

	modifier_hsm.active_state_changed.connect(func(current: LimboState, previous: LimboState) -> void:
		DebugIt.show_value_on_screen("Current Modifier", current.name)
	)

	DebugIt.show_value_on_screen("Current Modifier", modifier_hsm.get_active_state().name)
#endregion

#region Intro Modifier
func _on_enter_intro() -> void:

	pass

func _on_exit_intro() -> void:
	pass
#endregion

#region Assassin Modifier
func _on_enter_assassin() -> void:
	can_look_at_book = false

func _on_exit_assassin() -> void:
	can_look_at_book = true
#endregion
