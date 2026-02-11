extends CanvasLayer

signal was_reset()
signal currently_editing()

@export var edit_deck_scene: PackedScene = null

var _current_deck: CustomDeckResource = null
var _last_loaded_deck: Array[CustomDeckResource] = []

signal deck_updated(deck: CustomDeckResource)

func _ready() -> void:
	_reset()

func _reset() -> void:
	_last_loaded_deck = []
	set_deck(CustomDeckResource.new(0, true, "", "", ""))
	was_reset.emit()

func deck_back_path_changed(path: String) -> void:
	_current_deck.set_image(path)
	_current_deck.loaded_texture = null

func deck_name_changed(new_name: String) -> void:
	_current_deck.set_deck_name(new_name)

func deck_description_changed(description: String) -> void:
	_current_deck.set_description(description)

func create_deck() -> void:
	if _last_loaded_deck.size() > 0:
		_reset()
		return

	_current_deck.update_file_name(_current_deck.get_resource_name())
	var scene_instance: EditCustomDeck = edit_deck_scene.instantiate() as EditCustomDeck
	scene_instance.set_deck(_current_deck)
	ScreenTransitionManager.transit_screen_by_node(scene_instance)

func edit_deck() -> void:
	if _current_deck == null or _last_loaded_deck == null:
		return
	var scene_instance: EditCustomDeck = edit_deck_scene.instantiate() as EditCustomDeck
	
	scene_instance.set_deck(_current_deck)
	for card: CustomDeckResource in _last_loaded_deck:
		if card.get_is_deck():
			continue
		scene_instance.add_or_update_card(card)

	ScreenTransitionManager.transit_screen_by_node(scene_instance)

func set_deck(deck: CustomDeckResource) -> void:
	_current_deck = deck
	if _current_deck != null:
		deck_updated.emit(_current_deck)

func load_existing_deck(path: String) -> void:
	_last_loaded_deck = []
	if path == "":
		return
	var loader: CustomDeckLoader = CustomDeckLoader.new()
	var loaded_deck: Array[CustomDeckResource] = loader.load_editable_deck(path)
	if loaded_deck != null:
		set_deck(find_deck(loaded_deck))
		_last_loaded_deck = loaded_deck
		currently_editing.emit()
		#edit_deck(loaded_deck)

func find_deck(deck_data: Array[CustomDeckResource]) -> CustomDeckResource:
	for data: CustomDeckResource in deck_data:
		if data.get_is_deck():
			return data
	return null