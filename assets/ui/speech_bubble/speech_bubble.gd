extends AnimatedSprite3D

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	GlobalEventBus.drink_generated.connect(func(drink: Array[Ingredient]) -> void:
		# Wraith drink icons for Wraith
		var temp_drink: Array[Ingredient] = drink.duplicate()
		if (GameState.game_state.modifier_hsm.get_active_state().name == &"Wraith"):
			temp_drink = [temp_drink[0]]

		match (len(temp_drink)):
			1:
				mesh_instance_3d.mesh.size = Vector2(30, 30)
				mesh_instance_3d.position = Vector3(5.475, -6.09, 0)
			2:
				mesh_instance_3d.mesh.size = Vector2(28, 28)
				mesh_instance_3d.position = Vector3(2.8, -5.82, 0)
			3:
				mesh_instance_3d.mesh.size = Vector2(24, 24)
				mesh_instance_3d.position = Vector3(0.28, -5.2, 0)
			4:
				mesh_instance_3d.mesh.size = Vector2(20, 20)
				mesh_instance_3d.position = Vector3(-0.305, -3.755, 0.505)
			5:
				mesh_instance_3d.mesh.size = Vector2(20, 20)
				mesh_instance_3d.position = Vector3(-0.305, -3.755, 0.505)
			6:
				mesh_instance_3d.mesh.size = Vector2(20, 20)
				mesh_instance_3d.position = Vector3(-0.305, -3.755, 0.505)
			_:
				mesh_instance_3d.mesh.size = Vector2(20, 20)
				mesh_instance_3d.position = Vector3(-0.305, -3.755, 0.505)
	)
