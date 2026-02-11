extends TextEditValidation

func deck_updated(deck: CustomDeckResource) -> void:
	text = deck.get_description()
	_validate_and_trigger(text)
