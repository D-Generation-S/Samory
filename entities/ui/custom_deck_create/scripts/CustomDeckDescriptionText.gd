extends TextEdit

func deck_updated(deck: CustomDeckResource) -> void:
	text = deck.get_description()