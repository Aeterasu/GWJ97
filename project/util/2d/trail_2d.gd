class_name Trail2D extends Line2D

@export_category("Trail")
@export var length: int = 10
@export var fps: float = 60.0:
    set(value):
        fps = max(value, 1.0)
        step = 1.0 / fps

@export var enabled: bool = true:
    set(value):
        enabled = value
        if not enabled:
            clear_points()
        set_process(value)

@onready var parent: Node2D = get_parent()

var time_accum: float = 0.0
var step: float = 1.0 / 60.0

var ring: PackedVector2Array
var head: int = 0
var count: int = 0

func _ready() -> void:
    top_level = true
    global_position = Vector2.ZERO
    step = 1.0 / fps
    ring.resize(length)

func _physics_process(delta: float) -> void:
    time_accum += delta
    if time_accum < step:
        return
    time_accum = fmod(time_accum, step)

    process_trail()

func process_trail() -> void:
    ring[head] = parent.global_position
    head = (head + 1) % length
    if count < length:
        count += 1

    var pts := PackedVector2Array()
    pts.resize(count)
    var start := (head - count + length) % length
    for i in count:
        pts[i] = ring[(start + i) % length]
    points = pts

func reset() -> void:
    clear_points()
    head = 0
    count = 0
    time_accum = 0.0