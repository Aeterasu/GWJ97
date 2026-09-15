class_name LifePickup extends Node

@export var sprite: Sprite2D = null
@export var particles: CPUParticles2D = null
var item: ScoreItem = null

signal on_life_collected

func _ready() -> void:
	item = ScoreItem.new()
	item.type = ScoreItem.Type.LIFE
	item.state = ScoreItem.State.DISABLED

	item.on_collection.connect(on_item_collected)

	sprite.hide()

func _physics_process(delta: float) -> void:
	if item.state == ScoreItem.State.DISABLED:
		sprite.visible = false
	else:
		sprite.visible = true

	item.update(delta)

	particles.emitting = sprite.visible

	sprite.global_position = item.position

func spawn_life_pickup(position: Vector2) -> void:
	item.position = position
	item.state = ScoreItem.State.NORMAL

	item.velocity = Vector2.UP * 64.0
	item.use_gravity = true
	item.current_collection_radius = ScoreItem.ITEM_COLLECT_RADIUS

	item.collect_timer = 0.0

	if not ScoreItem.player:
		ScoreItem.player = Game.get_player()
	
	sprite.global_position = position
	sprite.reset_physics_interpolation()

func on_item_collected(item: ScoreItem) -> void:
	on_life_collected.emit()
