class_name Player extends Area2D

@export var base_speed: float = 0.0
@export var focus_speed: float = 0.0

@export var base_weapon: PlayerWeapon = null
@export var focus_weapon: PlayerWeapon = null
var is_focused: bool = false
var focus_fx: float = 0.0

@export var bullet_engine: BulletEngine = null
@export var enemy_bullet_engine: BulletEngine = null

@export var game_sequencer : GameSequencer = null

@export var options_rotation_speed: float = 0.0
@export var options_base_distance: float = 0.0
@export var options_focus_distance: float = 0.0
@export var options: Array[Node2D] = []
@export var options_transition_duration: float = 0.0
var options_transition_current_timer: float = 0.0
var options_angle: float = 0.0

@export var sprite: Sprite2D = null
@export var hitbox_sprite: Sprite2D = null
var sprite_shader: ShaderMaterial = null
var sprite_tilt: float = 0.0
var sprite_yaw: float = 0.0

@export var muzzle_flashes: Array[Node2D] = []

@export var bomb_animation: BombAnimation = null

@export var bomb_parent: Node = null
@export var bomb_projectile_scene: PackedScene = null

var lives: int = 0
const STARTING_LIVES: int = 2
const MAX_LIVES: int = 5
const INVINCIBILITY_ON_HIT: float = 8.0
const INVINCIBILITY_ON_BOMB: float = 5.0

var enable_hitbox: bool = false

var control_state: ControlState = ControlState.NORMAL

var invincibility_timer: float = 0.0

var bomb_restart_duration : float = 30.0
var bomb_restart_timer : float = 0.0
var bomb_effect_duration : float = 0.8
var bomb_effect_timer : float = 0.0
var bomb_ready_toggle: bool = false

var is_dead: bool = false

var shot_audio: float = 0.0

const COUNTERBOMB_WINDOW: int = 6
var counterbomb_ticker: int = 0
var is_counterbomb_active: bool = false

var is_bomb_active: bool = false

signal on_hit
signal on_death
signal on_heal
signal on_bomb
signal on_bomb_ready

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
	area_entered.connect(contact_hit)

	collision_layer = 1 << BulletEngine.PLAYER_COLLISION_BIT
	collision_mask = 1 << BulletEngine.ENEMY_COLLISION_BIT

	for flash in muzzle_flashes:
		flash.scale.x = 0.0

	sprite_shader = sprite.material as ShaderMaterial

func contact_hit(area: Area2D) -> void:
	if area is Enemy:
		deduct_life()

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

	# bomb

	if is_bomb_active and game_sequencer.enemy_bullet_engine.active_bullet_count > 0:
		var array: Array[Vector2] = []
		array.resize(game_sequencer.enemy_bullet_engine.active_bullet_count)

		for i in game_sequencer.enemy_bullet_engine.active_bullet_count:
			array[i] = game_sequencer.enemy_bullet_engine.bullets[i].position
	
		bomb_animation.positions = array

		game_sequencer.enemy_bullet_engine.bullet_cancel()	

	# counterbomb

	if is_counterbomb_active:
		if counterbomb_ticker > COUNTERBOMB_WINDOW:
			is_counterbomb_active = false
			deduct_life()

		counterbomb_ticker += 1

