class_name Blackboard extends Resource

var cards: Array[CardInformationResource] = []
var latest_added_card: CardInformationResource = null;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_card(position: Point, card: MemoryCardResource):
	var new_card = CardInformationResource.new(position, card)
	var card_exists = false
	for current_card in cards:
		if current_card.position.is_identical(position):
			card_exists = true
			break
	if !card_exists:
		cards.append(new_card)
		latest_added_card = new_card

func remove_card(position: Point):
	var index = 0
	var match_found = false
	for card in cards:
		if card.position.is_identical(position):
			match_found = true
			break
		index = index + 1

	if match_found:
		cards.remove_at(index)

func cards_remembered() -> int:
	return cards.size()

func get_all_cards_with_id(id: int) -> Array[CardInformationResource]:
	return cards.filter(func(current_card): return current_card.card.id == id)

func get_random_known_card_from_storage() -> CardInformationResource:
	if cards_remembered() == 0:
		return null
	var available_cards: Array[CardInformationResource] = []
	var index = randi_range(0, cards_remembered() - 1)
	return cards[index]
#func get_card_positions_by_id(index: int) -> Array[CardInformationResource]:
#	return []

func get_last_saved_card() -> CardInformationResource:
	for current_card in cards:
		if current_card.position.is_identical(latest_added_card.position):
			return current_card

	return null
