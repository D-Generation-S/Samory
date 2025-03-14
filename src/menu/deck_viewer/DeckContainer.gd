class_name DeckContainer extends GridContainer

signal data_reloaded()
signal deck_selected(deck: MemoryDeckResource)
signal decks_getting_placed(decks: Array[MemoryDeckResource])
signal deck_unselected()

@export var deck_preview_template: PackedScene
@export var scroll_speed: float = 5
@export var decks_visible_on_start: bool = true

@onready var scoll_container: ScrollContainer = get_parent() as ScrollContainer

var deck_data: Array[MemoryDeckResource] = []
var show_built_in: bool = true
var show_custom: bool = true
var text_filter: String = ""
var is_in_foucus: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSystemDeckManager.loading_system_decks.connect(clear_all_decks)
	GlobalSystemDeckManager.loading_system_decks_done.connect(place_all_decks)
	place_all_decks()
	if is_mobile():
		columns = 1

func is_mobile() -> bool:
	return OS.has_feature("web_android") or OS.has_feature("web_ios")

func _process(_delta):
	var scroll_vector = Input.get_axis("scroll_up", "scroll_down")
	is_in_foucus = false
	for deck in get_valid_decks():
		if deck is DeckPreview and deck.is_in_focus():
			is_in_foucus = true

	if is_in_foucus:
		scoll_container.scroll_vertical = ceili(scoll_container.scroll_vertical + scroll_vector * scroll_speed)

func is_scroll_focus():
	return is_in_foucus	

func place_all_decks():
	deck_unselected.emit()
	var decks = GlobalGameManagerAccess.game_manager.get_available_decks()
	decks_getting_placed.emit(decks)
	decks.sort_custom(sort_by_name)
	for deck in decks:
		var template: DeckPreview = deck_preview_template.instantiate() as DeckPreview
		template.set_deck(deck)
		template.deck_selected.connect(deck_was_selected)
		template.visible = decks_visible_on_start
		add_child(template)


	data_reloaded.emit()

func make_decks_visible():
	for deck in get_children():
		deck.visible = true

func deck_was_selected(deck: MemoryDeckResource):
	for current_deck in get_children():
		if current_deck is DeckPreview and current_deck.deck != deck:
			current_deck.restore_deck()
	
	deck_selected.emit(deck)

func sort_by_name(a: MemoryDeckResource, b: MemoryDeckResource):
	return a.name < b.name

func show_only_built_in(active: bool):
	if !active:
		return

	show_built_in = true
	show_custom = false

	show_decks()

func show_all_decks(active: bool):
	if !active:
		return

	show_built_in = true
	show_custom = true

	show_decks()

func show_only_custom(active: bool):
	if !active:
		return

	show_built_in = false
	show_custom = true
	
	show_decks()

func clear_all_decks():
	deck_unselected.emit()
	deck_data = []
	for child in get_children():
		child.queue_free()

func filter_decks_by_name(filter: String):
	text_filter = filter
	show_decks()


func get_valid_decks() -> Array[DeckPreview]:
	var return_data: Array[DeckPreview] = []
	for deck in get_children():
		if deck is DeckPreview:
			return_data.append(deck)
	return return_data

func show_decks():
	for deck in get_valid_decks():
		deck.visible = false
		if deck.deck.built_in == show_built_in:
			deck.visible = true
		if deck.deck.built_in != show_custom:
			deck.visible = true
		if text_filter != "" and !deck.deck.name.containsn(text_filter):
			deck.visible = false

		if deck.is_selected and !deck.visible:
			deck.restore_deck()
			deck_unselected.emit()
			
		
	
		
