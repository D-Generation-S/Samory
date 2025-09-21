extends Label

@export_enum("Resolution", "UI Zoom", "Zoom Multiplier") var type: int

var _game_manager: GameManager

func _ready():
	if !OS.is_debug_build():
		queue_free()
	_game_manager = GlobalGameManagerAccess.get_game_manager()
	_set_resolution()
	_set_ui_zoom()
	_set_zoom_multiplier()

	if text == "":
		queue_free()

func _set_resolution():
	if type != 0:
		return
	var viewport: Vector2i = _game_manager._get_viewport_size()
	var real_viewport: Vector2i = get_viewport().content_scale_size
	text =  "Resolution: %s x %s (%s x %s)" % [real_viewport.x, real_viewport.y, viewport.x, viewport.y]

func _set_ui_zoom():
	if type != 1:
		return
	var real_zoom = _game_manager.get_ui_scale()
	text = "UI Zoom: %s" % real_zoom

func _set_zoom_multiplier():
	if type != 2:
		return
	var zoom_multiplier = _game_manager.get_camera_zoom_adjustment()
	text = "Camera zoom factor: %s" % zoom_multiplier		