extends Area2D

@export var animation: AnimationPlayer = null

func _ready() -> void:
	animation.animation_finished.connect(func(a): queue_free())

func _physics_process(delta: float) -> void: 
	var areas = get_overlapping_areas()

	for area in areas:
		if area is Enemy:
			area.hit(10.0)
