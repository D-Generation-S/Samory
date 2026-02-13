class_name CustomDeckCardEntry extends PanelContainer

@export var deck_resource: CustomDeckResource = null

signal _deck_resource_changed(deck_resource: CustomDeckResource)
signal _name_changed(new_name: String)
signal edit_card_requested(sender: CustomDeckCardEntry, deck_resource: CustomDeckResource)
signal delete_card_requested(sender: CustomDeckCardEntry, deck_resource: CustomDeckResource)
signal view_card_requested(sender: CustomDeckCardEntry, deck_resource: CustomDeckResource)

signal _disable_button()
signal _enable_button()

func set_deck_resource(deck: CustomDeckResource) -> void:
	deck_resource = deck
	_deck_resource_changed.emit(deck_resource)
	_name_changed.emit(deck_resource.get_resource_name())

func edit_card() -> void:
	edit_card_requested.emit(self, deck_resource)

func delete_card() -> void:
	delete_card_requested.emit(self, deck_resource)

func view_card() -> void:
	view_card_requested.emit(self, deck_resource)

func disable_buttons() -> void:
	_disable_button.emit()

func enable_buttons() -> void:
	_enable_button.emit()