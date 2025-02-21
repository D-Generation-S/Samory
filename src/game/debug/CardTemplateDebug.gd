extends Node2D

@export var card_id_label: Label
@export var card_position_label: Label

# Called when the node enters the scene tree for the first time.
func _ready():
	if !OS.is_debug_build():
		queue_free()
		return

	var card_information = get_parent() as CardTemplate
	var card = card_information.memory_card
	var card_position = card_information.grid_position

	card_id_label.text = str(card.get_id())
	card_position_label.text = "[" + str(card_position.get_x_pos()) + "," + str(card_position.get_y_pos()) + "]"
