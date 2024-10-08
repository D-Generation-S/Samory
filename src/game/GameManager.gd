extends Node2D

class_name GameManager

@export var main_menu_template: PackedScene
@export var build_in_decks: Array[MemoryCardResource]
@export var game_scene: PackedScene

var system_decks: Array[MemoryDeckResource]

# Called when the node enters the scene tree for the first time.
func _ready():
	reload_system_decks()
	open_menu(main_menu_template)

func close_game():
	remove_child(get_child(0))
	open_menu(main_menu_template)

func open_menu(scene: PackedScene):
	if scene == null:
		printerr("No scene was provided!")
		return
	clear_all_nodes()
	var node = scene.instantiate()
	add_child(node)

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
	var game_scene_node = game_scene.instantiate()
	game_scene_node.card_deck = card_deck
	add_child(game_scene_node)  
	game_scene_node.set_players(players)

func reload_system_decks():
	system_decks = []
	var deck_loader = DeckLoader.new() as DeckLoader
	for deck in deck_loader.list_decks():
		var loaded_deck = deck_loader.load_deck(deck)
		if loaded_deck != null:
			system_decks.append(loaded_deck)
	print(system_decks)

func get_available_decks() -> Array[MemoryDeckResource]:
	var return_array: Array[MemoryDeckResource] = []
	return_array.append_array(build_in_decks)
	return_array.append_array(system_decks)
	return return_array

func clear_all_nodes():
		for child in get_children():
			if child.name == "GlobalFixedNode":
				continue
			remove_child(child)
