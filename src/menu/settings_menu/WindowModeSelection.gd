extends OptionButton

enum modes {
	FULLSCREEN = 0,
	BORDERLESS = 1,
	MAXIMIZED = 2,
}

signal window_mode_changed(new_mode: DisplayServer.WindowMode)

var _current_settings: SettingsResource = null

func _ready():
	if OS.has_feature("web"):
		remove_item(modes.BORDERLESS)
	item_selected.connect(_on_item_was_selected)
	

func settings_loaded(settings: SettingsResource):
	_current_settings = settings
	set_default_option()

func set_default_option():
	selected = modes.MAXIMIZED
	match _current_settings.window_mode:
		DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
			selected = modes.FULLSCREEN
		DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED:
			selected = modes.MAXIMIZED
		DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			selected = modes.BORDERLESS

func _change_window_mode(mode: DisplayServer.WindowMode):
	DisplayServer.window_set_mode(mode)

func _on_item_was_selected(index: int):
	var mode := DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED
	match index:
		modes.FULLSCREEN:
			mode = DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN
		modes.BORDERLESS:
			mode = DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
		modes.MAXIMIZED:
			mode = DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED
	print(mode)
	_change_window_mode(mode)
	window_mode_changed.emit(mode)