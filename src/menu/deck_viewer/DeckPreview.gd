extends MarginContainer

class_name DeckPreview

signal deck_selected(deck: MemoryDeckResource)
signal deck_activate()
signal deck_unchecked()

@export var deck_name: Label
@export var card_count: RichTextLabel
@export var buildin: RichTextLabel
@export var texture_rect: DeckPreviewSelection
@export var deck_description: RichTextLabel
@export var selection_button: Button

@export_group("Translations")
@export var yes_translation: TextTranslation
@export var no_translation: TextTranslation

var deck: MemoryDeckResource
var _is_selected: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	deck_name.text = deck.name
	card_count.text = str(deck.cards.size())
	deck_description.text = deck.description
	var builtin_text: String = no_translation.key
	if deck.built_in:
		builtin_text = yes_translation.key
	buildin.text = builtin_text
	texture_rect.set_image(deck.card_back)

func set_deck(requested_deck: MemoryDeckResource) -> void:
	deck = requested_deck

func restore_deck() -> void:
	_is_selected = false
	deck_unchecked.emit()

func set_this_deck() -> void:
		_is_selected = true
		deck_selected.emit(deck)
		deck_activate.emit()

func is_in_focus() -> bool:
	return selection_button.has_focus()

func is_deck_selected() -> bool:
	return _is_selected

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		set_this_deck()
		
