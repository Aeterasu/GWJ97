class_name TitleButton extends Button

@export var label_light : Control = null
@export var box_light : Control = null

var tweens : Array[Tween] = []

func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	focus_entered.connect(animate_focus)
	focus_exited.connect(animate_unfocus)

	label_light.modulate.a = 0.0
	box_light.modulate.a = 0.0

	# pressed.connect(activate)

func _input(event : InputEvent) -> void:
	if event.is_action("ui_left")\
		or event.is_action("ui_right")\
		or event.is_action("ui_up")\
		or event.is_action("ui_down"):
			if event.is_echo():
				get_tree().root.set_input_as_handled()

func animate_focus() -> void:
	for t in tweens:
		t.kill()

	tweens.clear()

	var tween : Tween = create_tween() 
	tween.set_parallel(true)
	tween.tween_property(label_light, "modulate:a", 1.0, 0.15)
	tween.tween_property(box_light, "modulate:a", 1.0, 0.15)

	tweens.append(tween)

	# Main.instance.audio_manager.ui_select.play()

func animate_unfocus() -> void:
	for t in tweens:
		t.kill()

	tweens.clear()

	var tween : Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label_light, "modulate:a", 0.0, 0.2)
	tween.tween_property(box_light, "modulate:a", 0.0, 0.2)

	tweens.append(tween)

# func activate() -> void:
	# Main.instance.audio_manager.ui_accept.play()
