class_name GameManager extends Node2D

signal loading_message(message: String)
signal resolution_changed(resolution: Vector2i, ui_zoom: float, camera_zoom: float)
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

@export_group("debug")
@export var _debug_mobile: bool = false

var translated_build_in_decks: Array[MemoryDeckResource] = []
var initial_menu_shown: bool = false
var current_loading_node: Node = null
var is_debug: bool = false


var _viewport_size: Vector2i = Vector2i(1920, 1080)
var _ui_scale: float = 1
var _camera_zoom_factor: float = 1

var _deck_reload_connected: bool = false

func _ready() -> void:
	_calculate_resolution_values()
	get_viewport().content_scale_size = _viewport_size
	
	
	var counter: int = 0
	for deck: MemoryDeckResource in build_in_decks:
		deck.id = counter
		counter = counter + 1

	initial_settings_setup()
	reload_system_decks()
	translate_built_in_decks()

	MusicManager.start_playing()

func _calculate_resolution_values() -> void:
	if _debug_mobile || OS.has_feature("web_android") or OS.has_feature("web_ios"):
		_viewport_size = Vector2i(640, 360)
		_ui_scale = 0.3
		_camera_zoom_factor = 0.3
	
	resolution_changed.emit(_viewport_size, _ui_scale, _camera_zoom_factor)

func _get_viewport_size() -> Vector2i:
	return _viewport_size

func get_ui_scale() -> float:
	return _ui_scale

func get_camera_zoom_adjustment() -> float:
	return _camera_zoom_factor

func _process(_delta: float) -> void:
	if OS.is_debug_build() and Input.is_action_just_pressed("toggle_debug"):
		is_debug = !is_debug
		debug_mode.emit(is_debug)

func reload_system_decks() -> void:
	initial_menu_shown = false
	current_loading_node = open_menu(loading_screen_template)
	loading_message.emit(loading_decks.key)
	var settings: SettingsResource = SettingsRepository.load_settings()
	if OS.has_feature("web") or !settings.load_custom_decks:
		loading_data_done()
	else:
		if not _deck_reload_connected:
			_deck_reload_connected = true
			GlobalSystemDeckManager.loading_system_decks_done.connect(loading_data_done)
		GlobalSystemDeckManager.reload_system_decks()

func initial_settings_setup() -> void:
	var settings: SettingsResource = SettingsRepository.load_settings()
	DisplayServer.window_set_mode(settings.window_mode)

	var v_sync_mode: DisplayServer.VSyncMode = DisplayServer.VSYNC_ENABLED
	if not settings.vsync_active:
		v_sync_mode = DisplayServer.VSYNC_DISABLED

	DisplayServer.window_set_vsync_mode(v_sync_mode)

	var master_bus_id: int = AudioServer.get_bus_index(master_bus)
	var effect_bus_id: int = AudioServer.get_bus_index(effect_bus)
	var music_bus_id: int = AudioServer.get_bus_index(music_bus)

	AudioServer.set_bus_volume_db(master_bus_id, linear_to_db(settings.master_volume))
	AudioServer.set_bus_volume_db(effect_bus_id, linear_to_db(settings.effect_volume))
	AudioServer.set_bus_volume_db(music_bus_id, linear_to_db(settings.music_volume))
		
	TranslationServer.set_locale(settings.language_code)

func translate_built_in_decks() -> void:
	translated_build_in_decks = []
	for deck: MemoryDeckResource in build_in_decks:
		var new_deck: MemoryDeckResource = deck.duplicate_deep() as MemoryDeckResource
		new_deck.take_over_path(deck.resource_path)
		new_deck.name = tr(deck.name)
		new_deck.description = tr(deck.description)
		var cards: Array[MemoryCardResource] = deck.cards
		new_deck.cards.clear()
		for card: MemoryCardResource in cards:
			var card_copy: MemoryCardResource = card.duplicate_deep()
			card_copy.take_over_path(card.resource_path)
			card_copy.name = tr(card.name)
			card_copy.description = tr(card.description)
			new_deck.cards.append(card_copy)
		translated_build_in_decks.append(new_deck)

func close_game_with_position(transition_start_position: Vector2) -> void:
	ScreenTransitionManager.transit_screen_with_position(main_menu_template, transition_start_position)

func close_game() -> void:
	close_game_with_position(Vector2.ZERO)

func open_additional_menu(scene: PackedScene) -> Node:
	if scene == null:
		printerr("No scene was provided!")
		return null
	var node: Node = scene.instantiate()
	add_child(node)
	return node;

