class_name CustomDeckEditCard extends PanelContainer

signal add_new_card(card: CustomDeckResource)
signal update_card(card: CustomDeckResource)
signal card_updated(card: CustomDeckResource)
signal hiding()
signal showing()

@export var initial_card_name: TextTranslation = null
@export var initial_card_description: TextTranslation = null

var is_edit: bool = false
var _current_card_resource: CustomDeckResource = null

func _ready() -> void:
	cancel()

func show_add_card() -> void:
	is_edit = false
	_make_visible()
	load_card(CustomDeckResource.new(-1, false, tr(initial_card_name.key), tr(initial_card_description.key), ""))

func show_edit_card(deck_resource: CustomDeckResource) -> void:
	is_edit = true
	load_card(deck_resource)
	_make_visible()

func load_card(deck_resource: CustomDeckResource) -> void:
	_current_card_resource = deck_resource
	card_updated.emit(_current_card_resource)

func update_card_name(new_name: String) -> void:
	_current_card_resource.set_deck_name(new_name)

func update_card_description(new_description: String) -> void:
	_current_card_resource.set_description(new_description)

func update_card_image(path: String) -> void:
	_current_card_resource.loaded_texture = null
	_current_card_resource.set_image(path)

func save_card() -> void:
	if is_edit:
		update_card.emit(_current_card_resource)
		cancel()
		return
	print(_current_card_resource.get_resource_name())
	add_new_card.emit(_current_card_resource)
	cancel()

func cancel() -> void:
	hiding.emit()
	hide()

func _make_visible() -> void:
	showing.emit()
	show()
