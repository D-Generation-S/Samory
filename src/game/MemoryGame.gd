extends Node2D

class_name MemoryGame

signal round_start()
signal freeze_round()
signal round_end()
signal game_has_endet()

signal player_scored(player_id: int)
signal play_sound(stream: AudioStream)

const CARDS_PER_PLAYER = 2

@export var separation: int = 5
@export var card_deck: Resource
@export var card_template: PackedScene
@export var gui_node: CanvasLayer
@export var finished_game_template: PackedScene

var current_game_state
var player_node: PlayerManager
var triggered_cards: int
var removed_cards = 0

var game_manager: GameManager;

# Called when the node enters the scene tree for the first time.
func _ready():
	game_manager = get_tree().root.get_child(0) as GameManager
	connect("play_sound", game_manager.play_sound_effect)
	var card_pool = card_deck.cards
	var additional_cards = card_deck.cards
	card_pool = numberize_cards_from_pool(card_pool)
	player_node = get_node("%Players")
	card_pool.append_array(numberize_cards_from_pool(additional_cards))
	for i in range((randi() % 20) + 1):
		card_pool.shuffle()

	var current_card = 0
	var side_length = floor(sqrt(card_pool.size()));

	var row_count = side_length
	var column_count = side_length

	while row_count * column_count < card_pool.size():
		print("fix column count")
		column_count = column_count + 1
		print(column_count)

	for y in range(row_count):
		for x in range(column_count):
			var card_template_node = card_template.instantiate() as Node2D
			card_template_node.card_deck = card_deck
			if current_card >= card_pool.size():
				continue
			card_template_node.memory_card = card_pool[current_card]
			add_child(card_template_node)

			var height = card_template_node.get_height()
			var width = card_template_node.get_width()

			var height_to_set = y * height + y * separation
			var width_to_set = x * width + x * separation

			card_template_node.position = Vector2(width_to_set, height_to_set)
			card_template_node.connect("card_triggered", card_was_triggered)
			current_card = current_card + 1
	start_round_now()


func numberize_cards_from_pool(card_pool) -> Array:
	var cards: Array
	for i in range(card_pool.size()):
		var card = card_pool[i] as MemoryCardResource
		card.set_id(i)
		cards.append(card)
	return cards

func card_was_triggered():
	triggered_cards = triggered_cards + 1
	if cards_where_identically():
		for child in get_children():
			if child is CardTemplate and child.is_turned():
				child.remove_from_board()
		triggered_cards = 0
		removed_cards = removed_cards + 1
		var current_player = player_node.get_current_player()
		player_scored.emit(current_player.id)
		check_card_state()
		return
	if triggered_cards >= CARDS_PER_PLAYER:
		freeze_round_now()

func cards_where_identically() -> bool:
	var clicked_cards: Array[CardTemplate]
	for child in get_children():
		if child is CardTemplate and child.is_turned():
			clicked_cards.append(child as CardTemplate)

	if clicked_cards.size() != 2:
		return false
		
	print("Check cards")
	var first_card = clicked_cards[0]
	var second_card = clicked_cards[1]

	return first_card.get_card_id() == second_card.get_card_id()

func start_round_now():
	print("Start Round")
	current_game_state = GameState.ROUND_START
	round_start.emit()
	triggered_cards = 0

func freeze_round_now():
	print("Freeze Round")
	current_game_state = GameState.ROUND_FREEZE
	freeze_round.emit()

func end_round_now():
	current_game_state = GameState.ROUND_END
	print("End Round")
	round_end.emit()
	start_round_now()

func check_card_state():
	if removed_cards >= card_deck.cards.size():
		show_game_end_screen()

func show_game_end_screen():
	game_has_endet.emit()	
	var finish_node = finished_game_template.instantiate() as GameFinished
	finish_node.set_player_manager(player_node)
	finish_node.set_played_deck(card_deck)
	gui_node.add_child(finish_node)

func set_players(players_of_game: Array[PlayerResource]):
	player_node.add_players(players_of_game)

func get_current_game_phase() -> int:
	return current_game_state

func play_game_sound(stream: AudioStream):
	if stream == null:
		return
	play_sound.emit(stream)