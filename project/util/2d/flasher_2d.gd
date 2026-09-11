@tool
class_name Flasher extends Node2D

@export var flashes_per_second : float = 2.0 :
	set(value):
		flashes_per_second = value
		update_interval()
		
@export var flashing : bool = true

@export var alpha : float = 0.5

var vis : bool = false

var _timer : float = 0.0
var _interval : float = 0.0

func _ready() -> void:
	update_interval()

func _process(delta: float) -> void:
	modulate.a = 1.0 if vis else alpha

	if not flashing:
		vis = true
		return
	_timer += delta
	if _timer >= _interval:
		_timer = 0.0
		vis = not vis

func update_interval() -> void:
	if flashes_per_second <= 0.0:
		_interval = 1.0
	else:
		_interval = 1.0 / (flashes_per_second * 2.0)

func set_flashing(enable: bool) -> void:
	flashing = enable
	if not flashing:
		vis = true

func set_speed(hz: float) -> void:
	flashes_per_second = hz
	update_interval()
