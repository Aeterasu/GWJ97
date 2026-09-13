extends Pattern

@export var fire_rate: float = 0.5
@export var attack_2_interval: int = 8
@export var attack_3_interval: int = 16

var timer: float = 0.0
var fire_count: int = 0

var time: float = 0.0
var v_x: float = 0.0
var prev_x: float = 0.0

func _ready() -> void:
	super()

func init_pattern() -> void:
	super()

	timer = fire_rate + 3.0
	fire_count = 0

	is_started = true

func update(delta: float) -> void:
	timer -= delta

	if timer <= 0.0:
		timer = fire_rate
		fire_count += 1

		fire_1()

		if fire_count % attack_2_interval == 0:
			fire_2()

		if fire_count % attack_3_interval == 0:
			fire_3()

	var player = Game.get_player()
	var target_pos = player.global_position if player else Vector2(120.0, 320.0)

	var target_angle = -PI / 2 + entities[0].global_position.angle_to_point(target_pos)

	entities[0].rotation = rotate_toward(entities[0].rotation, target_angle, 2.0 * delta)

	prev_x = entities[0].position.x

	time += delta * 2.0

	entities[0].position.x = remap(sin(time), -1.0, 1.0, 44.0, 240.0 - 44.0)
	entities[0].position.y = 118.0

	v_x = (entities[0].position.x - prev_x)

func fire_1() -> void:
	var angle = entities[0].rotation + PI / 2

	var bullet_count: int = 3

	for i in bullet_count:
		var pos = entities[0].position + Vector2(randf_range(-12.0, 12.0), randf_range(-4.0, 4.0))
		bullet_engine.fire_bullet(pos, angle + randf_range(-0.2, 0.2), randf_range(100.0, 260.0), BulletSkin.Type.ENEMY_BULLET_ALT_LONG)

func fire_2() -> void:
	var bullet_counts: Array = [12, 7, 5]
	var speeds: Array = [200.0, 150.0, 80.0]
	
	for i in bullet_counts.size():
		var a = BulletPatternHelper.get_arc(entities[0].rotation + PI / 2, 0.4, bullet_counts[i])

		for angle in a:
			bullet_engine.fire_bullet(entities[0].global_position + Vector2(v_x, 0.0), angle, speeds[i] * randf_range(0.9, 1.1), BulletSkin.Type.ENEMY_BULLET_RED_SMALL, gravity_bullet)

func fire_3() -> void:
	var bullet_count: int = 8

	var c = BulletPatternHelper.get_circle(randf() * TAU, bullet_count)

	for a in c:
		bullet_engine.fire_bullet(entities[0].global_position + Vector2(v_x, 0.0), a, 90.0, BulletSkin.Type.ENEMY_BULLET_RED_SMALL)

static func gravity_bullet(bullet: Bullet, delta: float) -> Vector2:
	bullet.velocity += Vector2.DOWN * 98 * delta
	return bullet.position + bullet.velocity * delta
