class_name InputDeviceDetector extends Node

enum Device
{
	NONE,
	KEYBOARD_MOUSE,
	GAMEPAD,
}

var device : Device = Device.KEYBOARD_MOUSE:
	set(value):
		if device == value:
			return

		device = value
		on_device_update.emit(device)

var joy_name : String = ""

static var instance : InputDeviceDetector = null

signal on_device_update

func _ready() -> void:
	if instance and is_instance_valid(instance):
		self.queue_free()
	else:
		instance = self

func _input(event: InputEvent) -> void:
	if (event is InputEventKey or event is InputEventMouseButton):
		device = Device.KEYBOARD_MOUSE
		joy_name = ""
	elif (event is InputEventJoypadButton):
		device = Device.GAMEPAD
		joy_name = Input.get_joy_name(0)
	elif (event is InputEventJoypadMotion && abs((event as InputEventJoypadMotion).axis_value) >= 0.95):
		device = Device.GAMEPAD
		joy_name = Input.get_joy_name(0)