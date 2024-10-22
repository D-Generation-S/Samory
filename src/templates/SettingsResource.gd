class_name SettingsResource extends Resource

@export var fullscreen: bool = false
@export var vsync_active: bool = false
@export var load_custom_decks: bool = true
@export_range(0,1) var master_volume: float = 1
@export_range(0,1) var effect_volume: float = 1
@export_range(0,1) var music_volume: float = 1