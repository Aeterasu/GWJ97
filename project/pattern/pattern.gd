class_name Pattern extends Node

@export var spawn_life: bool = false

@export var entities: Array[Enemy] = []
@export var immune: bool = false

var health: float = 0.0

var sun_counter: int = 0

var life_spawner: LifePickup = null
var sun_spawner: ScoreSunManager = null
var bullet_engine: BulletEngine = null

var freeze: Array[Node] = []

var is_started: bool = false
var is_dead: bool = false

signal on_hit

# the obvious difference here:
# on_health_depleted fires when the health reaches 0
# on_death fires when the pattern goes out of scope - for example after death animation finishes
signal on_health_depleted
signal on_death

func _ready() -> void:
	for node in get_children():
		remove_child(node)
		freeze.append(node)

func init_pattern() -> void:	
	for node in freeze:
		add_child.call_deferred(node)

	for entity in entities:
		entity.on_hit.connect(on_entity_hit)
		entity.bullet_engine = self.bullet_engine

func _physics_process(delta: float) -> void:
	if is_started and (not is_dead):
		update(delta)

func update(_delta: float) -> void:
	pass

func on_entity_hit(entity: Enemy, damage: float) -> void:
	if immune:
		return

	health -= damage

	on_hit.emit(self)

	if health < 0.0:
		kill_start()
		on_health_depleted.emit(self)

func kill_start() -> void:
	is_dead = true

	bullet_engine.bullet_cancel()
	
	
	var sun_pos: Vector2 = Vector2(120.0, 88.0)

	if spawn_life:
		sun_pos = Vector2(80.0, 88.0)
		life_spawner.spawn_life_pickup(Vector2(160.0, 88.0))

	var sun = sun_spawner.spawn_sun(sun_pos)
	if sun:
		sun.use_gravity = true

	
func kill_finish() -> void:
	on_death.emit(self)

	for entity in entities:
		remove_child.call_deferred(entity)
