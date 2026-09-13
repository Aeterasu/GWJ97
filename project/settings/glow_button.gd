class_name GlowButton extends SettingsButton

var settings : SettingsManager = null

func _ready() -> void:
	super()

	settings = Main.instance.settings

	update_label()

func update_label() -> void:
	if label and settings:
		label.text = "GLOW: " + ("< ON >" if settings.glow else "< OFF >")

func on_toggle() -> void:
	settings.glow = !settings.glow

	update_label()

func change_left() -> void:
	on_toggle()

func change_right() -> void:
	on_toggle()