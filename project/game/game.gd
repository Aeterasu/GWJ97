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

	ui_root.boss_pattern_name_block.hide()
	ui_root.boss_healthbar.generate_healthbar(game_sequencer.patterns_health)

	if ui_root.boss_pattern_name_block.has_signal("resized"):
		ui_root.boss_pattern_name_block.resized.connect(update_boss_ticker_layout)
	
	game_sequencer.propagate_pattern_hit.connect(update_boss_healthbar)
	game_sequencer.on_pattern_init.connect(on_pattern_init)

	player.on_hit.connect(scoring.on_player_hit)
	player.on_hit.connect(ui_root.player_health.on_player_hit.bind(player.lives))
	player.on_heal.connect(ui_root.player_health.on_player_heal.bind(player.lives))

	game_sequencer.start_game()

func darken_screen() -> void:
	is_dark_screen = true

func lighten_scree() -> void:
	is_dark_screen = false

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
	if Input.is_action_pressed("restart"):
		restart_timer += delta

		if restart_timer > restart_target_time:
			Main.instance.load_state(Main.State.GAME)
	else:
		restart_timer = 0.0

func _process(delta: float) -> void:
	var lerp_weight: float = 1.0 - exp(-10.0 * delta)

	dark_screen.modulate.a = lerp(dark_screen.modulate.a, 1.0 if is_dark_screen else 0.0, lerp_weight)

	ui_root.boss_ticker_text.position.y = ui_root.boss_pattern_name.position.y
	ui_root.player_health.lives = player.lives

func on_pattern_init(pattern_idx: int) -> void:
	var pattern_str = game_sequencer.patterns_flavor[pattern_idx].pattern_names
	var current_text = ui_root.boss_pattern_name.text
	var dur: float = 0.4

	var ticker_text = game_sequencer.patterns_flavor[pattern_idx].pattern_subtext

	if current_text.is_empty():
		ui_root.boss_pattern_name_block.show()
		ui_root.boss_pattern_name.position.y = -16.0
		ui_root.boss_ticker_text.text = ticker_text.to_upper() + " " + ticker_text.to_upper()
		set_pattern_text('"' + pattern_str.to_upper() + '"')

		var tween: Tween = create_tween()
		tween.tween_property(ui_root.boss_pattern_name, "position:y", -1.0, dur)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_SINE)
	else:
		var tween: Tween = create_tween()
		ui_root.boss_pattern_name_block.show()	
		
		tween.tween_property(ui_root.boss_pattern_name, "position:y", -16.0, dur)\
			.set_ease(Tween.EASE_IN)\
			.set_trans(Tween.TRANS_SINE)
		
		tween.tween_callback(func(): 
			ui_root.boss_ticker_text.text = ticker_text.to_upper() + " " + ticker_text.to_upper()
			set_pattern_text('"' + pattern_str.to_upper() + '"'))

		tween.tween_property(ui_root.boss_pattern_name, "position:y", -1.0, dur)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_SINE)

func set_pattern_text(new_text: String) -> void:
	var label := ui_root.boss_pattern_name
	var ticker := ui_root.boss_ticker_text
	var block := ui_root.boss_pattern_name_block
	label.text = new_text
	# GODOT IS COMPLAINING ABOUT THIS LINE
	# TOO BAD!
	label.size = label.get_minimum_size()
	var block_width := block.size.x
	if block_width < 10.0:
		block_width = 236.0
	var right_edge_offset := 1.0
	var right_edge := block_width + right_edge_offset
	label.position.x = right_edge - label.size.x
	update_boss_ticker_layout()

func update_boss_ticker_layout() -> void:
	var label := ui_root.boss_pattern_name
	var ticker := ui_root.boss_ticker_text
	var gap := 18.0
	var new_width := label.position.x - ticker.position.x - gap
	if new_width < 0.0:
		new_width = 0.0
	ticker.size.x = new_width
	ticker.queue_redraw()

func update_boss_healthbar(pattern: Pattern) -> void:
	ui_root.boss_healthbar.update_healthbar(game_sequencer.get_all_health_percentagees(), game_sequencer.current_idx)
	ui_root.boss_healthbar.trailing_damage_time_left = ui_root.boss_healthbar.trailing_damage_duration

static func get_player() -> Player:
	if is_instance_valid(instance) and is_instance_valid(instance.player):
		return instance.player
	else:
		push_warning("Player not found! Proceed with caution...")
		return null
