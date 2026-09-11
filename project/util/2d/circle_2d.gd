@tool

class_name Circle2D extends Node2D

@export var filled : bool = true:
	set(value):
		filled = value

		queue_redraw()

@export var radius : float = 16.0:
	set(value):
		radius = value
		
		queue_redraw()

@export var width : float = 4.0:
	set(value):
		width = value
		
		queue_redraw()

@export var points : int = 8:
	set(value):
		points = value
		
		queue_redraw()

@export var color : Color = Color.WHITE:
	set(value):
		modulate = value

func _draw() -> void:
	if filled:
		draw_circle(Vector2.ZERO, radius, Color.WHITE)
	else:
		draw_arc(Vector2.ZERO, radius, 0, TAU, points, Color.WHITE, width)