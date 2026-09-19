class_name Transition extends Node2D

const ROWS : int = 12
const COLUMNS : int = 32
const TILE_SIZE : float = 32.0

@export_group("Visuals")
@export var color : Color = Color.WHITE
@export var color_alt : Color = Color.BLACK
@export var checker_pattern : bool = false

@export_group("Animation Settings")
@export var per_square_duration : float = 0.2
@export var wave_delay_step : float = 0.02
@export var hold_time : float = 0.5

var active_tween : Tween

signal animation_mid_point

func animate(use_alt_color : bool = false) -> void:
	if active_tween and active_tween.is_running():
		active_tween.kill()
		free_squares()

	var squares : Dictionary[Vector2i, TransitionSquare] = _spawn_squares(use_alt_color)

	active_tween = create_tween().set_parallel(true)

	var max_wave : int = (COLUMNS - 1) + (ROWS - 1)
	var mid_delay : float = (max_wave * wave_delay_step) + per_square_duration
	active_tween.tween_callback(animation_mid_point.emit).set_delay(mid_delay)

	for grid_pos in squares.keys():
		var square = squares[grid_pos]
		apply_animations(active_tween, square, grid_pos)

	var total_duration : float = (max_wave * wave_delay_step) + hold_time + (per_square_duration * 2.0)
	active_tween.tween_callback(free_squares).set_delay(total_duration)

func _spawn_squares(use_alt_color : bool) -> Dictionary[Vector2i, TransitionSquare]:
	var squares : Dictionary[Vector2i, TransitionSquare] = {}
	for x in COLUMNS:
		for y in ROWS:
			var pos : Vector2i = Vector2i(x, y)
			var square : TransitionSquare = TransitionSquare.new()
			squares[pos] = square
			add_child(square)
			setup_square(square, pos, use_alt_color)
	return squares

func free_squares() -> void:
	for child in get_children():
		if child is TransitionSquare:
			child.queue_free()

func setup_square(square: TransitionSquare, pos: Vector2i, use_alt_color : bool = false) -> void:
	if checker_pattern:
		square.color = color if ((pos.x + pos.y) % 2 == 0) else color_alt
	else:
		square.color = color_alt if use_alt_color else color

	square.size = TILE_SIZE
	square.scale = Vector2.ZERO
	square.position = Vector2(pos.x, pos.y) * TILE_SIZE + Vector2(TILE_SIZE, TILE_SIZE) / 2.0

	square.reset_physics_interpolation()

	square.queue_redraw()

func apply_animations(tween: Tween, square: TransitionSquare, pos: Vector2i) -> void:
	var wave_index : int = pos.x + pos.y
	var start_delay : float = wave_index * wave_delay_step
	var out_delay : float = start_delay + per_square_duration + hold_time

	# in
	tween.tween_property(square, "scale", Vector2.ONE, per_square_duration)\
		.from(Vector2.ZERO).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_delay(start_delay)

	tween.tween_property(square, "rotation_degrees", 90.0, per_square_duration * 0.5)\
		.from(0.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR).set_delay(start_delay)

	# out
	tween.tween_property(square, "scale", Vector2.ZERO, per_square_duration)\
		.from(Vector2.ONE).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR).set_delay(out_delay)

	tween.tween_property(square, "rotation_degrees", 180.0, per_square_duration)\
		.from(90.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR).set_delay(out_delay)
