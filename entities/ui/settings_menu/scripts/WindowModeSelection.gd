extends ClickableOptionButton

enum modes {
	FULLSCREEN = 0,
	BORDERLESS = 1,
	MAXIMIZED = 2,
}

signal window_mode_changed(new_mode: DisplayServer.WindowMode)

var _current_settings: SettingsResource = null

func _ready() -> void:
	super()
	if OS.has_feature("web"):
		remove_item(modes.BORDERLESS)
	

func settings_loaded(settings: SettingsResource) -> void:
	_current_settings = settings
	set_default_option()

func set_default_option() -> void:
	selected = modes.MAXIMIZED
	match _current_settings.window_mode:
		DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
			selected = modes.FULLSCREEN
		DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED:
			selected = modes.MAXIMIZED
		DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			selected = modes.BORDERLESS

func _change_window_mode(mode: DisplayServer.WindowMode) -> void:
	DisplayServer.window_set_mode(mode)

func _selection_changed(selection: int) -> void:
	var mode: DisplayServer.WindowMode = DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED
	match selection:
		modes.FULLSCREEN:
			mode = DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN
		modes.BORDERLESS:
			mode = DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
		modes.MAXIMIZED:
			mode = DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED
	_change_window_mode(mode)
	window_mode_changed.emit(mode)