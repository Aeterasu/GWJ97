class_name AudioManager extends Node

const BUS_NAME_MASTER = "Master"
const BUS_NAME_SFX = "SFX"
const BUS_NAME_BGM = "BGM"

var hitsound_deconflicter_time_left : float = 0.0

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
