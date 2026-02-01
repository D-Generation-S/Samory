class_name DeckContainer extends GridContainer

signal data_reloaded()
signal deck_selected(deck: MemoryDeckResource)
signal decks_getting_placed(decks: Array[MemoryDeckResource])
signal deck_unselected()

@export_group("Container settings")
@export var deck_preview_template: PackedScene
@export var scroll_speed: float = 5

@export_group("Deck settings")
@export var decks_visible_on_start: bool = true
@export var show_built_in: bool = true
@export var show_custom: bool = true

@onready var scoll_container: ScrollContainer = get_parent() as ScrollContainer

var deck_data: Array[MemoryDeckResource] = []

var text_filter: String = ""
var _is_in_focus: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSystemDeckManager.loading_system_decks.connect(clear_all_decks)
	GlobalSystemDeckManager.loading_system_decks_done.connect(place_all_decks)
	place_all_decks()
	if is_mobile():
		columns = 1

	show_decks()

func is_mobile() -> bool:
	return OS.has_feature("web_android") or OS.has_feature("web_ios")

func _process(_delta: float) -> void:
	var scroll_vector: float = Input.get_axis("scroll_up", "scroll_down")
	_is_in_focus = false
	for deck: DeckPreview in get_valid_decks():
		if deck is DeckPreview and deck.is_in_focus():
			_is_in_focus = true

	if _is_in_focus:
		scoll_container.scroll_vertical = ceili(scoll_container.scroll_vertical + scroll_vector * scroll_speed)

func is_scroll_focus() -> bool:
	return _is_in_focus	

func place_all_decks() -> void:
	if not decks_visible_on_start:
		hide()
	deck_unselected.emit()
	var decks: Array[MemoryDeckResource] = GlobalGameManagerAccess.game_manager.get_available_decks()
	decks_getting_placed.emit(decks)
	decks.sort_custom(sort_by_name)
	for deck: MemoryDeckResource in decks:
		var template: DeckPreview = deck_preview_template.instantiate() as DeckPreview
		template.set_deck(deck)
		template.deck_selected.connect(deck_was_selected)
		template.name = deck.name
		add_child(template)

	data_reloaded.emit()

func deck_was_selected(deck: MemoryDeckResource) -> void:
	for current_deck: Node in get_children():
		if current_deck is DeckPreview and current_deck.deck != deck:
			current_deck.restore_deck()
	
	deck_selected.emit(deck)

func sort_by_name(a: MemoryDeckResource, b: MemoryDeckResource) -> bool:
	return a.name < b.name

func show_only_built_in(active: bool) -> void:
	if !active:
		return

	show_built_in = true
	show_custom = false

	show_decks()

func show_all_decks(active: bool) -> void:
	if !active:
		return

	show_built_in = true
	show_custom = true

	show_decks()

func show_only_custom(active: bool) -> void:
	if !active:
		return

	show_built_in = false
	show_custom = true
	
	show_decks()

func clear_all_decks() -> void:
	deck_unselected.emit()
	deck_data = []
	for child: Node in get_children():
		child.queue_free()

func filter_decks_by_name(filter: String) -> void:
	text_filter = filter
	show_decks()


func get_valid_decks() -> Array[DeckPreview]:
	var return_data: Array[DeckPreview] = []
	for deck: Node in get_children():
		if deck is DeckPreview:
			return_data.append(deck)
	return return_data

func show_decks() -> void:
	for deck: DeckPreview in get_valid_decks():
		deck.visible = false
		if deck.deck.built_in == show_built_in:
			deck.visible = true
		if deck.deck.built_in != show_custom:
			deck.visible = true
		if text_filter != "" and !deck.deck.name.containsn(text_filter):
			deck.visible = false

		if deck.is_deck_selected() and !deck.visible:
			deck.restore_deck()
			deck_unselected.emit()
