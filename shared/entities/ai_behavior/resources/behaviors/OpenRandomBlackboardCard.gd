class_name OpenRandomBlackBoardCard extends AiBehaviorNode

@export var backup_action: AiBehaviorNode
var attempts: int = 0

func can_execute(blackboard: Blackboard, grid: GameCardGrid) -> bool:
    if blackboard.cards_remembered() == 0 or grid.get_all_card_positions(false).size() % 2 == 1:
        return false
    attempts = 0
    return true

func execute_action(blackboard: Blackboard, grid: GameCardGrid) -> void:
    print_debug("OpenRandomBlackBoardCard")
    var card: CardInformationResource = blackboard.get_random_known_card_from_storage()
    if !_trigger_card(card.position, blackboard, grid) and blackboard.cards_remembered() > 1 and attempts < 5:
        attempts = attempts + 1
        execute_action(blackboard, grid)
    
    if backup_action != null and backup_action.can_execute(blackboard, grid):
        print_debug("Trigger fallback action")
        backup_action.execute_action(blackboard, grid)
        
