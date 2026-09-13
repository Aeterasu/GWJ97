class_name DisableFxButton extends SettingsButton

var settings : SettingsManager = null

func _ready() -> void:
	super()

	settings = Main.instance.settings

	update_label()

func update_label() -> void:
	if label and settings:
		label.text = "VISUAL EFFECTS: " + ("< OFF >" if settings.disable_fx else "< ON >")

func on_toggle() -> void:
	settings.disable_fx = !settings.disable_fx

	update_label()

func change_left() -> void:
	on_toggle()

func change_right() -> void:
	on_toggle()