extends Pattern

@export var sprite: Sprite2D = null

@export var muzzle_flash: Sprite2D = null

func init_pattern() -> void:
	super()
	
	animation_player.animation_finished.connect(on_anim_finished)

	animation_player.play("start")

	muzzle_flash.scale = Vector2.ZERO

func on_anim_finished(anim_name: StringName) -> void:
	if anim_name == "start":
		animation_player.play("default")
		is_started = true

func update(delta: float) -> void:
	if is_timeout:
		timeout_pattern.shot_origin_position = entities[0].global_position
		timeout_pattern.update(delta)
		return

	var player = Game.get_player()
	var target_pos = player.global_position if player else Vector2(120.0, 320.0)

	var target_angle = -PI / 2 + entities[0].global_position.angle_to_point(target_pos)

	entities[0].rotation = rotate_toward(entities[0].rotation, target_angle, 2.0 * delta)

func fire(sun: bool = false) -> void:
	if is_timeout:
		return

	var angle = entities[0].rotation + PI / 2

	var bullet_count_1: int = int(24 * bullet_count_multiplier)
	var bullet_count_2: int = int(5 * bullet_count_multiplier)

	for i in bullet_count_1:
		var pos = entities[0].position + Vector2(randf_range(-12.0, 12.0), randf_range(-4.0, 4.0))
		
		var speed: float = randf_range(60.0, 350.0) * bullet_speed_multiplier

		var type = BulletSkin.Type.ENEMY_BULLET_RED_MEDIUM if randf() <= 0.5 else BulletSkin.Type.ENEMY_BULLET_ALT_LONG

		bullet_engine.fire_bullet(pos, angle + randf_range(-0.05, 0.05), speed, type)

	var arc = BulletPatternHelper.get_arc(angle, PI / 6, bullet_count_2)

	for a in arc:
		bullet_engine.fire_bullet(entities[0].position, a, 50.0 * bullet_speed_multiplier, BulletSkin.Type.ENEMY_BULLET_RED_MEDIUM)

	if sun:
		sun_spawner.spawn_sun(entities[0].position, Vector2.from_angle(angle) * 25.0)
	
	# visual

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "offset:y", -24.0, 0.1)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(sprite, "offset:y", 0.0, 0.2)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_delay(0.2)

	muzzle_flash.scale = Vector2(4.5, 1.0)
	tween.tween_property(muzzle_flash, "scale", Vector2(0.0, 2.0), 0.15)

