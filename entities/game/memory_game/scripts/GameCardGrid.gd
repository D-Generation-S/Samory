class_name GameCardGrid extends Node2D

signal card_removed()
signal all_matching_cards_removed()
signal card_triggered(CardTemplate: CardTemplate)
signal identical_cards(first_card_point: Point, set_icon_modulated_card_point: Point)
signal no_matches_found()
signal board_ready()
signal board_empty()
signal card_activated()

@export var state_machine: GameStateMachine

var current_card: CardTemplate

var controller_input_was_made: bool = false
var currently_ai_player: bool = false

var number_of_triggered_cards: int = 0

enum Axis {X, Y}

func get_current_grid_position() -> Point:
	if current_card == null:
		return Point.new(0,0)
	return Point.new(current_card.grid_position.get_x_pos(), current_card.grid_position.get_y_pos())

func _move_axis(direction: int, axis: Axis) -> void:
	var clamped_direction: int = clampi(direction, -1, 1)
	if clamped_direction == 0:
		return

	var grid_position: Point = get_current_grid_position()
	var is_negative_direction: bool = clamped_direction < 0

	var next_position: Point = _get_next_card_position(grid_position, is_negative_direction, axis)		

	if next_position == null or !select_card_at_position(next_position):
		current_card = null

func get_card_grid(current_pos: Point) -> Array[Point]:
	var all_cards: Array[Point] = []
	for card: Node2D in get_children():
		if card is CardTemplate and !card.grid_position.is_identical(current_pos) and not card.is_getting_removed():
			all_cards.append(card.grid_position)

	return all_cards

func get_closest_card_to_position(current_pos: Point, card_positions: Array[Point]) -> Point:
	var return_point: Point = null
	var distance: float = 10000
		
	for current_position: Point in card_positions:
		if current_position.get_distance(current_pos) < distance:
			return_point = current_position
			distance = current_position.get_distance(current_pos) 

	return return_point

func _get_next_card_position(current_pos: Point, go_negative: bool, axis: Axis) -> Point:
	var all_card_positions: Array[Point] = _get_valid_card_positions(current_pos, go_negative, axis)

	var return_point: Point = _get_card_on_same_axis(current_pos, all_card_positions, axis)

	if return_point == null:
		return_point = get_closest_card_to_position(current_pos, all_card_positions)

	return return_point
	
func _get_valid_card_positions(current_pos: Point, go_negative: bool, axis: Axis) -> Array[Point]:
	var all_card_positions: Array[Point] = get_card_grid(current_pos);
	var valid_cards: Array[Point] = []
	for card_position: Point in all_card_positions:
		var current_card_position: int = 0
		var current_position: int = 0
		match axis:
			Axis.X:
				current_card_position = card_position.get_x_pos()
				current_position = current_pos.get_x_pos()
			Axis.Y:
				current_card_position = card_position.get_y_pos()
				current_position = current_pos.get_y_pos()
		
		if go_negative and current_card_position >= current_position:
			continue
		if !go_negative and current_card_position <= current_position:
			continue
		valid_cards.append(card_position)
	return valid_cards

func _get_card_on_same_axis(current_position: Point, valid_positions: Array[Point], axis: Axis) -> Point:
	var return_point: Point = null;
	for valid_position: Point in valid_positions:
		var is_same_axis: bool = false
		match axis:
			Axis.X:
				is_same_axis = current_position.get_x_pos() == valid_position.get_x_pos()
			Axis.Y:
				is_same_axis = current_position.get_y_pos() == valid_position.get_y_pos()

		if not is_same_axis:
			continue

		if return_point == null:
			return_point = valid_position
			continue
		
		var current_distance: int = 0
		var return_point_distance: int = 0
		match axis:
			Axis.X:
				current_distance = absi(valid_position.get_x_pos() - current_position.get_x_pos())
				return_point_distance = absi(return_point.get_x_pos() - current_position.get_x_pos())
			Axis.Y:
				current_distance = absi(valid_position.get_y_pos() - current_position.get_y_pos())
				return_point_distance = absi(return_point.get_y_pos() - current_position.get_y_pos())

		if current_distance < return_point_distance:
			return_point = current_position

	return return_point

func trigger_card_at_position(grid_position: Point) -> void:
	if select_card_at_position(grid_position):
		if current_card == null:
			return
		current_card.force_reveal_card()

func remove_cards_from_board(grid_positions: Array[Point]) -> void:
	for grid_position: Point in grid_positions:
		remove_card_from_board(grid_position)
	all_matching_cards_removed.emit()
	
func remove_card_from_board(grid_position: Point) -> void:
	for child: CardTemplate in _get_game_card_templates_children():
		if child.grid_position.is_identical(grid_position):
			child.remove_from_board(currently_ai_player)
			child.about_to_get_delete.connect(func() -> void: card_removed.emit())

func select_card_at_position(grid_position: Point) -> bool:
	var found_card: bool = false
	var initial_card: CardTemplate = current_card
	for card: CardTemplate in _get_game_card_templates_children():
		card.lost_focus()
		if grid_position.is_identical(card.grid_position):
			card.got_focus()
			current_card = card
			found_card = true

	if !found_card and current_card != null:
		current_card = initial_card
		current_card.got_focus()
	return found_card

func confirm_current_card() -> void:
	if current_card == null or get_tree().paused:
		return
	current_card.card_was_clicked()
	
