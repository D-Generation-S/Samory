extends GridContainer

class_name  DisplayDecksInGrid

@export var deck_template: PackedScene

signal deck_selected()

var current_deck: MemoryDeckResource = null

func _ready() -> void:
	var decks: Array[MemoryDeckResource] = GlobalGameManagerAccess.get_game_manager().get_available_decks()
	for deck: MemoryDeckResource in decks:
		var template: DeckPreview = deck_template.instantiate() as DeckPreview
		template.set_deck(deck)
		template.deck_selected.connect(deck_was_selected)
		add_child(template)

func deck_was_selected(deck: MemoryDeckResource) -> void:
	current_deck = deck
	for child: Node in get_children():
		if child is DeckPreview and child.deck != current_deck:
			child.restore_deck()
		
	deck_selected.emit()
