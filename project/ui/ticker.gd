class_name TickerLabel extends Control

@export var text: String = "fancy fancy ticker text oh wow // ":
	set(value):
		text = value
		update_text_metrics()
		queue_redraw()

@export var speed: float = 60.0
@export var gap: float = 64.0
@export var font: Font:
	set(value):
		font = value
		update_text_metrics()
		queue_redraw()
@export var font_size: int = 16:
	set(value):
		font_size = value
		update_text_metrics()
		queue_redraw()
@export var color: Color = Color.WHITE
@export var pause_when_fits: bool = true

var scroll_x: float = 0.0
var text_width: float = 0.0
var effective_font: Font

func _ready() -> void:
	clip_contents = true
	update_text_metrics()

func update_text_metrics() -> void:
	effective_font = font if font else ThemeDB.fallback_font
	var f_size := font_size if font_size > 0 else ThemeDB.fallback_font_size
	text_width = effective_font.get_string_size(
		text, HORIZONTAL_ALIGNMENT_LEFT, -1, f_size
	).x

func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		update_text_metrics()
		queue_redraw()

func _process(delta: float) -> void:
	if text.is_empty():
		return
	if pause_when_fits and text_width <= size.x:
		return

	scroll_x -= speed * delta
	var period := text_width + gap
	if period > 0.0:
		scroll_x = wrapf(scroll_x, -period, 0.0)
	queue_redraw()

func _draw() -> void:
	if text.is_empty() or not effective_font:
		return

	var fsize := font_size if font_size > 0 else ThemeDB.fallback_font_size
	var baseline_y := (size.y + effective_font.get_ascent(fsize) - effective_font.get_descent(fsize)) * 0.5

	if pause_when_fits and text_width <= size.x:
		draw_string(effective_font, Vector2(0, baseline_y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize, color)
		return

	var period := text_width + gap
	if period <= 0.0:
		return

	var start_x := scroll_x
	while start_x < size.x:
		draw_string(effective_font, Vector2(start_x, baseline_y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize, color)
		start_x += period

func set_ticker_text(new_text: String) -> void:
	text = new_text
	scroll_x = 0.0
