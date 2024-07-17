@icon("res://addons/jaysreusablecomponentsandthings/assets/icons/icon_projectile_component_3d.svg")
extends Node3D
class_name ProjectileComponent3D

@onready var projectile: PhysicsBody3D = get_parent_node_3d()
@export var speed: float = 5.0

signal projectile_collided(collision: KinematicCollision3D)

func _physics_process(delta: float) -> void:
	var collision: KinematicCollision3D = projectile.move_and_collide(-projectile.global_transform.basis.z * speed * delta)
	if (collision != null):
		projectile_collided.emit(collision)
