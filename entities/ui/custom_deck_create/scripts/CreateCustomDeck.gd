extends CanvasLayer

signal was_reset()
signal currently_editing()
signal create_is_valid()
signal create_is_invalid()

signal load_deck()
signal deck_loaded()

@export var edit_deck_scene: PackedScene = null

var _current_deck: CustomDeckResource = null
var _last_loaded_deck: Array[CustomDeckResource] = []
var _name_is_valid: bool = false

var _load_thread: Thread = null
var _lazy_loader: CustomDeckLoader = null

signal deck_updated(deck: CustomDeckResource)

func _ready() -> void:
	_reset()

func _get_loader() -> CustomDeckLoader:
	if _lazy_loader == null:
		_lazy_loader = CustomDeckLoader.new()
	return _lazy_loader

func _process(_delta: float) -> void:
	if _load_thread == null or _load_thread.is_alive():
		return

	var data: Variant = _load_thread.wait_to_finish()
	_load_thread = null
	deck_loaded.emit()
	_sync_name_valid()
	if data != null and data is Array[CustomDeckResource]:
		set_deck(find_deck(data))
		_last_loaded_deck = data
		currently_editing.emit()


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
	if not _name_is_valid:
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
	if _load_thread != null and _load_thread.is_active():
		return
	_last_loaded_deck = []
	if path == "":
		return
	var loader: CustomDeckLoader = _get_loader()
	load_deck.emit()
	_load_thread = loader.load_editable_deck_async(path)


func find_deck(deck_data: Array[CustomDeckResource]) -> CustomDeckResource:
	for data: CustomDeckResource in deck_data:
		if data.get_is_deck():
			return data
	return null

func set_name_is_valid() -> void:
	create_is_valid.emit()
	_name_is_valid = true

func set_name_is_invalid() -> void:
	create_is_invalid.emit()
	_name_is_valid = false

func _sync_name_valid() -> void:
	if _name_is_valid:
		create_is_valid.emit()
		return
	create_is_invalid.emit()