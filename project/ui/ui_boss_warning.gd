extends Control

@export var animation: AnimationPlayer = null

signal on_finished

func _ready() -> void:
	animation.animation_finished.connect(animation_finished)

func animate() -> void:
	animation.play("boss_warning")

func animation_finished(anim_name: StringName) -> void:
	on_finished.emit()
