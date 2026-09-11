class_name BGMManager extends Node

enum BGMType
{
    MENU,
    GAME,
}

@export var bgm_dict : Dictionary[BGMType, BGM] = {}

var current_bgm : AudioStreamPlayer = null

func update_bgm(bgm : BGMType, reset : bool = false) -> void:
    for type in bgm_dict.keys():
        var player = bgm_dict[type]

        if type == bgm:
            player.enable(reset)
            current_bgm = player
        else:
            player.disable()
            current_bgm = null

func pause() -> void:
    if current_bgm:
        current_bgm.stream_paused = true

func resume() -> void:
    if current_bgm:
        current_bgm.stream_paused = false