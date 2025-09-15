extends Node

@export var default_settings: SettingsResource

var loaded_settings: SettingsResource

const settings_file: String = "user://options.dat"

func load_settings() -> SettingsResource:
	if loaded_settings != null:
		return loaded_settings
	if !FileAccess.file_exists(settings_file):
		return default_settings

	var save_file = FileAccess.open(settings_file, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(save_file.get_as_text())
	save_file.close()
	var return_settings: SettingsResource = default_settings.duplicate()
	
	return_settings.fullscreen = data.get("fullscreen")
	return_settings.load_custom_decks = data.get("load_custom_decks")
	return_settings.vsync_active = data.get("vsync_active")
	return_settings.language_code = data.get("language", "en")
	return_settings.auto_close_popup_shown = data.get_or_add("auto_close_popup_shown", false)
	return_settings.auto_close_round = data.get_or_add("auto_close_round", true)
	return_settings.close_round_after_seconds = data.get_or_add("close_round_after_seconds", 3)
	return_settings.master_volume = data.get("master_volume")
	return_settings.effect_volume = data.get("effect_volume")
	return_settings.music_volume = data.get("music_volume")
	if data.has("completed_tutorials"):
		return_settings.tutorials = data.get("completed_tutorials") as Dictionary
	loaded_settings = return_settings
	return return_settings

func save_settings(settings: SettingsResource) -> bool:
	var data_to_save: Dictionary = {
		"fullscreen": settings.fullscreen,
		"vsync_active": settings.vsync_active,
		"language": settings.language_code,
		"load_custom_decks": settings.load_custom_decks,
		"auto_close_popup_shown": settings.auto_close_popup_shown,
		"auto_close_round": settings.auto_close_round,
		"close_round_after_seconds": settings.close_round_after_seconds,
		"master_volume": settings.master_volume,
		"effect_volume": settings.effect_volume,
		"music_volume": settings.music_volume,
		"tutorial_aborted": settings.tutorial_aborted,
		"completed_tutorials": settings.tutorials
	}

	var file = FileAccess.open(settings_file, FileAccess.WRITE)
	file.store_line(JSON.stringify(data_to_save))
	file.close()

	loaded_settings = null


	return load_settings() != null
