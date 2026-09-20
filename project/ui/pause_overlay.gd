class_name PauseOverlay extends Control

func _ready() -> void:
	hide()

func update_overlay(toggle: bool) -> void:
	if toggle:
		show_overlay()
	else:
		hide_overlay()

func show_overlay() -> void:
	show()

func hide_overlay() -> void:
	hide()
