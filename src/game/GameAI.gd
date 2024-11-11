class_name AiAgent extends Node

@export var cards_node: GameCardGrid
@export var blackboard: Blackboard

@export var random_card: AiBehaviorNode

var should_play_round: bool = false
var current_player_data: PlayerResource = null
var last_card: MemoryCardResource = null


func game_state_changed(game_state:int):
	if game_state == GameState.ROUND_START:
		last_card = null
		random_card.execute_action(blackboard)
		
	pass

func get_all_card_positions() -> Array[Point]:
	return cards_node.get_all_card_positions()

func player_changed(current_player:PlayerResource):
	current_player_data = current_player
	should_play_round = current_player.is_ai()

func trigger_card(position: Point) -> bool:
	var card = cards_node.get_card_on_position(position)
	if card == null:
		return false

	if cards_node.select_card_at_position(position):
		cards_node.confirm_current_card()
		blackboard.add_card(position, card)
		last_card = card
		return true

	return false
