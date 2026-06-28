class_name OpenLastRevealedCard extends AiBehaviorNode

func can_execute(blackboard: Blackboard, grid: CardInteractionField) -> bool:
    var all_card_positions: Array[Vector2i] = grid.get_all_card_positions(false)
    if blackboard.get_last_saved_card() != null and all_card_positions.size() % 2 == 0:
        for card_position: Vector2i in all_card_positions:
            if blackboard.get_last_saved_card().position == card_position:
                return true
    return false

func execute_action(blackboard: Blackboard, grid: CardInteractionField) -> void:
    print_debug("OpenLastRevealedCard")
    var card: CardInformationResource = blackboard.get_last_saved_card()
    _trigger_card(card.position, blackboard, grid)
