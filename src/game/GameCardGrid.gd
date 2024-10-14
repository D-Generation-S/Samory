extends Node2D

var current_card: CardTemplate;

var currently_forzen: bool = false

func get_current_grid_position() -> Point:
	if current_card == null:
		return Point.new(0,0)
	return Point.new(current_card.grid_position.get_x_pos(), current_card.grid_position.get_y_pos())

func move_right():
	var grid_position = get_current_grid_position()
	grid_position.set_x_pos(get_next_x_pos(grid_position, false))
	if current_card == null:
		grid_position.set_x_pos(0)
	if !select_card_at_position(grid_position):
		grid_position.set_x_pos(grid_position.get_x_pos() - 1)

func move_left():
	var grid_position = get_current_grid_position()
	grid_position.set_x_pos(get_next_x_pos(grid_position, true))
	if current_card == null:
		grid_position.set_x_pos(0)
	if !select_card_at_position(grid_position):
		grid_position.set_x_pos(grid_position.get_x_pos() + 1)

func get_next_x_pos(start_pos: Point, go_left: bool) -> int:
	var all_x_positions: Array[int] = []
	for card in get_children():
		if card is CardTemplate and card.grid_position.get_y_pos() == start_pos.get_y_pos():
			var card_x = card.grid_position.get_x_pos()
			if !go_left and card_x > start_pos.get_x_pos():
				all_x_positions.append(card_x)
			if go_left and card_x < start_pos.get_x_pos():
				all_x_positions.append(card_x)

	all_x_positions.sort()
	if go_left:
		all_x_positions.reverse()
	if all_x_positions.size() == 0:
		return start_pos.get_x_pos()
	return all_x_positions.pop_front()

func move_up():
	var grid_position = get_current_grid_position()
	grid_position.set_y_pos(get_next_y_pos(grid_position, true))
	if current_card == null:
		grid_position.set_y_pos(0)
	if !select_card_at_position(grid_position):
		grid_position.set_y_pos(grid_position.get_y_pos() + 1)

func move_down():
	var grid_position = get_current_grid_position()
	grid_position.set_y_pos(get_next_y_pos(grid_position, false))
	if current_card == null:
		grid_position.set_y_pos(0)
	if !select_card_at_position(grid_position):
		grid_position.set_y_pos(grid_position.get_y_pos() - 1)

func get_next_y_pos(start_pos: Point, go_up: bool) -> int:
	var all_y_positions: Array[int] = []
	for card in get_children():
		if card is CardTemplate and card.grid_position.get_x_pos() == start_pos.get_x_pos():
			var card_y = card.grid_position.get_y_pos()
			if !go_up and card_y > start_pos.get_y_pos():
				all_y_positions.append(card_y)
			if go_up and card_y < start_pos.get_y_pos():
				all_y_positions.append(card_y)

	all_y_positions.sort()
	if go_up:
		all_y_positions.reverse()
	if all_y_positions.size() == 0:
		return start_pos.get_y_pos()
	return all_y_positions.pop_front()

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

func parse_movement(information: Point):
	if currently_forzen:
		return
	if information.get_x_pos() > 0:
		move_right()
	if information.get_x_pos() < 0:
		move_left()
	if information.get_y_pos() > 0:
		move_down()
	if information.get_y_pos() < 0:
		move_up()

func round_frozen():
	currently_forzen = true
	current_card = null

func round_unfrozen():
	select_closest_card(Point.new(0,0))
	currently_forzen = false