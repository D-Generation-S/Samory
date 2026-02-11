extends TextEdit

signal text_is_changed(text: String)

func _ready() -> void:
	text_changed.connect(_text_is_updated)

func _text_is_updated() -> void:
	text_is_changed.emit(text)

func deck_updated(deck: CustomDeckResource) -> void:
	text = deck.get_description()

