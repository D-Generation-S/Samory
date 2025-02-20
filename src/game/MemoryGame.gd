extends Node2D

class_name MemoryGame

signal game_state_changed(game_state: int)

signal game_has_endet()
signal game_paused(is_paused: bool)
signal card_loading_done()

signal card_triggered(game_state: int, clicked_cards: Array[CardTemplate])
signal identical_cards(first_card_point: Point, set_icon_modulatecard_point: Point)

signal player_scored(player_id: int)

const CARDS_PER_PLAYER = 2

@export var card_lay_sounds: Array[AudioStream] = []
@export var seconds_to_lay_cards: float = 0.25

@export var separation: int = 25
@export var card_deck: Resource
@export var card_template: PackedScene
@export var gui_node: CanvasLayer
@export var finished_game_template: PackedScene
@export var game_menu_template: PackedScene

@export var card_target_node: Node2D

@export var game_nodes_to_show: Array[Node]
@export var loading_scene: LoadingScreen

var current_game_state
var player_node: PlayerManager
var triggered_cards: int
var removed_cards = 0

var load_thread: Thread = null
var current_sound_timer = 0

var paused: bool = false

func _ready():
	current_sound_timer = seconds_to_lay_cards
	load_thread = Thread.new()
	load_thread.start(build_card_layout.bind(card_deck, card_template, separation))
	player_node = get_node("%Players")
	
	loading_scene.set_screen_message("PLACING_CARDS", true)

func _process(delta):
	check_if_still_paused()
	if current_game_state == GameState.ROUND_END:
		check_if_round_complete()
	if current_game_state == GameState.ROUND_FREEZE:
		check_if_round_can_be_closed()
	if !is_node_ready() or !is_loading():
		return
	current_sound_timer = current_sound_timer + delta
	if current_sound_timer < seconds_to_lay_cards:
		return

	current_sound_timer = current_sound_timer - seconds_to_lay_cards
	var still_loading = load_thread.is_alive()
	if !still_loading:
		current_sound_timer = 0
		var cards = load_thread.wait_to_finish() as Array[CardTemplate]
		for card in cards:
			card_target_node.add_child(card)
			card.card_triggered.connect(card_was_triggered)
		load_thread = null
		card_loading_done.emit()
		start_round_now()
		
		loading_scene.queue_free()
		for node in game_nodes_to_show:
			if node is Node2D:
				node.visible = true 
			if node is CanvasLayer:
				node.visible = true
		return

	if card_lay_sounds.size() == 0:
		return

	var sound_index = randi() % card_lay_sounds.size()
	play_game_sound(card_lay_sounds[sound_index])

func is_loading() -> bool:
	return load_thread != null

func check_if_round_can_be_closed():
	var all_cards_shown = true
	for node in card_target_node.get_children():
		if node is CardTemplate and node.is_turned():
			if !node.card_is_fully_shown():
				all_cards_shown = false
	if all_cards_shown:
		round_closed_now()

func build_card_layout(deck_of_cards: MemoryDeckResource,
					   template: PackedScene,
					   card_separation: int
					   ) -> Array[CardTemplate]:
	var return_cards: Array[CardTemplate] = []

	var card_pool = deck_of_cards.cards
	var additional_cards = deck_of_cards.cards
	card_pool = numberize_cards_from_pool(card_pool)
	card_pool.append_array(numberize_cards_from_pool(additional_cards))
	for i in range((randi() % 20) + 1):
		card_pool.shuffle()

	var current_card = 0
	var side_length = floor(sqrt(card_pool.size()))

	var row_count = side_length
	var column_count = side_length

	while row_count * column_count < card_pool.size():
		column_count = column_count + 1

	for y in range(row_count):
		for x in range(column_count):
			var card_template_node = template.instantiate() as CardTemplate
			card_template_node.card_deck = deck_of_cards
			if current_card >= card_pool.size():
				print("exceed pool!")
				continue
			card_template_node.memory_card = card_pool[current_card]
			var height = card_template_node.get_height()
			var width = card_template_node.get_width()
			var height_to_set = y * height + y * card_separation
			var width_to_set = x * width + x * card_separation
			card_template_node.position = Vector2(width_to_set, height_to_set)
			card_template_node.grid_position = Point.new(x, y)
			
			return_cards.append(card_template_node)
			current_card = current_card + 1
	return return_cards

func numberize_cards_from_pool(card_pool) -> Array:
	var cards: Array
	for i in range(card_pool.size()):
		var card = card_pool[i] as MemoryCardResource
		card.set_id(i)
		cards.append(card)
	return cards

func card_was_triggered():
	if current_game_state == GameState.ROUND_END:
		return
	triggered_cards = triggered_cards + 1
	
	var clicked_cards: Array[CardTemplate] = get_clicked_cards()
	card_triggered.emit(current_game_state, clicked_cards)
	if cards_where_identically():
		for child in card_target_node.get_children():
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
		return

func cards_where_identically() -> bool:
	var clicked_cards: Array[CardTemplate] = get_clicked_cards()

	if clicked_cards.size() != 2:
		return false
		
	var first_card = clicked_cards[0]
	var second_card = clicked_cards[1]

	var identical = first_card.get_card_id() == second_card.get_card_id()
	if identical:
		identical_cards.emit(first_card.grid_position, second_card.grid_position)
	return identical

func get_clicked_cards() -> Array[CardTemplate]:
	var clicked_cards: Array[CardTemplate]
	for child in card_target_node.get_children():
		if child is CardTemplate and child.is_turned() and !child.is_getting_removed():
			clicked_cards.append(child as CardTemplate)
	return clicked_cards

func start_round_now():
	print("Start Round")
	current_game_state = GameState.ROUND_START
	game_state_changed.emit(current_game_state)
	triggered_cards = 0

func freeze_round_now():
	print("Freeze Round")
	current_game_state = GameState.ROUND_FREEZE
	game_state_changed.emit(current_game_state)

func round_closed_now():
	print("Closing round")
	current_game_state = GameState.PREPARE_ROUND_END
	game_state_changed.emit(current_game_state)

func end_round_now():
	print("End Round")
	current_game_state = GameState.ROUND_END
	game_state_changed.emit(current_game_state)

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

## Deprecated: Use GLobalSoundManager instead
func play_game_sound(stream: AudioStream):
	if stream == null:
		return
	GlobalSoundManager.play_sound_effect(stream)

func show_game_menu():
	paused = true
	game_paused.emit(true)
	var menu = game_menu_template.instantiate() as GamePauseMenu
	gui_node.add_child(menu)

func check_if_still_paused():
	if !paused:
		return
	var pause_complete = true
	for node in gui_node.get_children():
		if node is GamePauseMenu:
			pause_complete = false
			break
	if pause_complete:
		paused = false
		continue_game()

func continue_game():
	game_paused.emit(false)

func check_if_round_complete():
	var card_not_hidden = false
	for node in card_target_node.get_children():
		if node is CardTemplate:
			if !node.card_is_hidden():
				card_not_hidden = true
				break
	if card_not_hidden:
		return
	start_round_now()
