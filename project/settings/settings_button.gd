class_name SettingsButton extends Button

@export var label_text : String = '':
	set(value):
		update_label()

		label_text = value

@export var label : Label = null

@export var highlight : Control = null

var tween : Tween = null

func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	mouse_entered.connect(grab_focus)
	mouse_exited.connect(release_focus)

	focus_entered.connect(on_focus)
	focus_exited.connect(on_unfocus)
	
	pressed.connect(on_toggle)
	# pressed.connect(Main.instance.audio_manager.ui_accept.play)

	highlight.modulate.a = 0.0

	update_label()

func _physics_process(_delta: float) -> void:
	if has_focus() and Input.is_action_just_pressed("ui_left"):
		change_left()
	elif has_focus() and Input.is_action_just_pressed("ui_right"):
		change_right()

func on_toggle() -> void:
	pass

func change_left() -> void:
	pass

func change_right() -> void:
	pass

func _input(event : InputEvent) -> void:
	if event.is_action("ui_left")\
		or event.is_action("ui_right")\
		or event.is_action("ui_up")\
		or event.is_action("ui_down"):
			if event.is_echo():
				get_tree().root.set_input_as_handled()

func on_focus() -> void:
	tween = create_tween()
	tween.tween_property(highlight, "modulate:a", 1.0, 0.1)

	# Main.instance.audio_manager.ui_select.play()

func on_unfocus() -> void:
	tween = create_tween()
	tween.tween_property(highlight, "modulate:a", 0.0, 0.2)

func update_label() -> void:
	if label:
		label.text = label_text.to_upper()
