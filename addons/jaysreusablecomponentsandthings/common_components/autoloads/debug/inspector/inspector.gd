extends Tree
class_name Inspector

var _tree_root: TreeItem
var _fallback_icon: Texture2D = preload("res://addons/jaysreusablecomponentsandthings/assets/icons/object.svg")
var _reset_icon: Texture2D = preload("res://addons/jaysreusablecomponentsandthings/assets/icons/reset.svg")
@onready var _enabled_color: Color = ProjectSettings.get_setting("jays_reusable_components/default_colors/enabled", Color.GREEN)
@onready var _disabled_color: Color = ProjectSettings.get_setting("jays_reusable_components/default_colors/disabled", Color.RED)
@onready var _highlight_color: Color = ProjectSettings.get_setting("jays_reusable_components/default_colors/highlight", Color.CORAL)

# TODO: Queue freed nodes are not removed.

func _ready() -> void:
	columns = 2
	allow_reselect = false
	allow_search = false
	hide_root = true
	column_titles_visible = false
	set_column_custom_minimum_width(0, 125)

	_tree_root = create_item()
	_tree_root.set_selectable(0, false)

func _physics_process(_delta: float) -> void:
	if (is_instance_valid(_tree_root)):
		for child: TreeItem in _tree_root.get_children():
			_update_values_in_tree(child)

func _register_inspector(node: Node, _bit_flag: int, icon: Texture2D) -> void:
	var registered_root_tree_item: TreeItem = create_item(_tree_root)

	_create_node_tree_item(node, registered_root_tree_item, icon)

func _update_values_in_tree(root_node_tree_item: TreeItem) -> void:
	var current_node: Object = instance_from_id(root_node_tree_item.get_meta(&"current_node_instance_id"))

	for property_row: TreeItem in root_node_tree_item.get_children():
		if (property_row.get_parent().collapsed): return

		if (property_row.has_meta(&"current_node_instance_id")):
			_update_values_in_tree(property_row)
		else:
			var current_item_name: StringName = property_row.get_text(0)
			var node_value: Variant = current_node.get(current_item_name)
			var prev_value: Variant = property_row.get_meta(&"prev_value")
			var color_lerp_weight: float = property_row.get_meta(&"color_lerp_weight")

			if (node_value != prev_value):
				property_row.set_meta(&"color_lerp_weight", 0.0)
			else:
				color_lerp_weight += 0.01
				property_row.set_meta(&"color_lerp_weight", color_lerp_weight)

			property_row.set_custom_color(0, (_highlight_color.lerp(Color.WHITE, color_lerp_weight)))
			property_row.set_text(0, current_item_name)
			property_row.set_text(1, str(node_value))
			property_row.set_meta(&"prev_value", node_value)

func _create_node_tree_item(node: Object, node_tree_item: TreeItem, icon: Texture2D, child_node: bool = false) -> void:
	node_tree_item.set_text(0, node.to_string())
	node_tree_item.set_icon(0, icon)
	node_tree_item.set_icon_max_width(0, 24 if child_node else 32)
	node_tree_item.set_text_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)
	node_tree_item.set_text(1, &"[Click to open]")
	node_tree_item.set_meta(&"current_node_instance_id", node.get_instance_id())

func _create_property_tree_item(property: Dictionary, property_value: Variant, property_tree_item: TreeItem) -> void:
	property_tree_item.set_text(0, property["name"])
	property_tree_item.set_suffix(0, "[%s]" % type_string(property["type"]))
	property_tree_item.set_editable(1, true)
	property_tree_item.set_meta(&"default_value", property_value)
	property_tree_item.set_meta(&"prev_value", property_value)
	property_tree_item.set_meta(&"color_lerp_weight", 1.0)

	if (typeof(property_value) == TYPE_BOOL):
		property_tree_item.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
		property_tree_item.set_checked(1, property_value)
		if (property_tree_item.is_checked(1)):
			property_tree_item.set_custom_color(1, _enabled_color)
		else:
			property_tree_item.set_custom_color(1, _disabled_color)

