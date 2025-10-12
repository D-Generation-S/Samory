class_name OpenRandomCard extends AiBehaviorNode

func can_execute(_blackboard: Blackboard, grid: GameCardGrid) -> bool:
    if grid.get_all_card_positions(false).size() > 0:
        return true
    return false

func execute_action(blackboard: Blackboard, grid: GameCardGrid) -> void:
    print_debug("OpenRandomCard")
    var card_positions: Array[Point] = grid.get_all_card_positions(false)
    var index: int = randi() % card_positions.size()
    if !_trigger_card(card_positions[index], blackboard, grid):
        execute_action(blackboard, grid)
