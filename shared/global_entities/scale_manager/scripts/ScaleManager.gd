extends Node

var _ui_zoom: float = 1
var _custom_scale: float = 1

func _ready() -> void:
	var game_manager: GameManager = GlobalGameManagerAccess.get_game_manager()
	game_manager.resolution_changed.connect(_scaling_changed)
	SettingsRepository.settings_updated.connect(_settings_changed)

	await game_manager.ready

func _settings_changed(new_settings: SettingsResource) -> void:
	update_ui_scale(new_settings.ui_scale_factor)

func update_ui_scale(new_scale_factor: float) -> void:
	_custom_scale = new_scale_factor
	_update_ui_zoom()

func _scaling_changed(_viewport_resolution: Vector2i, ui_zoom: float, _camera_zoom: float) -> void:
	_ui_zoom = ui_zoom
	_update_ui_zoom()

func _update_ui_zoom() -> void:
	get_window().content_scale_factor = _ui_zoom * _custom_scale