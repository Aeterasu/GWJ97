class_name ScoreItemManager extends Node

@export var max_item_count: int = 256
@export var visual: MultiMeshInstance2D = null

# array layout
# 0 - size of the texture in the atlas
# 1 - offset to get to the damn texture
@export var atlas_offsets: Dictionary[ScoreItem.Type, PackedVector2Array] = {}
var OVERLAY_OFFSET: Vector2 = Vector2(0.0, 36.0)

var items: Array[ScoreItem] = []

var active_item_count: int = 0

static var default_transform: Transform2D = Transform2D.IDENTITY.scaled(Vector2.ZERO)

signal on_item_collection
signal all_items_cleared

func _ready() -> void:
	items.resize(max_item_count)

	visual.multimesh.instance_count = max_item_count
	visual.multimesh.visible_instance_count = max_item_count

	for i in max_item_count:
		items[i] = ScoreItem.new()
		items[i].multimesh_id = i

		items[i].on_collection.connect(on_item_collection.emit)

		visual.multimesh.set_instance_transform_2d(i, default_transform)	

func has_active_items() -> bool:
	return active_item_count > 0

func await_all_items_cleared() -> void:
	if active_item_count == 0:
		return
	await all_items_cleared

func _physics_process(delta: float) -> void:
	var i: int = 0
	while i < active_item_count:
		var item = items[i]
		item.update(delta)

		if item.state == ScoreItem.State.DISABLED:
			active_item_count -= 1
			items[i] = items[active_item_count]
			items[active_item_count] = item
			visual.multimesh.set_instance_transform_2d(item.multimesh_id, default_transform)
			visual.multimesh.reset_instance_physics_interpolation(item.multimesh_id)
			if active_item_count == 0:
				all_items_cleared.emit()
			continue

		i += 1

		visual.multimesh.set_instance_transform_2d(item.multimesh_id, Transform2D.IDENTITY.scaled_local((atlas_offsets[item.type])[1] * item.scale).translated(item.position))
		visual.multimesh.set_instance_color(item.multimesh_id, Color(clampf(item.fx_alpha, 1.0, 1.0), 0.0, 0.0, 0.0))

func spawn_score_item(type: ScoreItem.Type, position: Vector2) -> ScoreItem:
	if active_item_count >= max_item_count:
		return
	
	var item = items[active_item_count]
	item.state = ScoreItem.State.NORMAL
	item.position = position
	item.type = type
	item.velocity.y = randf_range(-120.0, -96.0)
	item.velocity.x = remap(position.x, 0.0, 240.0, -32.0, 32.0)
	item.fx_alpha = 3.0
	item.scale = Vector2.ONE * 2.5
	item.collect_timer = 0.0
	item.current_collection_radius = ScoreItem.ITEM_COLLECT_RADIUS

	if not ScoreItem.player:
		ScoreItem.player = Game.get_player()

	visual.multimesh.set_instance_transform_2d(item.multimesh_id, Transform2D.IDENTITY.translated(position))
	visual.multimesh.reset_instance_physics_interpolation(item.multimesh_id)

	var custom = atlas_offsets[type]
	visual.multimesh.set_instance_custom_data(item.multimesh_id, Color(custom[0].x, custom[0].y, custom[1].x, custom[1].y))

	active_item_count += 1

	return item
