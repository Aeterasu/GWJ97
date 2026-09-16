extends Pattern

@export var fire_rate: float = 0.5
var fire_timer: float = 0.0

@export var is_firing: bool = false

func init_pattern() -> void:
	super()

	is_started = true

	animation_player.play("default")

func update(delta: float) -> void:
	if is_timeout:
		timeout_pattern.shot_origin_position = entities[0].global_position
		timeout_pattern.update(delta)
		return

	if is_firing:
		fire_timer -= delta

		if fire_timer <= 0.0:
			fire_timer = fire_rate * fire_rate_multiplier
			fire_rapid()
	else:
		fire_timer = 0.0

	var player = Game.get_player()
	var target_pos = player.global_position if player else Vector2(120.0, 320.0)

	var target_angle = -PI / 2 + entities[0].global_position.angle_to_point(target_pos)

	entities[0].rotation = rotate_toward(entities[0].rotation, target_angle, 2.0 * delta)

func fire_rapid() -> void:
	var angle = entities[0].rotation + PI / 2

	var bullet_count_1: int = int(4 * bullet_count_multiplier)
	var bullet_count_2: int = int(2 * bullet_count_multiplier)

	for i in bullet_count_1:
		var pos = entities[0].position + Vector2(randf_range(-12.0, 12.0), randf_range(-4.0, 4.0))
		bullet_engine.fire_bullet(pos, angle + randf_range(-0.1, 0.1), randf_range(150.0, 250.0) * bullet_speed_multiplier, BulletSkin.Type.ENEMY_BULLET_RED_LONG)

	for j in bullet_count_2:
		var pos = entities[0].position + Vector2(randf_range(-12.0, 12.0), randf_range(-4.0, 4.0))
		bullet_engine.fire_bullet(pos, TAU * randf(), randf_range(90.0, 150.0) * bullet_speed_multiplier, BulletSkin.Type.ENEMY_BULLET_RED_SMALL)

func fire_circle(idx: int = 0) -> void:
	var bullet_count = 0
	var speed = 0.0

	if idx == 0:
		bullet_count = int(16 * bullet_count_multiplier)
		speed = 105.0 * bullet_speed_multiplier
	elif idx == 1:
		bullet_count = int(14 * bullet_count_multiplier)
		speed = 90.0 * bullet_speed_multiplier
	elif idx == 2:
		bullet_count = int(12 * bullet_count_multiplier)
		speed = 75.0 * bullet_speed_multiplier

	var circle = BulletPatternHelper.get_circle(0.0, bullet_count)

	for angle in circle:
		bullet_engine.fire_bullet(entities[0].global_position, angle, speed, BulletSkin.Type.ENEMY_BULLET_ALT_SMALL)

func spawn_sun() -> void:
	sun_counter += 1

	if sun_counter >= 4:
		var sun = sun_spawner.spawn_sun(entities[0].position)
		sun_counter = 0

static func gravity_bullet(bullet: Bullet, delta: float) -> Vector2:
	bullet.velocity += Vector2.DOWN * 98 * delta
	return bullet.position + bullet.velocity * delta
