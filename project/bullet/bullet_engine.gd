class_name BulletEngine extends Node

@export var max_bullet_count: int = 0
@export var shape_radius: float = 2.0
@export var use_tunneling_fix: bool = false
@export var bullet_visual: MultiMeshInstance2D = null
@export_flags("Default", "Player", "Enemy") var collision_mask: int = 0

var bullets: Array[Bullet] = []
var area_rids: Array[RID] = []
var shape_rid: RID = RID()

# tunneling for fast moving bulelts
var ray_query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.new()

var active_bullet_count: int = 0

const PLAYER_COLLISION_BIT = 1
const ENEMY_COLLISION_BIT = 2

func _ready() -> void:
	bullets.resize(max_bullet_count)
	area_rids.resize(max_bullet_count)
	
	# physics
	
	shape_rid = PhysicsServer2D.circle_shape_create()
	PhysicsServer2D.shape_set_data(shape_rid, shape_radius)

	ray_query.collision_mask = collision_mask
	ray_query.collide_with_areas = true
	ray_query.collide_with_bodies = false

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
	var space_state: PhysicsDirectSpaceState2D = PhysicsServer2D.space_get_direct_state(bullet_visual.get_world_2d().space)

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
		else:
			if use_tunneling_fix:
				update_tunnel_hit(bullet, space_state)
	
		PhysicsServer2D.area_set_transform(bullet.area_rid, Transform2D.IDENTITY.translated(bullet.position))
		set_bullet_mesh_position(bullet, bullet.position)
		i += 1

func update_tunnel_hit(bullet: Bullet, space_state: PhysicsDirectSpaceState2D) -> void:
	ray_query.from = bullet.previous_position
	ray_query.to = bullet.position

	var result := space_state.intersect_ray(ray_query)
	
	if result.is_empty():
		return
	else:
		check_collision_hit(bullet, result.collider)

func _process(delta: float) -> void:
	(bullet_visual.material as ShaderMaterial).set_shader_parameter("game_time", fmod(Time.get_ticks_msec() / 1000.0, 1800.0))

func on_area_entered(status: int, area_rid: RID, instance_id: int, area_shape_idx: int, self_shape_idx: int, bullet: Bullet) -> void:
	if status == PhysicsServer2D.AREA_BODY_ADDED:
		var body := instance_from_id(instance_id)
		check_collision_hit(bullet, body)

func check_collision_hit(bullet: Bullet, body: Object) -> void:
	if body is Enemy:
		(body as Enemy).hit(bullet.damage)
	elif body is Player:
		(body as Player).hit()

	bullet.is_active = false
	PhysicsServer2D.area_set_shape_disabled.call_deferred(bullet.area_rid, 0, true)

func fire_bullet(position: Vector2, angle: float, speed: float, skin: BulletSkin.Type, behaviour: Callable = Bullet.process_standard_bullet) -> Bullet:
	if active_bullet_count >= max_bullet_count:
		return
	
	var bullet = bullets[active_bullet_count]	
	bullet.is_active = true
	bullet.position = position
	bullet.angle = angle
	bullet.velocity = Vector2.from_angle(angle) * speed
	bullet.skin = BulletSkinManager.get_skin_by_type(skin)
	bullet.behaviour = behaviour

	set_bullet_mesh_position(bullet, position)
	bullet_visual.multimesh.reset_instance_physics_interpolation(bullet.multimesh_id)
	bullet_visual.multimesh.set_instance_custom_data(bullet.multimesh_id, Color(bullet.skin.atlas_offset.x, bullet.skin.atlas_offset.y, bullet.skin.size.x, bullet.skin.size.y))
	bullet_visual.multimesh.set_instance_color(bullet.multimesh_id, Color(fmod(Time.get_ticks_msec() + 100000.0, 1800.0), 0.0, 0.0, 0.0))

	PhysicsServer2D.area_set_transform(bullet.area_rid, Transform2D.IDENTITY.translated(bullet.position))
	PhysicsServer2D.area_set_shape_disabled(bullet.area_rid, 0, false)

	active_bullet_count += 1

	return bullet

func set_bullet_mesh_position(bullet: Bullet, position: Vector2) -> void:
	var rot: float = 0.0

	if bullet.skin.align_angle:
		rot = bullet.angle + PI / 2

	bullet_visual.multimesh.set_instance_transform_2d(bullet.multimesh_id, Transform2D.IDENTITY.translated(position).rotated_local(rot).scaled_local(bullet.skin.size))	

func bullet_cancel() -> void:
	for i in active_bullet_count:
		bullets[i].is_active = false
		PhysicsServer2D.area_set_shape_disabled.call_deferred(bullets[i].area_rid, 0, true)

