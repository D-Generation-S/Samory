class_name CardInteractionField extends Node2D

signal mouse_enter(grid: Vector2i)
signal mouse_left(grid: Vector2i)
signal clicked(grid: Vector2i)
signal card_activated()
signal remove_cards_at(cards: Array[Vector2i])
signal ai_information_card_clicked(grid: Vector2i, card: MemoryCardResource)

signal place_card(card: MemoryCardResource, grid_position: Vector2i, world_position: Vector2)
signal board_area(area: Rect2)
signal board_build()

# Methods to manage game flow

signal remove_card_at(grid_coordinate: Vector2i)

## The whole board is empty now
signal board_empty()

## Player turn did end
signal turn_ended()

## A match was found
signal match_found()


enum Axis {X, Y}

@export_group("Field Settings")
@export var default_texture_size: Vector2 = Vector2(499, 550)
@export var collider_template: PackedScene = null
@export var additional_offset: Vector2i = Vector2i(0, 25)

@export_group("Sound Effects")
@export var card_selection_sounds: Array[AudioStream] = []
## Set the pitch to change for each sound effect, a value of 0.2, will set the range to 0.8 and 1.2.
@export var card_selection_sound_pitch: float = 0.2

var _separation: int = 0
var _offset: Vector2i = Vector2i.ZERO
var _card_size: Vector2
var _field_size: Vector2i = Vector2i.ZERO

var _is_ai_player: bool = false
var _selected_grid_position: Vector2i = -Vector2i.ONE
var _controller_input_was_made: bool = false

var _placed_cards: Dictionary[Vector2i, CardCollider]
var _current_deck: MemoryDeckResource = null

var possible_movements: Array[Vector2] = [
		Vector2.RIGHT,
		Vector2.DOWN,
		Vector2.LEFT,
		Vector2.UP
	]

func _init() -> void:
	remove_card_at.connect(remove_card)
	mouse_enter.connect(_play_selection_sound)

func _play_selection_sound(_grid_position: Vector2i) -> void:
	if card_selection_sounds.size() == 0:
		return
	GlobalSoundManager.play_sound_effect(card_selection_sounds.pick_random(), 0.0, randf_range(1.0 - card_selection_sound_pitch, 1.0 + card_selection_sound_pitch))

func _reset_grid_position() -> void:
	_selected_grid_position = -Vector2i.ONE

func set_board_information(deck_to_use: MemoryDeckResource, card_separation: int, field_offset: Vector2i) -> void:
	_current_deck = deck_to_use

	var back_image: Texture2D = deck_to_use.get_back_image()
	_card_size = default_texture_size
	if back_image != null:
		_card_size = deck_to_use.get_back_image().get_size()
	_separation = card_separation
	_offset = field_offset

	await _create_field()
	var area: Rect2 = _calculate_field_area()
	board_area.emit(area)
	board_build.emit()

func _create_field() -> void:
	var play_cards: Array[MemoryCardResource] = _create_card_set()
	_field_size = _calculate_field_size(play_cards.size())
	
	build_field(play_cards)
	await RenderingServer.frame_post_draw

func _calculate_field_size(card_count: int) -> Vector2i:
	if card_count <= 0:
		return Vector2i.ZERO

	var side_length: int = floori(sqrt(card_count))

	var row_count: int = side_length
	var column_count: int = side_length

	while row_count * column_count < card_count:
		column_count = column_count + 1

	return Vector2i(column_count, row_count)

func _create_card_set() -> Array[MemoryCardResource]:
	var return_data: Array[MemoryCardResource] = []
	for card: MemoryCardResource in _current_deck.cards:
		return_data.append(card)
		return_data.append(card)

	return_data.shuffle()
	return return_data

func build_field(cards: Array[MemoryCardResource]) -> void:
	for x: int in _field_size.x:
		for y: int in _field_size.y:
			if cards.size() == 0:
				return
			var card: MemoryCardResource = cards.pick_random()
			_remove_card_from_cards_stack(card.id, cards)
			var x_addition: int = _separation * x
			x_addition += int(_card_size.x) * x
			var y_addition: int = _separation * y
			y_addition += int(_card_size.y) * y
			var template: CardCollider = collider_template.instantiate()
			template.set_size(_card_size)
			template.position = _offset + additional_offset + Vector2i(x_addition, y_addition)
			template.set_grid_coordinate(Vector2i(x, y))
			template.set_data(card)
			_connect_card_interaction(template)
			_placed_cards.set(Vector2i(x, y), template)
			add_child(template)
			template.disable_collider()
			place_card.emit(card, Vector2i(x, y), Vector2i(x_addition, y_addition) + _offset)

