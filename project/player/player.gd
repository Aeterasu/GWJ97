class_name Player extends Area2D

@export var base_speed: float = 0.0
@export var focus_speed: float = 0.0

@export var base_weapon: PlayerWeapon = null
@export var focus_weapon: PlayerWeapon = null
var is_focused: bool = false

@export var bullet_engine: BulletEngine = null

@export var options_rotation_speed: float = 0.0
@export var options_base_distance: float = 0.0
@export var options_focus_distance: float = 0.0
@export var options: Array[Node2D] = []
@export var options_transition_duration: float = 0.0
var options_transition_current_timer: float = 0.0
var options_angle: float = 0.0

@export var sprite: Sprite2D = null
var sprite_shader: ShaderMaterial = null
var sprite_tilt: float = 0.0
var sprite_yaw: float = 0.0

@export var muzzle_flashes: Array[Node2D] = []

var lives: int = 0
const STARTING_LIVES: int = 2
const INVINCIBILITY_ON_HIT: float = 6.0
const INVINCIBILITY_ON_BOMB: float = 3.0

var enable_hitbox: bool = false

var control_state: ControlState = ControlState.NORMAL

var invincibility_timer: float = 0.0

var is_dead: bool = false

signal on_hit
signal on_death

enum ControlState
{
	NORMAL,
	IN_CUTSCENE,
}

func _ready() -> void:
	lives = STARTING_LIVES

	base_weapon.bullet_engine = self.bullet_engine
	focus_weapon.bullet_engine = self.bullet_engine

	base_weapon.on_fire.connect(on_fire)
	focus_weapon.on_fire.connect(on_fire)

	collision_layer = 1 << BulletEngine.PLAYER_COLLISION_BIT
	collision_mask = 1 << BulletEngine.ENEMY_COLLISION_BIT

	for flash in muzzle_flashes:
		flash.scale.x = 0.0

	sprite_shader = sprite.material as ShaderMaterial

func _physics_process(delta: float) -> void:
	if control_state == ControlState.NORMAL:
		if is_dead:
			return

		process_movement(delta)
		process_weapon(delta)

	invincibility_timer = max(invincibility_timer - delta, 0.0)

	# options

	options_angle += options_rotation_speed * delta

	if is_focused:
		options_transition_current_timer = min(options_transition_current_timer + delta, options_transition_duration)
	else:
		options_transition_current_timer = max(options_transition_current_timer - delta, 0.0)

	var final_radius: float = lerp(options_base_distance, options_focus_distance, options_transition_current_timer / options_transition_duration)

	if options.size() > 0:
		for i in options.size():
			var angle = options_angle + (TAU / options.size()) * i
			var offset = Vector2(cos(angle), sin(angle)) * final_radius
			options[i].position = offset

func process_movement(delta: float) -> void:
	var dir: Vector2 = Vector2.ZERO

	dir = Input.get_vector("player_input_left", "player_input_right", "player_input_up","player_input_down")
	var move_speed = focus_speed if is_focused else base_speed

	global_position += dir.normalized() * move_speed * delta
	global_position.x = clampf(global_position.x, 0.0, Game.BOARD_SIZE.x)
	global_position.y = clampf(global_position.y, 0.0, Game.BOARD_SIZE.y)

	# visual

	var lerp_weight: float = 1.0 - exp(-10.0 * delta)
	var target_tilt: float = 0.0
	var target_yaw: float = 0.0

	if dir.x < -0.1 or dir.x > 0.1:
		target_tilt = 30.0 * sign(dir.x)

	if dir.y < -0.1 or dir.y > 0.1:
		target_yaw = 35.0 * -sign(dir.y)

	sprite_tilt = lerp(sprite_tilt, target_tilt, lerp_weight)
	sprite_yaw = lerp(sprite_yaw, target_yaw, lerp_weight)
	sprite_shader.set_shader_parameter("rot_y_deg", sprite_tilt)
	sprite_shader.set_shader_parameter("rot_x_deg", sprite_yaw)

func process_weapon(delta: float) -> void:
	is_focused = Input.is_action_pressed("player_input_action_2")

	var fire_input = Input.is_action_pressed("player_input_action_1")

	var focus_ready = options_transition_current_timer >= options_transition_duration

	base_weapon.is_firing = fire_input and (not focus_ready)
	focus_weapon.is_firing = fire_input and focus_ready

func hit() -> void:
	if is_dead:
		return

	if control_state == ControlState.IN_CUTSCENE:
		return

	if invincibility_timer > 0.0:
		return

	lives -= 1;

	invincibility_timer = INVINCIBILITY_ON_HIT
	
	on_hit.emit()

	if lives < 0:
		on_death.emit()

func _process(delta: float) -> void:	
	for flash in muzzle_flashes:
		flash.scale.x = lerp(flash.scale.x, 0.0, 1.0 - exp(-20.0 * delta))
		flash.scale.y = lerp(flash.scale.y, 2.0, 1.0 - exp(-20.0 * delta))

		if (not base_weapon.is_firing) and (not focus_weapon.is_firing):
			flash.visible = true
	
func on_fire() -> void:
	for flash in muzzle_flashes:
		flash.scale = Vector2.ONE * randf_range(0.8, 1.5)
		
		flash.position.x = randf_range(-2.0, 2.0)
		flash.visible = not flash.visible
