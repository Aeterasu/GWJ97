class_name AudioManager extends Node

@export_group("Player")
@export var sfx_player_shot: AudioStreamPlayer = null
@export var sfx_player_bomb: AudioStreamPlayer = null
@export var sfx_player_death: AudioStreamPlayer = null
@export var sfx_player_heal: AudioStreamPlayer = null

@export_group("Enemy")
@export var sfx_boss_shot_1: AudioStreamPlayer = null
@export var sfx_boss_shot_2: AudioStreamPlayer = null
@export var sfx_boss_shot_3: AudioStreamPlayer = null
@export var sfx_boss_shot_4: AudioStreamPlayer = null
@export var sfx_boss_shot_5: AudioStreamPlayer = null
@export var sfx_explosion_1: AudioStreamPlayer = null

const BUS_NAME_MASTER = "Master"
const BUS_NAME_SFX = "SFX"
const BUS_NAME_BGM = "BGM"

var hitsound_deconflicter_time_left : float = 0.0

static var instance: AudioManager = null

func _ready() -> void:
	instance = self

static func play_sfx(player: AudioStreamPlayer, pitch: float = 1.0) -> void:
	if player:
		player.pitch_scale = pitch
		player.play()

func _physics_process(delta: float) -> void:
	hitsound_deconflicter_time_left = max(hitsound_deconflicter_time_left - delta, 0.0)

static func set_master_volume(vol : float) -> void:
	vol = clampf(vol, 0.0, 1.0)

	var bus = AudioServer.get_bus_index(BUS_NAME_MASTER)
	AudioServer.set_bus_volume_linear(bus, vol)

static func get_master_volume() -> float:
	var bus = AudioServer.get_bus_index(BUS_NAME_MASTER)
	return AudioServer.get_bus_volume_linear(bus)    

static func set_sfx_volume(vol : float) -> void:
	vol = clampf(vol, 0.0, 1.0)

	var bus = AudioServer.get_bus_index(BUS_NAME_SFX)
	AudioServer.set_bus_volume_linear(bus, vol)

static func get_sfx_volume() -> float:
	var bus = AudioServer.get_bus_index(BUS_NAME_SFX)
	return AudioServer.get_bus_volume_linear(bus)    

static func set_bgm_volume(vol : float) -> void:
	vol = clampf(vol, 0.0, 1.0)

	var bus = AudioServer.get_bus_index(BUS_NAME_BGM)
	AudioServer.set_bus_volume_linear(bus, vol)

static func get_bgm_volume() -> float:
	var bus = AudioServer.get_bus_index(BUS_NAME_BGM)
	return AudioServer.get_bus_volume_linear(bus)    

static func mute_audio() -> void:
	var bus = AudioServer.get_bus_index(BUS_NAME_MASTER)
	AudioServer.set_bus_mute(bus, true)

static func unmute_audio() -> void:
	var bus = AudioServer.get_bus_index(BUS_NAME_MASTER)
	AudioServer.set_bus_mute(bus, false)