func _calculate_field_area() -> Rect2:
	var field_width: float = _card_size.x * _field_size.x
	var field_height: float = _card_size.y * _field_size.y

	var center_x: float = field_width / 2
	var center_y: float = field_height / 2
	return Rect2(center_x, center_y, field_width, field_height)

func _remove_card_from_cards_stack(id: int, cards: Array[MemoryCardResource]) -> void:
	var index: int = cards.find_custom((func(card: MemoryCardResource) -> bool: return card.id == id))
	cards.remove_at(index)

func get_field_size() -> Vector2i:
	return _field_size

func card_was_added(card: CardTemplate) -> void:
	card.remove_requested.connect(remove_card.bind(card.grid_position))

func remove_card(grid_position: Vector2i) -> void:
	if _placed_cards.has(grid_position):
		var child: CardCollider = _placed_cards.get(grid_position)
		child.queue_free()
		_placed_cards.erase(grid_position)
		_check_if_board_empty()

func _check_if_board_empty() -> void:
	if _placed_cards.size() == 0:
		board_empty.emit()


func player_changed(current_player: PlayerResource) -> void:
	_is_ai_player = current_player.is_ai()

func game_state_changed(new_state: GameEnum.State) -> void:
	var _new_collider_enabled_state: bool = false
	if new_state == GameEnum.State.TURN_START:
		_new_collider_enabled_state = true
			
	if new_state == GameEnum.State.TURN_FREEZE:
		_new_collider_enabled_state = false

	_change_interaction_state(_new_collider_enabled_state)

func _change_interaction_state(new_state: bool) -> void:
	for child: CardCollider in _placed_cards.values():
		if new_state:
			child.reset()
			if not _is_ai_player:
				child.enable_collider()
		else:
			child.disable_collider()

func parse_movement(information: Vector2) -> void:
	if get_tree().paused or _is_ai_player:
		_controller_input_was_made = false
		return
	_controller_input_was_made = true
	if information != Vector2.ZERO:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	mouse_left.emit(_selected_grid_position)
	var card_position: Vector2i =_get_closest_card_position(information)
	if card_position == -Vector2i.ONE:  # or !select_card_at_position(card_position):
		card_position = _selected_grid_position

	_selected_grid_position = card_position
	mouse_enter.emit(_selected_grid_position)

func _get_closest_card_position(movement: Vector2) -> Vector2i:
	var target_position: Vector2i = Vector2i(int(movement.x), int(movement.y)) + _selected_grid_position
	if _selected_grid_position == -Vector2i.ONE:
		_selected_grid_position = -Vector2i.ONE
		target_position = Vector2i.ZERO

	target_position.x = clampi(target_position.x, 0, _field_size.x)
	target_position.y = clampi(target_position.y, 0, _field_size.y)

	if _selected_grid_position == target_position:
		return _selected_grid_position
	
	var axis: Axis = Axis.X
	var is_negative: bool = false
	var closest_distance: float = 100000.0
	var return_position: Vector2i = -Vector2i.ONE

	if movement.y != 0:
		axis = Axis.Y

	if movement.y < -0.0001 or movement.x < -0.0001:
		is_negative = true
	for valid_position: Vector2i in _get_all_relevant_available_cards(_selected_grid_position, is_negative, axis):
		if valid_position == target_position:
			return valid_position
		var calculate_distance: Vector2i = valid_position
		var weight: int = (_field_size.x + _field_size.y) * 2
		if axis == Axis.X:
			if valid_position.x == target_position.x:
				weight = 0
		else:
			if valid_position.y == target_position.y:
				weight = 0
		var current_distance: float = calculate_distance.distance_to(target_position) + weight
		if current_distance < closest_distance:
			closest_distance = current_distance
			return_position = valid_position

	return return_position

func get_card_id_from_position(grid_position: Vector2i) -> int:
	if _placed_cards.has(grid_position):
		return _placed_cards.get(grid_position).get_card_id()
	return -1

func get_all_card_positions(get_turned: bool = false) -> Array[Vector2i]:
	var card_positions: Array[Vector2i] = []
	for card_collider: CardCollider in _placed_cards.values():
		if card_collider != null and not card_collider.is_queued_for_deletion():
			if get_turned or card_collider.is_active():
				card_positions.append(card_collider.get_grid_coordinate())
	return card_positions

