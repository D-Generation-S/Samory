class_name GetMatchingCard extends AiBehaviorNode

func can_execute(blackboard: Blackboard, grid: CardInteractionField) -> bool:
	var unrevealed_cards: Array[Vector2i] = grid.get_all_disabled_cards()
	if unrevealed_cards.size() != 1:
		return false;

	var card_of_focus: Vector2i = unrevealed_cards[0]
	var id: int = grid.get_card_id_from_position(card_of_focus)
	if id == -1:
		return false
	var stored_cards: Array[CardInformationResource] = blackboard.get_all_cards_with_id(id)
	for stored_card: CardInformationResource in stored_cards:
		if !stored_card.position == card_of_focus:
			return true
	return false

func execute_action(blackboard: Blackboard, grid: CardInteractionField) -> void:
	print_debug("GetMatchingCard")
	var unrevealed_cards: Array[Vector2i] = grid.get_all_disabled_cards()
	var card_of_focus: Vector2i = unrevealed_cards[0]
	
	var id: int = grid.get_card_id_from_position(card_of_focus)
	var card_to_reveal: CardInformationResource = null
	var stored_cards: Array[CardInformationResource] = blackboard.get_all_cards_with_id(id)

	for stored_card: CardInformationResource in stored_cards:
		if not stored_card.position == (card_of_focus):
			card_to_reveal = stored_card
	_trigger_card(card_to_reveal.position, blackboard, grid)
