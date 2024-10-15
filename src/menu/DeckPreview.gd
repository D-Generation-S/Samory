extends MarginContainer

class_name DeckPreview

signal deck_selected(deck: MemoryDeckResource)
signal deck_activate()
signal deck_unchecked()

const BUILT_IN_YES = "YES"
const BUILT_IN_NO = "NO"

@export var deck_name: Label
@export var card_count: RichTextLabel
@export var buildint: RichTextLabel
@export var texture_rect: DeckPreviewSelection
@export var deck_description: RichTextLabel

var deck: MemoryDeckResource
var is_selected: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	deck_name.text = deck.name
	card_count.text = str(deck.cards.size())
	deck_description.text = deck.description
	var builtin_text = BUILT_IN_NO
	if deck.built_in:
		builtin_text = BUILT_IN_YES
	buildint.text = builtin_text
	texture_rect.set_image(deck.card_back)

func set_deck(requested_deck: MemoryDeckResource):
	deck = requested_deck

func restore_deck():
	is_selected = false
	deck_unchecked.emit()

func set_this_deck():
		is_selected = true
		deck_selected.emit(deck)
		deck_activate.emit()

func is_deck_selected():
	return is_selected

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		set_this_deck()
		
