class_name AiBehaviorNode extends Resource

@export var propability:int = 0
#var ai_node: AiAgent

#func _ready():
	#ai_node = get_parent() as AiAgent

func get_execution_probability() -> int:
	return propability

func can_execute(_blackboard: Blackboard, _grid: GameCardGrid) -> bool:
	return false

func execute_action(_blackboard: Blackboard, _grid: GameCardGrid):
	pass

func trigger_card(position: Point, _blackboard: Blackboard, grid: GameCardGrid) -> bool:
	var card = grid.get_card_on_position(position)
	if card == null:
		return false

	if grid.select_card_at_position(position):
		grid.confirm_current_card()
		return true

	return false