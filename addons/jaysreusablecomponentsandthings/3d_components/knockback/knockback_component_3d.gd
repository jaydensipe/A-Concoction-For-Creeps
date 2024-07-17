@icon("res://addons/jaysreusablecomponentsandthings/assets/icons/icon_knockback_component_3d.svg")
extends ShapeCast3D
class_name KnockbackComponent3D

@export var knockback_amount: Vector3 = Vector3.ZERO
@export_group("Config")
@export var wall_detection: bool = true

func trigger_knockback()  -> void:
	for collision_index: int  in get_collision_count():
		var collider: Object = get_collider(collision_index)
		if (collider is not PhysicsBody3D): return

		var direction: Vector3 = collider.global_transform.origin - global_transform.origin
		var impulse: Vector3 = direction.normalized() * knockback_amount

		if (collider is CharacterBody3D):
			collider.velocity += impulse
		elif (collider is RigidBody3D):
			collider.apply_central_impulse(direction)
