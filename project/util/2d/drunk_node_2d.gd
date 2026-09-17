class_name DrunkNode2D extends Node2D

@export var speed : float = 1.0
@export var offset : Vector2 = Vector2.ZERO
@export var strength : float = 1.0

func _process(delta: float) -> void:
	var time = Time.get_ticks_msec() / 1000.0

	position.x = cos(time * speed) * offset.x * strength
	position.y = sin(time * speed) * offset.y * strength
