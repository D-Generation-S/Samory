class_name SettingsResource extends Save

@export var window_mode: DisplayServer.WindowMode
@export var vsync_active: bool = false
@export var load_custom_decks: bool = true
@export var language_code: String = "en"
@export var tutorials: Dictionary = {}
@export var tutorial_aborted: bool = false
@export var auto_close_popup_shown: bool = false
@export var auto_close_round: bool = true
@export var close_round_after_seconds: float = 3
@export_range(0.2, 3) var ui_scale_factor: float = 1

@export_group("Audio")
@export_range(0,1) var master_volume: float = 1
@export_range(0,1) var effect_volume: float = 1
@export_range(0,1) var music_volume: float = 0.15

@export_group("Multiplayer")
@export var default_multiplayer_name: String = ""
@export var last_used_ip: String = "127.0.0.1"