func select_closest_card(source_position: Point, include_source: bool) -> void:
	if currently_ai_player:
		return
	var cards: Array[Point] = get_card_grid(source_position)
	if include_source:
		cards.append(source_position)
	var return_position: Point = get_closest_card_to_position(source_position, cards)

	if return_position != null:
		select_card_at_position(return_position)

func get_card_on_position(card_position: Point) -> MemoryCardResource:
	for card: CardTemplate in _get_game_card_templates_children():
		if card_position.is_identical(card.grid_position):
			return card.memory_card
	return null
		
func parse_movement(information: Vector2) -> void:
	if get_tree().paused or currently_ai_player:
		return
	controller_input_was_made = true
	if information != Vector2.ZERO:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	_move_axis(sign(information.x), Axis.X)
	_move_axis(sign(information.y), Axis.Y)

func round_frozen() -> void:
	current_card = null

func round_unfrozen() -> void:
	if currently_ai_player:
		controller_input_was_made = false
		return
	if controller_input_was_made:
		select_closest_card(Point.new(0,0), true)
	controller_input_was_made = false

func card_loading_done() -> void:
	for card: CardTemplate in _get_game_card_templates():
		card.mouse_was_used.connect(func() -> void: 
			current_card = null
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		)	

func game_state_changed(game_state: GameEnum.State) -> void:
	match game_state:
		GameEnum.State.TURN_START:
			round_unfrozen()
			for card: CardTemplate in _get_game_card_templates():
				card.player_changed(currently_ai_player)
			print(_get_all_cards().size())
			if _get_all_cards().size() == 0:
				board_empty.emit()

		GameEnum.State.TURN_FREEZE:
			round_frozen()
		GameEnum.State.TURN_COMPLETED:
			_validate_grid()
		GameEnum.State.PREPARE_TURN_END:
			_prepare_turn_complete()			

func _validate_grid() -> void:
	for card: CardTemplate in _get_all_cards():
		if card == null or card.is_queued_for_deletion():
			continue
		if card.is_turned() and not card.card_is_fully_shown():
			print("Waiting")
			await card.fully_shown
	if _any_matching():
		var card_positions: Array[Point] = []
		for card: CardTemplate in _get_all_cards():
			if card.is_turned():
				card_positions.append(card.grid_position)
		identical_cards.emit(card_positions[0], card_positions[1])
		remove_cards_from_board(card_positions)
		var count: int = _get_all_cards().filter(func (card: CardTemplate) -> bool: return not card.getting_removed).size()
		if count == 0:
			board_empty.emit()
			
		return


	no_matches_found.emit()

func _prepare_turn_complete() -> void:
	for card: CardTemplate in _get_all_cards():
		if not card.card_is_hidden():
			print ("wait hidden card")
			await card.fully_hidden
	
	print ("continue prepare turn complete")
	var all_cards: Array[CardTemplate] = _get_all_cards()
	if all_cards.size() == 0:
		board_empty.emit()
		return

	board_ready.emit()

func _any_matching() -> bool:
	var first_found: CardTemplate = null
	for card: CardTemplate in _get_all_cards():
		if not card.is_turned():
			continue
		if first_found == null:
			first_found = card
			continue	
		if card.get_card_id() == first_found.get_card_id():
			return true
	return false

func _get_all_cards() -> Array[CardTemplate]:
	var _templates: Array[CardTemplate] = []
	for card_node: Node in get_children():
		if card_node is CardTemplate:
			_templates.append(card_node)
	return _templates

func get_all_card_positions(get_turned: bool = false) -> Array[Point]:
	var return_data: Array[Point] = []
	for card: CardTemplate in _get_game_card_templates_children():
		if card.getting_removed:
			continue
		if get_turned or !card.is_turned():
			return_data.append(card.grid_position)
	return return_data

func get_all_cards_currently_turned() -> Array[Point]:
	var return_data: Array[Point] = []
	for card: CardTemplate in _get_game_card_templates_children():
		if card.is_turned():
			return_data.append(card.grid_position)
	return return_data

func player_changed(current_player:PlayerResource) -> void:
	currently_ai_player = current_player.is_ai()
	if multiplayer.get_peers().size() > 0 and current_player.id != multiplayer.get_unique_id():
		currently_ai_player = true

func disable_card_effects() -> void:
	for card: CardTemplate in _get_game_card_templates():
		card.lost_focus()

func _get_game_card_templates_children() -> Array[CardTemplate]:
	var return_data: Array[CardTemplate]
	for card_template: CardTemplate in get_children().filter(func(data: Node) -> bool: return data is CardTemplate):
		return_data.append(card_template)
	return return_data

func _get_game_card_templates() -> Array[CardTemplate]:
	var return_data: Array[CardTemplate]
	for card_template: CardTemplate in get_tree().get_nodes_in_group("game_card").filter(func(card: Node) -> bool: return card is CardTemplate):
		return_data.append(card_template)
	return return_data

func prevent_input(prevent: bool) -> void:
	for card: CardTemplate in _get_game_card_templates_children():
		card.input_allowed(!prevent)

func card_was_placed(card: CardTemplate) -> void:
	card.card_triggered.connect(card_triggered_hook)
	state_machine.state_changed.connect(card.game_state_changed)


func card_triggered_hook(card: CardTemplate) -> void:
	select_card_at_position(card.grid_position)
	card_triggered.emit(card)
	card_activated.emit()
	
