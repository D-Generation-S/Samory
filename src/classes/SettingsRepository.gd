extends Node

signal settings_updated(setings: SettingsResource)

@export var default_settings: SettingsResource

var loaded_settings: SettingsResource

const settings_file: String = "user://options.dat"

func load_settings() -> SettingsResource:
	if loaded_settings != null:
		return loaded_settings
	if !FileAccess.file_exists(settings_file):
		return default_settings

	var save_file: FileAccess = FileAccess.open(settings_file, FileAccess.READ)
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
	
	settings_updated.emit(return_settings)
	return return_settings

func save_settings(settings: SettingsResource) -> bool:
	var data_to_save: Dictionary = {
		"window_mode": settings.window_mode,
		"vsync_active": settings.vsync_active,
		"ui_scale_factor": settings.ui_scale_factor,
		"language": settings.language_code,
		"load_custom_decks": settings.load_custom_decks,
		"auto_close_popup_shown": settings.auto_close_popup_shown,
		"auto_close_round": settings.auto_close_round,
		"close_round_after_seconds": settings.close_round_after_seconds,
		"master_volume": settings.master_volume,
		"effect_volume": settings.effect_volume,
		"music_volume": settings.music_volume,
		"tutorial_aborted": settings.tutorial_aborted,
		"completed_tutorials": settings.tutorials,
		"multiplayer_name": settings.default_multiplayer_name,
		"last_used_ip": settings.last_used_ip
	}

	var file: FileAccess = FileAccess.open(settings_file, FileAccess.WRITE)
	var indent: String = ""
	if OS.is_debug_build():
		indent = "\t"
	file.store_line(JSON.stringify(data_to_save, indent))
	file.close()

	loaded_settings = null
	return load_settings() != null

func save_current_settings() -> void:
	var settings: SettingsResource = load_settings()
	save_settings(settings)