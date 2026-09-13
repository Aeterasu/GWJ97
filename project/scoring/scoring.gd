class_name Scoring extends Node

@export var score_awards_per_pattern: Array[int] = []
@export var label: Label = null

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

# is is important - if anything awards score, it can NEVER directly call award_score!
# everything must be routed through functions here so that we do not lose track of the multipliers
func award_score(amount: int) -> void:
	score += amount

func on_pattern_completed(pattern_idx: int) -> void:
	award_score(roundi(score_awards_per_pattern[pattern_idx] * current_rescue_multiplier))

func on_score_item_picked_up() -> void:
	pass
