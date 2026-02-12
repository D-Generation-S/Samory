class_name EditCustomDeck extends CanvasLayer

signal deck_name_changed(new_name: String)
signal card_added(card: CustomDeckResource)
signal card_updated(card: CustomDeckResource)
signal show_card(card: MemoryCardResource)

var _resources: Array[CustomDeckResource] = []
var _deck_loader: CustomDeckLoader = CustomDeckLoader.new()

func set_deck(deck: CustomDeckResource) -> void:
	_resources.append(deck)
	deck_name_changed.emit(deck.get_resource_name())

func get_deck() -> CustomDeckResource:
	for data: CustomDeckResource in _resources:
		if data.get_is_deck():
			return data
	return null

func delete_card(card: CustomDeckResource) -> void:
	for card_resource: CustomDeckResource in _resources:
		if card_resource.get_id() == card.get_id():
			_resources.erase(card_resource)


func add_or_update_card(card: CustomDeckResource) -> void:
	for card_resource: CustomDeckResource in _resources:
		if card_resource.get_id() == card.get_id():
			card_resource.set_deck_name(card.get_resource_name())
			card_resource.set_description(card.get_description())
			card_resource.set_image(card.get_image_path())
			card_updated.emit(card_resource)
			return

	card.set_id(_get_next_card_id())
	_resources.append(card)
	card_added.emit(card)
	

func _get_next_card_id() -> int:
	var max_id: int = 0
	for resource: CustomDeckResource in _resources:
		if resource.get_id() > max_id:
			max_id = resource.get_id()
	return max_id + 1


func save_deck() -> void:
	if _deck_loader.save_deck(get_deck(), _resources):
		GlobalGameManagerAccess.get_game_manager().reload_system_decks()

func view_card(resource: CustomDeckResource) -> void:
	var card: MemoryCardResource = _deck_loader.convert_to_playable_card(resource)
	show_card.emit(card)