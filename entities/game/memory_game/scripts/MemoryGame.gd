class_name MemoryGame extends Node2D

signal load_game(card_deck: MemoryDeckResource)

signal game_paused(is_paused: bool)

signal request_popup(window: PopupWindow)

const CARDS_PER_PLAYER: int = 2

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

#var current_game_state: int
var player_node: PlayerSystem
var triggered_cards: int
var removed_cards: int = 0
var game_menu: GamePauseMenu = null

var ending_round: bool = false

var message_banner: PackedScene = preload("res://entities/game/bottom_message_banner/scenes/BottomMessageBanner.tscn")
var auto_close_popup: PackedScene = preload("res://entities/game/auto_close_popup/scenes/AutoClosePopup.tscn")
var last_message_banner_id: int = -1

var _is_local_only: bool = true

func _ready() -> void:
	process_mode = PROCESS_MODE_DISABLED
	player_node = get_node("%PlayerSystem")

func start_loading_data() -> void:
	load_game.emit(card_deck)

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
	var finish_node: GameFinished = finished_game_template.instantiate() as GameFinished
	finish_node.high_priority = true
	finish_node.set_player_manager(player_node)
	finish_node.set_played_deck(card_deck)
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