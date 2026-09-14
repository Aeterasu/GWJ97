class_name Omen extends Pattern

@export var animation_player: AnimationPlayer = null

@export var bullet_origin_left: Marker2D = null
@export var bullet_origin_right: Marker2D = null

@export_range(0.0, 1.0) var sin_ratio: float = 0.0
var time: float = 0.0

@export var fire_rate: float = 0.0
var fire_time_left: float = 0.0
var toggle_side: bool = false

@export var aimed_attack_fire_rate: float = 0.0
var aimed_attack_time_left: float = 0.0

enum Side
{
	LEFT,
	RIGHT,
}

func _ready() -> void:
	super()

	animation_player.animation_finished.connect(on_anim_finished)

func init_pattern() -> void:
	super()

	fire_time_left = fire_rate
	aimed_attack_time_left = aimed_attack_fire_rate

	animation_player.play("start")

func fire(side: Omen.Side) -> void:
	var bullet_count: int = 24

	var circle = BulletPatternHelper.get_circle(0.0, bullet_count)

	var pos = bullet_origin_left.global_position if side == Side.LEFT else bullet_origin_right.global_position

	for i in circle.size():
		var angle = circle[i]
		var speed = 150.0	
		if sun_counter > 0 and sun_counter % 3 == 0 and i == 6:
			sun_spawner.spawn_sun(pos, Vector2.from_angle(circle[i]) * 110.0)
		else:
			bullet_engine.fire_bullet(pos, angle, speed, BulletSkin.Type.ENEMY_BULLET_RED_SMALL)

	sun_counter += 1

func fire_aimed() -> void:
	var bullet_count: int = 16

	for i in bullet_count:
		var pos = entities[0].global_position + Vector2.from_angle(randf() * TAU) * randf_range(8.0, 16.0)
		var speed: float = randf_range(96.0, 200.0)
		var angle = BulletPatternHelper.get_angle_to_player(entities[0].global_position) + randf_range(-PI / 4, PI / 4)

		bullet_engine.fire_bullet(pos, angle, speed, BulletSkin.Type.ENEMY_BULLET_ALT_LONG)

func update(delta: float) -> void:
	var entity = entities[0]

	time += delta * 1.3333

	entity.global_position.x = 120.0 + (sin(time * 0.5) * 32.0) * sin_ratio
	entity.global_position.y = 88.0 + (sin(time * 1.0) * 16.0) * sin_ratio

	fire_time_left -= delta

	if fire_time_left <= 0.0:
		fire_time_left = fire_rate
		fire(Side.RIGHT if toggle_side else Side.LEFT)
		toggle_side = not toggle_side

	aimed_attack_time_left -= delta

	if aimed_attack_time_left <= 0.0:
		aimed_attack_time_left = aimed_attack_fire_rate
		fire_aimed()

func kill_start() -> void:
	super()

	animation_player.play("death")

func on_anim_finished(anim_name: StringName) -> void:
	if anim_name == "start":
		animation_player.play("default")
		is_started = true
