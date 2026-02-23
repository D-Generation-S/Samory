extends VBoxContainer

@export var card_entry_scene: PackedScene = null
@export var min_card_amount: int = 2

signal view_card_requested(deck_resource: CustomDeckResource)
signal edit_card_requested(deck_resource: CustomDeckResource)
signal delete_card_requested(deck_resource: CustomDeckResource)
signal card_amount_valid()
signal card_amount_invalid()

func add_card_entry(deck_resource: CustomDeckResource) -> void:
	var entry: CustomDeckCardEntry = card_entry_scene.instantiate() as CustomDeckCardEntry
	entry.set_deck_resource(deck_resource)
	entry.edit_card_requested.connect(card_edit_request)
	entry.delete_card_requested.connect(card_delete_request)
	entry.view_card_requested.connect(card_view_request)

	add_child(entry)
	_check_card_amount()

func update_card_entry(deck_resource: CustomDeckResource) -> void:
	for child: Node in get_children():
		if child is CustomDeckCardEntry:
			if child.deck_resource.get_id() == deck_resource.get_id():
				child.set_deck_resource(deck_resource)

func card_view_request(_sender: CustomDeckCardEntry,deck_resource: CustomDeckResource) -> void:
	view_card_requested.emit(deck_resource)

func card_edit_request(_sender: CustomDeckCardEntry, deck_resource: CustomDeckResource) -> void:
	edit_card_requested.emit(deck_resource)

func card_delete_request(sender: CustomDeckCardEntry, deck_resource: CustomDeckResource) -> void:
	delete_card_requested.emit(deck_resource)
	sender.queue_free()
	_check_card_amount()

func save_deck() -> void:
	for child: Node in get_children():
		if child is CustomDeckCardEntry:
			child.disable_buttons()

func saved() -> void:
	for child: Node in get_children():
		if child is CustomDeckCardEntry:
			child.enable_buttons()

func _check_card_amount() -> void:
	var number_of_cards: int = get_children().filter(func(node: Node) -> bool: return not node.is_queued_for_deletion()).size()
	if number_of_cards == null:
		card_amount_invalid.emit()
	if number_of_cards >= min_card_amount:
		card_amount_valid.emit()
		return

	card_amount_invalid.emit()