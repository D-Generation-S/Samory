extends Node2D

class_name GameManager

signal loading_message(message: String)

@export var main_menu_template: PackedScene
@export var build_in_decks: Array[MemoryDeckResource]
@export var game_scene: PackedScene
@export var loading_screen_template: PackedScene
@export var master_bus: String= "Master"
@export var effect_bus: String= "sfx"
@export var music_bus: String= "music"

var inital_menu_shown = false


# Called when the node enters the scene tree for the first time.
func _ready():
	initial_settings_setup()
	reload_system_decks()
	translate_built_in_decks()

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

	AudioServer.set_bus_volume_db(master_bus_id, settings.master_volume)
	AudioServer.set_bus_volume_db(effect_bus_id, settings.effect_volume)
	AudioServer.set_bus_volume_db(music_bus_id, settings.music_volume)

func translate_built_in_decks():
	for deck in build_in_decks:
		deck.name = tr(deck.name)
		deck.description = tr(deck.description)
		for card in deck.cards:
			card.name = tr(card.name)
			card.description = tr(card.description)

func close_game():
	clear_all_nodes()
	open_menu(main_menu_template)

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
	clear_all_nodes()
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
	add_child(game_scene_node)  
	game_scene_node.set_players(players)


func get_available_decks() -> Array[MemoryDeckResource]:
	var return_array: Array[MemoryDeckResource] = []
	return_array.append_array(build_in_decks)
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
