extends Enemy

@export var bullet_engine: BulletEngine = null

var time: float = 0.0

var fire_rate: float = 1.0
var fire_time_left: float = 1.0

# woah! ugly ugliness :)
var fire_rate_2: float = 0.3
var fire_time_left_2: float = 1.0

func _physics_process(delta: float) -> void:
	time += delta * 1.25

	global_position.x = 120.0 + sin(time * 0.5) * 64.0
	global_position.y = 80.0 + sin(time * 1.0) * 36.0

	fire_time_left -= delta

	if fire_time_left <= 0.0:
		fire()

	fire_time_left_2 -= delta

	if fire_time_left_2 <= 0.0:
		fire_2()

func fire() -> void:
	for i in 36:
		var pos = Vector2.from_angle(TAU * randf()) * randf() * 8.0
		var speed = randf_range(96.0, 180.0)
		bullet_engine.fire_bullet(global_position + pos, global_position.angle_to_point(Game.get_player().global_position), speed)

	fire_time_left = fire_rate

func fire_2() -> void:
	for i in 8:
		var pos = Vector2.from_angle(TAU * randf()) * randf() * 16.0
		var speed = randf_range(44.0, 90.0)
		bullet_engine.fire_bullet(global_position + pos, PI / 2.0 + randf_range(-PI / 2.0, PI / 2.0), speed)

	fire_time_left_2 = fire_rate_2
	
