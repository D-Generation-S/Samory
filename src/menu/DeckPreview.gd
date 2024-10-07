extends MarginContainer

class_name DeckPreview

@export var deck_name: Label
@export var card_count: RichTextLabel
@export var buildint: RichTextLabel
@export var texture_rect: TextureRect

var deck: MemoryDeckResource

# Called when the node enters the scene tree for the first time.
func _ready():
	deck_name.text = deck.name
	card_count.text = str(deck.cards.size())
	var builtin_text = "No"
	if deck.built_in:
		builtin_text = "Yes"
	buildint.text = builtin_text
	texture_rect.texture = deck.card_back
	pass # Replace with function body.

func set_deck(requested_deck: MemoryDeckResource):
	deck = requested_deck

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Deck pressed")

