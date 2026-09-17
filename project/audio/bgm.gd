class_name BGM extends Node

@export var audio_intro: AudioStreamPlayer = null
@export var audio_loop: AudioStreamPlayer = null

@export var start_at_zero: bool = false
@export var fade_in_duration: float = 0.5
@export var fade_out_duration: float = 0.5

var playing: bool = false

func _ready() -> void:
	if audio_intro:
		audio_intro.finished.connect(on_intro_finished)

func enable(reset: bool = false) -> void:
	if start_at_zero or reset:
		seek(0.0)
		play_from_start()
	else:
		if not playing:
			play_from_start()

func disable() -> void:
	stop()

func play_from_start() -> void:
	playing = true
	if audio_intro:
		audio_intro.play()
		fade_in(audio_intro)
	else:
		audio_loop.play()
		fade_in(audio_loop)

func stop() -> void:
	playing = false
	fade_out()

func seek(position: float) -> void:
	if audio_intro:
		audio_intro.seek(position)
	if audio_loop:
		audio_loop.seek(position)

func on_intro_finished() -> void:
	if playing:
		audio_loop.volume_db = 0.0
		audio_loop.play()

func fade_in(player: AudioStreamPlayer) -> void:
	if fade_in_duration <= 0.0:
		return
	player.volume_db = linear_to_db(0.01)
	var tween = create_tween()
	tween.tween_property(player, "volume_db", 0.0, fade_in_duration).from(linear_to_db(0.01))

func fade_out() -> void:
	if fade_out_duration <= 0.0:
		if audio_intro:
			audio_intro.stop()
		if audio_loop:
			audio_loop.stop()
		return
	var tween = create_tween()
	tween.set_parallel(true)
	if audio_intro and audio_intro.playing:
		tween.tween_property(audio_intro, "volume_db", linear_to_db(0.01), fade_out_duration).from(0.0)
	if audio_loop and audio_loop.playing:
		tween.tween_property(audio_loop, "volume_db", linear_to_db(0.01), fade_out_duration).from(0.0)
	tween.chain().tween_callback(stop_all)

func stop_all() -> void:
	if audio_intro:
		audio_intro.stop()
	if audio_loop:
		audio_loop.stop()
