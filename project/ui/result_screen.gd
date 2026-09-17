class_name ResultScreen extends Control

@export var animation_player: AnimationPlayer = null

@export var pattern_reward_label: Label = null
@export var score_multiplier_label: Label = null
@export var score_item_label: Label = null
@export var score_suns_label: Label = null
@export var total_label: Label = null

@export var no_miss_checkmark: ResultScreenCheckbox = null
@export var no_bomb_checkmark: ResultScreenCheckbox = null

@export var ticker_label: TickerLabel = null

@export var kill_category: Control = null
@export var timeout_category: Control = null

var pattern_reward: int = 0
var score_multiplier: float = 1.0
var score_items: int = 0
var score_suns_collected: int = 0
var total: int = 0

signal on_results_confirmed

func _ready() -> void:
	self.hide()

func show_results(data: Scoring, no_miss: bool, no_bomb: bool) -> void:
	kill_category.show()
	timeout_category.hide()

	pattern_reward = 0
	score_multiplier = 1.0
	score_items = 0
	score_suns_collected = 0
	total = data.results_starting_score
	no_miss_checkmark.reset()
	no_bomb_checkmark.reset()

	self.show()
	animation_player.play("show_results")

	var tween: Tween = create_tween()

	var d = 1.0
	var p = 0.5

	tween.tween_property(self, "pattern_reward", data.results_pattern_reward, d)
	tween.tween_callback(no_miss_checkmark.animate_check if no_miss else no_miss_checkmark.animate_cross).set_delay(p)
	var intermediate_mult := 1.5 if no_miss else 1.0
	tween.tween_property(self, "score_multiplier", intermediate_mult, 0.1).set_delay(p)
	tween.parallel().tween_property(self, "pattern_reward", roundi(data.results_pattern_reward * intermediate_mult), d)
	tween.tween_callback(no_bomb_checkmark.animate_check if no_bomb else no_bomb_checkmark.animate_cross).set_delay(p)
	tween.tween_property(self, "score_multiplier", data.results_multiplier, 0.1).set_delay(p)
	tween.parallel().tween_property(self, "pattern_reward", roundi(data.results_pattern_reward * data.results_multiplier), d)
	tween.tween_property(self, "score_items", data.results_items_sum, d).set_delay(p)
	tween.tween_property(self, "score_suns_collected", data.results_suns_collected, d).set_delay(p)
	tween.tween_property(self, "total", data.results_total, d).set_delay(p)
	
	tween.tween_callback(on_results_confirmed.emit).set_delay(3.0)

func show_timeout_results(data: Scoring) -> void:
	kill_category.hide()
	timeout_category.show()

	pattern_reward = 0
	score_multiplier = 1.0
	score_items = 0
	score_suns_collected = 0
	total = data.results_starting_score
	no_miss_checkmark.reset()
	no_bomb_checkmark.reset()

	self.show()
	animation_player.play("show_results")
	
	var tween: Tween = create_tween()
	tween.tween_callback(on_results_confirmed.emit).set_delay(3.0)

func hide_results() -> void:
	animation_player.play("hide_results")
	await get_tree().create_timer(1.0, false).timeout

	self.hide()

func _process(delta: float) -> void:
	pattern_reward_label.text = Utils.format_thousands(pattern_reward)
	score_multiplier_label.text = "x" + str(Utils.round_place(score_multiplier, 1))
	score_item_label.text = Utils.format_thousands(score_items)
	score_suns_label.text = Utils.format_thousands(score_suns_collected)
	total_label.text = Utils.format_thousands(total)

