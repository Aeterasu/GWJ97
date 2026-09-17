class_name BombAnimation extends Node

@export var flash_1: ColorRect = null
@export var flash_2: ColorRect = null

@export var flash_3: TextureRect = null
var flash_3_alpha: float = 0.0

@export var particles: CPUParticles2D = null

var positions: Array[Vector2] = []

func _ready() -> void:
	flash_1.modulate.a = 0.0
	flash_2.modulate.a = 0.0
	flash_3_alpha = 0.0

	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINTS

func _process(delta: float) -> void:
	(flash_3.material as ShaderMaterial).set_shader_parameter("alpha", flash_3_alpha)

#func _physics_process(delta: float) -> void:
#	if positions.size() > 0:
#		for pos in positions:
			
#		positions.clear()	

func show_bomb_flash() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)

	particles.emission_points = positions
	particles.emitting = true

	var start_dur: float = 0.1
	var end_dur: float = 0.4
	var delay: float = 0.9

	tween.tween_property(flash_1, "modulate:a", 1.0, start_dur)
	tween.tween_property(flash_2, "modulate:a", 1.0, start_dur)
	tween.tween_property(self, "flash_3_alpha", 1.0, start_dur)

	tween.tween_property(flash_1, "modulate:a", 0.0, end_dur).set_delay(delay)
	tween.tween_property(flash_2, "modulate:a", 0.0, end_dur).set_delay(delay)
	tween.tween_property(self, "flash_3_alpha", 0.0, end_dur).set_delay(delay)
