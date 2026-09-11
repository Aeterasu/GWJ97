extends Label

func _process(delta: float) -> void:
	set_text(str(int(Engine.get_frames_per_second())) + " FPS")