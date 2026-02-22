class_name CardSpawner extends Node


signal field_constructed(cards_on_x: int, cards_on_y: int)
signal card_loading_done()
signal announce_field_size(area: Rect2)
signal card_placed(card: CardTemplate)
signal card_placing_done()

@export var card_template: PackedScene
@export var separation: int = 25
@onready var _card_target_node: Node2D = self.get_parent() as Node2D

var _load_thread: Thread = null
var _place_thread: Thread = null
var _current_deck: MemoryDeckResource

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

func place_cards_from_deck(deck_to_use: MemoryDeckResource) -> void:
	_current_deck = deck_to_use
	if multiplayer.is_server():
		_rpc_announce_deck.rpc(deck_to_use.resource_path)


	_load_thread = Thread.new()
	_load_thread.start(build_card_layout.bind(deck_to_use, card_template, separation))

	await field_constructed
	process_mode = PROCESS_MODE_INHERIT

	var cards: Array[CardTemplate] = _load_thread.wait_to_finish() as Array[CardTemplate]
	_load_thread = null
	
	_place_thread = Thread.new()
	_place_thread.start(_add_cards_to_field_async.bind(cards, _card_target_node))
	
	await card_placing_done
	_place_thread = null
	
	for card: CardTemplate in cards:
		card.visible = true
	announce_card_field()
	card_loading_done.emit()
	queue_free()

func _add_cards_to_field_async(cards: Array[CardTemplate], target: Node2D) -> void:
	for card: CardTemplate in cards:
		card.visible = false
		target.call_deferred("add_child", card)
		
		call_deferred("emit_signal","card_placed", card)
	call_deferred("emit_signal","card_placing_done")

func _calculate_field_size(cards_on_x: int, cards_on_y: int) -> void:
	if card_template == null:
		return
	var card_instance: CardTemplate = card_template.instantiate() as CardTemplate
	var card_height: float = card_instance.get_height() + separation
	var card_width: float = card_instance.get_width() + separation

	var field_width: float = card_width * cards_on_x
	var field_height: float = card_height * cards_on_y

	var center_x: float = field_width / 2
	var center_y: float = field_height / 2

	var field: Rect2 = Rect2(center_x, center_y, field_width, field_height)
	if multiplayer.is_server():
		_rpc_sync_field_size.rpc({
			"x": field.position.x,
			"y": field.position.y,
			"width": field.size.x,
			"height": field.size.y
		})
	announce_field_size.emit(field)

func build_card_layout(deck_of_cards: MemoryDeckResource,
					   template: PackedScene,
					   card_separation: int
					   ) -> Array[CardTemplate]:
	var return_cards: Array[CardTemplate] = []
	var card_pool: Array[MemoryCardResource] = deck_of_cards.cards
	var additional_cards: Array[MemoryCardResource] = deck_of_cards.cards
	card_pool = numbering_cards_from_pool(card_pool)
	card_pool.append_array(numbering_cards_from_pool(additional_cards))
	for i: int in range((randi() % 20) + 1):
		card_pool.shuffle()

	var current_card: int = 0
	var side_length: int = floori(sqrt(card_pool.size()))

	var row_count: int = side_length
	var column_count: int = side_length

	while row_count * column_count < card_pool.size():
		column_count = column_count + 1
	call_deferred("_calculate_field_size", column_count, row_count)
	for y: int in row_count:
		for x: int in column_count:
			var card_template_node: CardTemplate = template.instantiate() as CardTemplate
			card_template_node.card_deck = deck_of_cards
			if current_card >= card_pool.size():
				print("exceed pool!")
				continue
			card_template_node.memory_card = card_pool[current_card]
			var height: float = card_template_node.get_height()
			var width: float = card_template_node.get_width()
			var height_to_set: float = y * height + y * card_separation
			var width_to_set: float = x * width + x * card_separation
			card_template_node.position = Vector2(width_to_set, height_to_set)
			card_template_node.grid_position = Point.new(x, y)
			
			return_cards.append(card_template_node)
			current_card = current_card + 1
	call_deferred("emit_signal","field_constructed", column_count, row_count)
	return return_cards

func numbering_cards_from_pool(card_pool: Array[MemoryCardResource]) -> Array[MemoryCardResource]:
	var cards: Array[MemoryCardResource]
	for i: int in card_pool.size():
		var card: MemoryCardResource = card_pool[i] as MemoryCardResource
		cards.append(card)
	return cards

@rpc("authority", "reliable")
func _rpc_announce_deck(path: String) -> void:
	if _current_deck == null:
		_current_deck = load(path)

func announce_card_field() -> void:
	if !multiplayer.is_server():
		return
	var network_cards: Array[Dictionary] = []
	for card: CardTemplate in _card_target_node.get_children().filter(func(data: Node) -> bool: return data is CardTemplate):
		var real_card: MemoryCardResource = card.memory_card
		network_cards.append({
			"id": real_card.get_id(),
			"grid-position": card.grid_position.get_network_data(),
			"world-position": {
				"x": card.global_position.x,
				"y": card.global_position.y,
			},
			"card-resource": real_card.resource_path
		})

	_rpc_rebuild_field.rpc({"cards": network_cards})

@rpc("authority", "reliable")
func _rpc_rebuild_field(field: Dictionary) -> void:
	if multiplayer.is_server():
		return
	for card: Dictionary in field["cards"]:
		var real_card: CardTemplate = card_template.instantiate() as CardTemplate
		var world_pos: Dictionary = card["world-position"]
		var grid_pos: Dictionary = card["grid-position"]
		real_card.global_position = Vector2(world_pos["x"], world_pos["y"])
		real_card.grid_position = Point.new(grid_pos["x"], grid_pos["y"])
		real_card.memory_card = load(card["card-resource"])
		real_card.card_deck = _current_deck

		real_card.visible = true
		card_placed.emit(real_card)

		_card_target_node.add_child(real_card)
		queue_free()
		
	card_loading_done.emit()

@rpc("authority", "reliable")
func _rpc_sync_field_size(field_size: Dictionary) -> void:
	if multiplayer.is_server():
		return
	var rect: Rect2 = Rect2(field_size["x"], field_size["y"], field_size["width"], field_size["height"])
	announce_field_size.emit(rect)
