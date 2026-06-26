class_name MemoryGame extends Node2D

signal load_game(card_deck: MemoryDeckResource, separation: int, field_offset: Vector2i)

signal game_paused(is_paused: bool)

signal request_popup(window: PopupWindow)

const CARDS_PER_PLAYER: int = 2

@export_group("Game Setup")
@export var card_separation: int = 25
@export var field_offset: Vector2i = Vector2i(250, 250)
@export var finished_game_template: PackedScene
@export var game_menu_template: PackedScene


var _card_deck: Resource

#var current_game_state: int
var player_node: PlayerSystem
var triggered_cards: int
var removed_cards: int = 0
var game_menu: GamePauseMenu = null

var ending_round: bool = false

var auto_close_popup: PackedScene = preload("res://entities/game/auto_close_popup/scenes/AutoClosePopup.tscn")
var last_message_banner_id: int = -1

var _is_local_only: bool = true
var _game_scene_group_name: String = "game_scene"
var _systems: Systems:
	get():
		if _systems == null:
			_systems = get_node("%Systems")
		return _systems

func _init() -> void:
	add_to_group(_game_scene_group_name)

func _ready() -> void:
	process_mode = PROCESS_MODE_DISABLED
	player_node = get_node("%PlayerSystem")	

func set_card_deck(deck: MemoryDeckResource) -> void:
	_card_deck = deck

func start_loading_data() -> void:
	load_game.emit(_card_deck, card_separation, field_offset)

func _process(_delta: float) -> void:
	if !execute_logic():
		return

func show_initial_setup() -> bool:
	var settings: SettingsResource = SettingsRepository.load_settings() as SettingsResource
	if settings.auto_close_popup_shown:
		return false
	settings.auto_close_popup_shown = true	
	SettingsRepository.save_settings(settings)

	var popup: PopupWindow = auto_close_popup.instantiate() as PopupWindow
	request_popup.emit(popup)
	return true

func show_game_end_screen() -> void:
	remove_from_group(_game_scene_group_name)
	var finish_node: GameFinished = finished_game_template.instantiate() as GameFinished
	finish_node.high_priority = true
	finish_node.set_player_manager(player_node)
	finish_node.set_played_deck(_card_deck)
	request_popup.emit(finish_node)

func set_players(players_of_game: Array[PlayerResource]) -> void:
	player_node.add_players(players_of_game)

func pause_game() -> void:
	get_tree().paused = true
	game_paused.emit(get_tree().paused)

func unpause_game() -> void:
	get_tree().paused = false
	game_paused.emit(get_tree().paused)

func show_game_menu() -> void:
	game_menu = game_menu_template.instantiate() as GamePauseMenu
	game_menu.high_priority = true
	request_popup.emit(game_menu)

func set_is_multiplayer() -> void:
	_is_local_only = false

func execute_logic() -> bool:
	if _is_local_only:
		return true
	
	return multiplayer.is_server()

func game_state_has_changed(new_state: GameEnum.State) -> void:
	if new_state == GameEnum.State.TURN_START:
		turn_start_trigger()

## This will be triggered if a new turn does start
func turn_start_trigger() -> void:
	if not execute_logic():
		return
	
	ending_round = false
	print("Start Round")
	triggered_cards = 0

func all_cards_placed() -> void:
	for child: Node in get_tree().get_nodes_in_group("game_initialize_scene"):
		child.queue_free()
	GlobalSoundManager.stop_all_sounds()
	process_mode = Node.PROCESS_MODE_INHERIT

func get_systems() -> Systems:
	return _systems