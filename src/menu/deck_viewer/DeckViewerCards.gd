extends GridContainer

@export var card_template: PackedScene
@export var deck_container: DeckContainer
@export var scroll_speed: float = 1

@onready var scroll_container: ScrollContainer = get_parent() as ScrollContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSystemDeckManager.loading_system_decks.connect(remove_all_cards)

func _process(delta):
	var scroll_vector = Input.get_axis("scroll_up", "scroll_down")
	print(scroll_vector)
	var is_in_foucus = !deck_container.is_scroll_focus()

	if is_in_foucus:
		scroll_container.scroll_vertical = ceili(scroll_container.scroll_vertical + scroll_vector * scroll_speed)

func show_cards(deck: MemoryDeckResource):
	remove_all_cards() 
	var cards: Array[MemoryCardResource] = deck.cards
	
	cards.sort_custom(card_name_sort)
	for card in cards:
		var card_node = card_template.instantiate() as CardPreview
		card_node.set_card(card)
		add_child(card_node)
		var parent = get_parent() as ScrollContainer

func card_name_sort(a: MemoryCardResource, b: MemoryCardResource):
	return a.name < b.name

func remove_all_cards():
	for card in get_children():
		if card is Control:
			card.visible = false
		card.queue_free()