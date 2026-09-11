class_name LerpFollower2D extends Node2D

@export var lerp_weight : float = 10.0

@onready var parent: Node2D = get_parent()
var offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	offset = position
	top_level = true

func _physics_process(delta : float) -> void:
	var target_position = parent.global_position + offset
	global_position = global_position.lerp(target_position, 1.0 - exp(-lerp_weight * delta))