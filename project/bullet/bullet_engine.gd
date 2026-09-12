class_name BulletEngine extends Node

@export var max_bullet_count: int = 0
@export var bullet_visual: MultiMeshInstance2D = null

var bullets : Array[Bullet] = []
var active_bullet_count: int = 0

func _ready() -> void:
	bullets.resize(max_bullet_count)

	bullet_visual.multimesh.instance_count = max_bullet_count
	bullet_visual.multimesh.visible_instance_count = max_bullet_count

	for i in max_bullet_count:
		bullets[i] = Bullet.new()
		bullets[i].multimesh_id = i

		var transform = Transform2D.IDENTITY.scaled(Vector2.ZERO)
		bullet_visual.multimesh.set_instance_transform_2d(i, transform)

func _physics_process(delta: float) -> void:
	var i: int = 0
	while i < active_bullet_count:
		var bullet = bullets[i]
		bullet.update(delta)

		if not bullet.is_active:
			active_bullet_count -= 1
			bullets[i] = bullets[active_bullet_count]
			bullets[active_bullet_count] = bullet
			bullet_visual.multimesh.set_instance_transform_2d(bullet.multimesh_id, Transform2D.IDENTITY.scaled(Vector2.ZERO))
			bullet_visual.multimesh.reset_instance_physics_interpolation(bullet.multimesh_id)
			continue
	
		set_bullet_mesh_position(bullet.multimesh_id, bullet.position)
		i += 1

func fire_bullet(position: Vector2, angle: float, speed: float) -> void:
	if active_bullet_count >= max_bullet_count:
		return
	
	var bullet = bullets[active_bullet_count]	
	bullet.is_active = true
	bullet.position = position
	bullet.angle = angle
	bullet.speed = speed

	set_bullet_mesh_position(bullet.multimesh_id, position)
	bullet_visual.multimesh.reset_instance_physics_interpolation(bullet.multimesh_id)

	active_bullet_count += 1

func set_bullet_mesh_position(id: int, position: Vector2) -> void:
	bullet_visual.multimesh.set_instance_transform_2d(id, Transform2D.IDENTITY.translated(position).scaled(Vector2.ONE))
