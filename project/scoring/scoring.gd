class_name Scoring extends Node

@export var score_awards_per_pattern: Array[int] = []

@export var label: RichTextLabel = null

@export var score_item_manager: ScoreItemManager = null
@export var score_item_particles: CPUParticles2D = null
@export var score_sun_manager: ScoreSunManager = null
@export var game_sequencer: GameSequencer = null

var score: int = 0:
	set(value):
		if value < 0:
			value = 0

		score = value
		
		update_label()

var results_pattern_reward: int = 0
var results_multiplier: float = 1.0
var results_items_sum: int = 0
var results_suns_collected: int = 0
var results_starting_score: int = 0
var results_total: int = 0

# this is the multiplier awarded for rescuing little suns
# it is not related to no-miss-no-bombs bonuses
var current_rescue_multiplier: float = 1.0:
	set(value):
		current_rescue_multiplier = clampf(value, 1.0, MAX_RESCUE_MULTIPLIER)
		
		update_label()

const MAX_RESCUE_MULTIPLIER: float = 9999.0
const SCORE_ITEM_BASE_VALUE: int = 100

func _ready() -> void:
	score_item_manager.on_item_collection.connect(on_score_item_picked_up)
	score_sun_manager.on_sun_collection.connect(on_sun_collection)

	update_label()

func reset_results() -> void:
	results_pattern_reward = 0
	results_multiplier = 1.0
	results_items_sum = 0
	results_suns_collected = 0
	results_starting_score = score
	results_total = score

func update_label() -> void:
	label.text = Utils.format_thousands(score) + " ([img]res://ui/texture/texture_ui_little_sun.png[/img]x" + str(Utils.round_place(current_rescue_multiplier, 1)) + ")"

# is is important - if anything awards score, it can NEVER directly call award_score!
# everything must be routed through functions here so that we do not lose track of the multipliers
func award_score(amount: int) -> void:
	score += amount
	results_total += amount

func award_rescue_multiplier() -> void:
	current_rescue_multiplier += 1.0

func reset_rescue_multiplier() -> void:
	current_rescue_multiplier = 1.0

func on_pattern_completed(pattern_idx: int) -> void:
	#var award = roundi(score_awards_per_pattern[pattern_idx] * current_rescue_multiplier) 
	var multiplier = 1.0
	if game_sequencer.no_miss and game_sequencer.no_bomb:
		multiplier = 2.0
	elif game_sequencer.no_miss or game_sequencer.no_bomb:
		multiplier = 1.5
	else:
		multiplier = 1.0

	results_multiplier = multiplier
	results_pattern_reward = score_awards_per_pattern[pattern_idx]

	var award = roundi(results_pattern_reward * multiplier)

	award_score(award)

	# turn bullets into yummy score!

	var engine = game_sequencer.enemy_bullet_engine

	var count: int = min(score_item_manager.max_item_count, engine.active_bullet_count)

	if count <= 0:
		return

	var positions: PackedVector2Array = []
	positions.resize(count)

	for i in count:
		var type = get_item_type_from_multiplier(current_rescue_multiplier) 

		var item = score_item_manager.spawn_score_item(type, engine.bullets[i].position)
		
		if item:
			item.reward = roundi(SCORE_ITEM_BASE_VALUE * current_rescue_multiplier)

		positions[i] = engine.bullets[i].position

	score_item_particles.amount = count
	score_item_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINTS
	score_item_particles.emission_points = positions
	score_item_particles.set_deferred("emitting", true)

func get_item_type_from_multiplier(multiplier: float = 1.0) -> ScoreItem.Type:
	if multiplier <= 1.0:
		return ScoreItem.Type.VERY_SMALL
	elif multiplier > 1.0 and multiplier <= 10.0:
		return ScoreItem.Type.SMALL
	elif multiplier > 10.0 and multiplier < 20.0:
		return ScoreItem.Type.MEDIUM
	elif multiplier >= 20.0:
		return ScoreItem.Type.LARGE

	return ScoreItem.Type.VERY_SMALL

func on_score_item_picked_up(item: ScoreItem) -> void:
	award_score(item.reward)

	results_items_sum += item.reward

func on_sun_collection(item: ScoreItem) -> void:
	award_rescue_multiplier()

	results_suns_collected += 1

func on_player_hit() -> void:
	current_rescue_multiplier = 1.0
