extends Control

@export var back_to_menu : SettingsButton = null
@export var top_entries : Array[LeaderboardEntry] = []

@export var entries_box : VBoxContainer = null

func _ready() -> void:
	#var save = Main.instance.save

	self.grab_focus.call_deferred()
	back_to_menu.pressed.connect(on_back_to_menu)

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		on_back_to_menu()

func on_back_to_menu() -> void:
	await Main.instance.load_state(Main.State.TITLE)
