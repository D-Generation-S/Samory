extends VBoxContainer

@export var card_entry_scene: PackedScene = null

signal view_card_requested(deck_resource: CustomDeckResource)
signal edit_card_requested(deck_resource: CustomDeckResource)
signal delete_card_requested(deck_resource: CustomDeckResource)

func add_card_entry(deck_resource: CustomDeckResource) -> void:
	var entry: CustomDeckCardEntry = card_entry_scene.instantiate() as CustomDeckCardEntry
	entry.set_deck_resource(deck_resource)
	entry.edit_card_requested.connect(card_edit_request)
	entry.delete_card_requested.connect(card_delete_request)
	entry.view_card_requested.connect(card_view_request)

	add_child(entry)

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

func save_deck() -> void:
	for child: Node in get_children():
		if child is CustomDeckCardEntry:
			child.disable_buttons()

func saved() -> void:
	for child: Node in get_children():
		if child is CustomDeckCardEntry:
			child.enable_buttons()