class_name AiDifficultyResource extends Resource

@export var name: String
@export var actions: Array[AiBehaviorNode]

var blackboard: Blackboard = Blackboard.new()

func execute_action(grid: GameCardGrid):
    var possible_actions = actions.filter(func(current_action): return current_action.can_execute(blackboard, grid))
    var loottable = LootTable.new()
    for action in possible_actions:
        loottable.add_to_table(action, action.get_execution_probability())

    var action = loottable.get_loot() as AiBehaviorNode
    action.execute_action(blackboard, grid)

func get_translated_name() -> String:
    return tr(name)