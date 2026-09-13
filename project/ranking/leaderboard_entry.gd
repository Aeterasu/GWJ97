class_name LeaderboardEntry extends Control

var score : int = 0:
	set(value):
		score = value
		score_label.text = Utils.format_thousands(value) + ""

var rank : int = 0:
	set(value):
		rank = value
		rank_label.text = str(rank) + "."

@export var pb_label : Label = null
@export var score_label : Label = null

@export var rank_label : Label = null

func reset_modulate() -> void:
	score_label.modulate = Color.WHITE
	rank_label.modulate = Color.WHITE
