class_name Main extends Node

enum State
{
	DEFAULT, # none
	GAME,
	TITLE,
	SETTINGS_MENU,
	RANKING_MENU,
	EPILEPSY_WARNING,
}

@export var viewport : Viewport = null
@export var transition : Transition = null
@export var world : WorldEnvironment = null
@export var fps_counter : Control = null

@export_group("State")
@export var scenes : Dictionary[Main.State, PackedScene] = {}
@export var default_state : Main.State = Main.State.GAME

@export_group("Audio")
@export var audio_manager : AudioManager = null
@export var bgm_manager : BGMManager = null

var settings : SettingsManager = null
var save : SaveManager = null

var currently_loaded : Node = null
var current_state : State = State.DEFAULT

var is_loading : bool = false

var input_device_detector : InputDeviceDetector = null

var os : String = ""

var show_fps : bool = false

static var instance : Main = null

func _ready() -> void:
	instance = self

	os = OS.get_name()

	fps_counter.hide()
	fps_counter.set_process(false)

	get_viewport().disable_3d = true
	get_viewport().debug_draw = Viewport.DEBUG_DRAW_UNSHADED
	get_viewport().audio_listener_enable_3d = false

	settings = SettingsManager.new()
	settings.load()

	save = SaveManager.new()
	save.load()

	if default_state != State.DEFAULT:
		load_state(default_state)
	else:
		load_state(State.EPILEPSY_WARNING)

	input_device_detector = InputDeviceDetector.new()
	add_child(input_device_detector)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_1"):
		show_fps = not show_fps
		fps_counter.visible = show_fps
		fps_counter.set_process(true)

func _input(event: InputEvent) -> void:
	if (not currently_loaded)\
		or (not is_instance_valid(currently_loaded)):
			return

func load_state(state : State, with_transition : bool = true, transition_alt_color : bool = false) -> void:
	if (not transition):
		with_transition = false

	get_tree().paused = false

	if is_loading:
		return

	is_loading = true

	if (with_transition):
		transition.animate(transition_alt_color)
		await transition.animation_mid_point

	if currently_loaded:
		currently_loaded.queue_free()

	var node : Node = null
	var scene = scenes[state]

	if scene:
		node = scene.instantiate()
	else:
		push_error("No valid state scene corresponding to state ID " + str(state))

	if node:
		currently_loaded = node
		current_state = state
		if viewport:
			viewport.add_child.call_deferred(node)
		else:
			add_child.call_deferred(node)

	Engine.set_deferred("time_scale", 1.0)

	is_loading = false

func exit() -> void:
	get_tree().quit()

static func is_in_web() -> bool:
	return OS.get_name() == "Web"
