class_name BulletSkin extends Resource

enum Type
{
	NONE = 0,

	ENEMY_BULLET_SMALL = 100,
	ENEMY_BULLET_MEDIUM = 101,
	ENEMY_BULLET_LONG = 102,

	PLAYER_BULLET_DEFAULT = 200,
}

@export var size: Vector2 = Vector2(16.0, 16.0)
@export var atlas_offset: Vector2 = Vector2.ZERO
@export var h_frames: int = 4
@export var v_frames: int = 1
@export var align_angle: bool = false
