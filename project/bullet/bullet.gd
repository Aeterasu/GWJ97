class_name Bullet extends RefCounted

var damage: float = 1.0

var previous_position: Vector2 = Vector2.ZERO
var position: Vector2 = Vector2.ZERO
var angle: float = 0.0
var velocity: Vector2 = Vector2.ZERO

var behaviour: Callable = process_standard_bullet

var skin: BulletSkin = null

var is_active: bool = false

const OOB_THRESHOLD: float = 48.0

# bookkeeping

var area_rid: RID = RID()
var multimesh_id: int = 0

func update(delta: float) -> void:
	if not is_active:
		return

	previous_position = position
	position = behaviour.call(self, delta)
	angle = velocity.angle()

	if position.y <= -OOB_THRESHOLD or position.y >= Game.BOARD_SIZE.y + OOB_THRESHOLD or position.x <= -OOB_THRESHOLD or position.x >= Game.BOARD_SIZE.x + OOB_THRESHOLD: 
		is_active = false
		PhysicsServer2D.area_set_shape_disabled.call_deferred(area_rid, 0, true)

static func process_standard_bullet(bullet: Bullet, delta: float) -> Vector2:
	return bullet.position + bullet.velocity * delta
