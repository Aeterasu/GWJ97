class_name Game extends Node2D

@export var game_sequencer: GameSequencer = null
@export var player: Player = null
@export var scoring: Scoring = null
@export var ui_root: UI = null

@export var bomb_animation: BombAnimation = null

@export var dark_screen: DarkScreen = null
@export var debug_hp_label: Label = null
@export var pause_overlay: PauseOverlay = null
@export var restart_overlay: RestartOverlay = null

const BOARD_SIZE: Vector2 = Vector2(240.0, 320.0)
const PLAYER_STARTING_POSITION: Vector2 = Vector2(54.0, 260.0)

var restart_timer: float = 0.0
var restart_target_time: float = 1.0

var is_paused: bool = false
var time: float = 0.0

static var instance: Game = null

func _ready() -> void:
	instance = self

	game_sequencer.fix()

	animate_player_intro()

	ui_root.boss_pattern_name_block.hide()
	ui_root.boss_healthbar.generate_healthbar(game_sequencer.patterns_health)

	ui_root.boss_healthbar.parent.hide()
	ui_root.boss_timer.hide()

	if ui_root.boss_pattern_name_block.has_signal("resized"):
		ui_root.boss_pattern_name_block.resized.connect(update_boss_ticker_layout)
	
	game_sequencer.propagate_pattern_hit.connect(update_boss_healthbar)
	game_sequencer.on_pattern_init.connect(on_pattern_init)

	if not game_sequencer.show_boss_warning:
		ui_root.boss_healthbar.parent.show()

	player.on_hit.connect(scoring.on_player_hit)
	player.on_hit.connect(func(): ui_root.player_health.on_player_hit(player.lives))
	player.on_heal.connect(func(): ui_root.player_health.on_player_heal(player.lives))
	player.on_bomb_ready.connect(ui_root.bomb_bar.show_bomb_ready_notif)
	player.on_bomb.connect(on_player_bomb)
	player.on_bomb_end.connect(on_player_bomb_end)

	game_sequencer.start_game()

func darken_screen() -> void:
	dark_screen.darken()

func lighten_scree() -> void:
	dark_screen.lighten()

func animate_player_intro() -> void:
	player.state = Player.State.CUTSCENE
	player.global_position = PLAYER_STARTING_POSITION + Vector2.DOWN * 150.0
	player.reset_physics_interpolation()

	var tween: Tween = create_tween()
	tween.tween_property(player, "global_position", PLAYER_STARTING_POSITION, 1.0)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)\
		.set_delay(0.4)
	tween.tween_callback(func(): player.state = Player.State.DEFAULT)

func _physics_process(delta: float) -> void:
	time += delta

	if Input.is_action_just_pressed("pause"):
		is_paused = not is_paused
		pause_overlay.update_overlay(is_paused)
		return

	if not is_paused:
		if time > 1.0 and Input.is_action_pressed("restart"):
			restart_timer += delta

			if restart_timer > restart_target_time:
				Main.instance.load_state(Main.State.GAME)
		else:
			restart_timer = 0.0
	
	get_tree().paused = is_paused or game_sequencer.timeout_pause or restart_timer > 0.0

	if player.is_bomb_active and game_sequencer.enemy_bullet_engine.active_bullet_count > 0:
		game_sequencer.enemy_bullet_engine.bullet_cancel()

func _process(delta: float) -> void:
	ui_root.boss_ticker_text.position.y = ui_root.boss_pattern_name.position.y
	ui_root.player_health.lives = player.lives

	ui_root.immune_label.visible = player.invincibility_timer > 0.0
	ui_root.immune_label.text = "IMMUNE: " + str(Utils.round_place(player.invincibility_timer, 1)) + "s"

	ui_root.bomb_bar.max_value = 1.0
	ui_root.bomb_bar.value = 1.0 - (player.bomb_restart_timer / player.bomb_restart_duration)

	if ui_root.bomb_bar.value >= 1.0:
		ui_root.bomb_bar.tint_progress = Color("#faeac9")
	else:
		ui_root.bomb_bar.tint_progress = Color("#927873")

	ui_root.boss_timer_panel.visible = ui_root.boss_timer.visible

	restart_overlay.set_progress(restart_timer, restart_target_time)

func on_pattern_init(pattern_idx: int) -> void:
	var pattern_str = game_sequencer.patterns_flavor[pattern_idx].pattern_names
	var current_text = ui_root.boss_pattern_name.text
	var dur: float = 0.4

	var ticker_text = game_sequencer.patterns_flavor[pattern_idx].pattern_subtext

	if current_text.is_empty():
		ui_root.boss_pattern_name_block.show()
		ui_root.boss_timer.show()
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
		ui_root.boss_timer.show()

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

func on_player_bomb() -> void:
	game_sequencer.no_bomb = false

	var bullet_count: int = game_sequencer.enemy_bullet_engine.active_bullet_count
	bomb_animation.positions.resize(bullet_count)
	
	for i: int in bullet_count:
		bomb_animation.positions[i] = game_sequencer.enemy_bullet_engine.bullets[i].position
	bomb_animation.particles.amount = max(bullet_count * 48, 1)

	bomb_animation.show_bomb_flash()

func on_player_bomb_end() -> void:
	pass
