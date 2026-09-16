extends Pattern

var fire_rate_1: float = 0.0
var fire_rate_2: float = 0.0

func init_pattern() -> void:
	super()

	is_started = true

	animation_player.play("default")

func update(delta: float) -> void:
	if is_timeout:
		timeout_pattern.shot_origin_position = entities[0].global_position
		timeout_pattern.update(delta)
		return

	fire_rate_1 -= delta
	if fire_rate_1 <= 0.0:
		fire_1()
		fire_rate_1 = 0.05

	fire_rate_2 -= delta
	if fire_rate_2 <= 0.0:
		fire_2()
		fire_rate_2 = 0.05

func fire_1() -> void:
	var spread: float = randf_range(0.0, 0.2)
	bullet_engine.fire_bullet(entities[0].global_position, Vector2.DOWN.angle() + spread, randf_range(80.0, 140.0), BulletSkin.Type.ENEMY_BULLET_ALT_SMALL)

	if Game.get_player().global_position.y < 30.0:
		if randf() < 0.05:
			for i in 32:
				bullet_engine.fire_bullet(Vector2(240.0 / 32.0 * i, -16.0), Vector2.DOWN.angle(), randf_range(50.0, 100.0), BulletSkin.Type.ENEMY_BULLET_RED_SMALL)

func fire_2() -> void:
	var spread: float = randf_range(-0.2, 0.0)
	bullet_engine.fire_bullet(entities[1].global_position, Vector2.DOWN.angle() + spread, randf_range(80.0, 140.0), BulletSkin.Type.ENEMY_BULLET_RED_SMALL)
	

func fire_sun() -> void:
	sun_counter += 1

	if sun_counter > 3:
		sun_spawner.spawn_sun(Vector2(120.0, 0.0), Vector2.DOWN * 80.0) 	
