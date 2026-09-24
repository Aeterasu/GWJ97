class_name Player extends Area2D

enum State
{
	DEFAULT,
	COUNTERBOMB,
	DYING,
	DEAD,
	CUTSCENE,
}

const PLAYER_STARTING_POSITION: Vector2 = Vector2(54.0, 260.0)

const STARTING_LIVES_EASY: int = 3
const STARTING_LIVES_NORMAL: int = 2
const MAX_LIVES: int = 5
const INVINCIBILITY_ON_HIT: float = 8.0
const INVINCIBILITY_ON_BOMB: float = 5.0
const COUNTERBOMB_WINDOW: int = 10

@export_group("Movement")
@export var base_speed: float = 0.0
@export var focus_speed: float = 0.0

@export_group("Attack")
@export var base_weapon: PlayerWeapon = null
@export var focus_weapon: PlayerWeapon = null

@export var options_rotation_speed: float = 0.0
@export var options_base_distance: float = 0.0
@export var options_focus_distance: float = 0.0
@export var options: Array[Node2D] = []
@export var options_transition_duration: float = 0.0

@export var bullet_engine: BulletEngine = null

@export_group("Visuals")
@export var sprite: Sprite2D = null
@export var muzzle_flashes: Array[Node2D] = []
@export var visibilty_origin: Node2D = null
@export var death_explosion: Node2D = null

@export var bomb_parent: Node = null
@export var bomb_projectile_scene: PackedScene = null

@export var death_delay: float = 0.5

@export var animation_player: AnimationPlayer = null
@export var cutscene_config: CustceneConfig = null

var state: State = State.DEFAULT
var lives: int = 0

var is_focused: bool = false
var disable_input: bool = false

var options_transition_current_timer: float = 0.0
var options_angle: float = 0.0

var bomb_restart_duration: float = 50.0
var bomb_restart_timer: float = 0.0
var bomb_effect_duration: float = 0.8
var bomb_effect_timer: float = 0.0
var bomb_ready_toggle: bool = false
var is_bomb_active: bool = false

var counterbomb_ticker: int = 0
var death_delay_timer: float = 0.0

var invincibility_timer: float = 0.0

var shot_audio: float = 0.0

var visuals: PlayerVisuals = PlayerVisuals.new()

signal on_hit
signal on_death
signal on_heal
signal on_bomb
signal on_bomb_end
signal on_bomb_ready

func _ready() -> void:
	lives = STARTING_LIVES_NORMAL

	base_weapon.bullet_engine = bullet_engine
	focus_weapon.bullet_engine = bullet_engine

	base_weapon.on_fire.connect(visuals.on_fire)
	focus_weapon.on_fire.connect(visuals.on_fire)

	collision_layer = 1 << BulletEngine.PLAYER_COLLISION_BIT
	collision_mask = 1 << BulletEngine.ENEMY_COLLISION_BIT

	visuals.init(sprite, options, muzzle_flashes)
	visuals.update_frame(1.0, false, false, false)

	cutscene_config.visual_component = visuals

func _physics_process(delta: float) -> void:
	update_audio(delta)

	match state:
		State.DEFAULT:
			state_default(delta)
		State.COUNTERBOMB:
			state_counterbomb(delta)
		State.DYING:
			state_dying(delta)
		State.DEAD:
			state_dead()
		State.CUTSCENE:
			pass

	invincibility_timer = max(invincibility_timer - delta, 0.0)
	update_options(delta)

func _process(delta: float) -> void:
	var is_firing: bool = base_weapon.is_firing or focus_weapon.is_firing

	if state != State.CUTSCENE:
		visuals.update_frame(delta, is_focused, invincibility_timer > 0.0, is_firing)
	else:
		cutscene_config.update(delta)

#	visuals.update_3d_effect()

func state_default(delta: float) -> void:
	if disable_input:
		return
	process_movement(delta)
	process_weapon(delta)

func state_counterbomb(delta: float) -> void:
	counterbomb_ticker += 1

	if counterbomb_ticker > COUNTERBOMB_WINDOW:
		transition_to_dying()
		return

	if Input.is_action_just_pressed(InputActions.PLAYER_INPUT_ACTION_3):
		if bomb_effect_timer <= 0.0 and bomb_restart_timer <= 0.0:
			activate_bomb()
			state = State.DEFAULT
			disable_input = false
			visibilty_origin.visible = true

func state_dying(delta: float) -> void:
	death_delay_timer -= delta
	if death_delay_timer <= 0.0:
		state = State.DEAD

func state_dead() -> void:
	deduct_life()
	disable_input = false
	visibilty_origin.visible = true
	state = State.DEFAULT

