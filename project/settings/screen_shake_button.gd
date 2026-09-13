class_name ScreenShakeButton extends SettingsButton

var settings : SettingsManager = null

func _ready() -> void:
	super()

	settings = Main.instance.settings

	update_label()

func update_label() -> void:
	if label and settings:
		label.text = "SCREEN SHAKE: " + ("< ON >" if settings.screen_shake else "< OFF >")

func on_toggle() -> void:
	settings.screen_shake = !settings.screen_shake

	update_label()

func change_left() -> void:
	on_toggle()

func change_right() -> void:
	on_toggle()