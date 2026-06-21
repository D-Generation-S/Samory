class_name RevealUnknownCornerCard extends AiBehaviorNode

func can_execute(blackboard: Blackboard, grid: GameCardGrid) -> bool:
	for position: Point in grid.get_all_card_positions(false):
		var real_position: Vector2i = Vector2i(position.get_x_pos(), position.get_y_pos())
		if _get_corner_positions(grid).find(real_position) != -1 and not _blackboard_card_known(blackboard, position):
			return true
	return false

func _blackboard_card_known(blackboard: Blackboard, position: Point) -> bool:
	for card: CardInformationResource in blackboard.get_all_saved_cards():
		if card.position.is_identical(position):
			return true
	return false

func _get_corner_positions(grid: GameCardGrid) -> Array[Vector2i]:
	var field_size: Vector2i  = grid.get_field_size()
	var allowed_positions: Array[Vector2i] = [
		Vector2i.ZERO, # top left
		Vector2i(field_size.x, 0), # top right
		Vector2i(0, field_size.y), # bottom left
		Vector2i(field_size.x, field_size.y) # bottom right
	]
	return allowed_positions

func execute_action(blackboard: Blackboard, grid: GameCardGrid) -> void:
	var allowed_positions: Array[Vector2i] = _get_corner_positions(grid)
	var valid_positions: Array[Vector2i] = []
	for position: Vector2i in allowed_positions:
		if not _blackboard_card_known(blackboard, Point.new(position.x, position.y)):
			valid_positions.append(position)
	
	var position: Vector2i = valid_positions.pick_random()
	var point: Point = Point.new(position.x, position.y)
	_trigger_card(point, blackboard, grid)