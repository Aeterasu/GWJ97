class_name Bullet extends Node

@export var bullet_visual: MultiMeshInstance2D = null

const MAX_BULLET_COUNT: int = 4096

func _ready() -> void:
	bullet_visual.multimesh.instance_count = MAX_BULLET_COUNT
	
	for i in MAX_BULLET_COUNT:
		var transform = Transform2D.IDENTITY
		transform = transform.translated(Vector2(randf_range(0.0, Game.BOARD_SIZE.x), randf_range(0.0, Game.BOARD_SIZE.y)))
		bullet_visual.multimesh.set_instance_transform_2d(i, transform)

func _process(delta: float) -> void:
	pass
