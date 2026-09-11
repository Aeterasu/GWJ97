class_name BulletManager extends Node

@export var max_bullet_count: int = 0
@export var bullet_visual: MultiMeshInstance2D = null

var bullets : Array[Bullet] = []

func _ready() -> void:
	bullets.resize(max_bullet_count)

	bullet_visual.multimesh.instance_count = max_bullet_count
	bullet_visual.multimesh.visible_instance_count = -1

	for i in max_bullet_count:
		bullets[i] = Bullet.new()

		var transform = Transform2D.IDENTITY
		bullet_visual.multimesh.set_instance_transform_2d(i, transform)

func _physics_process(delta: float) -> void:
	for i in max_bullet_count:
		var bullet = bullets[i]

		if (not bullet.is_active):
			continue
		else:
			bullet.update(delta)
			bullet_visual.multimesh.set_instance_transform_2d(i, Transform2D.IDENTITY.translated(bullet.position))

func fire_bullet(position: Vector2, angle: float, speed: float) -> void:
	for i in max_bullet_count:
		var bullet = bullets[i]

		if (not bullet.is_active):
			bullet.is_active = true
			bullet.position = position
			bullet.angle = angle
			bullet.speed = speed

			return
