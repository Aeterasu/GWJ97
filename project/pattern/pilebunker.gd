extends Pattern

@export var animation_player: AnimationPlayer = null

func _ready() -> void:
	super()

func init_pattern() -> void:
	super()

	is_started = true

	animation_player.play("default")

func kill_start() -> void:
	super()
	animation_player.play("death")

	animation_player.stop()

func update(delta: float) -> void:
	var player = Game.get_player()
	var target_pos = player.global_position if player else Vector2(120.0, 320.0)

	var target_angle = -PI / 2 + entities[0].global_position.angle_to_point(target_pos)

	entities[0].rotation = rotate_toward(entities[0].rotation, target_angle, 2.0 * delta)

func fire(sun: bool = false) -> void:
	var angle = entities[0].rotation + PI / 2

	var bullet_count_1: int = 36
	var bullet_count_2: int = 7

	for i in bullet_count_1:
		var pos = entities[0].position + Vector2(randf_range(-12.0, 12.0), randf_range(-4.0, 4.0))
		
		var speed: float = randf_range(60.0, 350.0)

		var type = BulletSkin.Type.ENEMY_BULLET_RED_SMALL if randf() <= 0.5 else BulletSkin.Type.ENEMY_BULLET_ALT_LONG

		bullet_engine.fire_bullet(pos, angle + randf_range(-0.05, 0.05), speed, type)

	var arc = BulletPatternHelper.get_arc(angle, PI / 6, bullet_count_2)

	for a in arc:
		bullet_engine.fire_bullet(entities[0].position, a, 50.0, BulletSkin.Type.ENEMY_BULLET_RED_SMALL)

	if sun:
		sun_spawner.spawn_sun(entities[0].position, Vector2.from_angle(angle) * 25.0)
