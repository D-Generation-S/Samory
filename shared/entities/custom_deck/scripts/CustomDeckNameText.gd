extends LineEditValidation

func deck_updated(deck: CustomDeckResource) -> void:
	text = deck.get_resource_name()
	_validate_and_trigger(text)