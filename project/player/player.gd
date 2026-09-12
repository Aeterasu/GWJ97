class_name Player extends Node2D

@export var base_speed: float = 0.0
@export var focus_speed: float = 0.0

@export var fire_rate: float = 0.1
var fire_time_left: float = 0.0

@export var bullet: BulletEngine = null

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
		process_weapon(delta)

func process_movement(delta: float) -> void:
	var dir: Vector2 = Vector2.ZERO

	dir = Input.get_vector("player_input_left", "player_input_right", "player_input_up","player_input_down")

	global_position += dir.normalized() * base_speed * delta
	global_position.x = clampf(global_position.x, 0.0, Game.BOARD_SIZE.x)
	global_position.y = clampf(global_position.y, 0.0, Game.BOARD_SIZE.y)

func process_weapon(delta: float) -> void:
	fire_time_left = max(fire_time_left - delta, 0.0)

	if fire_time_left <= 0.0 and Input.is_action_pressed("player_input_action_1"):
		fire_time_left = fire_rate
		fire()

func fire() -> void:
	bullet.fire_bullet(global_position, Vector2.UP.angle(), 512.0)	

func _process(delta: float) -> void:
	pass
