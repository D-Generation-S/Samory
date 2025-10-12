class_name OpenLastRevealedCard extends AiBehaviorNode

func can_execute(blackboard: Blackboard, grid: GameCardGrid) -> bool:
    var all_card_positions: Array[Point] = grid.get_all_card_positions(false)
    if blackboard.get_last_saved_card() != null and all_card_positions.size() % 2 == 0:
        for card: Point in all_card_positions:
            if blackboard.get_last_saved_card().position.is_identical(card):
                return true
    return false

func execute_action(blackboard: Blackboard, grid: GameCardGrid) -> void:
    print_debug("OpenLastRevealedCard")
    var card: CardInformationResource = blackboard.get_last_saved_card()
    _trigger_card(card.position, blackboard, grid)
