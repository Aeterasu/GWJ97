class_name AnimatedText extends Label

signal typing_finished
signal animation_finished

@export var scramble_chars: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*-_=+<>/\\|"
@export var cursor_rect: ColorRect
@export var cursor_offset: Vector2 = Vector2.ZERO
@export var scramble_cycles: int = 4

@export var bg: TextureRect = null

var cursor_target_pos: Vector2 = Vector2.ZERO
var cursor_snap_next: bool = false

var coroutine_id: int = 0

var show_bg: bool = false

func _ready() -> void:
	text = ""
	if cursor_rect:
		cursor_rect.visible = false

	bg.modulate.a = 0.0

func _process(delta: float) -> void:
	cursor_rect.global_position = cursor_rect.global_position.lerp(cursor_target_pos, 1.0 - exp(-30.0 * delta))

	bg.modulate.a = lerp(bg.modulate.a, 1.0 if show_bg else 0.0, 1.0 - exp(-8.0 * delta))

func tween_1() -> void:
	if cursor_rect:
		var tween: Tween = create_tween()
		tween.tween_property(cursor_rect, "scale", Vector2.ONE, 0.2)\
			.from(Vector2(1.0, 5.0))\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_BACK)
	
func tween_2() -> void:
	if cursor_rect:
		var tween: Tween = create_tween()
		tween.tween_property(cursor_rect, "scale", Vector2(1.0, 0.0), 0.1)\
			.from(Vector2(1.0, 1.0))\
			.set_ease(Tween.EASE_IN)\
			.set_trans(Tween.TRANS_SINE)

func animate_text(str_text: String, duration_in: float, wait_time: float, duration_out: float) -> void:
	tween_1()

	show_bg = true

	coroutine_id += 1
	var my_id: int = coroutine_id
	cursor_snap_next = true

	var length: int = str_text.length()
	if length == 0:
		text = ""
		return

	var steps: int = max(1, scramble_cycles)

	var time_per_char_in: float = max(0.0, duration_in) / float(length)
	var scramble_span_in: float = time_per_char_in * 0.65
	var settle_span_in: float = time_per_char_in - scramble_span_in
	var step_time_in: float = scramble_span_in / float(steps)

	for i in range(length):
		var revealed: String = str_text.substr(0, i)
		for s in range(steps):
			if my_id != coroutine_id:
				return
			text = revealed + scramble_chars[randi() % scramble_chars.length()]
			set_cursor(i + 1, true)
			if step_time_in > 0.0:
				await get_tree().create_timer(step_time_in, false).timeout
		if my_id != coroutine_id:
			return
		text = str_text.substr(0, i + 1)
		set_cursor(i + 1, true)
		if settle_span_in > 0.0:
			await get_tree().create_timer(settle_span_in, false).timeout

	if my_id != coroutine_id:
		return
	text = str_text
	#set_cursor(length, false)
	
	tween_2()

	cursor_rect.global_position = cursor_target_pos

	typing_finished.emit()

	if wait_time > 0.0:
		await get_tree().create_timer(wait_time, false).timeout
	if my_id != coroutine_id:
		return

	var time_per_char_out: float = max(0.0, duration_out) / float(length)
	var scramble_span_out: float = time_per_char_out * 0.65
	var settle_span_out: float = time_per_char_out - scramble_span_out
	var step_time_out: float = scramble_span_out / float(steps)

	tween_1()

	for i in range(length, 0, -1):
		for s in range(steps):
			if my_id != coroutine_id:
				return
			text = str_text.substr(0, i - 1) + scramble_chars[randi() % scramble_chars.length()]
			set_cursor(i, true, true)
			if step_time_out > 0.0:
				await get_tree().create_timer(step_time_out, false).timeout
		if my_id != coroutine_id:
			return
		text = str_text.substr(0, i - 1)
		set_cursor(i - 1, true, true)
		if settle_span_out > 0.0:
			await get_tree().create_timer(settle_span_out, false).timeout

	if my_id != coroutine_id:
		return
	text = ""
	
	tween_2()

	show_bg = false

	#set_cursor(0, false)
	animation_finished.emit()

func stop_and_clear() -> void:
	coroutine_id += 1
	text = ""
	set_cursor(0, false)

func set_cursor(char_count: int, visible_flag: bool, erasing: bool = false) -> void:
	if not cursor_rect:
		return
	cursor_rect.visible = visible_flag
	if not visible_flag:
		return

	var local_point: Vector2
	if char_count <= 0:
		local_point = get_character_bounds(0).position
	else:
		var bounds: Rect2 = get_character_bounds(char_count - 1)
		local_point = bounds.position + Vector2(bounds.size.x, 0.0)

	var offset: Vector2 = cursor_offset
	if erasing:
		offset.x = -offset.x

	cursor_target_pos = global_position + local_point + offset

	if cursor_snap_next:
		cursor_rect.global_position = cursor_target_pos
		cursor_snap_next = false
