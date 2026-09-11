class_name DrunkNode2D extends Node2D

@export var speed : float = 1.0
@export var offset : Vector2 = Vector2.ZERO
@export var strength : float = 1.0

var time : float = 0.0

func _process(delta: float) -> void:
	time += delta

	position.x = cos(time * speed) * offset.x * strength
	position.y = sin(time * speed) * offset.y * strength