extends Node3D

@onready var button: MeshInstance3D = $Button
@onready var STONE_ACTIVATED: Resource = preload("res://assets/models/stone/stone_activated.tres")
@onready var STONE_FIRST: Resource = preload("res://assets/models/stone/stone_first.tres")
@onready var STONE_WAITING: Resource = preload("res://assets/models/stone/stone_waiting.tres")
@onready var STONE_FAILURE: Resource = preload("res://assets/models/stone/stone_failure.tres")
@onready var tween: Tween
@onready var _reset_position: Vector3 = global_position
@onready var _mat: StandardMaterial3D = button.get_surface_override_material(0)
var activated: bool = false

# Fix camera when hovering over one of the spheres

func _ready() -> void:
	_clear()

	GlobalEventBus.symbol_clear.connect(_clear)
	GlobalEventBus.camera_changed_state.connect(func(_new_camera_state: GameStateResource.CAMERA_STATE) -> void:	_clear())
	GlobalEventBus.symbol_stone_selected.connect(_activate_stone)

func _on_area_3d_input_event(_camera: Node, _event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if (activated or !GameState.game_state.holding_mouse_button_down or GameState.game_state.camera_state != GameStateResource.CAMERA_STATE.PLAYSPACE): return

	GlobalEventBus.signal_symbol_stone_selected(get_index())

func _clear() -> void:
	activated = false
	tween = create_tween()
	tween.tween_property(self, ^"global_position:y", _reset_position.y, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	_mat.emission_texture = (STONE_WAITING as StandardMaterial3D).emission_texture
	_mat.emission = (STONE_WAITING as StandardMaterial3D).emission

func _failure() -> void:
	_mat.emission_texture = (STONE_FAILURE as StandardMaterial3D).emission_texture
	_mat.emission = (STONE_FAILURE as StandardMaterial3D).emission
	await get_tree().create_timer(0.15).timeout
	_clear()

func _activate_stone(_stone_index: int) -> void:
	if (_stone_index != get_index()): return

	activated = true
	tween.kill()
	tween = create_tween()
	tween.tween_property(self, ^"global_position:y", _reset_position.y + 0.025, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	var button_mat: StandardMaterial3D = _mat
	if (Game.is_board_empty()):
		button_mat.emission_texture = (STONE_FIRST as StandardMaterial3D).emission_texture
		button_mat.emission = (STONE_FIRST as StandardMaterial3D).emission
	else:
		button_mat.emission_texture = (STONE_ACTIVATED as StandardMaterial3D).emission_texture
		button_mat.emission = (STONE_ACTIVATED as StandardMaterial3D).emission

func _on_area_3d_mouse_entered() -> void:
	if (GameState.game_state.camera_state != GameStateResource.CAMERA_STATE.PLAYSPACE or activated): return

	tween = create_tween()
	tween.tween_property(self, ^"global_position:y", global_position.y - 0.015, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)

func _on_area_3d_mouse_exited() -> void:
	if (GameState.game_state.camera_state != GameStateResource.CAMERA_STATE.PLAYSPACE or activated): return

	tween.kill()
	tween = create_tween()
	tween.tween_property(self, ^"global_position:y", _reset_position.y, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
