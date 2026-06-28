class_name GameCardGrid extends Node2D

signal card_removed()
signal all_matching_cards_removed()
signal card_triggered(CardTemplate: CardTemplate)
signal identical_cards(first_card_Vector2i: Vector2i, set_icon_modulated_card_Vector2i: Vector2i)
signal no_matches_found()
signal board_ready()
signal board_empty()
signal card_activated()

@export var state_machine: GameStateSystem
@export var matching_card_sound_effect: AudioStream
@export var visual_card_node: Node2D

var current_card: CardTemplate

var controller_input_was_made: bool = false
var currently_ai_player: bool = false

var number_of_triggered_cards: int = 0

var _field_size: Vector2i = Vector2i.ZERO
var _game_completed: bool = false

enum Axis {X, Y}

func get_current_grid_position() -> Vector2i:
	if current_card == null:
		return -Vector2i.ONE
	return current_card.grid_position

func receive_field_size(x: int, y: int) -> void:
	_field_size = Vector2i(x - 1, y - 1) # Field size starts at 1 but index starts at 0

func get_field_size() -> Vector2i:
	return _field_size

func _get_valid_card_positions(current_pos: Vector2i, go_negative: bool, axis: Axis) -> Array[Vector2i]:
	var all_card_positions: Array[Vector2i] = get_card_grid(current_pos);
	var valid_cards: Array[Vector2i] = []
	for card_position: Vector2i in all_card_positions:
		var current_card_position: int = 0
		var current_position: int = 0
		match axis:
			Axis.X:
				current_card_position = card_position.x
				current_position = current_pos.x
			Axis.Y:
				current_card_position = card_position.y
				current_position = current_pos.y
		
		if go_negative and current_card_position >= current_position:
			continue
		if !go_negative and current_card_position <= current_position:
			continue
		valid_cards.append(card_position)
	return valid_cards

func get_card_grid(current_pos: Vector2i) -> Array[Vector2i]:
	var all_cards: Array[Vector2i] = []
	for card: Node2D in visual_card_node.get_children():
		if card is CardTemplate and card.grid_position != current_pos and not card.is_getting_removed():
			all_cards.append(card.grid_position)

	return all_cards

func trigger_card_at_position(grid_position: Vector2i) -> void:
	if select_card_at_position(grid_position):
		if current_card == null:
			return
		current_card.force_reveal_card()

func remove_cards_from_board(grid_positions: Array[Vector2i]) -> void:
	for grid_position: Vector2i in grid_positions:
		remove_card_from_board(grid_position)
	for card: CardTemplate in _get_game_card_templates():
		if card.is_playing_animation():
			await card.about_to_get_delete
	all_matching_cards_removed.emit()
	GlobalSoundManager.play_sound_effect(matching_card_sound_effect)
	
func remove_card_from_board(grid_position: Vector2i) -> void:
	for child: CardTemplate in _get_game_card_templates_children():
		if child.grid_position == grid_position:
			child.remove_from_board(currently_ai_player)
			child.about_to_get_delete.connect(func() -> void: card_removed.emit())

func select_card_at_position(grid_position: Vector2i) -> bool:
	var found_card: bool = false
	var initial_card: CardTemplate = current_card
	for card: CardTemplate in _get_game_card_templates_children():
		card.lost_focus()
		if grid_position == card.grid_position:
			card.got_focus()
			current_card = card
			found_card = true

	if !found_card and current_card != null:
		current_card = initial_card
		current_card.got_focus()
	return found_card


func get_card_on_position(card_position: Vector2i) -> MemoryCardResource:
	for card: CardTemplate in _get_game_card_templates_children():
		if card_position == card.grid_position:
			return card.memory_card
	return null

func round_frozen() -> void:
	current_card = null

func card_loading_done() -> void:
	for card: CardTemplate in _get_game_card_templates():
		card.mouse_was_used.connect(func() -> void: 
			current_card = null
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		)

func game_state_changed(game_state: GameEnum.State) -> void:
	match game_state:
		GameEnum.State.TURN_START:
			for card: CardTemplate in _get_game_card_templates():
				card.player_changed(currently_ai_player)
			print(_get_game_card_templates().size())
			if _get_game_card_templates().size() == 0:
				_announce_empty_board()

		GameEnum.State.TURN_FREEZE:
			round_frozen()
		GameEnum.State.TURN_COMPLETED:
			_validate_grid()
		GameEnum.State.PREPARE_TURN_END:
			_prepare_turn_complete()

func _announce_empty_board() -> void:
	if _game_completed:
		return
	_game_completed = true
	board_empty.emit()

func _validate_grid() -> void:
	for card: CardTemplate in _get_game_card_templates():
		if card == null or card.is_queued_for_deletion():
			continue
		if card.is_turned() and not card.card_is_fully_shown():
			await card.fully_shown
	if _any_matching():
		var card_positions: Array[Vector2i] = []
		for card: CardTemplate in _get_game_card_templates():
			if card.is_turned():
				card_positions.append(card.grid_position)
		identical_cards.emit(card_positions[0], card_positions[1])
		remove_cards_from_board(card_positions)
		var count: int = _get_game_card_templates().filter(func (card: CardTemplate) -> bool: return not card.is_getting_removed()).size()
		if count == 0:
			_announce_empty_board()
			
		return


	no_matches_found.emit()

func _prepare_turn_complete() -> void:
	for card: CardTemplate in _get_game_card_templates():
		if card == null or card.is_queued_for_deletion():
			continue
		if not card.card_is_hidden():
			print ("wait hidden card")
			await card.fully_hidden
	
	print ("continue prepare turn complete")
	var all_cards: Array[CardTemplate] = _get_game_card_templates()
	if all_cards.size() == 0:
		_announce_empty_board()
		return

	board_ready.emit()

func _any_matching() -> bool:
	var first_found: CardTemplate = null
	for card: CardTemplate in _get_game_card_templates():
		if not card.is_turned():
			continue
		if first_found == null:
			first_found = card
			continue	
		if card.get_card_id() == first_found.get_card_id():
			return true
	return false

func get_all_card_positions(get_turned: bool = false) -> Array[Vector2i]:
	var return_data: Array[Vector2i] = []
	for card: CardTemplate in _get_game_card_templates_children():
		if card.is_getting_removed():
			continue
		if get_turned or !card.is_turned():
			return_data.append(card.grid_position)
	return return_data

func get_all_cards_currently_turned() -> Array[Vector2i]:
	var return_data: Array[Vector2i] = []
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
	for card_template: CardTemplate in visual_card_node.get_children().filter(func(data: Node) -> bool: return data is CardTemplate):
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
