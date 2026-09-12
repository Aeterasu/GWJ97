class_name Pattern extends Node

@export var entities: Array[Enemy] = []

var health: float = 0.0

var bullet_engine: BulletEngine = null

signal on_hit
signal on_health_depleted

func init_pattern() -> void:
	for entity in entities:
		entity.on_hit.connect(on_entity_hit)
		entity.bullet_engine = self.bullet_engine

func on_entity_hit(entity: Enemy, damage: float) -> void:
	health -= damage

	on_hit.emit(self)

	if health < 0.0:
		on_health_depleted.emit(self)
