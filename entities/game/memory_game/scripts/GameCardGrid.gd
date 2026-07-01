class_name GameCardGrid extends Node2D

signal board_ready()

signal animations_finished()

@export var state_machine: GameStateSystem
@export var matching_card_sound_effect: AudioStream
@export var visual_card_node: Node2D

@export var card_template: PackedScene

var current_card: CardTemplate

var controller_input_was_made: bool = false
var currently_ai_player: bool = false

var _deck: MemoryDeckResource = null
var _cards: Dictionary[Vector2i, CardTemplate] = {}

enum Axis {X, Y}

func set_deck(deck: MemoryDeckResource) -> void:
	_deck = deck

func trigger_card_at_position(grid_position: Vector2i) -> void:
	if select_card_at_position(grid_position):
		if current_card == null:
			return
		current_card.force_reveal_card()

func remove_cards_from_board(grid_positions: Array[Vector2i]) -> void:
	for grid_position: Vector2i in grid_positions:
		remove_card_from_board(grid_position)
	
	await animations_finished
	GlobalSoundManager.play_sound_effect(matching_card_sound_effect)
	
func remove_card_from_board(grid_position: Vector2i) -> void:
	if _cards.has(grid_position):
		var card: CardTemplate = _cards.get(grid_position)
		_cards.erase(grid_position)
		card.remove_from_board(currently_ai_player)

func _await_animations_finished() -> void:
	## This search must be done on the visual node as the card is already remove from the
	## dictionary track
	for card: Node in visual_card_node.get_children():
		if card != null and card is CardTemplate and card.is_playing_animation():
			await card.animation_done	

func select_card_at_position(grid_position: Vector2i) -> bool:
	var found_card: bool = false
	if _cards.has(grid_position):
		for card: CardTemplate in _cards.values():
			card.change_focus(false)

		var card: CardTemplate = _cards.get(grid_position)
		card.change_focus(true)
		current_card = card
		found_card = true
	return found_card

func round_frozen() -> void:
	current_card = null

func game_state_changed(game_state: GameEnum.State) -> void:
	match game_state:
		GameEnum.State.TURN_FREEZE:
			round_frozen()
		GameEnum.State.PREPARE_TURN_END:
			_prepare_turn_complete()
		GameEnum.State.WAIT_FOR_ANIMATION_FINISH:
			await wait_for_animations()
			animations_finished.emit()
			
func wait_for_animations() -> void:
	await _await_animations_finished()

func _prepare_turn_complete() -> void:
	for card: CardTemplate in _cards.values():
		if card == null or card.is_queued_for_deletion():
			continue
		if not card.card_is_hidden():
			print ("wait hidden card")
			await card.fully_hidden

	#board_ready.emit()

func _any_matching() -> bool:
	var first_found: CardTemplate = null
	for card: CardTemplate in _cards.values():
		if not card.is_turned():
			continue
		if first_found == null:
			first_found = card
			continue	
		if card.get_card_id() == first_found.get_card_id():
			return true
	return false

func get_all_cards_currently_turned() -> Array[Vector2i]:
	var return_data: Array[Vector2i] = []
	for card: CardTemplate in _cards.values():
		if card.is_turned():
			return_data.append(card.grid_position)
	return return_data

func player_changed(current_player:PlayerResource) -> void:
	currently_ai_player = current_player.is_ai()
	if multiplayer.get_peers().size() > 0 and current_player.id != multiplayer.get_unique_id():
		currently_ai_player = true

func place_card(card: MemoryCardResource, grid_position: Vector2i, world_position: Vector2) -> void:
	var card_template_node: CardTemplate = card_template.instantiate() as CardTemplate
	card_template_node.memory_card = card
	card_template_node.position = world_position
	card_template_node.grid_position = grid_position
	card_template_node.card_deck = _deck

	visual_card_node.add_child(card_template_node)
	_cards.set(grid_position, card_template_node)

	state_machine.state_changed.connect(card_template_node.game_state_changed)
