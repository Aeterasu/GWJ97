class_name CustceneConfig extends Node

@export var sprite_tilt: float = 0.0
@export var sprite_yaw: float = 0.0

var visual_component: PlayerVisuals = null

func update(delta: float) -> void:
	if not visual_component:
		return

	visual_component.sprite_shader.set_shader_parameter("rot_y_deg", sprite_tilt)
	visual_component.sprite_shader.set_shader_parameter("rot_x_deg", sprite_yaw)

