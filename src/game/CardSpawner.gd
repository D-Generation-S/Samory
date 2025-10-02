class_name CardSpawner extends Node


signal field_constructed(cards_on_x: int, cards_on_y: int)
signal card_loading_done()
signal announce_field_size(area: Rect2)
signal card_placed(card: CardTemplate)

@export var card_template: PackedScene
@export var separation: int = 25
@onready var _card_target_node: Node2D = self.get_parent() as Node2D

var load_thread: Thread = null
var _current_deck: MemoryDeckResource

func _ready():
	process_mode = Node.PROCESS_MODE_DISABLED

func place_cards_from_deck(deck_to_use: MemoryDeckResource):
	_current_deck = deck_to_use
	if multiplayer.is_server():
		_rpc_announce_deck.rpc(deck_to_use.resource_path)
	load_thread = Thread.new()
	load_thread.start(build_card_layout.bind(deck_to_use, card_template, separation))

	await field_constructed

	process_mode = PROCESS_MODE_INHERIT

	var cards = load_thread.wait_to_finish() as Array[CardTemplate]
	for card in cards:
		_card_target_node.add_child(card)
		card.visible = false
		card_placed.emit(card)
		
	load_thread = null
	for card in cards:
		card.visible = true
	announce_card_field()
	card_loading_done.emit()
	queue_free()

func _calculate_field_size(cards_on_x: int, cards_on_y: int):
	if card_template == null:
		return
	var card_instance = card_template.instantiate()
	var card_height = card_instance.get_height() + separation
	var card_width = card_instance.get_width() + separation

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
	var card_pool = deck_of_cards.cards
	var additional_cards = deck_of_cards.cards
	card_pool = numbering_cards_from_pool(card_pool)
	card_pool.append_array(numbering_cards_from_pool(additional_cards))
	for i in range((randi() % 20) + 1):
		card_pool.shuffle()

	var current_card = 0
	var side_length = floor(sqrt(card_pool.size()))

	var row_count = side_length
	var column_count = side_length

	while row_count * column_count < card_pool.size():
		column_count = column_count + 1
	call_deferred("_calculate_field_size", column_count, row_count)
	for y in range(row_count):
		for x in range(column_count):
			var card_template_node = template.instantiate() as CardTemplate
			card_template_node.card_deck = deck_of_cards
			if current_card >= card_pool.size():
				print("exceed pool!")
				continue
			card_template_node.memory_card = card_pool[current_card]
			var height = card_template_node.get_height()
			var width = card_template_node.get_width()
			var height_to_set = y * height + y * card_separation
			var width_to_set = x * width + x * card_separation
			card_template_node.position = Vector2(width_to_set, height_to_set)
			card_template_node.grid_position = Point.new(x, y)
			
			return_cards.append(card_template_node)
			current_card = current_card + 1
	call_deferred("emit_signal","field_constructed", column_count, row_count)
	return return_cards

func numbering_cards_from_pool(card_pool) -> Array:
	var cards: Array
	for i in range(card_pool.size()):
		var card = card_pool[i] as MemoryCardResource
		#card.set_id(i)
		cards.append(card)
	return cards

@rpc("authority", "reliable")
func _rpc_announce_deck(path: String):
	if _current_deck == null:
		_current_deck = load(path)

func announce_card_field():
	if !multiplayer.is_server():
		return
	var network_cards: Array[Dictionary] = []
	for card in _card_target_node.get_children():
		if card is CardTemplate:
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
func _rpc_rebuild_field(field: Dictionary):
	print(field)
	if multiplayer.is_server():
		return
	for card in field["cards"]:
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
func _rpc_sync_field_size(field_size: Dictionary):
	if multiplayer.is_server():
		return
	var rect: Rect2 = Rect2(field_size["x"], field_size["y"], field_size["width"], field_size["height"])
	announce_field_size.emit(rect)
