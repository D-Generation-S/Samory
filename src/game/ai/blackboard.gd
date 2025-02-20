class_name Blackboard extends Resource

var unlimited_memory: bool = true
var max_cards_to_remember: int = -1
var cards: Array[CardInformationResource] = []
var latest_added_card: CardInformationResource = null;

func _init(max_cards: int):
	max_cards_to_remember = max_cards
	unlimited_memory = max_cards_to_remember == -1


func add_card(position: Point, card: MemoryCardResource):
	var new_card = CardInformationResource.new(position, card)
	if !cards.any(func(current_card): return current_card.position.is_identical(position)):
		cards.append(new_card)
		latest_added_card = new_card
		ensure_memory_boundry()
		return

	move_card_to_top(position)

func move_card_to_top(card_position: Point):
	var index = -1
	var running_index = 0
	for current_card in cards:
		if card_position.is_identical(current_card.position):
			index = running_index
			break
		running_index = running_index + 1

	if index == -1:
		return

	var saved_card = cards[index]
	cards.remove_at(index)
	cards.append(saved_card)

func ensure_memory_boundry():
	if unlimited_memory or cards.size() <= max_cards_to_remember:
		return
	var cards_to_remove = cards.size() - max_cards_to_remember
	for i in range(cards_to_remove):
		cards.remove_at(0)

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
	var index = randi_range(0, cards_remembered() - 1)
	return cards[index]

func get_all_saved_cards() -> Array[CardInformationResource]:
	return cards

func get_last_saved_card() -> CardInformationResource:
	for current_card in cards:
		if current_card.position.is_identical(latest_added_card.position):
			return current_card

	return null
