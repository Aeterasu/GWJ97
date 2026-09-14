extends Pattern

@export var animation_player: AnimationPlayer = null

@export var shot_origins: Array[Marker2D] = []

@export var fire_rate: float = 0.0
var fire_time_left: float = 0.0
var is_bursting: bool = false

@export var burst_count: int = 5
@export var burst_rate: float = 0.05
var burst_current: int = -1
var burst_timer: float = 0.0

@export var arc_fire_rate: float = 0.0
var arc_time_left: float = 0.0

var sun_max: int = 10
var exclude_origin: int = 0

func init_pattern() -> void:
	super()

	fire_time_left = fire_rate
	arc_time_left = arc_fire_rate

	is_started = true

	shot_origins.sort_custom(func(a, b): return a.global_position.x < b.global_position.x)

func update(delta: float) -> void:
	fire_time_left -= delta

	if fire_time_left <= 0.0:
		fire_time_left = fire_rate

		fire_primary()
		sun_counter += 1
		exclude_origin = randi_range(1, shot_origins.size() - 2)

	if is_bursting:
		burst_timer -= delta

	if is_bursting and burst_timer <= 0.0:
		for i in shot_origins.size():
			var origin = shot_origins[i]

			if i == exclude_origin and sun_counter >= sun_max:
				if burst_current == burst_count / 2:
					sun_spawner.spawn_sun(origin.global_position, Vector2.DOWN * 120.0) 	
				continue
			
			var pos = origin.global_position
			var angle = Vector2.DOWN.angle()
			var speed = 120.0

			bullet_engine.fire_bullet(pos, angle, speed, BulletSkin.Type.ENEMY_BULLET_RED_LONG)

		burst_timer = burst_rate
		burst_current += 1

		if burst_current >= burst_count:
			is_bursting = false
			
			if sun_counter >= sun_max:
				sun_counter = 0

	arc_time_left -= delta

	if arc_time_left <= 0.0:
		arc_time_left = arc_fire_rate

		fire_arc()

func fire_primary() -> void:
	is_bursting = true

	burst_current = 0
	burst_timer = 0.0

func fire_arc() -> void:
	var bullet_count: int = 24

	var player: Player = Game.get_player()
	var player_pos: Vector2 = player.global_position if player else Vector2(120.0, 320.0)

	var target_pos: Vector2 = Vector2(remap(player_pos.x, 0.0, 240.0, 60.0, 180.0), entities[0].global_position.y - 100.0)

	var arc = BulletPatternHelper.get_arc(entities[0].global_position.angle_to_point(target_pos), 0.14, bullet_count)
	
	var pos = entities[0].global_position

	for i in arc:
		var speed = randf_range(90.0, 180.0)
		bullet_engine.fire_bullet(pos, i, speed, BulletSkin.Type.ENEMY_BULLET_ALT_SMALL, gravity_bullet)

static func gravity_bullet(bullet: Bullet, delta: float) -> Vector2:
	bullet.velocity += Vector2.DOWN * 98 * delta
	return bullet.position + bullet.velocity * delta

func kill_start() -> void:
	super()

	animation_player.play("death")
