@tool

class_name Rectangle2D extends Node2D

@export var rect : Rect2 = Rect2()
@export var color : Color = Color.WHITE
@export var filled : bool = true
@export var width : float = 1.0

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if filled:
		draw_rect(rect, color, true)
	else:
		draw_rect(rect, color, false, width)