class_name FullscreenButton extends SettingsButton

var settings : SettingsManager = null

func _ready() -> void:
	super()

	settings = Main.instance.settings

	update_label()

func update_label() -> void:
	if label and settings:
		label.text = "FULLSCREEN: " + ("< ON >" if settings.fullscreen else "< OFF >")

func on_toggle() -> void:
	settings.fullscreen = !settings.fullscreen

	update_label()

func change_left() -> void:
	on_toggle()

func change_right() -> void:
	on_toggle()