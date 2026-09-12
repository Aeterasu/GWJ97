class_name PlayerWeapon extends Node2D

@export var shot_origins: Array[Marker2D] = []
@export var origin_random_offset: Vector2 = Vector2.ZERO

@export var fire_rate: float = 0.0
var fire_time_left: float = 0.0

@export var damage: float = 0.0

@export var shot_speed: float = 0.0

var is_firing: bool = false

var bullet_engine: BulletEngine = null

signal on_fire

func _physics_process(delta: float) -> void:
	if is_firing:
		fire_time_left -= delta

		if fire_time_left <= 0.0:
			fire()
			fire_time_left = fire_rate
	else:
		fire_time_left = 0.0

func fire() -> void:
	for origin in shot_origins:
		var offset: Vector2 = Vector2(
			randf_range(-origin_random_offset.x, origin_random_offset.y),
			randf_range(-origin_random_offset.y, origin_random_offset.y))
		bullet_engine.fire_bullet(origin.global_position + offset, Vector2.UP.angle(), shot_speed)
	
	on_fire.emit()
