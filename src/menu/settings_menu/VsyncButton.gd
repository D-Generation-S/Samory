extends OptionButton


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func settings_loaded(settings: SettingsResource):
	match settings.vsync_mode:
		SettingsResource.VSyncModes.VSYNC_ENABLED:
			selected = 1
		SettingsResource.VSyncModes.VSYNC_DISABLED:
			selected = 2
		SettingsResource.VSyncModes.VSYNC_ADAPTIVE:
			selected = 0