class_name WallChipDamageHitbox extends Area2D

@export var damage_mult: float = 0.33

signal on_hit

func hit(damage: float) -> void:
	on_hit.emit(damage * damage_mult, false)
