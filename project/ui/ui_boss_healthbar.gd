class_name UIBossHealthbar extends Node

@export var parent: Node = null
@export var material: ShaderMaterial = null
@export var offset: Vector2 = Vector2.ZERO

@export var total_healthbar_length: Vector2 = Vector2.ZERO

@export var trailing_damage_duration: float = 0.0
@export var trailing_damage_fade_speed: float = 0.0

var segments: Array[ColorRect] = []

var trailing_damage_time_left: float = 0.0
var last_damaged_idx: int = -1

var patterns_health: Array[float] = []
var trailing_damage_progresses: Array[float] = []

func generate_healthbar(health_data: Array[float]) -> void:
	var total_health: float = 0.0

	trailing_damage_progresses.resize(health_data.size())

	for health in health_data:
		total_health += health

	var data = health_data.duplicate()
	data.reverse()

	var x_offset: float = 0.0
	for i in range(data.size()):
		var health: float = data[i]
		var segment_width: float = (health / total_health) * total_healthbar_length.x

		var segment: ColorRect = ColorRect.new()
		segment.name = "segment_%d" % i
		segment.size = Vector2(segment_width, total_healthbar_length.y)
		segment.position = Vector2(x_offset, 0) + offset
		segment.material = material.duplicate()
		(segment.material as ShaderMaterial).set_shader_parameter("node_size", segment.size)

		segments.push_back(segment)

		parent.add_child(segment)
		x_offset += segment_width

# TODO: there is a non-zero chance that this mess will completely break when we introduce multiple patterns. keep an eye on it...
func _process(delta: float) -> void:
	trailing_damage_time_left -= delta

	# TODO: fix this ugly uglyness of a hack
	for i in segments.size():	
		var progress = (segments[i].material as ShaderMaterial).get_shader_parameter("progress")

		if trailing_damage_time_left <= 0.0:
			trailing_damage_progresses[i] = max(trailing_damage_progresses[i] - trailing_damage_fade_speed * delta, progress)	

		(segments[i].material as ShaderMaterial).set_shader_parameter("damage_progress", trailing_damage_progresses[i])

func update_healthbar(health_data: Array[float], current_idx: int) -> void:
	last_damaged_idx = current_idx

	var data = health_data.duplicate()
	data.reverse()

	for i in data.size():
		var p = clampf(data[i], 0.0, 1.0)
		(segments[i].material as ShaderMaterial).set_shader_parameter("progress", p)

	patterns_health = health_data
	#trailing_damage_time_left = trailing_damage_duration

