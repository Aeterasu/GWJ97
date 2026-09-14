class_name VolumeSlider extends Control

enum Type
{
	MASTER,
	SFX,
	BGM,
}

@export var type : Type = Type.MASTER
@export var slider : HSlider = null

@export var label : Label = null
@export var percent_label : Label = null

@export var highlight : Control = null

var is_highlighted : bool = false:
	set(value):
		if is_highlighted == value:
			return

		is_highlighted = value

		if value:
			animate_focus()
		else:
			animate_unfocus()

var tween : Tween = null

func _ready() -> void:
	focus_mode = Control.FOCUS_ALL

	mouse_entered.connect(grab_focus)
	mouse_exited.connect(release_focus)

	highlight.modulate.a = 0.0

	slider.value_changed.connect(on_slider_value_change)

	match type:
		Type.MASTER:
			slider.value = AudioManager.get_master_volume()
		Type.SFX:
			slider.value = AudioManager.get_sfx_volume()
		Type.BGM:
			slider.value = AudioManager.get_bgm_volume()

func on_slider_value_change(value : float) -> void:
	match type:
		Type.MASTER:
			AudioManager.set_master_volume(value)
		Type.SFX:
			AudioManager.set_sfx_volume(value)
		Type.BGM:
			AudioManager.set_bgm_volume(value)

func _physics_process(_delta: float) -> void:
	is_highlighted = self.has_focus() or slider.has_focus()

	var input_left = Input.is_action_just_pressed("ui_left")
	var input_right = Input.is_action_just_pressed("ui_right")

	match type:
		Type.MASTER:
			var vol = AudioManager.get_master_volume()

			if is_highlighted:
				if input_left:
					AudioManager.set_master_volume(vol - 0.1)
				elif input_right:
					AudioManager.set_master_volume(vol + 0.1)

			label.text = "MASTER VOLUME:"
			percent_label.text = str(roundi(vol * 100.0)) + "%"
			slider.value = vol
		Type.SFX:
			var vol = AudioManager.get_sfx_volume()

			if is_highlighted:
				if input_left:
					AudioManager.set_sfx_volume(vol - 0.1)
				elif input_right:
					AudioManager.set_sfx_volume(vol + 0.1)

			label.text = "SFX VOLUME:"
			percent_label.text = str(roundi(vol * 100.0)) + "%"
			slider.value = vol
		Type.BGM:
			var vol = AudioManager.get_bgm_volume()

			if is_highlighted:
				if input_left:
					AudioManager.set_bgm_volume(vol - 0.1)
				elif input_right:
					AudioManager.set_bgm_volume(vol + 0.1)

			label.text = "BGM VOLUME:"
			percent_label.text = str(roundi(vol * 100.0)) + "%"
			slider.value = vol

func animate_focus() -> void:
	tween = create_tween()
	tween.tween_property(highlight, "modulate:a", 1.0, 0.1)

	# Main.instance.audio_manager.ui_select.play()

func animate_unfocus() -> void:
	tween = create_tween()
	tween.tween_property(highlight, "modulate:a", 0.0, 0.2)
