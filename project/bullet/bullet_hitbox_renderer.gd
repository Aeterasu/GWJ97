class_name BulletHitboxRenderer extends Node2D

var engine: BulletEngine = null

var hitbox_debug_color: Color = Color(0.0, 1.0, 0.0, 0.5)

var hitbox_mesh: ArrayMesh = null
var hitbox_surface: SurfaceTool = null

func _ready() -> void:
	hitbox_mesh = ArrayMesh.new()
	hitbox_surface = SurfaceTool.new()

	z_index = 4096

func _process(_delta: float) -> void:
	if BulletEngine.SHOW_HITBOXES:
		queue_redraw()

func _draw() -> void:
	hitbox_surface.clear()
	hitbox_surface.begin(Mesh.PRIMITIVE_TRIANGLES)

	for i in engine.active_bullet_count:
		var pos := engine.bullets[i].position
		for j in 8:
			var a0 := TAU * j / 8.0
			var a1 := TAU * (j + 1) / 8.0
			hitbox_surface.set_color(hitbox_debug_color)
			hitbox_surface.add_vertex(Vector3(pos.x, pos.y, 0.0))
			hitbox_surface.set_color(hitbox_debug_color)
			hitbox_surface.add_vertex(Vector3(pos.x + cos(a0) * engine.shape_radius, pos.y + sin(a0) * engine.shape_radius, 0.0))
			hitbox_surface.set_color(hitbox_debug_color)
			hitbox_surface.add_vertex(Vector3(pos.x + cos(a1) * engine.shape_radius, pos.y + sin(a1) * engine.shape_radius, 0.0))

	hitbox_mesh.clear_surfaces()
	hitbox_surface.commit(hitbox_mesh)
	draw_mesh(hitbox_mesh, null)
