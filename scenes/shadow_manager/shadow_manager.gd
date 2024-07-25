extends Node
class_name ShadowManager

@onready var scene_spawn_component_3d: SceneSpawnComponent3D = $SceneSpawnComponent3D
@onready var current_shadow_person: ShadowPerson

func _ready() -> void:
	GlobalEventBus.shadow_finish_drink_animation.connect(func() -> void:
		GameState.game_state.customers_served += 1
		DebugIt.show_value_on_screen("Customers Served", GameState.game_state.customers_served)

		spawn_shadow_person()
		current_shadow_person.queue_free()
	)

func spawn_shadow_person() -> void:
	scene_spawn_component_3d.spawn_delay_time = randf_range(0.1, 0.5)
	current_shadow_person = await scene_spawn_component_3d.spawn_at_location()
	await current_shadow_person.waiting_at_table

	GameState.game_state.ready_to_take_order = true
	Game.generate_modifier_chance()
	Game.generate_wanted_drink()
