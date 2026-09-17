class_name Pattern extends Node

@export var spawn_life: bool = false

@export var entities: Array[Enemy] = []
@export var sprites: Array[Sprite2D] = []

@export var immune: bool = false
@export var animation_player: AnimationPlayer = null

@export var explosion: Node2D = null

var health: float = 0.0

var time_left: float = 0.0

var bullet_count_multiplier: float = 1.0
var bullet_speed_multiplier: float = 1.0
var fire_rate_multiplier: float = 1.0

var sun_counter: int = 0

var life_spawner: LifePickup = null
var sun_spawner: ScoreSunManager = null
var bullet_engine: BulletEngine = null

var freeze: Array[Node] = []

var is_started: bool = false
var is_dead: bool = false
var is_timeout: bool = false

var timeout_pattern: TimeoutPattern = null

signal on_hit
signal on_timeout

# the obvious difference here:
# on_health_depleted fires when the health reaches 0
# on_death fires when the pattern goes out of scope - for example after death animation finishes
signal on_health_depleted
signal on_death

func _ready() -> void:
	for node in get_children():
		remove_child(node)
		freeze.append(node)

	if animation_player:
		animation_player.animation_finished.connect(_on_animation_finished)	

	timeout_pattern = TimeoutPattern.new()

func init_pattern() -> void:	
	for node in freeze:
		add_child.call_deferred(node)

	for entity in entities:
		entity.on_hit.connect(on_entity_hit)
		entity.bullet_engine = self.bullet_engine

	timeout_pattern.bullet_engine = bullet_engine

func start() -> void:
	is_started = true

func _physics_process(delta: float) -> void:
	if is_started and (not is_dead):
		time_left -= delta

		if time_left <= 0.0:
			if not is_timeout:
				is_timeout = true
				on_timeout.emit(self)

		update(delta)

func update(delta: float) -> void:
	pass

func on_entity_hit(entity: Enemy, damage: float) -> void:
	if immune:
		return

	if is_dead:
		return

	health -= damage

	on_hit.emit(self)

	if health < 0.0:
		on_health_depleted.emit(self)
		start_death()

	#Game.get_player().bomb_restart_timer -= 0.01

func start_death() -> void:
	if is_dead:
		return

	is_dead = true

	bullet_engine.bullet_cancel()	
	
	var sun_pos: Vector2 = Vector2(120.0, 88.0)

	if spawn_life:
		sun_pos = Vector2(80.0, 88.0)
		life_spawner.spawn_life_pickup(Vector2(160.0, 88.0))

	var sun = sun_spawner.spawn_sun(sun_pos)
	if sun:
		sun.use_gravity = true

	animation_player.play("death")

func start_timeout() -> void:
	if is_dead:
		return

	#is_dead = true
	is_timeout = true

	#bullet_engine.bullet_cancel()

	#animation_player.play("timeout")

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		if animation_player.has_animation("death_loop"):
			animation_player.play("death_loop")
		on_death.emit(self)

func deactivate() -> void:
	if animation_player:
		animation_player.stop()
		if animation_player.animation_finished.is_connected(_on_animation_finished):
			animation_player.animation_finished.disconnect(_on_animation_finished)

	for entity in entities:
		if entity.get_parent():
			entity.get_parent().remove_child(entity)

func create_random_explosion(scale: Vector2 = Vector2.ONE) -> void:
	AudioManager.play_sfx(AudioManager.instance.sfx_explosion_1, randf_range(0.9, 1.1))
	
	var exp = explosion.duplicate()
	add_child(exp)

	exp.scale = scale

	exp.global_position = Vector2(randf_range(100.0, 140.0), randf_range(60.0, 150.0))
	exp.reset_physics_interpolation()
	exp.on_all_finished.connect(exp.queue_free)
	exp.fire()
