extends Node

const LANGUAGE_CONFIG_ROOT: String = "res://shared/resources/languages/assets/"

signal language_changed()
signal language_iso_changed(iso_code: String)

var _available_languages: Array[GameLanguage] = []

func _ready() -> void:
	_load_game_languages()

func _load_game_languages() -> void:
	if _available_languages.size() > 0:
		return
	assert(DirAccess.dir_exists_absolute(LANGUAGE_CONFIG_ROOT), "Missing dir \"%s\"" % LANGUAGE_CONFIG_ROOT)
	for file_name: String in DirAccess.get_files_at(LANGUAGE_CONFIG_ROOT):
		if not file_name.ends_with(".tres"):
			continue
		var full_path: String = "%s%s" % [LANGUAGE_CONFIG_ROOT, file_name]
		var data: Resource = load(full_path)
		if data is GameLanguage:
			if _available_languages.any(func(language: GameLanguage) -> bool: return language.iso_code == data.iso_code) \
				or not data.is_valid():
				continue
			_available_languages.append(data)
			print_debug("Language %s with iso code \"%s\" added" % [data.display_name.key, data.iso_code])

	_available_languages.sort_custom(_sort_languages)

func get_available_languages() -> Array[GameLanguage]:
	return _available_languages.duplicate()

func _sort_languages(a: GameLanguage, b: GameLanguage) -> int:
	return a.order_id - b.order_id

func change_language(new_iso: String) -> void:
	for language: GameLanguage in _available_languages:
		if language.iso_code == new_iso:
			_switch_language(language)
			return
	push_warning("Tried to switch to unknown language code %s" % new_iso)

func _switch_language(language: GameLanguage) -> void:
	if language == null or not language.is_valid():
		return
	TranslationServer.set_locale(language.iso_code)
	language_changed.emit()
	language_iso_changed.emit(language.iso_code)
