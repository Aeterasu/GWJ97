class_name PlayerVisuals extends RefCounted

var sprite: Sprite2D = null
var hitbox_sprite: Sprite2D = null
var options: Array[Node2D] = []
var muzzle_flashes: Array[Node2D] = []

var sprite_shader: ShaderMaterial = null
var sprite_tilt: float = 0.0
var sprite_yaw: float = 0.0
var focus_fx: float = 0.0

func init(sprite_: Sprite2D, hitbox_: Sprite2D, options_: Array[Node2D], flashes_: Array[Node2D]) -> void:
	sprite = sprite_
	hitbox_sprite = hitbox_
	options = options_
	muzzle_flashes = flashes_
	sprite_shader = sprite.material as ShaderMaterial
	for flash: Sprite2D in muzzle_flashes:
		flash.scale.x = 0.0

func update_tilt(delta: float, dir: Vector2) -> void:
	var lerp_weight: float = 1.0 - exp(-10.0 * delta)
	var target_tilt: float = 0.0
	var target_yaw: float = 0.0

	if dir.x < -0.1 or dir.x > 0.1:
		target_tilt = 35.0 * sign(dir.x)

	if dir.y < -0.1 or dir.y > 0.1:
		target_yaw = 35.0 * -sign(dir.y)

	sprite_tilt = lerp(sprite_tilt, target_tilt, lerp_weight)
	sprite_yaw = lerp(sprite_yaw, target_yaw, lerp_weight)
	sprite_shader.set_shader_parameter("rot_y_deg", sprite_tilt)
	sprite_shader.set_shader_parameter("rot_x_deg", sprite_yaw)

func update_frame(delta: float, is_focused: bool, is_invul: bool, is_firing: bool) -> void:
	for flash: Node2D in muzzle_flashes:
		flash.scale.x = lerp(flash.scale.x, 0.0, 1.0 - exp(-20.0 * delta))
		flash.scale.y = lerp(flash.scale.y, 2.0, 1.0 - exp(-20.0 * delta))

		if not is_firing:
			flash.visible = true

	focus_fx = lerp(focus_fx, 1.0 if is_focused else 0.0, 1.0 - exp(-10.0 * delta))

	sprite_shader.set_shader_parameter("is_invul", is_invul)
	sprite_shader.set_shader_parameter("is_focused", focus_fx)

	for option: Node2D in options:
		(option.material as ShaderMaterial).set_shader_parameter("is_invul", is_invul)
		(option.material as ShaderMaterial).set_shader_parameter("is_focused", focus_fx)

	(hitbox_sprite.material as ShaderMaterial).set_shader_parameter("is_invul", is_invul)
	(hitbox_sprite.material as ShaderMaterial).set_shader_parameter("is_focused", focus_fx)

func on_fire() -> void:
	for flash: Sprite2D in muzzle_flashes:
		flash.scale = Vector2.ONE * randf_range(0.8, 1.5)
		flash.position.x = randf_range(-2.0, 2.0)
		flash.visible = not flash.visible
