class_name ScoreItem extends RefCounted

enum Type
{
	VERY_SMALL = 0,
	SMALL = 1,
	MEDIUM = 2,
	LARGE = 3,
	
	SUN = 100,
}

enum State
{
	DISABLED,
	NORMAL,
	VACUUM,
}

var multimesh_id: int = 0

var position: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var use_gravity: bool = true

var reward: int = 0

var scale: Vector2 = Vector2.ONE

var type: Type = Type.VERY_SMALL
var state: State = State.DISABLED

var collect_timer: float = 0.0

var fx_alpha: float = 0.0

var current_collection_radius: float = 0.0

const GRAVITY: float = 9.8 / 5.0
const OOB_THRESHOLD: float = 32.0

const ITEM_COLLECT_RADIUS: float = 96.0 * 96.0
const SUN_COLLECT_RADIUS: float = 54.0 * 54.0

const COLLECT_DURATION: float = 0.8

static var player: Player = null

signal on_collection

func update(delta: float) -> void:
	match state:
		State.DISABLED:
			return;
		State.NORMAL:
			process_normal_score_item(self, delta)
			update_alpha(delta)
		State.VACUUM:
			process_vacuum_score_item(self, delta)
			update_alpha(delta)

static func process_normal_score_item(item: ScoreItem, delta: float) -> void:
	item.position += item.velocity * delta;

	if item.use_gravity:
		item.velocity.x = lerp(item.velocity.x, 0.0, 4.0 * delta)
		item.velocity.y += GRAVITY;

	item.scale = item.scale.lerp(Vector2.ONE, 1.0 - exp(-10.0 * delta))

	if item.position.y <= -OOB_THRESHOLD or item.position.y >= Game.BOARD_SIZE.y + OOB_THRESHOLD or item.position.x <= -OOB_THRESHOLD or item.position.x >= Game.BOARD_SIZE.x + OOB_THRESHOLD:
		item.state = State.DISABLED

	if item.position.distance_squared_to(get_player_global_position()) <= item.current_collection_radius:
		item.state = State.VACUUM

static func process_vacuum_score_item(item: ScoreItem, delta: float) -> void:
	item.position = item.position.lerp(get_player_global_position(), item.collect_timer / COLLECT_DURATION)

	item.collect_timer = min(item.collect_timer + delta, COLLECT_DURATION)

	if item.collect_timer >= COLLECT_DURATION:
		item.on_collection.emit(item)
		item.state = State.DISABLED

static func get_player_global_position() -> Vector2:
	if not player:
		return Vector2(999.0, 999.0)
	else:
		return player.global_position

func update_alpha(delta: float) -> void:
	fx_alpha = max(fx_alpha - delta * 3.0, 0.0)
