class_name TransitionSquare extends Node2D

var size : float = 32.0:
    set(value):
        size = value
        #queue_redraw()

var color : Color = Color.WHITE:
    set(value):
        color = value
        #queue_redraw()

func _draw() -> void:
    var rect : Rect2 = Rect2(-Vector2.ONE * size * 0.5, Vector2.ONE * size)
    draw_rect(rect, color)