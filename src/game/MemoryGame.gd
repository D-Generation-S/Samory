class_name MemoryGame extends Node2D

signal game_state_changed(game_state: int)

signal game_has_endet()
signal game_paused(is_paused: bool)
signal card_loading_done()

signal card_triggered(game_state: int, clicked_cards: Array[CardTemplate])
signal identical_cards(first_card_point: Point, set_icon_modulatecard_point: Point)

signal player_scored(player_id: int)

signal field_constructed(cards_on_x: int, cards_on_y: int)
signal request_popup(window: PopupWindow)
signal close_last_message_box(id: int)

##Tutorial
signal turn_of_an_player()
signal card_turned_by_player()
signal matching_card_by_player()
signal player_round_endet()

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
var game_menu: GamePauseMenu = null

var load_thread: Thread = null
var current_sound_timer = 0

var ending_round: bool = false

var message_banner: PackedScene = preload("res://scenes/game/overlay/BottomMessageBanner.tscn")
var auto_close_popup: PackedScene = preload("res://scenes/game/overlay/AutoClosePopup.tscn")
var last_message_banner_id: int = -1

func _ready():
	process_mode = Node.PROCESS_MODE_DISABLED
	loading_scene.set_screen_message("PLACING_CARDS", true)
	current_sound_timer = seconds_to_lay_cards
	
	player_node = get_node("%Players")

	load_thread = Thread.new()
	load_thread.start(build_card_layout.bind(card_deck, card_template, separation))

	await field_constructed

	process_mode = Node.PROCESS_MODE_INHERIT

	current_sound_timer = 0
	var cards = load_thread.wait_to_finish() as Array[CardTemplate]
	for card in cards:
		card_target_node.add_child(card)
		card.card_triggered.connect(card_was_triggered)
	load_thread = null
	card_loading_done.emit()
	start_round_now()
		
	loading_scene.destory()
	for node in game_nodes_to_show:
		if node is Node2D:
			node.visible = true 
		if node is CanvasLayer:
			node.visible = true

func _process(delta):
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
	call_deferred("emit_signal","field_constructed", column_count, row_count)
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
	
	var current_player = player_node.get_current_player()
	if !current_player.is_ai():
		card_turned_by_player.emit()
	
	var clicked_cards: Array[CardTemplate] = get_clicked_cards()
	card_triggered.emit(current_game_state, clicked_cards)
	if cards_where_identically():
		if !current_player.is_ai():
			matching_card_by_player.emit()
		for child in card_target_node.get_children():
			if child is CardTemplate and child.is_turned():
				child.remove_from_board()
		triggered_cards = 0
		removed_cards = removed_cards + 1
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
	ending_round = false
	print("Start Round")
	current_game_state = GameState.ROUND_START
	if !player_node.get_current_player().is_ai():
		turn_of_an_player.emit()
	game_state_changed.emit(current_game_state)
	triggered_cards = 0

func freeze_round_now():
	print("Freeze Round")
	current_game_state = GameState.ROUND_FREEZE
	game_state_changed.emit(current_game_state)

func round_closed_now():
	print("Closing round")
	current_game_state = GameState.PREPARE_ROUND_END
	var current_player = player_node.get_current_player()
	if !current_player.is_ai():
		player_round_endet.emit()
	game_state_changed.emit(current_game_state)
	var initial_setup_shown = show_initial_setup()
	if !initial_setup_shown:
		show_round_ended_banner()

func show_initial_setup() -> bool:
	var settings = SettingsRepository.load_settings() as SettingsResource
	if settings.auto_close_popup_shown:
		return false
	settings.auto_close_popup_shown = true	
	SettingsRepository.save_settings(settings)

	var popup = auto_close_popup.instantiate() as PopupWindow
	request_popup.emit(popup)
	popup.popup_closed.connect(func(): show_round_ended_banner())
	return true


func show_round_ended_banner():
	var settings = SettingsRepository.load_settings() as SettingsResource
	var auto_close = settings.auto_close_round
	var time_until_close = settings.close_round_after_seconds
	var popup_banner: BottomMessageBanner = message_banner.instantiate() as BottomMessageBanner
	var message = "ROUND_END_BANNER_MESSAGE"
	if !auto_close:
		message = "ROUND_END_BANNER_MESSAGE_NO_COMPLETE"

	popup_banner.initialize_popup(message, time_until_close, auto_close, func(): end_round_now())
	popup_banner.should_pause = false
	request_popup.emit(popup_banner)

	last_message_banner_id = popup_banner.get_id()
	

func end_round_now():
	if ending_round:
		return
	ending_round = true
	print("End Round")
	if last_message_banner_id != -1:
		close_last_message_box.emit(last_message_banner_id)
	last_message_banner_id = -1

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

func pause_game():
	get_tree().paused = true
	game_paused.emit(get_tree().paused)

func unpause_game():
	get_tree().paused = false
	game_paused.emit(get_tree().paused)

func show_game_menu():
	game_menu = game_menu_template.instantiate() as GamePauseMenu
	game_menu.high_priority = true
	request_popup.emit(game_menu)

func continue_game():
	printerr("should not be used!")
	unpause_game()

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
