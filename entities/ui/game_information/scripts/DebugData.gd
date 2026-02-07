extends Label

@export_enum("Resolution", "UI Zoom", "Zoom Multiplier", "V Sync Mode", "Screen Mode") var type: int

var _game_manager: GameManager

func _ready() -> void:
	if !OS.is_debug_build():
		queue_free()
	_game_manager = GlobalGameManagerAccess.get_game_manager()
	_set_resolution()
	_set_ui_zoom()
	_set_zoom_multiplier()
	_set_vsync_mode()
	_set_screen_mode()

	if text == "":
		queue_free()

func _set_resolution() -> void:
	if type != 0:
		return
	var viewport: Vector2i = _game_manager._get_viewport_size()
	var real_viewport: Vector2i = get_viewport().content_scale_size
	text =  "Resolution: %s x %s (%s x %s)" % [real_viewport.x, real_viewport.y, viewport.x, viewport.y]

func _set_ui_zoom() -> void:
	if type != 1:
		return
	text = "UI Zoom: %s" % _game_manager.get_ui_scale()

func _set_zoom_multiplier() -> void:
	if type != 2:
		return
	text = "Camera zoom factor: %s" % _game_manager.get_camera_zoom_adjustment()		

func _set_vsync_mode() -> void:
	if type != 3:
		return
	text = "VSync: %s" % (DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED)

func _set_screen_mode() -> void:
	if type != 4:
		return
	text = "Screen Mode: %s" % DisplayServer.window_get_mode()