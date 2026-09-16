extends Control

@export var bomb_ready_notification: ColorRect = null

func show_bomb_ready_notif() -> void:
	bomb_ready_notification.position.y = 310.0

	var tween: Tween = create_tween()
	tween.tween_property(bomb_ready_notification, "position:y", 297.0, 0.25)
	tween.tween_property(bomb_ready_notification, "position:y", 310.0, 0.25).set_delay(2.0)

	var tween_2: Tween = create_tween()
	bomb_ready_notification.color = Color("#faeac9")
	tween_2.tween_property(bomb_ready_notification, "color", Color("#979fff"), 0.3).set_delay(0.3)
