class_name AiDifficultyResource extends Resource

@export var name: String
## Set to -1 if the memory should be unlimited
@export_range(-1, 200) var card_memory: int = -1:
    set(value):
        card_memory = value
        blackboard = Blackboard.new(card_memory)
@export var actions: Array[AiBehaviorNode]

var blackboard: Blackboard


func execute_action(grid: GameCardGrid):
    var possible_actions = actions.filter(func(current_action): return current_action.can_execute(blackboard, grid))
    var loottable = LootTable.new()
    for action in possible_actions:
        loottable.add_to_table(action, action.get_execution_probability())

    var action = loottable.get_loot() as AiBehaviorNode
    if action == null:
        printerr("Action was null, but there should be something ...")
        return
    action.execute_action(blackboard, grid)

func get_translated_name() -> String:
    return tr(name)