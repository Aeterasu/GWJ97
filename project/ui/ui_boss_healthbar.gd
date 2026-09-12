class_name UIBossHealthbar extends Node

@export var parent: Node = null
@export var material: ShaderMaterial = null
@export var offset: Vector2 = Vector2.ZERO

@export var total_healthbar_length: Vector2 = Vector2.ZERO

var segments: Array[ColorRect] = []

func generate_healthbar(health_data: Array[float]) -> void:
	var total_health: float = 0.0
	health_data.reverse()

	for health in health_data:
		total_health += health

	var x_offset: float = 0.0
	for i in range(health_data.size()):
		var health: float = health_data[i]
		var segment_width: float = (health / total_health) * total_healthbar_length.x

		var segment: ColorRect = ColorRect.new()
		segment.name = "segment_%d" % i
		segment.size = Vector2(segment_width, total_healthbar_length.y)
		segment.position = Vector2(x_offset, 0) + offset
		segment.material = material.duplicate()
		(segment.material as ShaderMaterial).set_shader_parameter("node_size", segment.size)

		segments.push_front(segment)

		parent.add_child(segment)
		x_offset += segment_width

func update_healthbar(health_data: Array[float]) -> void:
	for i in health_data.size():
		var data = clampf(health_data[i], 0.0, 1.0)
		(segments[i].material as ShaderMaterial).set_shader_parameter("progress", data)
		(segments[i].material as ShaderMaterial).set_shader_parameter("damage_progress", data)