func get_all_disabled_cards() -> Array[Vector2i]:
	var card_positions: Array[Vector2i] = []
	for card_collider: CardCollider in _placed_cards.values():
		if card_collider != null and not card_collider.is_queued_for_deletion():
			if not card_collider.is_active():
				card_positions.append(card_collider.get_grid_coordinate())
	return card_positions

func is_there_a_card_on_position(grid_position: Vector2i) -> bool:
	for card_collider: CardCollider in _placed_cards.values():
		if card_collider.get_grid_coordinate() == grid_position:
			var active: bool = card_collider.is_active()
			return active
	return false

func _get_all_relevant_available_cards(current_pos: Vector2i, go_negative: bool, axis: Axis) -> Array[Vector2i]:
	var valid_cards: Array[Vector2i] = []
	for card_collider: Node in _placed_cards.values():
		if card_collider != null and not card_collider.is_queued_for_deletion() and card_collider is CardCollider:
			if _check_if_valid_card(current_pos, go_negative, axis, card_collider):
				valid_cards.append(card_collider.get_grid_coordinate())
	return valid_cards

func _check_if_valid_card(current_pos: Vector2i, go_negative: bool, axis: Axis, card: CardCollider) -> bool:
	if not card.is_active():
		return false
	match axis:
		Axis.X:
			if go_negative:
				return card.get_grid_coordinate().x < current_pos.x
			return card.get_grid_coordinate().x > current_pos.x
		Axis.Y:
			if go_negative:
				return card.get_grid_coordinate().y < current_pos.y
			return card.get_grid_coordinate().y > current_pos.y
			
	return false

func confirm_selected_card() -> void:
	mouse_has_clicked(_selected_grid_position)

func _connect_card_interaction(collider: CardCollider) -> void:
	collider.mouse_enter.connect(mouse_has_entered)
	collider.mouse_enter.connect(_mouse_movement_was_made)
	collider.mouse_left.connect(mouse_has_left)
	collider.mouse_left.connect(_mouse_movement_was_made)
	collider.clicked.connect(card_was_clicked)

func _mouse_movement_was_made(_grid_position: Vector2i) -> void:
	_controller_input_was_made = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func card_was_clicked(grid_position: Vector2i, data: MemoryCardResource) -> void:
	clicked.emit(grid_position)
	card_activated.emit()
	ai_information_card_clicked.emit(grid_position, data)

	_check_board_state()

func _check_board_state() -> void:
	var cards: Array[CardCollider] = _placed_cards.values().filter(func(card: CardCollider) -> bool: return not card.is_active())
	if cards.size() < 2:
		return
	if _check_for_matching(cards):
		match_found.emit()
		return
	
	turn_ended.emit()

func _check_for_matching(cards: Array[CardCollider]) -> bool:
	if cards.size() != 2:
		return false
	if cards[0].get_card_id() == cards[1].get_card_id():
		var grid_positions: Array[Vector2i] = []
		
		for card: CardCollider in cards:
			grid_positions.append(card.get_grid_coordinate())
		remove_cards_at.emit(grid_positions)
		remove_card_at.emit(grid_positions[0])
		remove_card_at.emit(grid_positions[1])
		return true
	return false

func mouse_has_clicked(grid_position: Vector2i) -> void:
	if not _placed_cards.has(grid_position):
		return
	
	var card: CardCollider = _placed_cards.get(grid_position)
	if not card.is_active():
		return
	card.activate()

	_reset_player_selection()

func _reset_player_selection() -> void:
	if _is_ai_player:
		return
	
	if not _controller_input_was_made:
		_reset_grid_position()
		return
	_selected_grid_position = _get_closest_card()
	mouse_has_entered(_selected_grid_position)

func _get_closest_card() -> Vector2i:
	for direction: Vector2 in possible_movements:
		var possible_position: Vector2i = _get_closest_card_position(direction)
		if possible_position != -Vector2i.ONE:
			return possible_position
		
	return -Vector2i.ONE

func mouse_has_entered(grid_position: Vector2i) -> void:
	mouse_enter.emit(grid_position)
	_selected_grid_position = grid_position

func mouse_has_left(grid_position: Vector2i) -> void:
	mouse_left.emit(grid_position)
	_selected_grid_position = grid_position