extends Node2D

var current_card: CardTemplate

var currently_forzen: bool = false
var controller_input_was_made: bool = false

func get_current_grid_position() -> Point:
	if current_card == null:
		return Point.new(0,0)
	return Point.new(current_card.grid_position.get_x_pos(), current_card.grid_position.get_y_pos())

func move_x_axis(direction: int):
	var real_direction = clampi(direction, -1, 1)
	if real_direction == 0:
		return
	var grid_position = get_current_grid_position()
	var is_left = real_direction < 0
	grid_position.set_x_pos(get_next_x_pos(grid_position, is_left))
	if current_card == null:
		grid_position.set_x_pos(0)
	if !select_card_at_position(grid_position):
		grid_position.set_x_pos(grid_position.get_x_pos() + real_direction)

func move_y_axis(direction: int):
	var real_direction = clampi(direction, -1, 1)
	if real_direction == 0:
		return
	var grid_position = get_current_grid_position()
	var is_up = real_direction < 0
	grid_position.set_y_pos(get_next_y_pos(grid_position, is_up))
	if current_card == null:
		grid_position.set_y_pos(0)
	if !select_card_at_position(grid_position):
		grid_position.set_y_pos(grid_position.get_y_pos() + real_direction)

func get_next_x_pos(start_pos: Point, go_left: bool) -> int:
	var all_x_positions: Array[int] = []
	for card in get_children():
		if card is CardTemplate and card.grid_position.get_y_pos() == start_pos.get_y_pos() and card.card_is_hidden():
			var card_x = card.grid_position.get_x_pos()
			if !go_left and card_x > start_pos.get_x_pos():
				all_x_positions.append(card_x)
			if go_left and card_x < start_pos.get_x_pos():
				all_x_positions.append(card_x)

	var return_data = get_next_position_from_array(all_x_positions, go_left)
	if return_data == -1:
		return_data = start_pos.get_y_pos()
	return return_data

func get_next_y_pos(start_pos: Point, go_up: bool) -> int:
	var all_y_positions: Array[int] = []
	for card in get_children():
		if card is CardTemplate and card.grid_position.get_x_pos() == start_pos.get_x_pos() and card.card_is_hidden():
			var card_y = card.grid_position.get_y_pos()
			if !go_up and card_y > start_pos.get_y_pos():
				all_y_positions.append(card_y)
			if go_up and card_y < start_pos.get_y_pos():
				all_y_positions.append(card_y)

	var return_data = get_next_position_from_array(all_y_positions, go_up)
	if return_data == -1:
		return_data = start_pos.get_y_pos()
	return return_data

func get_next_position_from_array(data: Array[int], lower: bool) -> int:
	data.sort()
	if data.size() == 0:
		return -1
	if lower:
		return data.pop_back()
	return data.pop_front()

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
	if current_card == null or currently_forzen:
		return
	current_card.card_was_clicked()
	if current_card == null:
		return
	select_closest_card(current_card.grid_position)
	
func select_closest_card(source_position: Point):
	var distance = 10000
	var return_position: Point = null

	for card in get_children():
		if card is CardTemplate and !card.is_turned():
			var current_distance = card.grid_position.get_distance(source_position)
			if current_distance < distance:
				distance = current_distance
				return_position = card.grid_position

	if return_position != null:
		select_card_at_position(return_position)

func parse_movement(information: Vector2):
	if currently_forzen:
		return
	controller_input_was_made = true
	if information != Vector2.ZERO:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	move_x_axis(map_float(information.x))
	move_y_axis(map_float(information.y))

func map_float(input: float) -> int:
	if input > 0:
		return 1
	if input < 0:
		return -1
	return 0

func round_frozen():
	currently_forzen = true
	current_card = null

func round_unfrozen():
	if controller_input_was_made:
		select_closest_card(Point.new(0,0))
	currently_forzen = false
	controller_input_was_made = false

func card_loading_done():
	for card in get_children():
		if card is CardTemplate:
			card.mouse_was_used.connect(func(): 
				current_card = null
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			)
			