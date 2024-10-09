extends Node2D

class_name CardTemplate

signal hide_card()
signal card_triggered()
signal trigger_sound_effect(stream: AudioStream)


@export var card_deck: Resource
@export var memory_card: Resource
@export var front_side: CardFrontSize
@export var text_node: Node
@export var back_side: Sprite2D
@export var flip_effects: Array[AudioStream]

var was_clicked: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	var parent_node = get_parent() as MemoryGame
	if parent_node == null:
		printerr("No parent node was found!")
		return
	if memory_card == null:
		printerr("No card was set!")
		return
	if card_deck == null:		
		printerr("No deck was set")
		return
	text_node.set_card_text(memory_card.name)
	var real_texture: Texture2D = memory_card.texture
	front_side.set_and_scale_texture(real_texture)
	back_side.texture = card_deck.card_back
	parent_node.connect("round_start", unfreeze_card)
	parent_node.connect("freeze_round", freeze_card)
	parent_node.connect("round_end", toggle_card_on)
	connect("trigger_sound_effect", parent_node.play_game_sound)

func toggle_card_on():
	hide_card.emit()
	pass

func get_height() -> float:
	return back_side.get_rect().size.y

func freeze_card():
	back_side.freeze_card()

func unfreeze_card():
	was_clicked = false
	back_side.unfreeze_card()

func get_width() -> float:
	return back_side.get_rect().size.x

func card_was_clicked():
	was_clicked = true
	freeze_card()
	var index = randi() % flip_effects.size()
	var effect = flip_effects[index]
	trigger_sound_effect.emit(effect)
	card_triggered.emit()

func get_card_id():
	var card = memory_card as MemoryCardResource
	return card.get_id()

func is_turned() -> bool:
	return was_clicked

func remove_from_board():
	call_deferred("queue_free")
