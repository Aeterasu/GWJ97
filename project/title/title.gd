class_name Title extends Control

@export_group("Buttons")
@export var press_button : Control = null
@export var start : TitleButton = null
@export var ranking : TitleButton = null
@export var settings : TitleButton = null
@export var exit : TitleButton = null

static var skip_press_any_button : bool = false

func _ready() -> void:
	self.grab_focus.call_deferred()

	press_any_button()

	start.pressed.connect(on_start)
	ranking.pressed.connect(on_ranking)
	settings.pressed.connect(on_settings)

	if Main.is_in_web():
		start.focus_neighbor_top = settings.get_path()
		settings.focus_neighbor_bottom = start.get_path()
		exit.queue_free()
	else:
		exit.pressed.connect(on_exit)

	# Main.instance.bgm_manager.update_bgm(BGMManager.BGMType.MENU)

func _input(event: InputEvent) -> void:
	if event.is_pressed():
		skip_press_any_button = true
		press_any_button()

func press_any_button() -> void:
	if skip_press_any_button:
		start.show()
		ranking.show()
		settings.show()
		exit.show()
		press_button.hide()
	else:
		start.hide()
		ranking.hide()
		settings.hide()
		exit.hide()

func _physics_process(_delta: float) -> void:
	if not get_viewport().gui_get_focus_owner():
		self.grab_focus.call_deferred()

func on_start() -> void:
	await Main.instance.load_state(Main.State.GAME)

func on_ranking() -> void:
	await Main.instance.load_state(Main.instance.State.RANKING_MENU)

func on_settings() -> void:
	await Main.instance.load_state(Main.instance.State.SETTINGS_MENU)


func on_exit() -> void:
	Main.instance.exit()