func process_movement(delta: float) -> void:
	var dir: Vector2 = Vector2.ZERO

	dir = Input.get_vector(InputActions.PLAYER_INPUT_LEFT, InputActions.PLAYER_INPUT_RIGHT, InputActions.PLAYER_INPUT_UP, InputActions.PLAYER_INPUT_DOWN)
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
	is_focused = Input.is_action_pressed(InputActions.PLAYER_INPUT_ACTION_2)

	var fire_input = Input.is_action_pressed(InputActions.PLAYER_INPUT_ACTION_1)
	var bomb_input = Input.is_action_just_pressed(InputActions.PLAYER_INPUT_ACTION_3)

	var focus_ready = options_transition_current_timer >= options_transition_duration

	base_weapon.is_firing = fire_input and (not focus_ready)
	focus_weapon.is_firing = fire_input and focus_ready
	
	if bomb_input and bomb_effect_timer <= 0.0 and bomb_restart_timer <= 0.0:
		bomb_effect_timer = bomb_effect_duration
		bomb_restart_timer = bomb_restart_duration
		invincibility_timer = INVINCIBILITY_ON_BOMB
		game_sequencer.no_bomb = false
		bomb_ready_toggle = true
		on_bomb.emit()

		is_bomb_active = true
		
		AudioManager.play_sfx(AudioManager.instance.sfx_player_bomb)

		var projectile = bomb_projectile_scene.instantiate() as Node2D
		bomb_parent.add_child(projectile)
		projectile.global_position = self.global_position + Vector2.UP * 128.0
		projectile.reset_physics_interpolation()

		if is_counterbomb_active:
			is_counterbomb_active = false

	if bomb_effect_timer > 0.0:
		bomb_effect_timer -= delta	
	elif bomb_effect_timer <= 0.0:
		bomb_restart_timer -= delta
		is_bomb_active = false

		if bomb_restart_timer <= 0.0 and bomb_ready_toggle:
			on_bomb_ready.emit()
			bomb_ready_toggle = false

	# hacky audio
	if (not AudioManager.instance.sfx_player_shot.playing):
		AudioManager.instance.sfx_player_shot.play()

	AudioManager.instance.sfx_player_shot.volume_linear = shot_audio

	if fire_input:
		shot_audio = lerp(shot_audio, 1.2, 1.0 - exp(-40.0 * delta))
	else:
		shot_audio = lerp(shot_audio, 0.0, 1.0 - exp(-30.0 * delta))

func hit() -> void:
	if is_dead:
		return

	if control_state == ControlState.IN_CUTSCENE:
		return

	if invincibility_timer > 0.0:
		return

	if is_counterbomb_active:
		return

	is_counterbomb_active = true
	counterbomb_ticker = 0

func deduct_life() -> void:
	lives -= 1;

	invincibility_timer = INVINCIBILITY_ON_HIT
	
	on_hit.emit()

	if lives < 0:
		on_death.emit()
		lives = 0

func _process(delta: float) -> void:	
	for flash in muzzle_flashes:
		flash.scale.x = lerp(flash.scale.x, 0.0, 1.0 - exp(-20.0 * delta))
		flash.scale.y = lerp(flash.scale.y, 2.0, 1.0 - exp(-20.0 * delta))

		if (not base_weapon.is_firing) and (not focus_weapon.is_firing):
			flash.visible = true
	
	focus_fx = lerp(focus_fx, 1.0 if is_focused else 0.0, 1.0 - exp(-10.0 * delta))

	sprite_shader.set_shader_parameter("is_invul", invincibility_timer > 0.0)
	sprite_shader.set_shader_parameter("is_focused", focus_fx)

	for o in options:
		(o.material as ShaderMaterial).set_shader_parameter("is_invul", invincibility_timer > 0.0)
		(o.material as ShaderMaterial).set_shader_parameter("is_focused", focus_fx)

	(hitbox_sprite.material as ShaderMaterial).set_shader_parameter("is_invul", invincibility_timer > 0.0)
	(hitbox_sprite.material as ShaderMaterial).set_shader_parameter("is_focused", focus_fx)

func on_fire() -> void:
	for flash in muzzle_flashes:
		flash.scale = Vector2.ONE * randf_range(0.8, 1.5)
		
		flash.position.x = randf_range(-2.0, 2.0)
		flash.visible = not flash.visible

func award_life() -> void:
	if (lives + 1 > MAX_LIVES):
		return

	lives += 1
	on_heal.emit()

func reset_position() -> void:
	global_position = Game.PLAYER_STARTING_POSITION
	reset_physics_interpolation()
