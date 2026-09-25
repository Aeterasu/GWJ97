extends Node2D

const GAME_SPACE: Vector2 = Vector2(240.0, 320.0)
const INSTANCE_COUNT: int = 10_000
const SPEED: float = 200.0
const QUAD_SIZE: Vector2 = Vector2(2.0, 2.0)
const Z_RANGE: int = 100

@export var gradient_from: Color = Color(1.0, 0.2, 0.6)
@export var gradient_to: Color = Color(0.1, 0.4, 1.0)

var texture: Texture2D
var positions: PackedVector2Array
var directions: PackedVector2Array
var z_indices: PackedInt32Array
var item_rids: Array[RID] = []

func _ready() -> void:
	texture = generate_gradient_texture()
	spawn_instances()

func spawn_instances() -> void:
	var canvas := get_canvas_item()
	var rect := Rect2(-QUAD_SIZE * 0.5, QUAD_SIZE)

	positions.resize(INSTANCE_COUNT)
	directions.resize(INSTANCE_COUNT)
	z_indices.resize(INSTANCE_COUNT)
	item_rids.resize(INSTANCE_COUNT)

	for i in INSTANCE_COUNT:
		var pos := random_position()
		var dir := random_direction()
		var z := random_z_index()

		var rid := RenderingServer.canvas_item_create()
		RenderingServer.canvas_item_set_parent(rid, canvas)
		RenderingServer.canvas_item_set_z_index(rid, z)
		RenderingServer.canvas_item_add_texture_rect(rid, rect, texture)
		RenderingServer.canvas_item_set_transform(rid, Transform2D(0.0, pos))

		positions[i] = pos
		directions[i] = dir
		z_indices[i] = z
		item_rids[i] = rid

func _physics_process(delta: float) -> void:
	var half := GAME_SPACE * 0.5
	for i in INSTANCE_COUNT:
		var pos: Vector2 = positions[i] + directions[i] * SPEED * delta
		if absf(pos.x) > half.x or absf(pos.y) > half.y:
			pos = random_position()
			directions[i] = random_direction()
			var z := random_z_index()
			z_indices[i] = z
			RenderingServer.canvas_item_set_z_index(item_rids[i], z)
		positions[i] = pos
		RenderingServer.canvas_item_set_transform(item_rids[i], Transform2D(0.0, pos))

func random_position() -> Vector2:
	var half := GAME_SPACE * 0.5
	return Vector2(randf_range(-half.x, half.x), randf_range(-half.y, half.y))

func random_direction() -> Vector2:
	return Vector2.from_angle(randf_range(0.0, TAU))

func random_z_index() -> int:
	return randi_range(-Z_RANGE, Z_RANGE)

func generate_gradient_texture() -> ImageTexture:
	var size := 64
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	for x in size:
		var t := float(x) / float(size - 1)
		var col := gradient_from.lerp(gradient_to, t)
		for y in size:
			image.set_pixel(x, y, col)
	return ImageTexture.create_from_image(image)

func _exit_tree() -> void:
	for rid in item_rids:
		RenderingServer.free_rid(rid)