class_name OpenLastRevealedCard extends AiBehaviorNode

func can_execute(blackboard: Blackboard, grid: GameCardGrid) -> bool:
    var all_cards = grid.get_all_card_positions(false)
    if blackboard.get_last_saved_card() != null and all_cards.size() % 2 == 0:
        for card in all_cards:
            if blackboard.get_last_saved_card().position.is_identical(card):
                return true
    return false

func execute_action(blackboard: Blackboard, grid: GameCardGrid):
    print_debug("OpenLastRevealedCard")
    var card = blackboard.get_last_saved_card()
    trigger_card(card.position, blackboard, grid)
