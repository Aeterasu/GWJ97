class_name UIBossHealthbar extends Node

@export var parent: Node = null
@export var material: ShaderMaterial = null
@export var offset: Vector2 = Vector2.ZERO

@export var total_healthbar_length: Vector2 = Vector2.ZERO

@export var trailing_damage_duration: float = 0.0
@export var trailing_damage_fade_speed: float = 0.0

var segments: Array[ColorRect] = []

var trailing_damage_time_left: float = 0.0
var trailing_damage_progress: float = 1.0
var last_damaged_idx: int = 0

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

# TODO: there is a non-zero chance that this mess will completely break when we introduce multiple patterns. keep an eye on it...
func _process(delta: float) -> void:
	trailing_damage_time_left -= delta

	# TODO: fix this ugly uglyness of a hack
	var progress = (segments[last_damaged_idx].material as ShaderMaterial).get_shader_parameter("progress")

	if trailing_damage_time_left <= 0.0:
		trailing_damage_progress = max(trailing_damage_progress - trailing_damage_fade_speed * delta, progress)		

	(segments[last_damaged_idx].material as ShaderMaterial).set_shader_parameter("damage_progress", trailing_damage_progress)

func update_healthbar(health_data: Array[float], current_idx: int) -> void:
	trailing_damage_time_left = trailing_damage_duration

	for i in health_data.size():
		var data = clampf(health_data[i], 0.0, 1.0)
		(segments[i].material as ShaderMaterial).set_shader_parameter("progress", data)
	
