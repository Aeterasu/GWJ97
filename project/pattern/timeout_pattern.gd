class_name TimeoutPattern extends Node

var shot_origin_position: Vector2 = Vector2.ZERO
var fire_rate: float = 0.1

var bullet_engine: BulletEngine = null

func update(delta: float) -> void:
	fire_rate -= delta

	if fire_rate <= 0.0:
		fire_rate = 0.2
		fire_1()

func fire_1() -> void:
	var types = [BulletSkin.Type.ENEMY_BULLET_RED_SMALL, BulletSkin.Type.ENEMY_BULLET_RED_LONG, BulletSkin.Type.ENEMY_BULLET_ALT_SMALL, BulletSkin.Type.ENEMY_BULLET_ALT_LONG]

	for i in 64:
		bullet_engine.fire_bullet(shot_origin_position, TAU * randf(), randf_range(90.0, 200.0), types.pick_random())
