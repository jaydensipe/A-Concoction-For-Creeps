extends MarginContainer
class_name DebugBoxContainer

@onready var background: Panel = $Background
@onready var label: Label = $VBoxContainer/Label
@onready var grid_container: GridContainer = $VBoxContainer/GridContainer
@onready var _enabled_color: Color = ProjectSettings.get_setting("jays_reusable_components/default_colors/enabled", Color.GREEN)
@onready var _disabled_color: Color = ProjectSettings.get_setting("jays_reusable_components/default_colors/disabled", Color.RED)

class ShortcutButton extends Button:
	func add_shortcut(shortcut_key: Key) -> void:
		var input_key: InputEventKey = InputEventKey.new()
		input_key.keycode = shortcut_key

		self.shortcut =  Shortcut.new()
		self.shortcut.events.append(input_key)
		self.text = "[%s] " % input_key.as_text_keycode() + self.text

class PlusMinusButton extends BaseButton:
	var button_text: String
	var initial_value: float
	var step: float
	var setter: Callable
	var _store_initial_value: float

	func init_plus_minus_button() -> HBoxContainer:
		var hbox_container: HBoxContainer = HBoxContainer.new()
		var minus_button: Button = Button.new()
		var button: Button = Button.new()
		var plus_button: Button = Button.new()
		_store_initial_value = initial_value

		minus_button.text = "-"
		minus_button.tooltip_text = "Subtract by %f" % step

		button.text = button_text + ": %s" % initial_value
		button.tooltip_text = "Reset value to %f" % _store_initial_value

		plus_button.text = "+"
		plus_button.tooltip_text = "Add by %f" % step

		minus_button.pressed.connect(func() -> void:
			initial_value -= step
			_call_button(button, initial_value))
		button.pressed.connect(func() -> void:
			initial_value = _store_initial_value
			_call_button(button, initial_value))
		plus_button.pressed.connect(func() -> void:
			initial_value += step
			_call_button(button, initial_value))

		hbox_container.add_child(minus_button)
		hbox_container.add_child(button)
		hbox_container.add_child(plus_button)
		hbox_container.alignment = BoxContainer.ALIGNMENT_CENTER

		return hbox_container

	func _call_button(button: Button, value: float) -> void:
		button.text = button_text + ": %s" % value
		setter.call(value)

func add_button(button_text: String, functionality: Callable) -> ShortcutButton:
	var button: ShortcutButton = ShortcutButton.new()
	button.text = button_text
	button.pressed.connect(functionality)

	grid_container.add_child(button)

	return button

func add_toggle_button(button_text: String, functionality: Callable, start_pressed: bool = false) -> ShortcutButton:
	var toggle_button: Button = ShortcutButton.new()
	toggle_button.text = button_text
	toggle_button.pressed.connect(functionality)
	toggle_button.toggle_mode = true
	toggle_button.button_pressed = start_pressed

	toggle_button.add_theme_color_override("font_color", _disabled_color)
	toggle_button.add_theme_color_override("font_pressed_color", _enabled_color)
	toggle_button.add_theme_color_override("font_focus_color", _disabled_color)
	toggle_button.add_theme_color_override("font_hover_color", _disabled_color)

	grid_container.add_child(toggle_button)

	return toggle_button

func add_plus_minus_buton(button_text: String, initial_value: float, setter: Callable, step: float = 0.1) -> PlusMinusButton:
	var plus_minus_button: PlusMinusButton = PlusMinusButton.new()
	plus_minus_button.button_text = button_text
	plus_minus_button.initial_value = initial_value
	plus_minus_button.step = step
	plus_minus_button.setter = setter

	grid_container.add_child(plus_minus_button.init_plus_minus_button())

	return plus_minus_button
