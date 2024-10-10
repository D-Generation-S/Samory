extends Node2D

var current_card: CardTemplate;

func get_current_grid_position() -> Point:
	if current_card == null:
		return Point.new(0,0)
	return Point.new(current_card.grid_position.get_x_pos(), current_card.grid_position.get_y_pos())

func move_right():
	var grid_position = get_current_grid_position()
	grid_position.set_x_pos(get_next_x_pos(grid_position.get_x_pos(), false))
	if current_card == null:
		grid_position.set_x_pos(0)
	if !select_card_at_position(grid_position):
		grid_position.set_x_pos(grid_position.get_x_pos() - 1)

func move_left():
	var grid_position = get_current_grid_position()
	grid_position.set_x_pos(get_next_x_pos(grid_position.get_x_pos(), true))
	if current_card == null:
		grid_position.set_x_pos(0)
	if !select_card_at_position(grid_position):
		grid_position.set_x_pos(grid_position.get_x_pos() + 1)

func get_next_x_pos(start_pos: int, go_left: bool) -> int:
	var all_x_positions: Array[int] = []
	for card in get_children():
		if card is CardTemplate:
			var card_x = card.grid_position.get_x_pos()
			if !go_left and card_x > start_pos:
				all_x_positions.append(card_x)
			if go_left and card_x < start_pos:
				all_x_positions.append(card_x)

	all_x_positions.sort()
	if go_left:
		all_x_positions.reverse()
	if all_x_positions.size() == 0:
		return start_pos
	return all_x_positions.pop_front()

func move_up():
	var grid_position = get_current_grid_position()
	grid_position.set_y_pos(grid_position.get_y_pos() - 1)
	if current_card == null:
		grid_position.set_y_pos(0)
	if !select_card_at_position(grid_position):
		grid_position.set_y_pos(grid_position.get_y_pos() + 1)

func move_down():
	var grid_position = get_current_grid_position()
	grid_position.set_y_pos(grid_position.get_y_pos() + 1)
	if current_card == null:
		grid_position.set_y_pos(0)
	if !select_card_at_position(grid_position):
		grid_position.set_y_pos(grid_position.get_y_pos() - 1)

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
	if current_card == null:
		return
	current_card.card_was_clicked()
	select_first_card()
	
func select_first_card():
	var smallest_x = 1000
	var smallest_y = 1000
	for card in get_children():
		if card is CardTemplate:
			if card.grid_position.get_x_pos() < smallest_x:
				smallest_x = card.grid_position.get_x_pos()
			if card.grid_position.get_y_pos() < smallest_y:
				smallest_y = card.grid_position.get_y_pos()
	if !select_card_at_position(Point.new(smallest_x, smallest_y)):
		for card in get_children():
			if card is CardTemplate:
				select_card_at_position(Point.new(card.grid_position.get_x_pos(), card.grid_position.get_y_pos()))

func parse_movement(information: Point):
	if information.get_x_pos() > 0:
		move_right()
	if information.get_x_pos() < 0:
		move_left()
	if information.get_y_pos() > 0:
		move_down()
	if information.get_y_pos() < 0:
		move_up()

