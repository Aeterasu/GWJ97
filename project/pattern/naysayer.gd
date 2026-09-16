extends Pattern

@export var sword: Area2D = null
var sword_velocity: Vector2 = Vector2.ZERO
@export var circle_fire_rate: float = 0.05
var circle_fire_timer: float = 0.0

@export var line: Line2D = null

@export var is_raining: bool = false
var rain_rate: float = 0.3
var rain_timer: float = 0.0

var circle_counts: int = 16
var circle_current_count: int = 0
var offset: float = 0.0
var side_toggle: bool = false

func init_pattern() -> void:
	super()

	is_started = true

	animation_player.play("default")

	#line.hide()

func update(delta: float) -> void:
	if is_raining:
		rain_timer -= delta

		for i in 8:
			if rain_timer <= 0.0:
				rain_timer = rain_rate
				bullet_engine.fire_bullet(Vector2(randf_range(10.0, 230.0), -16), Vector2.DOWN.angle(), 100.0, BulletSkin.Type.ENEMY_BULLET_ALT_SMALL)

func fire_circle() -> void:
	circle_current_count = 0
	side_toggle = not side_toggle

	while circle_current_count < circle_counts and (not is_dead):
		var circle = BulletPatternHelper.get_circle(offset, 24)

		await get_tree().create_timer(0.12).timeout

		if is_dead:
			return

		for a in circle:
			var speed: float = 180.0
			bullet_engine.fire_bullet(entities[0].global_position, a, speed, BulletSkin.Type.ENEMY_BULLET_RED_LONG)

		var o = 1.5
		offset += -o if side_toggle else o
		circle_current_count += 1

