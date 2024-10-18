extends Node2D

class_name GameManager

signal loading_message(message: String)

@export var main_menu_template: PackedScene
@export var build_in_decks: Array[MemoryDeckResource]
@export var game_scene: PackedScene
@export var loading_screen_template: PackedScene

var inital_menu_shown = false


# Called when the node enters the scene tree for the first time.
func _ready():
	open_menu(loading_screen_template)
	loading_message.emit("LOAD_DECKS")
	if OS.has_feature("web"):
		loading_data_done()
	else:
		GlobalSystemDeckManager.reload_system_decks()
		GlobalSystemDeckManager.loading_system_decks_done.connect(loading_data_done)
	
	translate_built_in_decks()

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
