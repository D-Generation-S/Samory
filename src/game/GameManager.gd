class_name GameManager extends Node2D



signal loading_message(message: String)
signal debug_mode(on: bool)

@export var main_menu_template: PackedScene
@export var build_in_decks: Array[MemoryDeckResource]
@export var game_scene: PackedScene
@export var loading_screen_template: PackedScene
@export var master_bus: String= "Master"
@export var effect_bus: String= "sfx"
@export var music_bus: String= "music"

var translated_build_in_decks: Array[MemoryDeckResource] = []
var inital_menu_shown = false
var is_debug = false


func _ready():
	var counter: int = 0
	for deck in build_in_decks:
		deck.id = counter
		counter = counter + 1

	initial_settings_setup()
	reload_system_decks()
	translate_built_in_decks()

	MusicManager.start_playing()

func _process(_delta):
	if OS.is_debug_build() and Input.is_action_just_pressed("toggle_debug"):
		is_debug = !is_debug
		debug_mode.emit(is_debug)

func reload_system_decks():
	inital_menu_shown = false
	open_menu(loading_screen_template)
	loading_message.emit("LOAD_DECKS")
	var settings = SettingsRepository.load_settings()
	if OS.has_feature("web") or !settings.load_custom_decks:
		loading_data_done()
	else:
		GlobalSystemDeckManager.loading_system_decks_done.connect(loading_data_done)
		GlobalSystemDeckManager.reload_system_decks()

func initial_settings_setup():
	var settings: SettingsResource = SettingsRepository.load_settings()

	if settings.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	if settings.vsync_active:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)

	var master_bus_id = AudioServer.get_bus_index(master_bus)
	var effect_bus_id = AudioServer.get_bus_index(effect_bus)
	var music_bus_id = AudioServer.get_bus_index(music_bus)

	AudioServer.set_bus_volume_db(master_bus_id, linear_to_db(settings.master_volume))
	AudioServer.set_bus_volume_db(effect_bus_id, linear_to_db(settings.effect_volume))
	AudioServer.set_bus_volume_db(music_bus_id, linear_to_db(settings.music_volume))
		
	TranslationServer.set_locale(settings.language_code)

func translate_built_in_decks():
	translated_build_in_decks = []
	for deck in build_in_decks:
		var new_deck = deck.duplicate() as MemoryDeckResource
		new_deck.name = tr(deck.name)
		new_deck.description = tr(deck.description)
		var cards = deck.cards
		new_deck.cards.clear()
		for card in cards:
			var card_copy = card.duplicate()
			card_copy.name = tr(card.name)
			card_copy.description = tr(card.description)
			new_deck.cards.append(card_copy)
		translated_build_in_decks.append(new_deck)

func close_game():
	ScreenTransitionManager.transit_screen(main_menu_template)

func open_menu(scene: PackedScene):
	if scene == null:
		printerr("No scene was provided!")
		return
	clear_all_nodes()
	var node = scene.instantiate()
	add_child(node)

	
	for child in get_children():
		if child is LoadingScreen:
			loading_message.connect(child.set_screen_message)

func play_game(players: Array[PlayerResource], deck: MemoryDeckResource):
	for player in players:
		player.score = 0
	load_game(deck, players)

func quit_game():
	get_tree().quit()

func load_game(card_deck: Resource, players: Array[PlayerResource]):
	var current_player_id = 0
	for player in players:
		player.id = current_player_id
		current_player_id = current_player_id + 1
	var game_scene_node = game_scene.instantiate() as MemoryGame
	game_scene_node.card_deck = card_deck
	game_scene_node.add_to_group("active_scene")
	#for scene in get_tree().get_nodes_in_group("active_scene"):
	#	scene.queue_free()
	#add_child(game_scene_node)  
	var transit = ScreenTransitionManager.transit_screen_by_node(game_scene_node)
	transit.scene_instantiated.connect(func(_scene): 
		game_scene_node.set_players(players)
		)
	transit.animation_done.connect(func(_scene):
		game_scene_node.start_loading_data()
		)
	#game_scene_node.set_players(players)


func get_available_decks() -> Array[MemoryDeckResource]:
	var return_array: Array[MemoryDeckResource] = []
	return_array.append_array(translated_build_in_decks)
	return_array.append_array(GlobalSystemDeckManager.get_system_decks())
	return return_array

func clear_all_nodes():
		for child in get_children():
			if child.name == "GlobalFixedNode" or child.is_in_group("static"):
				continue
			remove_child(child)

func loading_data_done():
	if inital_menu_shown:
		return
	GlobalSoundManager.stop_all_sounds()
	inital_menu_shown = true
	open_menu(main_menu_template)
