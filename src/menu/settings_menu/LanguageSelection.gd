extends OptionButton

signal language_changed(new_language_code: int)

func _ready():
	connect("item_selected", selection_changed)
	
func settings_loaded(settings: SettingsResource):
	match settings.language_code:
		"en":
			selected = 0
		"de_DE":
			selected = 1

func selection_changed(selection: int):
	var language_code = "en"
	match selection:
		0: 
			language_code = "en"
		1: 
			language_code = "de_DE"
	TranslationServer.set_locale(language_code)
	GlobalGameManagerAccess.get_game_manager().translate_built_in_decks()
	language_changed.emit(language_code)