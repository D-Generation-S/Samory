class_name OpenRandomBlackBoardCard extends AiBehaviorNode

@export var backup_action: AiBehaviorNode
var attemps = 0

func can_execute(blackboard: Blackboard, grid: GameCardGrid) -> bool:
    if blackboard.cards_remembered() == 0 or grid.get_all_card_positions(false).size() % 2 == 1:
        return false
    attemps = 0
    return true

func execute_action(blackboard: Blackboard, grid: GameCardGrid):
    print("OpenRandomBlackBoardCard")
    var card = blackboard.get_random_known_card_from_storage()
    var success = false
    if !trigger_card(card.position, blackboard, grid) and blackboard.cards_remembered() > 1 and attemps < 5:
        attemps = attemps + 1
        success = execute_action(blackboard, grid)
    
    if !success and backup_action != null and backup_action.can_execute(blackboard, grid):
        backup_action.execute_action(blackboard, grid)
        
