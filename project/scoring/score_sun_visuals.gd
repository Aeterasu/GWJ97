extends Node2D

@export var pivot: Node2D = null
@export var particles: CPUParticles2D = null

@export var godrays: Array[Node2D] = []
@export var godray_speeds: Array[float] = []
@export var animation_player: AnimationPlayer = null

func _ready() -> void:
	for i in godrays.size():
		godrays[i].rotation = randf() * TAU

func _process(delta: float) -> void:
	for i in godrays.size():
		godrays[i].rotation += godray_speeds[i] * delta

	particles.emitting = pivot.visible

func animate_spawn() -> void:
	animation_player.play("spawn")
