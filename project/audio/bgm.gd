class_name BGM extends AudioStreamPlayer

@export var start_at_zero: bool = false
@export var start_time : float = 0.0
@export var fade_in_duration: float = 0.5

var default_volume: float = 0.0
var is_muted: bool = false
var current_vol: float = 1.0:
	set(value):
		current_vol = value

		volume_linear = value

func _ready() -> void:
	default_volume = db_to_linear(volume_db)
	if start_at_zero:
		current_vol = 0.0
		is_muted = true
	else:
		current_vol = default_volume

func enable(reset: bool = false) -> void:
	if (not playing) or reset:
		if reset:
			if start_at_zero:
				current_vol = 0.0
				var tween = create_tween()
				tween.tween_property(self, "current_vol", default_volume, fade_in_duration).set_delay(0.1)
			else:
				current_vol = default_volume
			is_muted = false

		play.call_deferred(start_time)
		return

	if is_muted:
		var tween = create_tween()
		tween.tween_property(self, "current_vol", default_volume, fade_in_duration)
		is_muted = false

func disable() -> void:
	if (not playing) or is_muted:
		return

	var tween = create_tween()
	tween.tween_property(self, "current_vol", 0.0, 0.5)
	is_muted = true