extends CanvasLayer

@export var initial_name: String = tr("MY_DECK")
@export var initial_description: String = tr("MY_DECK_DESCRIPTION")

@export var edit_deck_scene: PackedScene = null

var _current_deck: CustomDeckResource = null

signal deck_updated(deck: CustomDeckResource)

func _ready() -> void:
	set_deck(CustomDeckResource.new(true, initial_name, initial_description, ""))

func deck_back_path_changed(path: String) -> void:
	_current_deck.set_image(path)

func deck_name_changed(new_name: String) -> void:
	_current_deck.set_deck_name(new_name)

func deck_description_changed(description: String) -> void:
	_current_deck.set_description(description)

func create_deck() -> void:
	var scene_instance: EditCustomDeck = edit_deck_scene.instantiate() as EditCustomDeck
	scene_instance.set_deck(_current_deck)
	ScreenTransitionManager.transit_screen_by_node(scene_instance)

func set_deck(deck: CustomDeckResource) -> void:
	_current_deck = deck
	deck_updated.emit(_current_deck)
