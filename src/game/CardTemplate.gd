extends Node2D

class_name CardTemplate

signal hide_card()
signal card_triggered()
signal trigger_sound_effect(stream: AudioStream)
signal card_in_focus()
signal card_lost_focus()

@export var card_deck: Resource
@export var memory_card: Resource
@export var front_side: CardFrontSize
@export var text_node: Node
@export var back_side: ToggleCardVisibility
@export var flip_effects: Array[AudioStream]
@export var timer_for_hide_delay: Timer
@export_range(0,0.25) var min_time_delay: float = 0.1
@export_range(0,0.5) var max_time_delay: float = 0.5

@export var grid_position: Point

var was_clicked: bool

func _ready():	
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

func _enter_tree():
	var parent_node = get_parent().get_parent() as MemoryGame
	if parent_node == null:
		printerr("No parent node was found!")
		return

	parent_node.connect("round_start", unfreeze_card)
	parent_node.connect("freeze_round", freeze_card)
	parent_node.connect("round_end", toggle_card_on)
	connect("trigger_sound_effect", parent_node.play_game_sound)

func toggle_card_on():
	var time_range = max_time_delay - min_time_delay
	var delay = randf() * time_range + min_time_delay
	timer_for_hide_delay.wait_time = delay
	timer_for_hide_delay.start()

func hide_card_now():
	if back_side.is_hidden():
		return;
	hide_card.emit()
	play_card_turn_sound()

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
	play_card_turn_sound()
	back_side.toggle_off()

func play_card_turn_sound():
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

func card_is_hidden() -> bool:
	return back_side.is_hidden()

func got_focus():
	if was_clicked:
		return
	card_in_focus.emit()

func lost_focus():
	if was_clicked:
		return
	card_lost_focus.emit()