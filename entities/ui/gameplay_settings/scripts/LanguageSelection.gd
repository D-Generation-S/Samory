class_name LanguageSelection extends ClickableOptionButton

signal language_changed(new_language_code: String)

@export var should_grab_focus: bool = false

var _entry_dictionary: Dictionary[int, GameLanguage]

var _next_entry: int = 0

func _ready() -> void:
	super()
	_create_entries()
	LanguageManager.language_changed.connect(_update_item_names)
	if should_grab_focus:
		grab_focus()

func _create_entries() -> void:
	var languages: Array[GameLanguage] = LanguageManager.get_available_languages()
	if languages.is_empty():
		return
	for key: int in item_count:
		## Always remove the first entry
		remove_item(0)
	_next_entry = 0
	_entry_dictionary.clear()
	for game_language: GameLanguage in languages:
		_entry_dictionary.set(_next_entry, game_language)
		add_item(tr(game_language.display_name.key), _next_entry)
		if game_language.icon != null:
			set_item_icon(_next_entry, game_language.icon)
		_next_entry += 1
		
func settings_loaded(settings: SettingsResource) -> void:
	var key_index: int = 0
	for entry: GameLanguage in _entry_dictionary.values():
		if entry.iso_code == settings.language_code:
			key_index= _entry_dictionary.find_key(entry)
			if key_index == null or key_index < 0:
				key_index = 0
			break
	
	select(key_index)

func _selection_changed(selection: int) -> void:
	super(selection)
	var language_code: String = "en"
	var selected_language: GameLanguage = _entry_dictionary.get(selection)
	if selected_language != null:
		language_code = selected_language.iso_code

		LanguageManager.change_language(language_code)
		language_changed.emit(language_code)
		
func _update_item_names() -> void:
	for index: int in item_count:
		var id: int = get_item_id(index)
		var game_language: GameLanguage = _entry_dictionary.get(id)
		if game_language == null:
			continue
		
		set_item_text(index, tr(game_language.display_name.key))