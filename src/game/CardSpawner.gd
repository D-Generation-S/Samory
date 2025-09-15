class_name CardSpawner extends Node


signal field_constructed(cards_on_x: int, cards_on_y: int)
signal card_loading_done()
signal announce_field_size(area: Rect2)
signal card_placed(card: CardTemplate)

@export var card_template: PackedScene
@export var separation: int = 25
@onready var _card_target_ode: Node2D = self.get_parent() as Node2D

var load_thread: Thread = null

func _ready():
	process_mode = Node.PROCESS_MODE_DISABLED

func place_cards_from_deck(deck_to_user: MemoryDeckResource):
	load_thread = Thread.new()
	load_thread.start(build_card_layout.bind(deck_to_user, card_template, separation))

	await field_constructed

	process_mode = PROCESS_MODE_INHERIT

	var cards = load_thread.wait_to_finish() as Array[CardTemplate]
	for card in cards:
		_card_target_ode.add_child(card)
		card.visible = false
		card_placed.emit(card)
		
	load_thread = null
	for card in cards:
		card.visible = true
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

	announce_field_size.emit(Rect2(center_x, center_y, field_width, field_height))

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
		card.set_id(i)
		cards.append(card)
	return cards
