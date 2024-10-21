class_name SettingsResource extends Resource

enum VSyncModes 
{
	VSYNC_ENABLED,
	VSYNC_DISABLED,
	VSYNC_ADAPTIVE
}
@export var fullscreen: bool = false
@export var vsync_mode: VSyncModes = VSyncModes.VSYNC_DISABLED
@export var load_custom_decks: bool = true
@export_range(0,1) var master_volume: float = 1
@export_range(0,1) var effect_volume: float = 1
@export_range(0,1) var music_volume: float = 1