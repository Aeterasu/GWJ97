extends Pattern

@export var intensity: float = 0.1

var fire_timer_1: float = 0.0
var fire_timer_2: float = 0.0
var offset: float = 0.0

const ORIGIN: Vector2 = Vector2(120.0, 100.0)

func init_pattern() -> void:
	super()

	is_started = true

	animation_player.play("default")

	fire_timer_1 = 0.0
	fire_timer_2 = 10.0

func update(delta: float) -> void:
	if is_timeout:

		timeout_pattern.shot_origin_position = entities[0].global_position
		timeout_pattern.update(delta)
		return
	
	fire_timer_1 -= delta

	if fire_timer_1 <= 0.0:
		fire_timer_1 = remap(intensity, 0.1, 2.0, 0.4, 0.2)
		fire_1()

	fire_timer_2 -= delta
	
	if fire_timer_2 <= 0.0:
		fire_timer_2 = remap(intensity, 0.1, 2.0, 2.0, 1.0)
		fire_2()

func fire_1() -> void:
	var count = clampi(remap(intensity, 0.2, 2.0, 1, 10), 1, 10)
	var type = [BulletSkin.Type.ENEMY_BULLET_RED_SMALL, BulletSkin.Type.ENEMY_BULLET_RED_LONG]

	for i in (1 if count <= 1 else randi() % int(count)):
		var pos = Utils.get_random_rectangle_perimeter_pos(Vector2(260.0, 340.0), Vector2(130.0, 170.0))
		bullet_engine.fire_bullet(pos, pos.angle_to_point(ORIGIN), randf_range(20.0, 90.0), type.pick_random(), process_bullet)

	sun_counter += 1

	if sun_counter >= 20:
		var pos = Vector2(randf_range(10.0, 230.0), 320.0)
		sun_spawner.spawn_sun(pos, Vector2.from_angle(pos.angle_to_point(ORIGIN)) * 40.0)
		sun_counter = 0

func fire_2() -> void:
	var count = clampi(remap(intensity, 0.2, 2.0, 5, 12), 5, 12)
	var type = [BulletSkin.Type.ENEMY_BULLET_ALT_SMALL, BulletSkin.Type.ENEMY_BULLET_ALT_LONG]

	var circle = BulletPatternHelper.get_circle(offset, count)
	offset += 0.3

	for i in circle:
		bullet_engine.fire_bullet(ORIGIN, i, 40.0, type.pick_random())

static func process_bullet(bullet: Bullet, delta: float) -> Vector2:
	var pos = bullet.position + bullet.velocity * delta
	
	if pos.distance_to(ORIGIN) <= 4.0:
		bullet.is_active = false
		PhysicsServer2D.area_set_shape_disabled.call_deferred(bullet.area_rid, 0, true)
		return Vector2(-99.0, -99.0)
	else:
		return pos
