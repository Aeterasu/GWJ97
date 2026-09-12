class_name Enemy extends Area2D

var health: float = 0.0
var is_dead: bool = false

signal on_death

func _ready() -> void:
	collision_layer = 1 << BulletEngine.ENEMY_COLLISION_BIT
	collision_mask = 1 << BulletEngine.PLAYER_COLLISION_BIT

func hit(damage: float) -> void:
	if is_dead:
		return

	health -= damage

	if health < 0.0:
		on_death.emit(self)
