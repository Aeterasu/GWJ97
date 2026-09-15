class_name GameSequencer extends Node

@export var show_boss_warning: bool = true
@export var boss_warning: Control = null

@export var starting_pattern: int = 0

@export var animation_player: AnimationPlayer = null

@export var patterns: Array[Pattern] = []
@export var patterns_health: Array[float] = []
@export var patterns_flavor: Array[PatternFlavor] = []

@export var scoring: Scoring = null

@export var enemy_bullet_engine: BulletEngine = null
@export var sun_spawner: ScoreSunManager = null

var current_idx: int = 0

signal on_pattern_init

signal propagate_pattern_hit

func start_game() -> void:
	if not show_boss_warning:
		init_pattern(starting_pattern)
	else:
		await get_tree().create_timer(1.0).timeout

		boss_warning.on_finished.connect(on_boss_warning_finished)
		boss_warning.animate()

func on_boss_warning_finished() -> void:
	init_pattern(starting_pattern)

func fix() -> void:
	for i in patterns.size():
		patterns[i].health = patterns_health[i]

func init_pattern(idx: int) -> void:
	if idx >= 0 and idx < patterns.size():
		patterns[idx].bullet_engine = self.enemy_bullet_engine
		patterns[idx].sun_spawner = self.sun_spawner
		patterns[idx].health = patterns_health[idx]
		patterns[idx].init_pattern()
		
		# TODO: don't forget to unsubscribe when the pattern is disposed!
		patterns[idx].on_hit.connect(on_pattern_hit)
		patterns[idx].on_health_depleted.connect(on_pattern_health_depleted)
		patterns[idx].on_death.connect(on_pattern_death)

		current_idx = idx

		on_pattern_init.emit(idx)

func get_all_health_percentagees() -> Array[float]:
	var result: Array[float] = []
	result.resize(patterns_health.size())
	
	for i in patterns_health.size():
		if i < patterns.size() and patterns[i] != null:
			result[i] = patterns[i].health / patterns_health[i]
		else:
			result[i] = 1.0

	return result

func on_pattern_hit(pattern: Pattern) -> void:
	propagate_pattern_hit.emit(pattern)

func on_pattern_health_depleted(pattern: Pattern) -> void:
	scoring.on_pattern_completed(current_idx)
	enemy_bullet_engine.bullet_cancel()

func on_pattern_death(pattern: Pattern) -> void:
	pattern.is_started = false
	pattern.is_dead = true
	
	var next_idx = current_idx + 1

	if next_idx >= patterns.size():
		return

	current_idx = next_idx

	init_pattern(current_idx)
