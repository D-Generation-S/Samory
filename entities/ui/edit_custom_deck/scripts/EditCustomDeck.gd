class_name EditCustomDeck extends CanvasLayer

var _resources: Array[CustomDeckResource] = []

func set_deck(deck: CustomDeckResource) -> void:
	_resources.append(deck)

func get_deck() -> CustomDeckResource:
	for data: CustomDeckResource in _resources:
		if data.get_is_deck():
			return data
	return null