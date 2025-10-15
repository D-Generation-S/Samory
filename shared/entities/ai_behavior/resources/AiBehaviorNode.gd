class_name AiBehaviorNode extends Resource

@export var probability: int = 0

func get_execution_probability() -> int:
	return probability

func can_execute(_blackboard: Blackboard, _grid: GameCardGrid) -> bool:
	return false

func execute_action(_blackboard: Blackboard, _grid: GameCardGrid) -> void:
	pass

func _trigger_card(position: Point, _blackboard: Blackboard, grid: GameCardGrid) -> bool:
	var card: MemoryCardResource = grid.get_card_on_position(position)
	if card == null:
		return false

	if grid.select_card_at_position(position):
		grid.confirm_current_card()
		return true

	return false