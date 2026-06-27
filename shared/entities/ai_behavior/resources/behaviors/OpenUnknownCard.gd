class_name OpenUnknownCard extends AiBehaviorNode


func can_execute(blackboard: Blackboard, grid: GameCardGrid) -> bool:
	var unknown_card_positions: Array[Vector2i] = get_all_unknown_card_positions(blackboard, grid)
	return unknown_card_positions.size() > 0

func get_all_unknown_card_positions(blackboard: Blackboard, grid: GameCardGrid) -> Array[Vector2i]:
	var return_data: Array[Vector2i] = []
	var all_positions: Array[Vector2i] = grid.get_all_card_positions()
	var known_positions: Array[CardInformationResource] = blackboard.get_all_saved_cards()
	for current_position: Vector2i in all_positions:
		if known_positions.any(func(known_position: CardInformationResource) -> bool: return known_position.position == current_position):
			continue
		return_data.append(current_position)


	return return_data

func execute_action(blackboard: Blackboard, grid: GameCardGrid) -> void:
	print_debug("OpenUnknownCard")
	var cards: Array[Vector2i]  = get_all_unknown_card_positions(blackboard, grid)
	var card_index: int = randi_range(0, cards.size() - 1)
	_trigger_card(cards[card_index], blackboard, grid)

		
