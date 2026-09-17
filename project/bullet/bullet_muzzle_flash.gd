class_name BulletMuzzleFlash extends MultiMeshInstance2D

var scales: PackedFloat32Array = []

func configure(count: int) -> void:
	self.multimesh.instance_count = count
	self.multimesh.visible_instance_count = count

	scales.resize(count)

	for i in count:
		self.multimesh.set_instance_transform_2d(i, Transform2D.IDENTITY.scaled(Vector2.ZERO))

func update(bullet: Bullet, delta: float) -> void:
	scales[bullet.multimesh_id] = lerp(scales[bullet.multimesh_id], 0.0, 1.0 - exp(-5.0 * delta))
	self.multimesh.set_instance_transform_2d(bullet.multimesh_id, Transform2D.IDENTITY.translated(bullet.position).scaled_local(scales[bullet.multimesh_id] * Vector2.ONE))

func hide_at_idx(idx: int) -> void:
	self.multimesh.set_instance_transform_2d(idx, Transform2D.IDENTITY.scaled(Vector2.ZERO))
	self.multimesh.reset_instance_physics_interpolation(idx)

	scales[idx] = 0.0

func show_at_bullet(bullet: Bullet) -> void:
	self.multimesh.set_instance_transform_2d(bullet.multimesh_id, Transform2D.IDENTITY.translated(bullet.position).scaled_local(Vector2.ONE))
	self.multimesh.reset_instance_physics_interpolation(bullet.multimesh_id)

	scales[bullet.multimesh_id] = 2.0
