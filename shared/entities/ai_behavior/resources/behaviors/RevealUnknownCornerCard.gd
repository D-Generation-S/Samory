class_name RevealUnknownCornerCard extends AiBehaviorNode

func can_execute(blackboard: Blackboard, grid: CardInteractionField) -> bool:
	for position: Vector2i in grid.get_all_card_positions(false):
		if _get_corner_positions(grid).find(position) != -1 and not _blackboard_card_known(blackboard, position):
			return true
	return false

func _blackboard_card_known(blackboard: Blackboard, position: Vector2i) -> bool:
	for card: CardInformationResource in blackboard.get_all_saved_cards():
		if card.position == position:
			return true
	return false

func _get_corner_positions(grid: CardInteractionField) -> Array[Vector2i]:
	var field_size: Vector2i  = grid.get_field_size()
	var allowed_positions: Array[Vector2i] = [
		Vector2i.ZERO, # top left
		Vector2i(field_size.x, 0), # top right
		Vector2i(0, field_size.y), # bottom left
		Vector2i(field_size.x, field_size.y) # bottom right
	]
	return allowed_positions

func execute_action(blackboard: Blackboard, grid: CardInteractionField) -> void:
	var allowed_positions: Array[Vector2i] = _get_corner_positions(grid)
	var valid_positions: Array[Vector2i] = []
	for position: Vector2i in allowed_positions:
		if not _blackboard_card_known(blackboard, position):
			valid_positions.append(position)
	
	var position: Vector2i = valid_positions.pick_random()
	_trigger_card(position, blackboard, grid)