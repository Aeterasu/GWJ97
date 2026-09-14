class_name Scoring extends Node

@export var score_awards_per_pattern: Array[int] = []
@export var label: Label = null

@export var score_item_manager: ScoreItemManager = null
@export var score_item_particles: CPUParticles2D = null
@export var game_sequencer: GameSequencer = null

var score: int = 0:
	set(value):
		if value < 0:
			value = 0

		score = value
		
		label.text = Utils.format_thousands(score)

# this is the multiplier awarded for rescuing little suns
# it is not related to no-miss-no-bombs bonuses
var current_rescue_multiplier: float = 1.0:
	set(value):
		current_rescue_multiplier = clampf(value, 1.0, MAX_RESCUE_MULTIPLIER)

const MAX_RESCUE_MULTIPLIER: float = 20.0
const SCORE_ITEM_BASE_VALUE: int = 100

func _ready() -> void:
	score_item_manager.on_item_collection.connect(on_score_item_picked_up)

# is is important - if anything awards score, it can NEVER directly call award_score!
# everything must be routed through functions here so that we do not lose track of the multipliers
func award_score(amount: int) -> void:
	score += amount

func on_pattern_completed(pattern_idx: int) -> void:
	award_score(roundi(score_awards_per_pattern[pattern_idx] * current_rescue_multiplier))

	# turn bullets into yummy score!

	var engine = game_sequencer.enemy_bullet_engine

	var count: int = min(score_item_manager.max_item_count, engine.active_bullet_count)
	var positions: PackedVector2Array = []
	positions.resize(count)

	for i in count:
		score_item_manager.spawn_score_item(ScoreItem.Type.MEDIUM, engine.bullets[i].position)
		positions[i] = engine.bullets[i].position

	score_item_particles.amount = count
	score_item_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINTS
	score_item_particles.emission_points = positions
	score_item_particles.set_deferred("emitting", true)

func on_score_item_picked_up(item: ScoreItem) -> void:
	award_score(SCORE_ITEM_BASE_VALUE)
