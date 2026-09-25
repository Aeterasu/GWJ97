class_name BulletSkin extends Resource

enum Type
{
	NONE = 0,

	ENEMY_BULLET_RED_SMALL = 100,
	ENEMY_BULLET_RED_MEDIUM = 101,
	ENEMY_BULLET_RED_LONG = 102,

	ENEMY_BULLET_ALT_SMALL = 200,
	ENEMY_BULLET_ALT_MEDIUM = 201,
	ENEMY_BULLET_ALT_LONG = 202,

	PLAYER_BULLET_DEFAULT = 300,
	PLAYER_BULLET_ALT = 301,
}

@export var size: Vector2 = Vector2(16.0, 16.0)
@export var atlas_offset: Vector2 = Vector2.ZERO
@export var h_frames: int = 4
@export var v_frames: int = 1
@export var align_angle: bool = false
