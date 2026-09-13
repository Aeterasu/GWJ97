class_name Game extends Node2D

@export var game_sequencer: GameSequencer = null
@export var player: Player = null
@export var ui_root: UI = null

const BOARD_SIZE: Vector2 = Vector2(240.0, 320.0)
const PLAYER_STARTING_POSITION: Vector2 = Vector2(54.0, 260.0)

static var instance: Game = null

func _ready() -> void:
	instance = self

	animate_player_intro()

	ui_root.boss_healthbar.generate_healthbar(game_sequencer.patterns_health)
	
	game_sequencer.propagate_pattern_hit.connect(update_boss_healthbar)
	game_sequencer.init_pattern(game_sequencer.starting_pattern)

func animate_player_intro() -> void:
	player.control_state = Player.ControlState.IN_CUTSCENE
	player.global_position = PLAYER_STARTING_POSITION + Vector2.DOWN * 96.0
	player.reset_physics_interpolation()

	var tween: Tween = create_tween()
	tween.tween_property(player, "global_position", PLAYER_STARTING_POSITION, 1.0)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)
	tween.tween_callback(func(): player.control_state = Player.ControlState.NORMAL)

func _physics_process(delta: float) -> void:
	pass

func update_boss_healthbar(pattern: Pattern) -> void:
	ui_root.boss_healthbar.update_healthbar(game_sequencer.get_all_health_percentagees(), game_sequencer.current_idx)

static func get_player() -> Player:
	if is_instance_valid(instance) and is_instance_valid(instance.player):
		return instance.player
	else:
		push_warning("Player not found! Proceed with caution...")
		return null
