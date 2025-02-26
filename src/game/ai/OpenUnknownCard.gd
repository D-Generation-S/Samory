class_name OpenUnknownCard extends AiBehaviorNode


func can_execute(blackboard: Blackboard, grid: GameCardGrid) -> bool:
	var unknown_cards = get_all_unknown_card_positions(blackboard, grid)
	return unknown_cards.size() > 0

func get_all_unknown_card_positions(blackboard: Blackboard, grid: GameCardGrid) -> Array[Point]:
	var return_data: Array[Point] = []
	var all_positions: Array[Point] = grid.get_all_card_positions()
	var known_positions: Array[CardInformationResource] = blackboard.get_all_saved_cards()
	for current_position in all_positions:
		if known_positions.any(func(known_position: CardInformationResource): return known_position.position.is_identical(current_position)):
			continue
		return_data.append(current_position)


	return return_data

func execute_action(blackboard: Blackboard, grid: GameCardGrid):
	print_debug("OpenUnknownCard")
	var cards = get_all_unknown_card_positions(blackboard, grid)
	var card_index = randi_range(0, cards.size() - 1)
	trigger_card(cards[card_index], blackboard, grid)

		
