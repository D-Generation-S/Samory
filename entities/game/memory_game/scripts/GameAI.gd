class_name AiAgent extends Node

@export var cards_node: GameCardGrid
@export var players: PlayerManager
@export var min_wait_seconds: float = 0.5
@export var max_wait_seconds: float = 3
var timer: Timer = null;
var triggered_cards: int = 0

func _ready() -> void:
	if multiplayer.get_peers().size() > 0 and !multiplayer.is_server():
		queue_free()
	timer = Timer.new()
	timer.timeout.connect(timer_triggered)
	add_child(timer)

var should_play_round: bool = false
var current_player_data: PlayerResource = null
var last_card: MemoryCardResource = null

func card_was_triggered(game_state:int, clicked_cards: Array[CardTemplate]) -> void:
	for card: CardTemplate in clicked_cards:
		add_card_to_all_ais(card.grid_position, card.memory_card)
	if !should_play_round:
		return
	if game_state == GameState.ROUND_START and triggered_cards < 2:
		prepare_and_start_timer()

func card_was_identically(first_card_position: Point, second_card_position: Point) -> void:
	remove_card_to_all_ais(first_card_position)
	remove_card_to_all_ais(second_card_position)
	
	triggered_cards = 0 
	if should_play_round:
		prepare_and_start_timer()

func game_state_changed(game_state:int) -> void:
	if !should_play_round:
		return

	if game_state == GameState.PREPARE_ROUND_END or game_state == GameState.ROUND_FREEZE:
		timer.stop()
		should_play_round = false
		return
	if game_state == GameState.ROUND_START:
		prepare_and_start_timer()

func get_all_card_positions() -> Array[Point]:
	return cards_node.get_all_card_positions()

func player_changed(current_player:PlayerResource) -> void:
	triggered_cards = 0 
	current_player_data = current_player
	should_play_round = current_player.is_ai()

func prepare_and_start_timer() -> void:
	if !timer.is_stopped():
		return
	var settings: SettingsResource = SettingsRepository.load_settings()
	timer.wait_time = randf_range(min_wait_seconds * settings.ai_think_time, max_wait_seconds * settings.ai_think_time)
	timer.start()

func timer_triggered() -> void:
	if triggered_cards >= 2:
		printerr("Already revealed 2 cards without matching pair!")
		return
	var ai_resource: AiDifficultyResource = current_player_data.ai_difficulty as AiDifficultyResource
	timer.stop()
	if should_play_round and ai_resource != null:
		triggered_cards += 1
		ai_resource.execute_action(cards_node)

func _call_action_on_all_ais(callback: Callable) -> void:
	for player: PlayerResource in players.players:
		if not player.is_ai():
			continue
		var ai: AiDifficultyResource = player.ai_difficulty
		if ai == null:
			continue
		callback.call(ai)

func add_card_to_all_ais(point: Point, card: MemoryCardResource) -> void:
	_call_action_on_all_ais(func(ai: AiDifficultyResource) -> void: ai.blackboard.add_card(point, card))

func remove_card_to_all_ais(point: Point) -> void:
	_call_action_on_all_ais(func(ai: AiDifficultyResource) -> void: ai.blackboard.remove_card(point))
