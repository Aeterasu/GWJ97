class_name SettingsMenu extends Control

@export_group("Buttons")
@export var back_to_menu : SettingsButton = null

@export var fullscreen : FullscreenButton = null
@export var screen_shake : ScreenShakeButton = null
@export var slider_3 : VolumeSlider = null

var settings : SettingsManager = null

func _ready() -> void:
	settings = Main.instance.settings

	self.grab_focus.call_deferred()

	back_to_menu.pressed.connect(on_back_to_menu)

	if Main.is_in_web():
		screen_shake.focus_neighbor_top = slider_3.get_path()
		slider_3.focus_neighbor_bottom = screen_shake.get_path()
		fullscreen.queue_free()

func _physics_process(delta: float) -> void:
	if not get_viewport().gui_get_focus_owner():
		self.grab_focus.call_deferred()

	if Input.is_action_just_pressed("ui_cancel"):
		on_back_to_menu()

func on_back_to_menu() -> void:
	settings.refresh_volume_config()
	settings.save()

	await Main.instance.load_state(Main.State.TITLE)
