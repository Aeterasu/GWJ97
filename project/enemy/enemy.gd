class_name Enemy extends Area2D

var bullet_engine: BulletEngine = null

var is_dead: bool = false

signal on_hit

func _ready() -> void:
	collision_layer = 1 << BulletEngine.ENEMY_COLLISION_BIT
	collision_mask = 1 << BulletEngine.PLAYER_COLLISION_BIT

func hit(damage: float) -> void:
	on_hit.emit(self, damage)
