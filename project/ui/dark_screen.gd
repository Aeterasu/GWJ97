class_name DarkScreen extends Control

var count: int = 0

func darken() -> void:
	count += 1

func lighten() -> void:
	count = maxi(count - 1, 0)

func _process(delta: float) -> void:
	var target: float = 1.0 if count > 0 else 0.0
	modulate.a = lerp(modulate.a, target, 1.0 - exp(-10.0 * delta))
