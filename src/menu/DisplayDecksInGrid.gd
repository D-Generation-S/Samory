extends GridContainer

@export var deck_template: PackedScene


func _ready():
	var game_manager = get_tree().root.get_child(0) as GameManager
	var decks = game_manager.get_available_decks()
	for deck in decks:
		var template = deck_template.instantiate() as DeckPreview
		template.set_deck(deck)
		add_child(template)
