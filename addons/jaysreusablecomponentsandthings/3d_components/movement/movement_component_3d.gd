@icon("res://addons/jaysreusablecomponentsandthings/assets/icons/icon_movement_component_3d.svg")
extends Node3D
class_name MovementComponent3D

@export var character: PhysicsBody3D
@export var collider: CollisionShape3D
@export var move_stats: MoveStats

@export_group("Footsteps")
@export var enable_footsteps: bool = false
@export var distance_between_steps: float = 70.0
@export var footstep_audio: AudioStreamPlayer3D
@export var jump_audio: AudioStreamPlayer3D
@export var land_audio: AudioStreamPlayer3D

@export_group("Advanced Config")
@export_subgroup("Jump Config")
@export var enable_jumping: bool = true
@export_subgroup("Sprint Config")
@export var enable_sprinting: bool = true
@export_subgroup("Crouch Config")
@export var enable_crouching: bool = true

@export_group("Flags")
@export var disable_movement: bool = false

@export_group("Debug")
@export var show_debug: bool = true

enum MOVEMENT_STATES {
	IDLE,
	WALKING,
	SPRINTING,
	FALLING,
	CROUCHING
}
var direction: Vector3 = Vector3.ZERO
var input_dir: Vector2 = Vector2.ZERO
var current_movement_state: MOVEMENT_STATES = MOVEMENT_STATES.WALKING
var prev_movement_state: MOVEMENT_STATES = MOVEMENT_STATES.WALKING
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _footstep_dist_traveled: float = 0.0
@onready var _current_max_move_speed: float = move_stats.speed
@onready var _character_movement: bool = true if (character is CharacterBody3D) else false

func _ready() -> void:
	Helpers.require_instance_variables(get_path(), [character, collider, move_stats])

func _physics_process(delta: float) -> void:
	# Add the gravity
	apply_gravity(delta)

	# Add footsteps
	apply_footsteps()

	# Disable movement check
	if (disable_movement): return

	# Process all states related to movement
	process_movement_states()

	# Determine whether to apply character or rigid body movement
	if (_character_movement):
		apply_character_body_movement(delta)
	else:
		apply_rigid_body_movement(delta)

func apply_gravity(delta: float) -> void:
	if (!character.is_on_floor()):
		character.velocity.y -= _gravity * delta

func apply_footsteps() -> void:
	if (!enable_footsteps): return

	# Add up distance traveled if velocity is not 0
	if (current_movement_state != MOVEMENT_STATES.FALLING and !input_dir.is_equal_approx(Vector2.ZERO)):
		_footstep_dist_traveled += max(0.8, (1.0 * character.velocity.length_squared()) / 60.0)

	# Play footsteps based on distance walked
	if (_footstep_dist_traveled >= distance_between_steps):
		footstep_audio.play()
		_footstep_dist_traveled = 0.0

func apply_character_body_movement(delta: float) -> void:
	# Checks for applying acceleration
	if (move_stats.apply_acceleration):
		direction = lerp(direction, (character.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * move_stats.acceleration)
	else:
		direction = (character.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Checks for applying air acceleration
	if (character.is_on_floor()):
		if (!direction.is_equal_approx(Vector3.ZERO)):
			character.velocity.x = direction.x * _current_max_move_speed
			character.velocity.z = direction.z * _current_max_move_speed

			switch_state(MOVEMENT_STATES.WALKING)
		else:
			character.velocity.x = move_toward(character.velocity.x, 0, _current_max_move_speed)
			character.velocity.z = move_toward(character.velocity.z, 0, _current_max_move_speed)

			switch_state(MOVEMENT_STATES.IDLE)
	elif (move_stats.apply_air_acceleration):
		character.velocity.x = lerp(character.velocity.x, direction.x * _current_max_move_speed, delta * move_stats.air_acceleration)
		character.velocity.z = lerp(character.velocity.z, direction.z * _current_max_move_speed, delta * move_stats.air_acceleration)

		switch_state(MOVEMENT_STATES.FALLING)

	character.move_and_slide()

	# Save previous movement state
	prev_movement_state = current_movement_state

func apply_rigid_body_movement(_delta: float) -> void:
	pass

func switch_state(state: MOVEMENT_STATES) -> void:
	# Switching to different state updates
	if (current_movement_state != state):
		match (current_movement_state):
			MOVEMENT_STATES.CROUCHING:
				create_tween().tween_property(collider.shape, "height", 2.0, 7.5 * get_physics_process_delta_time())
			MOVEMENT_STATES.FALLING:
				if (!enable_footsteps): return

				land_audio.play()

	current_movement_state = state

func process_movement_states() -> void:
	match (current_movement_state):
		MOVEMENT_STATES.WALKING:
			_current_max_move_speed = move_stats.speed
		MOVEMENT_STATES.SPRINTING:
			_current_max_move_speed = move_stats.speed * move_stats.sprint_multiplier
		MOVEMENT_STATES.CROUCHING:
			create_tween().tween_property(collider.shape, "height", 0.25, 7.5 * get_physics_process_delta_time())
			_current_max_move_speed = move_stats.speed * move_stats.crouch_multiplier

func jump() -> void:
	if (enable_jumping and current_movement_state != MOVEMENT_STATES.FALLING):
		character.velocity.y = move_stats.jump_height

		if (!enable_footsteps): return

		jump_audio.play()

func sprint() -> void:
	if (enable_sprinting and current_movement_state != MOVEMENT_STATES.FALLING and current_movement_state != MOVEMENT_STATES.CROUCHING):
		switch_state(MOVEMENT_STATES.SPRINTING)

func crouch() -> void:
	if (enable_crouching):
		switch_state(MOVEMENT_STATES.CROUCHING)

func move_to_direction(move_direction: Vector3, delta: float) -> void:
	move_direction = move_direction.normalized()

	character.velocity = character.velocity.lerp(move_direction * _current_max_move_speed, move_stats.acceleration * delta)
	character.move_and_slide()
