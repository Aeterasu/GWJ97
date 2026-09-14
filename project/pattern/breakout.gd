extends Pattern

@export var animation_player: AnimationPlayer = null

@export var shot_origins: Array[Marker2D] = []

@export var fire_rate: float = 0.8
var fire_time_left: float = 0.0

@export var fire_rate_secondary: float = 0.2
var fire_secondary_time_left: float = 0.2

var start_origin: int = 0

var max_sun_counter: int = 5

func init_pattern() -> void:
	super()

	fire_time_left = fire_rate
	fire_secondary_time_left = fire_secondary_time_left

	is_started = true

	start_origin = randi() % shot_origins.size()

func update(delta: float) -> void:
	fire_time_left -= delta

	if fire_time_left <= 0.0:
		fire_time_left = fire_rate

		fire_primary()
		sun_counter += 1

		if sun_counter > max_sun_counter:
			sun_counter = 0

	fire_secondary_time_left -= delta

	if fire_secondary_time_left <= 0.0:
		fire_secondary_time_left = fire_rate_secondary
		bullet_engine.fire_bullet(shot_origins.pick_random().global_position, PI / 2.0 + randf_range(-PI / 5.0, PI / 5.0), randf_range(60.0, 140.0), BulletSkin.Type.ENEMY_BULLET_ALT_SMALL)

func fire_primary() -> void:
	var bullet_count: int = 16

	var origin = shot_origins[start_origin]

	start_origin += 1
	if start_origin >= shot_origins.size():
		start_origin = 0

	var circle = BulletPatternHelper.get_circle(0.0, bullet_count)

	var angle = PI / 2
	var radius: float = 36.0

	var spawn_pos: Vector2 = origin.global_position
	var start_time: int = Time.get_ticks_msec()
	var intro_duration: float = 0.5

	for i in circle.size():
		var a = circle[i]

		if sun_counter == max_sun_counter:
			var target = (bullet_count / 4)
			if i == target or i == target - 1 or i == target + 1:
				continue

		var target_offset = Vector2.from_angle(a) * radius
		var intro_behaviour = process_circle_intro.bind(spawn_pos, target_offset, intro_duration, start_time)

		bullet_engine.fire_bullet(spawn_pos, angle, 100.0, BulletSkin.Type.ENEMY_BULLET_RED_SMALL, intro_behaviour)

	if sun_counter == max_sun_counter:
		await get_tree().create_timer(intro_duration).timeout
		sun_spawner.spawn_sun(origin.global_position, Vector2.DOWN * 100.0)

static func process_circle_intro(bullet: Bullet, delta: float, spawn_position: Vector2, target_offset: Vector2, intro_duration: float, start_time_msec: int) -> Vector2:
	var elapsed: float = (Time.get_ticks_msec() - start_time_msec) / 1000.0

	if elapsed >= intro_duration:
		bullet.behaviour = Bullet.process_standard_bullet
		bullet.position = spawn_position + target_offset
		return Bullet.process_standard_bullet(bullet, delta)

	var t: float = clamp(elapsed / intro_duration, 0.0, 1.0)
	t = smoothstep(0.0, 1.0, t)

	return spawn_position.lerp(spawn_position + target_offset, t)
