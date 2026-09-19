class_name Debug extends Node

@export var fps_counter: Control = null

@export var mute_audio: bool = false:
	set(value):
		mute_audio = value
		update_audio_mute()

var show_fps: bool = false:
	set(value):
		show_fps = value

		fps_counter.visible = show_fps
		fps_counter.set_process(show_fps)

static var IS_DEBUG: bool = false

func init() -> void:
	IS_DEBUG = OS.is_debug_build()

	if IS_DEBUG:
		show_fps = true
		update_audio_mute()
	else:
		show_fps = false
		mute_audio = false

func update_audio_mute() -> void:
	if mute_audio:
		AudioManager.mute_audio()
	else:
		AudioManager.unmute_audio()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(InputActions.DEBUG_1):
		show_fps = not show_fps	
