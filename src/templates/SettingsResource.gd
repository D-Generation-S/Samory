class_name SettingsResource extends Resource

@export var fullscreen: bool = false
@export var vsync_active: bool = false
@export var load_custom_decks: bool = true
@export var language_code: String = "en"
@export var tutorial: TutorialResource = TutorialResource.new()
@export var auto_close_popup_shown: bool = false
@export var auto_close_round: bool = true
@export var close_round_after_seconds: float = 3
@export_range(0,1) var master_volume: float = 1
@export_range(0,1) var effect_volume: float = 1
@export_range(0,1) var music_volume: float = 1
