class_name ResultScreenCheckbox extends TextureRect

@export var animation_player: AnimationPlayer = null
@export var sprite: Sprite2D = null
@export var check_texture: AtlasTexture = null
@export var cross_texture: AtlasTexture = null

func animate_check() -> void:
	animation_player.play("animate")

	sprite.texture = check_texture

func animate_cross() -> void:
	animation_player.play("animate")

	sprite.texture = cross_texture

func reset() -> void:
	animation_player.play("RESET")
