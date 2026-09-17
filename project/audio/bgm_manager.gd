class_name BGMManager extends Node

enum BGMType
{
	BOSS_1,
	BOSS_2,
	BOSS_3,
	MENU,
	CUTSCENE,
	TUTORIAL,
}

@export var bgm_dict : Dictionary[BGMType, BGM] = {}

var current_bgm: BGM = null

static var instance: BGMManager = null

func _ready() -> void:
	instance = self

func update_bgm(bgm : BGMType) -> void:
	if bgm_dict.has(bgm) and current_bgm == bgm_dict[bgm]:
		return

	for type in bgm_dict.keys():
		var player = bgm_dict[type]

		if type == bgm:
			player.enable()
			current_bgm = player
		else:
			player.disable()
