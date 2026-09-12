class_name Bullet extends RefCounted

var position: Vector2 = Vector2.ZERO
var angle: float = 0.0
var speed: float = 0.0

var behaviour: Callable = process_standard_bullet

var skin: BulletSkin = null

var is_active: bool = false

# bookkeeping

var area_rid: RID = RID()
var multimesh_id: int = 0

func update(delta: float) -> void:
	if not is_active:
		return

	position = process_standard_bullet(delta)

	if position.y <= -32.0 or position.y >= Game.BOARD_SIZE.y + 32.0 or position.x <= -32.0 or position.x >= Game.BOARD_SIZE.x + 32.0: 
		is_active = false

func process_standard_bullet(delta: float) -> Vector2:
	return position + Vector2.from_angle(angle) * speed * delta
