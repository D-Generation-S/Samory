class_name MemoryGame extends Node2D

signal game_state_changed(game_state: int)

signal load_game(card_deck: MemoryDeckResource)

signal game_has_endet()
signal game_paused(is_paused: bool)
signal card_loading_done()

signal card_triggered(game_state: int, clicked_cards: Array[CardTemplate])
signal identical_cards(first_card_point: Point, set_icon_modulated_card_point: Point)

signal player_scored(player_id: int)

signal request_popup(window: PopupWindow)
signal close_last_message_box(id: int)

##Tutorial
signal trigger_tutorial(tutorial_state: Enums.Tutorial_State)

const CARDS_PER_PLAYER = 2

@export_group("Translations")
@export var round_end_message: TextTranslation
@export var round_end_message_no_auto_complete: TextTranslation

@export_group("Game Setup")
@export var card_deck: Resource
@export var finished_game_template: PackedScene
@export var game_menu_template: PackedScene
@export var game_nodes_to_show: Array[Node]
@export var card_target_node: Node2D

@export_group("Effect Setup")
@export var sound_effect: AudioStream


var current_game_state
var player_node: PlayerManager
var triggered_cards: int
var removed_cards = 0
var game_menu: GamePauseMenu = null


var ending_round: bool = false

var message_banner: PackedScene = preload("res://scenes/game/overlay/BottomMessageBanner.tscn")
var auto_close_popup: PackedScene = preload("res://scenes/game/overlay/AutoClosePopup.tscn")
var last_message_banner_id: int = -1

func _ready():
	process_mode = PROCESS_MODE_DISABLED
	player_node = get_node("%Players")

func card_was_placed(card: CardTemplate):
	card.card_triggered.connect(card_was_triggered)

func start_loading_data():
	load_game.emit(card_deck)

func all_cards_placed():
	for child in get_tree().get_nodes_in_group("game_initialize_scene"):
		child.queue_free()
	for node in game_nodes_to_show:
		if node is Node2D:
			node.visible = true 
		if node is CanvasLayer:
			node.visible = true
			
	card_loading_done.emit()
	process_mode = Node.PROCESS_MODE_INHERIT
	start_round_now()

func _process(_delta):
	if current_game_state == GameState.ROUND_END:
		check_if_round_complete()
	if current_game_state == GameState.ROUND_FREEZE:
		check_if_round_can_be_closed()

func check_if_round_can_be_closed():
	var all_cards_shown = true
	for node in card_target_node.get_children():
		if node is CardTemplate and node.is_turned():
			if !node.card_is_fully_shown():
				all_cards_shown = false
	if all_cards_shown:
		round_closed_now()

func card_was_triggered():
	if current_game_state == GameState.ROUND_END:
		return
	triggered_cards = triggered_cards + 1
	
	var current_player = player_node.get_current_player()
	if !current_player.is_ai():
		trigger_tutorial.emit(Enums.Tutorial_State.PLAYER_TURNED_CARD)
	
	var clicked_cards: Array[CardTemplate] = get_clicked_cards()
	card_triggered.emit(current_game_state, clicked_cards)
	if cards_where_identically():
		if !current_player.is_ai():
			trigger_tutorial.emit(Enums.Tutorial_State.PLAYER_FOUND_MATCHING_PAIR)
		for child in card_target_node.get_children():
			if child is CardTemplate and child.is_turned():
				child.remove_from_board()
		if sound_effect != null:
			GlobalSoundBridge.play_sound(sound_effect)
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
		trigger_tutorial.emit(Enums.Tutorial_State.PLAYER_TURN)
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
		trigger_tutorial.emit(Enums.Tutorial_State.PLAYER_TURN_END)
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
	var message = round_end_message
	if !auto_close:
		message = round_end_message_no_auto_complete

	popup_banner.initialize_popup(message, time_until_close, auto_close, func(): end_round_now() )
	popup_banner.should_pause = false
	request_popup.emit(popup_banner)

	last_message_banner_id = popup_banner.get_id()
	

func end_round_now():
	if ending_round or current_game_state != GameState.PREPARE_ROUND_END:
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
	finish_node.high_priority = true
	finish_node.set_player_manager(player_node)
	finish_node.set_played_deck(card_deck)
	request_popup.emit(finish_node)

func set_players(players_of_game: Array[PlayerResource]):
	player_node.add_players(players_of_game)

func get_current_game_phase() -> int:
	return current_game_state

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