extends Pattern

@export var intensity: float = 0.1

var fire_timer_1: float = 0.0
var fire_timer_2: float = 10.0
var offset: float = 0.0

var sun_toggle: bool = false

const ORIGIN: Vector2 = Vector2(120.0, 100.0)

func init_pattern() -> void:
	super()

	is_started = true

	animation_player.play("default")

func update(delta: float) -> void:
	if is_timeout:
		timeout_pattern.shot_origin_position = entities[0].global_position
		timeout_pattern.update(delta)
		return

	fire_timer_1 -= delta

	if fire_timer_1 <= 0.0:
		fire_timer_1 = remap(intensity, 0.1, 2.0, 0.4, 0.1)
		fire_1()
	
	fire_timer_2 -= delta

	if fire_timer_2 <= 0.0:
		fire_timer_2 = remap(intensity, 0.1, 2.0, 3.0, 1.5)
		fire_2()

func fire_1() -> void:
	var count = clampi(remap(intensity, 0.2, 2.0, 1, 10), 1, 10)
	var type = [BulletSkin.Type.ENEMY_BULLET_RED_MEDIUM, BulletSkin.Type.ENEMY_BULLET_RED_LONG]

	var circle = BulletPatternHelper.get_circle(offset, count)

	offset += 1.5

	for i in circle:
		bullet_engine.fire_bullet(ORIGIN, i, 90.0, type.pick_random())

func fire_2() -> void:
	if not sun_toggle:
		for i in 6:
			await get_tree().create_timer(0.08, false).timeout

			bullet_engine.fire_bullet(ORIGIN, BulletPatternHelper.get_angle_to_player(ORIGIN), randf_range(120.0, 200.0), BulletSkin.Type.ENEMY_BULLET_ALT_LONG)
	else:
		sun_spawner.spawn_sun(ORIGIN, Vector2.from_angle(BulletPatternHelper.get_angle_to_player(ORIGIN)) * 100.0)

	sun_toggle = not sun_toggle
