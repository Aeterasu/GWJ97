class_name RankingPageButton extends Button

@export var highlight : Control = null

var tween : Tween = null

func _ready() -> void:
	focus_mode = Control.FOCUS_ALL

	mouse_entered.connect(grab_focus)
	mouse_exited.connect(release_focus)

	focus_entered.connect(on_focus)
	focus_exited.connect(on_unfocus)
	
	#pressed.connect(Main.instance.audio_manager.ui_accept.play)

	highlight.modulate.a = 0.0

func on_focus() -> void:
	tween = create_tween()
	tween.tween_property(highlight, "modulate:a", 1.0, 0.1)

	#Main.instance.audio_manager.ui_select.play()

func on_unfocus() -> void:
	tween = create_tween()
	tween.tween_property(highlight, "modulate:a", 0.0, 0.2)
