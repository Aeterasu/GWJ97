class_name GameSequencer extends Node

@export var player: Player = null

@export var show_boss_warning: bool = true
@export var boss_warning: Control = null

@export var timeout_warning: UITimeoutWarning = null

@export var starting_pattern: int = 0

@export var animation_player: AnimationPlayer = null

@export var patterns: Array[Pattern] = []
@export var patterns_health: Array[float] = []
@export var patterns_timer: Array[float] = []
@export var patterns_flavor: Array[PatternFlavor] = []

@export var scoring: Scoring = null

@export var enemy_bullet_engine: BulletEngine = null
@export var sun_spawner: ScoreSunManager = null
@export var life_spawner: LifePickup = null

@export var results: ResultScreen = null

var hitflash: float = 0.0

var current_pattern: Pattern = null
var current_idx: int = 0

var no_miss: bool = true
var no_bomb: bool = true

signal on_pattern_init
signal propagate_pattern_hit

func _ready() -> void:
	if not OS.is_debug_build():
		show_boss_warning = true
		starting_pattern = 0

func _process(delta: float) -> void:
	if current_pattern:
		for sprite in current_pattern.sprites:
			(sprite.material as ShaderMaterial).set_shader_parameter("hitflash", hitflash)

	hitflash = max(hitflash - delta * 5.0, 0.0)

func start_game() -> void:
	life_spawner.on_life_collected.connect(on_life_collected)

	player.on_hit.connect(func(): no_miss = false)

	if not show_boss_warning:
		init_pattern(starting_pattern)
	else:
		await get_tree().create_timer(1.0).timeout

		boss_warning.on_finished.connect(on_boss_warning_finished)
		boss_warning.animate()

func on_life_collected() -> void:
	player.award_life()

func on_boss_warning_finished() -> void:
	init_pattern(starting_pattern)

func fix() -> void:
	for i in patterns.size():
		patterns[i].health = patterns_health[i]

func init_pattern(idx: int) -> void:
	if idx >= 0 and idx < patterns.size():
		patterns[idx].bullet_engine = self.enemy_bullet_engine
		patterns[idx].sun_spawner = self.sun_spawner
		patterns[idx].life_spawner = self.life_spawner
		patterns[idx].health = patterns_health[idx]
		patterns[idx].time_left = patterns_timer[idx]
		patterns[idx].init_pattern()
		
		# TODO: don't forget to unsubscribe when the pattern is disposed!
		patterns[idx].on_hit.connect(on_pattern_hit)
		patterns[idx].on_health_depleted.connect(on_pattern_health_depleted)
		patterns[idx].on_death.connect(on_pattern_death)
		patterns[idx].on_timeout.connect(on_pattern_timeout)

		current_pattern = patterns[idx]

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

	hitflash = 1.0

func on_pattern_timeout(pattern: Pattern) -> void:
	get_tree().paused = true

	timeout_warning.animation_player.play("flash")
	await timeout_warning.animation_player.animation_finished

	get_tree().paused = false

func on_pattern_health_depleted(pattern: Pattern) -> void:
	scoring.on_pattern_completed(current_idx)
	enemy_bullet_engine.bullet_cancel()

func on_pattern_death(pattern: Pattern) -> void:
	#if pattern.is_timeout:
	#	results.ticker_label.text = ("TOO BAD! // ").repeat(10)
	#	results.show_timeout_results(scoring)

	#	await results.on_results_confirmed

	#	results.hide_results()
	#else:
	await scoring.score_item_manager.await_all_items_cleared()

	results.ticker_label.text = (patterns_flavor[current_idx].pattern_names + " // ").repeat(10)
	results.show_results(scoring, no_miss, no_bomb)

	await results.on_results_confirmed

	results.hide_results()

	await get_tree().create_timer(1.0).timeout

	pattern.is_started = false
	pattern.is_dead = true
	
	var next_idx = current_idx + 1

	if next_idx >= patterns.size():
		return

	current_idx = next_idx
	
	scoring.reset_results()
	init_pattern(current_idx)
	no_miss = true
	no_bomb = true

func get_current_timer() -> int:
	return floori(patterns[current_idx].time_left)
