class_name Player extends Node2D

var speed: float = 240.0
var enable_hitbox: bool = false

var control_state: ControlState = ControlState.NORMAL

enum ControlState
{
	NORMAL,
	IN_CUTSCENE,
}

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if control_state == ControlState.NORMAL:
		process_movement(delta)

func process_movement(delta: float) -> void:
	var dir: Vector2 = Vector2.ZERO

	dir = Input.get_vector("player_input_left", "player_input_right", "player_input_up","player_input_down")

	global_position += dir.normalized() * speed * delta
	global_position.x = clampf(global_position.x, 0.0, Game.BOARD_SIZE.x)
	global_position.y = clampf(global_position.y, 0.0, Game.BOARD_SIZE.y)


func _process(delta: float) -> void:
	pass
