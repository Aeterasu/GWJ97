class_name ScoreSunManager extends Node

@export var max_sun_count: int = 32

@export var visual_scene: PackedScene = null
@export var visual_parent: Node = null

var suns: Array[ScoreItem] = []
var visual_nodes: Array[Node2D] = []

var active_sun_count: int = 0

signal on_sun_collection

func _ready() -> void:
	suns.resize(max_sun_count)
	visual_nodes.resize(max_sun_count)

	for i in max_sun_count:
		suns[i] = ScoreItem.new()
		suns[i].type = ScoreItem.Type.SUN

		suns[i].on_collection.connect(on_sun_collection.emit)

		suns[i].multimesh_id = i

		visual_nodes[i] = visual_scene.instantiate() as Node2D
		visual_parent.add_child(visual_nodes[i])

		visual_nodes[i].pivot.hide()

func _physics_process(delta: float) -> void:
	var i: int = 0
	while i < active_sun_count:
		var sun = suns[i]
		sun.update(delta)

		if sun.state == ScoreItem.State.DISABLED:
			active_sun_count -= 1
			suns[i] = suns[active_sun_count]
			suns[active_sun_count] = sun
			visual_nodes[sun.multimesh_id].pivot.hide()
			visual_nodes[sun.multimesh_id].position = Vector2(-999.0, -999.0)
			continue

		i += 1

		visual_nodes[sun.multimesh_id].position = sun.position

func spawn_sun(position: Vector2, velocity: Vector2 = Vector2.ZERO) -> ScoreItem:
	if active_sun_count >= max_sun_count:
		return null

	var sun = suns[active_sun_count]
	sun.position = position
	sun.current_collection_radius = ScoreItem.SUN_COLLECT_RADIUS

	if velocity.is_equal_approx(Vector2.ZERO):
		sun.velocity = Vector2.UP * 64.0
		sun.use_gravity = true
	else:
		sun.velocity = velocity
		sun.use_gravity = false

	sun.collect_timer = 0.0

	sun.state = ScoreItem.State.NORMAL

	if not ScoreItem.player:
		ScoreItem.player = Game.get_player()

	visual_nodes[sun.multimesh_id].position = position
	visual_nodes[sun.multimesh_id].reset_physics_interpolation()
	visual_nodes[sun.multimesh_id].pivot.show()
	visual_nodes[sun.multimesh_id].animate_spawn()

	active_sun_count += 1

	return sun
