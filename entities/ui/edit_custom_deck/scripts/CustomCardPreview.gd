extends Control

signal show_preview_card()

@export var card_template: PackedScene = null

func load_card(card: MemoryCardResource) -> void:
	if card == null:
		return
	_show_self()

	var template: CardPreview = card_template.instantiate() as CardPreview
	template.set_card(card)
	_clear()

	add_child(template)
	

func _clear() -> void:
	for child: Node in get_children():
		child.queue_free()

func _show_self() -> void:
	show()
	show_preview_card.emit()

func show_empty() -> void:
	_clear()
	show()

func _hide_self() -> void:
	hide()
	_clear()
