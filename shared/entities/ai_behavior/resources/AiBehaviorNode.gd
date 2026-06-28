class_name AiBehaviorNode extends Resource

@export var probability: int = 0

func get_execution_probability() -> int:
	return probability

func can_execute(_blackboard: Blackboard, _grid: CardInteractionField) -> bool:
	return false

func execute_action(_blackboard: Blackboard, _grid: CardInteractionField) -> void:
	pass

func _trigger_card(position: Vector2i, _blackboard: Blackboard, grid: CardInteractionField) -> bool:
	var card_existing: bool = grid.is_there_a_card_on_position(position)
	if not card_existing:
		return false

	grid.mouse_has_clicked(position)
	return not grid.is_there_a_card_on_position(position)