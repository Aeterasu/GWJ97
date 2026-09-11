@tool
class_name Ellipse2D extends Node2D

@export var size : Vector2 = Vector2(100, 100):
	set(value):
		size = value
		queue_redraw()
@export var color : Color = Color.WHITE:
	set(value):
		modulate = value
@export var width : float = 1.0:
	set(value):
		width = value
		queue_redraw()
@export var filled : bool = false:
	set(value):
		filled = value
		queue_redraw()

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var points = PackedVector2Array()
	var radius_x = size.x / 2.0
	var radius_y = size.y / 2.0
	var resolution : int = 64
	
	for i in range(resolution + 1):
		var angle = i * TAU / resolution
		var x = cos(angle) * radius_x
		var y = sin(angle) * radius_y
		points.push_back(Vector2(x, y))
	
	if filled:
		draw_polygon(points, PackedColorArray([Color.WHITE]))
	else:
		draw_polyline(points, Color.WHITE, width, false)