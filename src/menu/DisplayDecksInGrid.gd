extends GridContainer

class_name  DisplayDecksInGrid

@export var deck_template: PackedScene

signal deck_selected()

var current_deck: MemoryDeckResource = null

func _ready():
	var game_manager = get_tree().root.get_child(0) as GameManager
	var decks = game_manager.get_available_decks()
	for deck in decks:
		var template = deck_template.instantiate() as DeckPreview
		template.set_deck(deck)
		template.deck_selected.connect(deck_was_selected)
		add_child(template)

func deck_was_selected(deck: MemoryDeckResource):
	current_deck = deck;
	for child in get_children():
		if child is DeckPreview and child.deck != current_deck:
			child.restore_deck()
		
	deck_selected.emit()
