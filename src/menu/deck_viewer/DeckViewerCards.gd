extends GridContainer

signal cards_preloaded()

@export var card_template: PackedScene
@export var deck_container: DeckContainer
@export var scroll_speed: float = 1

@export var system_card_container: Control = null
@export var built_in_card_container: Control = null

@onready var scroll_container: ScrollContainer = get_parent() as ScrollContainer

var is_initial_load: bool = true
var current_deck: MemoryDeckResource = null
var card_gen_thread: Thread = null

func create_new_card_container(node_name: String) -> CardViewerTemplate:
	var return_container = CardViewerTemplate.new()

	return_container.name = node_name
	return return_container

func _process(_delta):
	var scroll_vector = Input.get_axis("scroll_up", "scroll_down")
	var is_in_foucus = !deck_container.is_scroll_focus()

	if is_in_foucus:
		scroll_container.scroll_vertical = ceili(scroll_container.scroll_vertical + scroll_vector * scroll_speed)

func clear_card_view(restore_system: bool = true):
	if get_children().size() == 0:
		return
	if !restore_system and !current_deck.built_in:
		for card in get_children():
			card.queue_free()
		return
	move_cards_back(current_deck)
	current_deck = null

func decks_loading():
	clear_card_view(false)

func show_cards(deck: MemoryDeckResource):
	if current_deck != null:
		move_cards_back(current_deck)

	current_deck = deck
	var deck_card_parent = get_deck_preload_node(deck)
	if deck_card_parent == null:
		printerr("Deck template was missing, help")
		return

	for card_node in deck_card_parent.get_children():
		card_node.reparent(self)

func get_deck_preload_node(deck: MemoryDeckResource) -> Control:
	var source_node = built_in_card_container
	if !deck.built_in:
		source_node = system_card_container

	var deck_card_parent = null 
	for deck_template in source_node.get_children():
		if deck_template.name == str(deck.id):
			deck_card_parent = deck_template
			break

	return deck_card_parent

func card_name_sort(a: MemoryCardResource, b: MemoryCardResource):
	return a.name < b.name

func decks_loaded(decks: Array[MemoryDeckResource]):
	clear_all_system_cards()

	process_mode = Node.PROCESS_MODE_DISABLED
	card_gen_thread = Thread.new()
	card_gen_thread.start(get_cards_async.bind(decks, is_initial_load))
	is_initial_load = false

	await cards_preloaded

	process_mode = Node.PROCESS_MODE_INHERIT

	var data = card_gen_thread.wait_to_finish() as Array[CardViewerTemplate]
	card_gen_thread = null

	for card in data:
		var parent = system_card_container
		if card.built_in:
			parent = built_in_card_container
		parent.add_child(card)

func get_cards_async(decks: Array[MemoryDeckResource], inital_load: bool) -> Array[Control]:
	var return_data: Array[Control] = []
	for deck in decks:
		if !deck.built_in or inital_load:
			return_data.append(load_cards_from_deck(deck))
	inital_load = false

	call_deferred("emit_signal","cards_preloaded")
	return return_data

func load_cards_from_deck(deck: MemoryDeckResource) -> CardViewerTemplate:
	var parent = create_new_card_container(str(deck.id))
	parent.built_in = deck.built_in

	var cards: Array[MemoryCardResource] = deck.cards
	cards.sort_custom(card_name_sort)

	var card_number: int = 0
	for card in cards:
		var card_node = card_template.instantiate() as CardPreview
		card_node.set_card(card)
		card_node.name = str(card_number)
		parent.add_child(card_node)
		card_number = card_number + 1
	
	return parent

func clear_all_system_cards():
	for card in system_card_container.get_children():
		card.queue_free()

func move_cards_back(target_deck: MemoryDeckResource):
	var deck_card_parent = get_deck_preload_node(target_deck)
	if deck_card_parent == null:
		printerr("Missing deck parent")
		return

	for card in get_children():
		card.reparent(deck_card_parent)
