extends Resource
class_name MoveStats

@export var speed: float = 8.0
@export var sprint_multiplier: float = 1.25
@export var crouch_multiplier: float = 0.55
@export var jump_height: float = 3.0

@export_group("Advanced Config")
@export var apply_acceleration: bool = false
@export var acceleration: float = 10.0
@export var apply_air_acceleration: bool = false
@export var air_acceleration: float = 2.0
