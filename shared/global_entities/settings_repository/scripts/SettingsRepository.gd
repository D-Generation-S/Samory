extends Node

signal settings_updated(settings: SettingsResource)

@export var default_settings: SettingsResource

var loaded_settings: SettingsResource

const settings_file: String = "user://options.tres"
const legacy_settings_file: String = "user://options.dat"

func load_settings() -> SettingsResource:
	if loaded_settings != null:
		return loaded_settings
	if FileAccess.file_exists(legacy_settings_file):
		convert_legacy_setting()

	if !FileAccess.file_exists(settings_file):
		return default_settings

	var return_settings: SettingsResource = Save._impl_load(settings_file) as SettingsResource
	if return_settings == null:
		return_settings = default_settings.duplicate_deep()

	settings_updated.emit(return_settings)
	return return_settings

func save_settings(settings: SettingsResource) -> bool:
	return settings.save(settings_file)

func convert_legacy_setting() -> void:
	var settings: SettingsResource = load_legacy_setting()
	if settings.save(settings_file):
		DirAccess.remove_absolute(legacy_settings_file)

func load_legacy_setting() -> SettingsResource:
	if not FileAccess.file_exists(legacy_settings_file):
		return null

	var save_file: FileAccess = FileAccess.open(legacy_settings_file, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(save_file.get_as_text())
	save_file.close()
	var return_settings: SettingsResource = default_settings.duplicate_deep()
	
	return_settings.window_mode = data.get_or_add("window_mode", DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED)
	return_settings.load_custom_decks = data.get("load_custom_decks")
	return_settings.vsync_active = data.get("vsync_active")
	return_settings.ui_scale_factor = data.get_or_add("ui_scale_factor", 1)
	return_settings.language_code = data.get("language", "en")
	return_settings.auto_close_popup_shown = data.get_or_add("auto_close_popup_shown", false)
	return_settings.auto_close_round = data.get_or_add("auto_close_round", true)
	return_settings.close_round_after_seconds = data.get_or_add("close_round_after_seconds", 3)
	return_settings.master_volume = data.get("master_volume")
	return_settings.effect_volume = data.get("effect_volume")
	return_settings.music_volume = data.get("music_volume")
	return_settings.tutorial_aborted = data.get_or_add("tutorial_aborted", false)
	if data.has("completed_tutorials"):
		return_settings.tutorials = data.get("completed_tutorials") as Dictionary

	return_settings.master_volume = clampf(return_settings.master_volume, 0, 1)
	return_settings.effect_volume = clampf(return_settings.effect_volume, 0, 1)
	return_settings.music_volume = clampf(return_settings.music_volume, 0, 1)

	return_settings.default_multiplayer_name = data.get_or_add("multiplayer_name", "")
	return_settings.last_used_ip = data.get_or_add("last_used_ip", "127.0.0.1")
	
	loaded_settings = return_settings
	
	return loaded_settings

func save_current_settings() -> void:
	var settings: SettingsResource = load_settings()
	save_settings(settings)