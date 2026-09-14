extends Label

@export var great_color : Color
@export var ok_color : Color
@export var bad_color : Color

func _process(_delta: float) -> void:
	var fps = int(Engine.get_frames_per_second())
	set_text(str(fps) + " FPS")

	if fps >= 144:
		label_settings.font_color = great_color
	elif fps >= 50:
		label_settings.font_color = ok_color
	else:
		label_settings.font_color = bad_color
