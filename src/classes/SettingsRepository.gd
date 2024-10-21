extends Node

@export var default_settings: SettingsResource

func load_settings() -> SettingsResource:
    return default_settings

func save_settings(settings: SettingsRepository) -> bool:
    return false
