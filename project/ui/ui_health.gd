class_name UIHealth extends Control

@export var hearts: Array[TextureProgressBar] = []
@export var damage_fx: Sprite2D = null

@export var oneup_notification: Control = null

@export var heal_animation: AnimationPlayer = null

@export var animation_shit: Array[Node2D] = []

var lives: int = 0

# LAZY LAZY HACK
var skip_update: bool = false 

func _ready() -> void:
	damage_fx.hide()

func _process(delta: float) -> void:
	if skip_update:
		return

	for i in hearts.size():
		if i < lives:
			hearts[i].value = 1.0
		else:
			hearts[i].value = 0.0

func on_player_hit(lives_: int) -> void:
	damage_fx.show()

	var tween: Tween = create_tween()

	damage_fx.position = hearts[lives_].position + Vector2(8.0, 0.0)
	damage_fx.scale = Vector2(2.0, 0.0) * 2.0
	tween.tween_property(damage_fx, "scale", Vector2(0.0, 2.0) * 2.0, 0.3)

func on_player_heal(lives_: int) -> void:
	#var tween: Tween = create_tween()
	#hearts[lives_].texture_progress_offset = Vector2(0.0, -16.0)
	#tween.tween_property(hearts[lives_], "texture_progress_offset", Vector2(0.0, 0.0), 0.5)\
	#	.set_trans(Tween.TRANS_BACK)\
	#	.set_ease(Tween.EASE_IN_OUT)
	
	skip_update = true

	heal_animation.play("heal")

	for fuck in animation_shit:
		fuck.position.x = hearts[lives_ - 1].position.x + 5.0

func reset_update() -> void:
	skip_update = false

func show_oneup_notif() -> void:
	oneup_notification.position.y = 310.0

	var tween: Tween = create_tween()
	tween.tween_property(oneup_notification, "position:y", 297.0, 0.25)
	tween.tween_property(oneup_notification, "position:y", 310.0, 0.25).set_delay(2.0)

	var tween_2: Tween = create_tween()
	oneup_notification.color = Color("#faeac9")
	tween_2.tween_property(oneup_notification, "color", Color("#ff2900"), 0.3).set_delay(0.3)
