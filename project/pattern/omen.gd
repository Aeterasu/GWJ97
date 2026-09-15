class_name Omen extends Pattern

@export var animation_player: AnimationPlayer = null
@export var text: AnimatedText = null

@export var bullet_origin_left: Marker2D = null
@export var bullet_origin_right: Marker2D = null

@export_range(0.0, 1.0) var sin_ratio: float = 0.0
var time: float = 0.0

@export var fire_rate: float = 0.0
var fire_time_left: float = 0.0
@export var current_offset: float = 0.0
@export var arc_spread: float = 15.0
@export var max_offset: float = 45.0
var direction: float = 1.0

var count: int = 0

func _ready() -> void:
	super()

	animation_player.animation_finished.connect(on_anim_finished)

func init_pattern() -> void:
	super()

	fire_time_left = fire_rate

	animation_player.play("start")

func update(delta: float) -> void:
	var entity = entities[0]

	time += delta * 1.3333

	entity.global_position.x = 120.0 + (sin(time * 0.5) * 32.0) * sin_ratio
	entity.global_position.y = 88.0 + (sin(time * 1.0) * 16.0) * sin_ratio

	fire_time_left -= delta

	if fire_time_left <= 0.0:
		fire_time_left = fire_rate
		fire()

func fire() -> void:
	var arc_count: int = 6

	var arc = BulletPatternHelper.get_arc(PI / 2 + deg_to_rad(current_offset), deg_to_rad(arc_spread), arc_count)

	var speed: float = 200.0

	for angle in arc:
		bullet_engine.fire_bullet(entities[0].global_position, angle, speed, BulletSkin.Type.ENEMY_BULLET_RED_SMALL)	

	current_offset += arc_spread * direction

	if current_offset >= max_offset or current_offset <= -max_offset:
		direction *= -1.0
		
		count += 1

		if count > 3:
			sun_spawner.spawn_sun(entities[0].global_position)
			count = 0

	# aimed bullets

	var speed_2 := 130.0

	for i in 6:
		bullet_engine.fire_bullet(entities[0].global_position + Vector2.from_angle(TAU * randf()) * randf() * 8.0, BulletPatternHelper.get_angle_to_player(entities[0].global_position) + randf_range(-0.8, 0.8), speed_2, BulletSkin.Type.ENEMY_BULLET_ALT_LONG)

func kill_start() -> void:
	super()

	animation_player.play("death")

func on_anim_finished(anim_name: StringName) -> void:
	if anim_name == "start":
		animation_player.play("default")
		is_started = true
