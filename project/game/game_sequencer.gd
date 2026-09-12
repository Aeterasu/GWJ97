class_name GameSequencer extends Node

@export var animation_player: AnimationPlayer = null

@export var patterns: Array[Pattern] = []
@export var patterns_health: Array[float] = []
@export var patterns_flavor: Array[PatternFlavor] = []

@export var enemy_bullet_engine: BulletEngine = null

func init_pattern(idx: int) -> void:
	if idx >= 0 and idx < patterns.size():
		patterns[idx].bullet_engine = self.enemy_bullet_engine
		patterns[idx].health = patterns_health[idx]
		patterns[idx].init_pattern()

func get_all_health_percentagees() -> Array[float]:
	var result: Array[float] = []
	result.resize(patterns.size())

	for i in patterns.size():
		result[i] = patterns[i].health / patterns_health[i]

	return result
