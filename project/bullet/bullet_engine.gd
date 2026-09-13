class_name BulletEngine extends Node

@export var max_bullet_count: int = 0
@export var shape_radius: float = 2.0
@export var bullet_visual: MultiMeshInstance2D = null
@export_flags("Default", "Player", "Enemy") var collision_mask: int = 0

var bullets: Array[Bullet] = []
var area_rids: Array[RID] = []
var shape_rid: RID = RID()

var active_bullet_count: int = 0

const PLAYER_COLLISION_BIT = 1
const ENEMY_COLLISION_BIT = 2

func _ready() -> void:
	bullets.resize(max_bullet_count)
	area_rids.resize(max_bullet_count)
	
	# physics
	
	shape_rid = PhysicsServer2D.circle_shape_create()
	PhysicsServer2D.shape_set_data(shape_rid, shape_radius)

	# visual

	bullet_visual.multimesh.instance_count = max_bullet_count
	bullet_visual.multimesh.visible_instance_count = max_bullet_count

	# hot loop

	for i in max_bullet_count:
		bullets[i] = Bullet.new()
		bullets[i].multimesh_id = i

		# physics

		var area = PhysicsServer2D.area_create()
		PhysicsServer2D.area_set_space(area, bullet_visual.get_world_2d().space)
		PhysicsServer2D.area_add_shape(area, shape_rid, Transform2D())
		PhysicsServer2D.area_set_collision_layer(area, 0)
		PhysicsServer2D.area_set_collision_mask(area, collision_mask)

		PhysicsServer2D.area_set_area_monitor_callback(area, on_area_entered.bind(bullets[i]))
		PhysicsServer2D.area_set_shape_disabled.call_deferred(area, 0, true)
		
		area_rids[i] = area
		bullets[i].area_rid = area

		# visual

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
	
		PhysicsServer2D.area_set_transform(bullet.area_rid, Transform2D.IDENTITY.translated(bullet.position))
		set_bullet_mesh_position(bullet, bullet.position)
		i += 1

func on_area_entered(status: int, area_rid: RID, instance_id: int, area_shape_idx: int, self_shape_idx: int, bullet: Bullet) -> void:
	if status == PhysicsServer2D.AREA_BODY_ADDED:
		var body := instance_from_id(instance_id)

		if body is Enemy:
			(body as Enemy).hit(1.0)
		if body is Player:
			(body as Player).hit()

		bullet.is_active = false
		PhysicsServer2D.area_set_shape_disabled.call_deferred(bullet.area_rid, 0, true)

func fire_bullet(position: Vector2, angle: float, speed: float, skin: BulletSkin.Type) -> void:
	if active_bullet_count >= max_bullet_count:
		return
	
	var bullet = bullets[active_bullet_count]	
	bullet.is_active = true
	bullet.position = position
	bullet.angle = angle
	bullet.speed = speed
	bullet.skin = BulletSkinManager.get_skin_by_type(skin)

	set_bullet_mesh_position(bullet, position)
	bullet_visual.multimesh.reset_instance_physics_interpolation(bullet.multimesh_id)
	bullet_visual.multimesh.set_instance_custom_data(bullet.multimesh_id, Color(bullet.skin.atlas_offset.x, bullet.skin.atlas_offset.y, bullet.skin.size.x, bullet.skin.size.y))
	bullet_visual.multimesh.set_instance_color(bullet.multimesh_id, Color(fmod(Time.get_ticks_msec() / 1000.0, 3600.0), 0.0, 0.0, 0.0))

	PhysicsServer2D.area_set_transform(bullet.area_rid, Transform2D.IDENTITY.translated(bullet.position))
	PhysicsServer2D.area_set_shape_disabled(bullet.area_rid, 0, false)

	active_bullet_count += 1

func set_bullet_mesh_position(bullet: Bullet, position: Vector2) -> void:
	var rot: float = 0.0

	if bullet.skin.align_angle:
		rot = bullet.angle + PI / 2

	bullet_visual.multimesh.set_instance_transform_2d(bullet.multimesh_id, Transform2D.IDENTITY.translated(position).rotated_local(rot).scaled_local(bullet.skin.size))	

