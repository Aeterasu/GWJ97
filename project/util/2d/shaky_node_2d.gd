@tool 
class_name ShakyNode2D extends Node2D

@export var force: float = 0.0:
    set(value):
        force = value

        if force > 0.0:
            set_physics_process(true)
@export var decay_rate: float = 1.0

func _physics_process(delta: float) -> void:
    force = max(force - decay_rate * delta, 0.0)
    position = Vector2(randf_range(-force, force), randf_range(-force, force))
    if force <= 0.0:
        position = Vector2.ZERO
        set_physics_process(false)

func shake(a: float) -> void:
    if a > force:
        force = a
        set_physics_process(true)