func transition_to_counterbomb() -> void:
	state = State.COUNTERBOMB
	counterbomb_ticker = 0
	disable_input = true
	visibilty_origin.visible = false
	death_explosion.fire()

	base_weapon.is_firing = false
	focus_weapon.is_firing = false

	AudioManager.play_sfx(AudioManager.instance.sfx_player_death)

func transition_to_dying() -> void:
	state = State.DYING
	death_delay_timer = death_delay

func process_movement(delta: float) -> void:
	var dir: Vector2 = Input.get_vector(
		InputActions.PLAYER_INPUT_LEFT, InputActions.PLAYER_INPUT_RIGHT,
		InputActions.PLAYER_INPUT_UP, InputActions.PLAYER_INPUT_DOWN)

	var move_speed: float = focus_speed if is_focused else base_speed
	global_position += dir.normalized() * move_speed * delta
	global_position.x = clampf(global_position.x, 0.0, Game.BOARD_SIZE.x)
	global_position.y = clampf(global_position.y, 0.0, Game.BOARD_SIZE.y)

	visuals.update_tilt(delta, dir)

func process_weapon(delta: float) -> void:
	is_focused = Input.is_action_pressed(InputActions.PLAYER_INPUT_ACTION_2)

	var fire_input: bool = Input.is_action_pressed(InputActions.PLAYER_INPUT_ACTION_1)
	var bomb_input: bool = Input.is_action_just_pressed(InputActions.PLAYER_INPUT_ACTION_3)
	var focus_ready: bool = options_transition_current_timer >= options_transition_duration

	base_weapon.is_firing = fire_input and not focus_ready
	focus_weapon.is_firing = fire_input and focus_ready

	if bomb_input and bomb_effect_timer <= 0.0 and bomb_restart_timer <= 0.0:
		activate_bomb()

	update_bomb_timers(delta)

func update_bomb_timers(delta: float) -> void:
	if bomb_effect_timer > 0.0:
		bomb_effect_timer -= delta
		if bomb_effect_timer <= 0.0:
			bomb_effect_timer = 0.0
			is_bomb_active = false
			on_bomb_end.emit()
	else:
		if bomb_restart_timer > 0.0:
			bomb_restart_timer -= delta
			if bomb_restart_timer <= 0.0:
				bomb_restart_timer = 0.0
				if bomb_ready_toggle:
					on_bomb_ready.emit()
					bomb_ready_toggle = false

func activate_bomb() -> void:
	bomb_effect_timer = bomb_effect_duration
	bomb_restart_timer = bomb_restart_duration
	invincibility_timer = INVINCIBILITY_ON_BOMB
	bomb_ready_toggle = true

	on_bomb.emit()
	is_bomb_active = true

	AudioManager.play_sfx(AudioManager.instance.sfx_player_bomb)

	var projectile: Node2D = bomb_projectile_scene.instantiate() as Node2D
	bomb_parent.add_child(projectile)
	projectile.global_position = self.global_position + Vector2.UP * 64.0
	projectile.reset_physics_interpolation()

func hit(bullet: Bullet = null) -> void:
	match state:
		State.CUTSCENE, State.COUNTERBOMB, State.DYING, State.DEAD:
			return

	if invincibility_timer > 0.0:
		return

	transition_to_counterbomb()

func deduct_life() -> void:
	lives -= 1

	bomb_restart_timer -= 999.0
	invincibility_timer = INVINCIBILITY_ON_HIT

	on_hit.emit()

	if lives < 0:
		on_death.emit()
		lives = 0

func award_life() -> void:
	if lives + 1 > MAX_LIVES:
		return

	lives += 1
	on_heal.emit()

	AudioManager.play_sfx(AudioManager.instance.sfx_player_heal)

func update_options(delta: float) -> void:
	options_angle += options_rotation_speed * delta

	if is_focused:
		options_transition_current_timer = min(options_transition_current_timer + delta, options_transition_duration)
	else:
		options_transition_current_timer = max(options_transition_current_timer - delta, 0.0)

	var final_radius: float = lerp(options_base_distance, options_focus_distance, options_transition_current_timer / options_transition_duration)

	if options.size() > 0:
		for i in options.size():
			var angle: float = options_angle + (TAU / options.size()) * i
			var offset: Vector2 = Vector2(cos(angle), sin(angle)) * final_radius
			options[i].position = offset

func update_audio(delta: float) -> void:
	if not AudioManager.instance.sfx_player_shot.playing:
		AudioManager.instance.sfx_player_shot.play()

	AudioManager.instance.sfx_player_shot.volume_linear = shot_audio

	if base_weapon.is_firing or focus_weapon.is_firing:
		shot_audio = lerp(shot_audio, 1.2, 1.0 - exp(-40.0 * delta))
	else:
		shot_audio = lerp(shot_audio, 0.0, 1.0 - exp(-30.0 * delta))

func reset_position() -> void:
	global_position = PLAYER_STARTING_POSITION
	reset_physics_interpolation()
