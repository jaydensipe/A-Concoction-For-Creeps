@tool
extends CollisionShape3D
class_name TriggerShape3D

var _mesh: MeshInstance3D = null
const TRIGGER_MATERIAL = preload("res://addons/jaysreusablecomponentsandthings/assets/materials/triggers/trigger_material.tres")

func _ready() -> void:
	if (!is_instance_valid(shape)): return

	_init_and_update_debug()

func _set(property: StringName, value: Variant) -> bool:
	if (property == "shape"):
		if (is_instance_valid(value)):
			if (value is not BoxShape3D):
				printerr("Please only set Shape to a BoxShape3D for TriggerShape3D.")
			else:
				shape = value
				_init_and_update_debug()

			return true
		else:
			_mesh.queue_free()

	return false

func _notification(what: int) -> void:
	match (what):
		44:
			_update_debug_mesh()

func _init_and_update_debug() -> void:
	if (Engine.is_editor_hint()):
		_init_debug_mesh()
		_update_debug_mesh()

func _differentiate_trigger_texture() -> CompressedTexture2D:
	var parent_node_3d: Node3D = get_parent_node_3d()

	if (parent_node_3d is TriggerSoundscape3D):
		return preload("res://addons/jaysreusablecomponentsandthings/assets/materials/triggers/trigger_soundscape_texture.png")
	if (parent_node_3d is TriggerTeleport3D):
		return preload("res://addons/jaysreusablecomponentsandthings/assets/materials/triggers/trigger_teleport_texture.png")
	else:
		return preload("res://addons/jaysreusablecomponentsandthings/assets/materials/triggers/trigger_texture.png")

func _init_debug_mesh() -> void:
	_mesh = MeshInstance3D.new()
	_mesh.mesh = BoxMesh.new()
	_mesh.material_override = TRIGGER_MATERIAL.duplicate()
	_mesh.material_override.albedo_texture = _differentiate_trigger_texture()

	add_child(_mesh)

func _update_debug_mesh() -> void:
	if (!is_instance_valid(_mesh)): return

	_mesh.mesh.size = shape.size
