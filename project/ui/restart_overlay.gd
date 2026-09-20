class_name RestartOverlay extends Control

@export var progresses: Array[TextureProgressBar] = []

var target_alpha: float = 0.0

func _ready() -> void:
	modulate.a = 0.0

func set_progress(timer: float, target_time: float) -> void:
	target_alpha = 1.0 if timer > 0.0 else 0.0
	for progress in progresses:
		progress.max_value = target_time - 0.1
		progress.value = timer

func _process(delta: float) -> void:
	modulate.a = lerp(modulate.a, target_alpha, 1.0 - exp(-10.0 * delta))
