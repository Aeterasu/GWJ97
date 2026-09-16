extends Pattern

@export var fire_rate: float = 0.5
var fire_timer: float = 0.0

@export var fire_rate_secondary: float = 1.0
var fire_timer_secondary: float = 0.0

@export var fire_rate_sun: float = 5.0
var fire_timer_sun: float = 5.0

@export var rotation_speed: float = 0.0
@export var max_rotation_speed: float = 0.0
var current_angle: float = 0.0

@export var is_firing: bool = false

var circle_max: int = 32
var circle_idx: int = 24

func init_pattern() -> void:
	super()

	is_started = true

	fire_timer_secondary = fire_rate_secondary

	animation_player.play("default")

func update(delta: float) -> void:
	if is_firing:
		fire_timer -= delta

		if fire_timer <= 0.0:
			fire_timer = fire_rate
			fire_rapid()

		fire_timer_secondary -= delta

		if fire_timer_secondary <= 0.0:
			fire_timer_secondary = fire_rate_secondary
			fire_secondary()

		fire_timer_sun -= delta 

		if fire_timer_sun <= 0.0:
			fire_timer_sun = fire_rate_sun
			fire_sun()
	else:
		fire_timer = 0.0

	current_angle += rotation_speed * delta

	#entities[0].rotation = current_angle
	entities[0].rotation = lerp_angle(entities[0].rotation, -TAU * (float(circle_idx) / float(circle_max)) - PI / 2, 1.0 - exp(-5.0 * delta))

func fire_rapid() -> void:
	var bullet_count: int = 8
	
	for i in bullet_count:
		var pos = entities[0].position

		var speed = remap(i, 0, bullet_count, 40.0, 250.0)

		bullet_engine.fire_bullet(pos, -TAU * (float(circle_idx) / float(circle_max)), speed, BulletSkin.Type.ENEMY_BULLET_RED_SMALL)
		#bullet_engine.fire_bullet(pos, current_angle - PI / 2, speed, BulletSkin.Type.ENEMY_BULLET_RED_SMALL)

	circle_idx += 1

	if circle_idx >= circle_max:
		circle_idx = 0

func fire_secondary() -> void:
	var count: int = 16

	for i in count:
		bullet_engine.fire_bullet(entities[0].position, TAU * randf(), 60.0, BulletSkin.Type.ENEMY_BULLET_ALT_SMALL)

func fire_sun() -> void:
	var dir = randi_range(22, 26)

	sun_spawner.spawn_sun(entities[0].position, Vector2.from_angle(-TAU * (float(dir) / float(circle_max))) * 80.0)
