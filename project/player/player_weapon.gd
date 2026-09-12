class_name PlayerWeapon extends Node2D

@export var fire_rate: float = 0.0
var fire_time_left: float = 0.0

@export var damage: float = 0.0

@export var shot_speed: float = 0.0

var is_firing: bool = false

var bullet_engine: BulletEngine = null

func _physics_process(delta: float) -> void:
	if is_firing:
		fire_time_left -= delta

		if fire_time_left <= 0.0:
			fire()
			fire_time_left = fire_rate
	else:
		fire_time_left = 0.0

func fire() -> void:
	bullet_engine.fire_bullet(global_position, Vector2.UP.angle(), shot_speed)