func open_menu(scene: PackedScene) -> Node:
	if scene == null:
		printerr("No scene was provided!")
		return null
	clear_all_nodes()
	var new_node: Node = open_additional_menu(scene)
	
	for child: Node in get_children():
		if child is LoadingScreen:
			loading_message.connect(child.set_screen_message)
			child.set_follow_up_screen(main_menu_template)
			child.loaded_scene.connect(func(node_to_load: Node) -> void:
				if node_to_load.get_parent() != null:
					node_to_load.reparent(self)
			)

	return new_node;

func play_network_game(players: Array[PlayerResource], deck: MemoryDeckResource, click_position: Vector2) -> void:
	for player: PlayerResource in players:
		player.score = 0
		
	_rpc_load_game.rpc(_build_network_game_package(players, deck, click_position))

func _build_network_game_package(players: Array[PlayerResource], deck: MemoryDeckResource, click_position: Vector2) -> Dictionary:
	var network_players: Array[Dictionary] = []
	for player: PlayerResource in players:
		network_players.append(player.get_network_data_set())
	return {
		"players": network_players,
		"deck-path": deck.resource_path,
		"click-position": {
			"x": click_position.x,
			"y": click_position.y,
		}
	}

func play_game_with_position(players: Array[PlayerResource], deck: MemoryDeckResource, click_position: Vector2) -> void:
	for player: PlayerResource in players:
		player.score = 0
	load_game(deck, players, click_position)

func play_game(players: Array[PlayerResource], deck: MemoryDeckResource) -> void:
	play_game_with_position(players, deck, Vector2.ZERO)

func quit_game() -> void:
	get_tree().quit()

@rpc("call_local", "reliable")
func _rpc_load_game(game_data: Dictionary) -> void:
	var players: Array[PlayerResource] = []
	for player_data: Dictionary in game_data["players"]:
		var player: PlayerResource = PlayerResource.new()
		player.name = player_data["name"]
		player.id = player_data["id"]
		player.score = player_data["score"]
		player.order_number = player_data["order"]
		if player_data["ai-path"] != "":
			player.ai_difficulty = load(player_data["ai-path"])

		players.append(player)
	
	var click_position: Vector2 = Vector2.ZERO
	var card_deck: MemoryDeckResource = load(game_data["deck-path"]) as MemoryDeckResource

	var game_scene_node: MemoryGame = game_scene.instantiate() as MemoryGame
	game_scene_node.set_is_multiplayer()
	game_scene_node.card_deck = card_deck
	game_scene_node.ready.connect(func() -> void:
		game_scene_node.set_players(players)
		if multiplayer.is_server():
			game_scene_node.start_loading_data()
	)

	var loading_screen: LoadingScreen = loading_screen_template.instantiate() as LoadingScreen
	loading_screen.set_follow_up_node(game_scene_node)
	game_scene_node.card_loading_done.connect(loading_screen.destroy)

	await ScreenTransitionManager.transit_screen_by_node_with_position(loading_screen, click_position, false)
	get_tree().root.add_child(game_scene_node)

func load_game(card_deck: Resource, players: Array[PlayerResource], click_position: Vector2) -> void:
	var current_player_id: int = 0
	for player: PlayerResource in players:
		player.id = current_player_id
		current_player_id = current_player_id + 1
	var game_scene_node: MemoryGame = game_scene.instantiate() as MemoryGame
	game_scene_node.card_deck = card_deck

	
	game_scene_node.ready.connect(func() -> void:
		game_scene_node.set_players(players)
		game_scene_node.start_loading_data()
		)
	
	
	var loading_screen: LoadingScreen = loading_screen_template.instantiate() as LoadingScreen
	loading_screen.set_follow_up_node(game_scene_node)
	game_scene_node.card_loading_done.connect(loading_screen.destroy)

	await ScreenTransitionManager.transit_screen_by_node_with_position(loading_screen, click_position, false)
	get_tree().root.add_child(game_scene_node)

func get_available_decks() -> Array[MemoryDeckResource]:
	var return_array: Array[MemoryDeckResource] = []
	return_array.append_array(translated_build_in_decks)
	return_array.append_array(GlobalSystemDeckManager.get_system_decks())
	for deck: MemoryDeckResource in return_array:
		deck.ready_up()
	return return_array

func clear_all_nodes() -> void:
		for child: Node in get_children():
			if child.name == "GlobalFixedNode" or child.is_in_group("static"):
				continue
			remove_child(child)

func loading_data_done() -> void:
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
