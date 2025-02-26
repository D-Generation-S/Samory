class_name OpenRandomCard extends AiBehaviorNode

func can_execute(_blackboard: Blackboard, grid: GameCardGrid) -> bool:
    if grid.get_all_card_positions(false).size() > 0:
        return true
    return false

func execute_action(blackboard: Blackboard, grid: GameCardGrid):
    print_debug("OpenRandomCard")
    var cards = grid.get_all_card_positions(false)
    var index = randi() % cards.size()
    if !trigger_card(cards[index], blackboard, grid):
        execute_action(blackboard, grid)
