extends OptionButton


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("item_selected", selection_changed)

func settings_loaded(settings: SettingsResource):
	var selection = 2
	match settings.vsync_mode:
		SettingsResource.VSyncModes.VSYNC_ENABLED:
			selection = 1
		SettingsResource.VSyncModes.VSYNC_DISABLED:
			selection = 2
		SettingsResource.VSyncModes.VSYNC_ADAPTIVE:
			selection = 0
	selection_changed(selection)

func selection_changed(new_selection: int):
	match new_selection:
		0:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
		1:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		2:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	selected = new_selection