extends Node2D

@export var card_id_label: Label
@export var card_position_label: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !OS.is_debug_build():
		queue_free()
		return

	var card_information: CardTemplate = get_parent() as CardTemplate
	if card_information == null or card_information.is_ghost:
		queue_free()
		return
	var card: MemoryCardResource = card_information.memory_card
	if card == null:
		queue_free()
		return
	var card_position: Point = card_information.grid_position

	card_id_label.text = str(card.get_id())
	card_position_label.text = "[" + str(card_position.get_x_pos()) + "," + str(card_position.get_y_pos()) + "]"
