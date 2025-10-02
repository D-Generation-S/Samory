class_name AiAgent extends Node

@export var cards_node: GameCardGrid
@export var players: PlayerManager
@export var min_wait_milliseconds: float = 500
@export var max_wait_milliseconds: float = 3000
var timer: Timer = null;
var triggered_cards: int = 0

func _ready():
	if multiplayer.get_peers().size() > 0 and !multiplayer.is_server():
		queue_free()
	timer = Timer.new()
	timer.timeout.connect(timer_triggered)
	add_child(timer)

var should_play_round: bool = false
var current_player_data: PlayerResource = null
var last_card: MemoryCardResource = null

func card_was_triggered(game_state:int, clicked_cards: Array[CardTemplate]):
	for card in clicked_cards:
		add_card_to_all_ais(card.grid_position, card.memory_card)
	if !should_play_round:
		return
	if game_state == GameState.ROUND_START and triggered_cards < 2:
		prepare_and_start_timer()

func card_was_identically(first_card_position: Point, second_card_position: Point):
	remove_card_to_all_ais(first_card_position)
	remove_card_to_all_ais(second_card_position)
	
	triggered_cards = 0 
	if should_play_round:
		prepare_and_start_timer()

func game_state_changed(game_state:int):
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

func player_changed(current_player:PlayerResource):
	triggered_cards = 0 
	current_player_data = current_player
	should_play_round = current_player.is_ai()

func prepare_and_start_timer():
	if !timer.is_stopped():
		return
	timer.wait_time = randf_range(min_wait_milliseconds, max_wait_milliseconds) / 1000
	timer.start()

func timer_triggered():
	if triggered_cards >= 2:
		printerr("Already revealed 2 cards without matching pair!")
		return
	var ai_resource = current_player_data.ai_difficulty as AiDifficultyResource
	timer.stop()
	if should_play_round and ai_resource != null:
		triggered_cards += 1
		ai_resource.execute_action(cards_node)

func add_card_to_all_ais(point: Point, card: MemoryCardResource):
	for player in players.players:
		if !player.is_ai():
			continue
		var ai = player.ai_difficulty
		if ai == null:
			continue
		ai.blackboard.add_card(point, card)

func remove_card_to_all_ais(point: Point):
	for player in players.players:
		if !player.is_ai():
			continue
		var ai = player.ai_difficulty
		if ai == null:
			continue
		ai.blackboard.remove_card(point)