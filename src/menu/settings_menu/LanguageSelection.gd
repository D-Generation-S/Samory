extends OptionButton

signal language_changed(new_language_id: int)

func _ready():
	connect("item_selected", selection_changed)
	
func settings_loaded(settings: SettingsResource):
	selected = settings.language

func selection_changed(selection: int):
	match selection:
		0: 
			TranslationServer.set_locale("en")
		1: 
			TranslationServer.set_locale("de_DE")
	GlobalGameManagerAccess.get_game_manager().translate_built_in_decks()
	language_changed.emit(selection)