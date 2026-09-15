class_name Game extends Node2D

@export var game_sequencer: GameSequencer = null
@export var player: Player = null
@export var scoring: Scoring = null
@export var ui_root: UI = null

@export var dark_screen: Control = null
var is_dark_screen: bool = false

@export var debug_hp_label: Label = null

const BOARD_SIZE: Vector2 = Vector2(240.0, 320.0)
const PLAYER_STARTING_POSITION: Vector2 = Vector2(54.0, 260.0)

var restart_timer : float = 0.0
var restart_target_time : float = 3.0

static var instance: Game = null

func _ready() -> void:
	instance = self

	game_sequencer.fix()

	animate_player_intro()

	ui_root.boss_healthbar.generate_healthbar(game_sequencer.patterns_health)
	
	game_sequencer.propagate_pattern_hit.connect(update_boss_healthbar)
	game_sequencer.on_pattern_init.connect(on_pattern_init)

	game_sequencer.start_game()

func animate_player_intro() -> void:
	player.control_state = Player.ControlState.IN_CUTSCENE
	player.global_position = PLAYER_STARTING_POSITION + Vector2.DOWN * 150.0
	player.reset_physics_interpolation()

	var tween: Tween = create_tween()
	tween.tween_property(player, "global_position", PLAYER_STARTING_POSITION, 1.0)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)\
		.set_delay(0.4)
	tween.tween_callback(func(): player.control_state = Player.ControlState.NORMAL)

func _physics_process(delta: float) -> void:
	debug_hp_label.text = "HP: " + str(player.lives)
	
	if Input.is_action_pressed("restart"):
		restart_timer += delta

		if restart_timer > restart_target_time:
			Main.instance.load_state(Main.State.GAME)
	else:
		restart_timer = 0.0

func _process(delta: float) -> void:
	var lerp_weight: float = 1.0 - exp(-10.0 * delta)

	dark_screen.modulate.a = lerp(dark_screen.modulate.a, 1.0 if is_dark_screen else 0.0, lerp_weight)

func on_pattern_init(pattern_idx: int) -> void:
	var pattern_str = game_sequencer.patterns_flavor[pattern_idx].pattern_names
	ui_root.boss_pattern_name.text = '"' + pattern_str.to_upper() + '"'
	#ui_root.boss_pattern_name.reset_size()

func update_boss_healthbar(pattern: Pattern) -> void:
	ui_root.boss_healthbar.update_healthbar(game_sequencer.get_all_health_percentagees(), game_sequencer.current_idx)
	ui_root.boss_healthbar.trailing_damage_time_left = ui_root.boss_healthbar.trailing_damage_duration

static func get_player() -> Player:
	if is_instance_valid(instance) and is_instance_valid(instance.player):
		return instance.player
	else:
		push_warning("Player not found! Proceed with caution...")
		return null
