extends LineEdit


func deck_updated(deck: CustomDeckResource) -> void:
	text = deck.get_deck_name()