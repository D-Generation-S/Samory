class_name GameCardGrid extends Node2D

var current_card: CardTemplate

var controller_input_was_made: bool = false
var currently_ai_player: bool = false

enum Axis {X, Y}

func get_current_grid_position() -> Point:
	if current_card == null:
		return Point.new(0,0)
	return Point.new(current_card.grid_position.get_x_pos(), current_card.grid_position.get_y_pos())

func _move_axis(direction: int, axis: Axis):
	var clamped_direction = clampi(direction, -1, 1)
	if clamped_direction == 0:
		return

	var grid_position = get_current_grid_position()
	var is_negative_direction = clamped_direction < 0

	var next_position := _get_next_card_position(grid_position, is_negative_direction, axis)		

	if next_position == null or !select_card_at_position(next_position):
		current_card = null

func get_card_grid(current_pos: Point) -> Array[Point]:
	var all_cards: Array[Point] = []
	for card in get_children():
		if card is CardTemplate and !card.grid_position.is_identical(current_pos):
			all_cards.append(card.grid_position)

	return all_cards

func get_closest_card_to_position(current_pos: Point, cards: Array[Point]):
	var return_point: Point = null
	var distance: float = 10000
		
	for card in cards:
		if card.get_distance(current_pos) < distance:
			return_point = card
			distance = card.get_distance(current_pos) 

	return return_point

func _get_next_card_position(current_pos: Point, go_negative: bool, axis: Axis) -> Point:
	var all_card_positions: Array[Point] = _get_valid_card_positions(current_pos, go_negative, axis)

	var return_point := _get_card_on_same_axis(current_pos, all_card_positions, axis)

	if return_point == null:
		return_point = get_closest_card_to_position(current_pos, all_card_positions)

	return return_point
	
func _get_valid_card_positions(current_pos: Point, go_negative: bool, axis: Axis) -> Array[Point]:
	var all_card_positions: Array[Point] = get_card_grid(current_pos);
	var valid_cards: Array[Point] = []
	for card_position in all_card_positions:
		var current_card_position = 0
		var current_position = 0
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
	for valid_position in valid_positions:
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

func select_card_at_position(grid_position: Point) -> bool:
	var found_card = false
	var initial_card = current_card
	for card in get_children():
		if card is CardTemplate:
			card.lost_focus()
			if grid_position.is_identical(card.grid_position):
				card.got_focus()
				current_card = card
				found_card = true

	if !found_card and current_card != null:
		current_card = initial_card
		current_card.got_focus()
	return found_card

func confirm_current_card():
	if current_card == null or get_tree().paused:
		return
	current_card.card_was_clicked()
	# Card might have been destroyed by action above
	if current_card == null:
		return
	select_closest_card(current_card.grid_position, false)
	
func select_closest_card(source_position: Point, include_source: bool):
	if currently_ai_player:
		return
	var cards: Array[Point] = get_card_grid(source_position)
	if include_source:
		cards.append(source_position)
	var return_position: Point = get_closest_card_to_position(source_position, cards)

	if return_position != null:
		select_card_at_position(return_position)

func get_card_on_position(card_position: Point) -> MemoryCardResource:
	for card in get_children():
		if card is CardTemplate:
			if card_position.is_identical(card.grid_position):
				return card.memory_card
	return null
		
func parse_movement(information: Vector2):	
	if get_tree().paused or currently_ai_player:
		return
	controller_input_was_made = true
	if information != Vector2.ZERO:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	_move_axis(sign(information.x), Axis.X)
	_move_axis(sign(information.y), Axis.Y)

func round_frozen():
	current_card = null

func round_unfrozen():
	if currently_ai_player:
		controller_input_was_made = false
		return
	if controller_input_was_made:
		select_closest_card(Point.new(0,0), true)
	controller_input_was_made = false

func card_loading_done():
	for card in get_children():
		if card is CardTemplate:
			card.mouse_was_used.connect(func(): 
				current_card = null
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			)	

func game_state_changed(game_state:int):
	match game_state:
		GameState.ROUND_START:
			round_unfrozen()
			for card in get_children():
				if card is CardTemplate:
					card.player_changed(currently_ai_player)

		GameState.ROUND_FREEZE:
			round_frozen()

func get_all_card_positions(get_turned: bool = false) -> Array[Point]:
	var return_data: Array[Point] = []
	for card in get_children():
		if card is CardTemplate:
			if get_turned or !card.is_turned():
				return_data.append(card.grid_position)
	return return_data

func get_all_cards_currently_turned() -> Array[Point]:
	var return_data: Array[Point] = []
	for card in get_children():
		if card is CardTemplate:
			if card.is_turned():
				return_data.append(card.grid_position)
	return return_data

func player_changed(current_player:PlayerResource):
	currently_ai_player = current_player.is_ai()