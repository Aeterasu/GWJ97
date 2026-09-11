class_name Warning extends Control

var time_left : float = 3.0

func _physics_process(delta: float) -> void:
	time_left -= delta

	if time_left <= 0.0 \
		or (Input.is_action_just_pressed("ui_accept")) \
		or (Input.is_action_just_pressed("player_input_shoot")):
		await Main.instance.load_state(Main.State.TITLE, true, true)