func _on_item_selected() -> void:
	var selected_tree_item: TreeItem = get_selected()
	if (!selected_tree_item.has_meta(&"current_node_instance_id") or selected_tree_item.get_icon_modulate(0) == _enabled_color): return

	var current_node_instance_id: Variant = selected_tree_item.get_meta(&"current_node_instance_id")
	var current_node: Object = null
	if (current_node_instance_id == null):
		current_node = instance_from_id(selected_tree_item.get_parent().get_meta(&"current_node_instance_id"))
	else:
		current_node = instance_from_id(current_node_instance_id)

	selected_tree_item.set_icon_modulate(0, _enabled_color)

 	# Display child nodes
	if (current_node is Node and current_node.get_script() == null):
		for child: Node in current_node.get_children():
			if (child is InspectorRegister): return

			_create_node_tree_item(child, get_selected().create_child(), _fallback_icon, true)

	# Display export variables, script variables, etc.
	for item: Dictionary in current_node.get_property_list():
		if (item["usage"] == 4102 or item["usage"] == 69632 or item["usage"] == PROPERTY_USAGE_SCRIPT_VARIABLE):
			var child: TreeItem = get_selected().create_child()
			var value: Variant = current_node.get(item["name"])

			if (is_instance_valid(value) and item["type"] == TYPE_OBJECT):
				_create_node_tree_item(value, child, _fallback_icon, true)
			else:
				_create_property_tree_item(item, value, child)

			_setup_child_tree_node_bg_color(child, item)

func _on_item_edited() -> void:
	_set_tree_item_value(get_selected())

func _on_button_clicked(item: TreeItem, _column: int, id: int, _mouse_button_index: int) -> void:
	_set_tree_item_value(item, true, id)

func _set_tree_item_value(tree_item: TreeItem, reset_value: bool = false, button_id: int = 0) -> void:
	var cell_mode: TreeItem.TreeCellMode = tree_item.get_cell_mode(1)
	var object: Object = instance_from_id(tree_item.get_parent().get_meta(&"current_node_instance_id"))
	var current_item_name: StringName = tree_item.get_text(0)

	var default_value: Variant = tree_item.get_meta(&"default_value")
	var edited_value: Variant = str_to_var(tree_item.get_text(1))

	if (reset_value):
		edited_value = default_value
		_clear_edit_variable(tree_item, button_id)
	else:
		if (cell_mode == TreeItem.CELL_MODE_CHECK):
			edited_value = !edited_value

		if (edited_value == default_value):
			_clear_edit_variable(tree_item, button_id)
		elif(tree_item.get_button_by_id(1, button_id) == -1):
			_set_edit_variable(tree_item, button_id)

	object.set(current_item_name, edited_value)
	tree_item.set_text(1, str(edited_value))
	if (cell_mode == TreeItem.CELL_MODE_CHECK):
		tree_item.set_checked(1, edited_value)
		tree_item.set_custom_color(1, _enabled_color if edited_value else _disabled_color)

func _clear_edit_variable(tree_item: TreeItem, button_id: int) -> void:
	tree_item.clear_custom_bg_color(0)
	tree_item.clear_custom_bg_color(1)
	tree_item.erase_button(1, button_id)

func _set_edit_variable(tree_item: TreeItem, button_id: int) -> void:
	tree_item.set_custom_bg_color(0, _highlight_color, true)
	tree_item.add_button(1, _reset_icon, button_id, false, "Reset")
	tree_item.set_button_color(1, button_id, Color.WHITE)

func _setup_child_tree_node_bg_color(child: TreeItem, item: Dictionary) -> void:
	if (item["type"] == TYPE_OBJECT and (item["usage"] == 4102 or item["usage"] == 4096)):
		child.set_custom_bg_color(0, Color("#ff7477",  0.2))
	else:
		child.set_custom_bg_color(0, Color("#b5d6d6",  0.2))
