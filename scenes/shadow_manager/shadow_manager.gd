extends Node
class_name ShadowManager

@onready var scene_spawn_component_3d: SceneSpawnComponent3D = $SceneSpawnComponent3D
@onready var current_shadow_person: ShadowPerson

func _ready() -> void:
	GlobalEventBus.successful_drink_create.connect(func() -> void:
		current_shadow_person.queue_free()
		spawn_shadow_person()
	)

	#GlobalEventBus.failure_drink_create.connect(func() -> void:
		#current_shadow_person.queue_free()
		#spawn_shadow_person()
	#)

func spawn_shadow_person() -> void:
	current_shadow_person = await scene_spawn_component_3d.spawn_at_location()
	await current_shadow_person.waiting_at_table

	Game.generate_wanted_drink()
