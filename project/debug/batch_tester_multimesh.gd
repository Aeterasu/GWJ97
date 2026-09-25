extends Node3D

const GAME_SPACE: Vector2 = Vector2(240.0, 320.0)
const INSTANCE_COUNT: int = 10_000
const SPEED: float = 200.0
const QUAD_SIZE: Vector2 = Vector2(2.0, 2.0)
const Z_RANGE: int = 100

@export var gradient_from: Color = Color(1.0, 0.2, 0.6)
@export var gradient_to: Color = Color(0.1, 0.4, 1.0)

var multimesh: MultiMesh = null

var positions: PackedVector2Array = []
var directions: PackedVector2Array = []
var z_indices: PackedInt32Array = []

func _ready() -> void:
	setup_camera()
	setup_multimesh()
	spawn_instances()

func setup_camera() -> void:
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.keep_aspect = Camera3D.KEEP_WIDTH
	cam.size = GAME_SPACE.x
	cam.position = Vector3(0.0, 0.0, 500.0)
	add_child(cam)
	cam.look_at(Vector3.ZERO, Vector3.UP)
	cam.current = true

func setup_multimesh() -> void:
	var quad := QuadMesh.new()
	quad.size = QUAD_SIZE
	quad.orientation = PlaneMesh.FACE_Z # faces the camera looking down -Z

	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_texture = generate_gradient_texture()
	quad.material = material

	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_colors = false
	multimesh.use_custom_data = false
	multimesh.mesh = quad
	multimesh.instance_count = INSTANCE_COUNT

	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = multimesh
	add_child(mmi)

func spawn_instances() -> void:
	positions.resize(INSTANCE_COUNT)
	directions.resize(INSTANCE_COUNT)
	z_indices.resize(INSTANCE_COUNT)

	for i in INSTANCE_COUNT:
		positions[i] = random_position()
		directions[i] = random_direction()
		z_indices[i] = random_z_index()
		write_instance(i)

func _physics_process(delta: float) -> void:
	var half := GAME_SPACE * 0.5
	for i in INSTANCE_COUNT:
		var pos: Vector2 = positions[i] + directions[i] * SPEED * delta
		if absf(pos.x) > half.x or absf(pos.y) > half.y:
			pos = random_position()
			directions[i] = random_direction()
			z_indices[i] = random_z_index()
		positions[i] = pos
		write_instance(i)

func write_instance(i: int) -> void:
	var pos := positions[i]
	var z_depth := (float(z_indices[i]) / float(Z_RANGE)) * 10.0
	multimesh.set_instance_transform(i, Transform3D(Basis(), Vector3(pos.x, pos.y, z_depth)))

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
