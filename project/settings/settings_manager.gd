class_name SettingsManager extends RefCounted

const CONFIG_PATH : String = "user://config.cfg"
const CONFIG_SECTION : String = "config"

const CONFIG_KEY_FULLSCREEN : String = "fullscreen"
const CONFIG_KEY_SCREEN_SHAKE : String = "screen_shake"
const CONFIG_KEY_DISABLE_FX : String = "disable_fx"
const CONFIG_KEY_MASTER_VOLUME : String = "master_volume"
const CONFIG_KEY_MUSIC_VOLUME : String = "music_volume"
const CONFIG_KEY_SFX_VOLUME : String = "sfx_volume"

const DEFAULT_VALUE_FULLSCREEN : bool = false
const DEFAULT_VALUE_SCREEN_SHAKE : bool = true
const DEFAULT_VALUE_DISABLE_FX : bool = false
const DEFAULT_VALUE_MASTER_VOLUME : float = 0.5
const DEFAULT_VALUE_MUSIC_VOLUME : float = 0.5
const DEFAULT_VALUE_SFX_VOLUME : float = 0.5

var fullscreen : bool = false:
    set(value):
        fullscreen = value

        update_fullscreen(value)

var glow : bool = false:
    set(value):
        glow = value

        update_glow(value)

var screen_shake : bool = true:
    set(value):
        screen_shake = value

var disable_fx : bool = true:
    set(value):
        disable_fx = value

var master_volume : float = 0.5:
    set(value):
        value = clampf(value, 0.0, 1.0)
        master_volume = value

        AudioManager.set_master_volume(value)

var music_volume : float = 0.5:
    set(value):
        value = clampf(value, 0.0, 1.0)
        music_volume = value

        AudioManager.set_bgm_volume(value)

var sfx_volume : float = 0.5:
    set(value):
        value = clampf(value, 0.0, 1.0)
        sfx_volume = value

        AudioManager.set_sfx_volume(value)

func load() -> void:
    var config = ConfigFile.new()

    var err = config.load(CONFIG_PATH)

    if err != OK or config.get_sections().size() <= 0:
        fullscreen = DEFAULT_VALUE_FULLSCREEN
        screen_shake = DEFAULT_VALUE_SCREEN_SHAKE
        disable_fx = DEFAULT_VALUE_DISABLE_FX
        master_volume = DEFAULT_VALUE_MASTER_VOLUME
        music_volume = DEFAULT_VALUE_MUSIC_VOLUME
        sfx_volume = DEFAULT_VALUE_SFX_VOLUME
        return

    for section in config.get_sections():
        fullscreen = config.get_value(section, CONFIG_KEY_FULLSCREEN, DEFAULT_VALUE_FULLSCREEN)
        screen_shake = config.get_value(section, CONFIG_KEY_SCREEN_SHAKE, DEFAULT_VALUE_SCREEN_SHAKE)
        disable_fx = config.get_value(section, CONFIG_KEY_DISABLE_FX, DEFAULT_VALUE_DISABLE_FX)
        master_volume = config.get_value(section, CONFIG_KEY_MASTER_VOLUME, DEFAULT_VALUE_MASTER_VOLUME)
        music_volume = config.get_value(section, CONFIG_KEY_MUSIC_VOLUME, DEFAULT_VALUE_MUSIC_VOLUME)
        sfx_volume = config.get_value(section, CONFIG_KEY_SFX_VOLUME, DEFAULT_VALUE_SFX_VOLUME)

func save() -> void:
    var config = ConfigFile.new()

    config.set_value(CONFIG_SECTION, CONFIG_KEY_FULLSCREEN, fullscreen)
    config.set_value(CONFIG_SECTION, CONFIG_KEY_SCREEN_SHAKE, screen_shake)
    config.set_value(CONFIG_SECTION, CONFIG_KEY_DISABLE_FX, disable_fx)
    config.set_value(CONFIG_SECTION, CONFIG_KEY_MASTER_VOLUME, master_volume)
    config.set_value(CONFIG_SECTION, CONFIG_KEY_MUSIC_VOLUME, music_volume)
    config.set_value(CONFIG_SECTION, CONFIG_KEY_SFX_VOLUME, sfx_volume)

    config.save(CONFIG_PATH)

func update_fullscreen(toggle : bool) -> void:
    var result = DisplayServer.WINDOW_MODE_FULLSCREEN if toggle else DisplayServer.WINDOW_MODE_WINDOWED
    DisplayServer.window_set_mode(result)

func update_glow(toggle : bool) -> void:
    Main.instance.world.environment.glow_enabled = toggle

static func enable_fx() -> bool:
    if Main.instance and Main.instance.settings:
        return not Main.instance.settings.disable_fx
    else:
        return false

func refresh_volume_config() -> void:
    master_volume = AudioManager.get_master_volume()
    sfx_volume = AudioManager.get_sfx_volume()
    music_volume = AudioManager.get_bgm_volume()
