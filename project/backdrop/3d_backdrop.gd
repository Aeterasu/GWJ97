extends Node3D

@export var speed: float = 0.0

func _process(delta: float) -> void:
	global_position += Vector3.BACK * speed * delta

	if global_position.z >= 22.0:
		global_position.z = 0.0
		reset_physics_interpolation()
