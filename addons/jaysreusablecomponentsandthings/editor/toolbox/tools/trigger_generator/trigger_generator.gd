@tool
extends Panel

@onready var trigger_type_option_button: OptionButton = %TriggerTypeOptionButton
@onready var name_line_edit: LineEdit = %NameLineEdit
@onready var collision_layer_line_edit: LineEdit = %CollisionLayerLineEdit
@onready var debug_check_box: CheckBox = %DebugCheckBox
@onready var generate_button: Button = $VBoxContainer/HBoxContainer/GenerateButton
@onready var variety_option_button: OptionButton = %VarietyOptionButton

func _on_button_pressed() -> void:
	_generate_trigger()

# TODO: Add interact layer

func _generate_trigger() -> void:
	var trigger: Trigger3D = null
	if (trigger_type_option_button.text == &"Function"):
		trigger = TriggerFunction3D.new()
	elif(trigger_type_option_button.text == &"Interact"):
		trigger = TriggerInteract3D.new()
	elif(trigger_type_option_button.text == &"Soundscape"):
		trigger = TriggerSoundscape3D.new()
	elif(trigger_type_option_button.text == &"Teleport"):
		trigger = TriggerTeleport3D.new()
	elif(trigger_type_option_button.text == &"Scene"):
		trigger = TriggerLevel3D.new()

	# Add Trigger to scene tree
	EditorInterface.get_selection().get_selected_nodes()[0].add_child(trigger, true)
	trigger.owner = get_tree().edited_scene_root
	trigger.name = "Trigger%s_%s" % [trigger_type_option_button.text, name_line_edit.text]
	trigger.trigger_variety = 0 if variety_option_button.text == &"Multiple" else 1
	trigger.collision_layer = 0
	trigger.collision_mask = 0
	trigger.set_collision_mask_value(1 if int(collision_layer_line_edit.text) == 0 else int(collision_layer_line_edit.text), true)

	# Adds specific functionality to trigger
	_add_specific_functionality(trigger)

	# Add TriggerShape3D to created Trigger
	var trigger_shape: TriggerShape3D = TriggerShape3D.new()
	trigger_shape.shape = BoxShape3D.new()
	trigger.add_child(trigger_shape)
	trigger_shape.owner = get_tree().edited_scene_root
	trigger_shape.name = trigger_shape.get_script().get_global_name()

	# Conditionally add Debug Label
	if (debug_check_box.button_pressed):
		var debug_label: DebugLabel = DebugLabel.new()
		trigger_shape.add_child(debug_label)
		debug_label.owner = get_tree().edited_scene_root
		debug_label.name = debug_label.get_script().get_global_name()

func _add_specific_functionality(trigger: Trigger3D) -> void:
	# Soundscape functionality, add SpatialAudioStreamPlayer3D to created Trigger
	if(trigger_type_option_button.text == &"Soundscape"):
		var spatial_audio_stream_player_3d: SpatialAudioStreamPlayer3D = SpatialAudioStreamPlayer3D.new()
		spatial_audio_stream_player_3d.sound_type = 1
		trigger.add_child(spatial_audio_stream_player_3d)
		spatial_audio_stream_player_3d.owner = get_tree().edited_scene_root
		spatial_audio_stream_player_3d.name = spatial_audio_stream_player_3d.get_script().get_global_name()
		trigger.spatial_audio = spatial_audio_stream_player_3d

	# Trigger functionality, add Marker3D to created Trigger
	if(trigger_type_option_button.text == &"Teleport"):
		var marker: Marker3D = Marker3D.new()
		trigger.add_child(marker, true)
		marker.owner = get_tree().edited_scene_root
		trigger.marker = marker

func _on_trigger_type_option_button_item_selected(_index: int) -> void:
	generate_button.disabled = false
