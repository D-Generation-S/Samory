class_name GameManager extends Node2D



signal loading_message(message: String)
signal debug_mode(on: bool)

@export_group("Decks")
@export var build_in_decks: Array[MemoryDeckResource]

@export_group("Scene Templates")
@export var main_menu_template: PackedScene
@export var game_scene: PackedScene
@export var loading_screen_template: PackedScene

@export_group("Sound")
@export var master_bus: String= "Master"
@export var effect_bus: String= "sfx"
@export var music_bus: String= "music"

@export_group("Translations")
@export var loading_decks: TextTranslation

var translated_build_in_decks: Array[MemoryDeckResource] = []
var initial_menu_shown = false
var current_loading_node: Node = null
var is_debug = false


func _ready():
	get_viewport().content_scale_size = Vector2i(1920, 1080)
	
	
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
	initial_menu_shown = false
	current_loading_node = open_menu(loading_screen_template)
	loading_message.emit(loading_decks.key)
	var settings = SettingsRepository.load_settings()
	if OS.has_feature("web") or !settings.load_custom_decks:
		loading_data_done()
	else:
		GlobalSystemDeckManager.loading_system_decks_done.connect(loading_data_done)
		GlobalSystemDeckManager.reload_system_decks()

func initial_settings_setup():
	var settings: SettingsResource = SettingsRepository.load_settings()
	DisplayServer.window_set_mode(settings.window_mode)

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

func close_game_with_position(transition_start_position: Vector2):
	ScreenTransitionManager.transit_screen_with_position(main_menu_template, transition_start_position)

func close_game():
	close_game_with_position(Vector2.ZERO)

func open_additional_menu(scene: PackedScene) -> Node:
	if scene == null:
		printerr("No scene was provided!")
		return null
	var node = scene.instantiate()
	add_child(node)
	return node;

func open_menu(scene: PackedScene) -> Node:
	if scene == null:
		printerr("No scene was provided!")
		return null
	clear_all_nodes()
	var new_node: Node = open_additional_menu(scene)
	
	for child in get_children():
		if child is LoadingScreen:
			loading_message.connect(child.set_screen_message)
			child.set_follow_up_screen(main_menu_template)
			child.loaded_scene.connect(func(node_to_load: Node):
				if node_to_load.get_parent() != null:
					node_to_load.reparent(self)
			)

	return new_node;

func play_game_with_position(players: Array[PlayerResource], deck: MemoryDeckResource, click_position: Vector2):
	for player in players:
		player.score = 0
	load_game(deck, players, click_position)

func play_game(players: Array[PlayerResource], deck: MemoryDeckResource):
	play_game_with_position(players, deck, Vector2.ZERO)

func quit_game():
	get_tree().quit()

func load_game(card_deck: Resource, players: Array[PlayerResource], click_position: Vector2):
	var current_player_id = 0
	for player in players:
		player.id = current_player_id
		current_player_id = current_player_id + 1
	var game_scene_node = game_scene.instantiate() as MemoryGame
	game_scene_node.card_deck = card_deck

	
	game_scene_node.ready.connect(func():
		game_scene_node.set_players(players)
		game_scene_node.start_loading_data()
		)
	
	
	var loading_screen = loading_screen_template.instantiate() as LoadingScreen
	loading_screen.set_follow_up_node(game_scene_node)
	game_scene_node.card_loading_done.connect(loading_screen.destroy)

	await ScreenTransitionManager.transit_screen_by_node_with_position(loading_screen, click_position, false)
	get_tree().root.add_child(game_scene_node)

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
	if initial_menu_shown:
		return
	GlobalSoundManager.stop_all_sounds()
	initial_menu_shown = true
	if current_loading_node == null:
		return

	if current_loading_node.has_method("destroy"):
		current_loading_node.call("destroy")
		return
	current_loading_node.queue_free()
	#open_menu(main_menu_template)
