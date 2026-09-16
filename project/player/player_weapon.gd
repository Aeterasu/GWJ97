class_name PlayerWeapon extends Node2D

@export var shot_origins: Array[Marker2D] = []
@export var origin_random_offset: Vector2 = Vector2.ZERO

var game_sequencer : GameSequencer = null
var enemy_bullet_engine : BulletEngine = null

@export var fire_rate: float = 0.0
var fire_time_left: float = 0.0

@export var damage: float = 0.0

@export var shot_speed: float = 0.0

var is_firing: bool = false
var is_employed_bomb: bool = false

var bomb_time: float = 0.0
var bomb_reload_time: float = 0.0

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

	print(bomb_reload_time)

	#if is_employed_bomb:
		#if bomb_time >= 0.0 and bomb_reload_time >= 0.0:
			#bomb_time -= delta
			#enemy_bullet_engine.bullet_cancel()
		#elif bomb_time <= 0.0 and not bomb_reload_time <= 0.0:
			#bomb_reload_time -= delta
			#is_employed_bomb = false
			#print("meo")

func employ_bomb(_bomb_timer : float = 0.0, _bomb_reload_timer : float = 0.0) -> void:
	bomb_time = _bomb_timer
	bomb_reload_time = _bomb_reload_timer
	if bomb_reload_time <= 0.0 and bomb_time <= 0.0:
		is_employed_bomb = true
		game_sequencer.no_bomb = false

func fire() -> void:
	for origin in shot_origins:
		var offset: Vector2 = Vector2(
			randf_range(-origin_random_offset.x, origin_random_offset.x),
			randf_range(-origin_random_offset.y, origin_random_offset.y))
		var bullet = bullet_engine.fire_bullet(origin.global_position + offset, Vector2.UP.angle(), shot_speed, BulletSkin.Type.PLAYER_BULLET_DEFAULT)
		bullet.damage = damage

	on_fire.emit()
