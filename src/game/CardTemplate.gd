extends Node2D

class_name CardTemplate

signal hide_card()
signal card_triggered()
signal card_in_focus()
signal card_lost_focus()
signal mouse_was_used()
signal about_to_get_delete()
signal input_active(is_active: bool)

@export var is_ghost: bool = false

@export var card_deck: MemoryDeckResource
@export var memory_card: MemoryCardResource
@export var front_side: CardFrontSize
@export var text_node: Node
@export var back_side: ToggleCardVisibility
@export var flip_effects: Array[AudioStream]
@export var timer_for_hide_delay: Timer
@export_range(0,0.25) var min_time_delay: float = 0.1
@export_range(0,0.5) var max_time_delay: float = 0.5

@export var grid_position: Point

var was_clicked: bool
var getting_removed: bool = false
var is_ai_turn: bool = false

func _ready():
	if is_ghost:
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

func _enter_tree():
	if is_ghost:
		return
	var parent_node = get_parent().get_parent() as MemoryGame
	if parent_node == null:
		printerr("No parent node was found!")
		return

	parent_node.game_state_changed.connect(state_changed)

func toggle_card_on():
	var time_range = max_time_delay - min_time_delay
	var delay = randf() * time_range + min_time_delay
	timer_for_hide_delay.wait_time = delay
	timer_for_hide_delay.start()

func hide_card_now():
	if back_side == null or back_side.is_hidden():
		return
	hide_card.emit()
	play_card_turn_sound()

func get_height() -> float:
	return back_side.get_rect().size.y

func freeze_card():
	if back_side == null:
		return
	back_side.freeze_card()

func unfreeze_card():
	if back_side == null:
		return
	was_clicked = false
	back_side.unfreeze_card()

func get_width() -> float:
	return back_side.get_rect().size.x

func card_was_clicked():
	if was_clicked:
		printerr("Clicked on already revealed card")
		return
	was_clicked = true
	freeze_card()
	play_card_turn_sound()
	back_side.toggle_off()

func play_card_turn_sound():
	var index = randi() % flip_effects.size()
	var effect = flip_effects[index]
	GlobalSoundManager.play_sound_effect(effect)
	card_triggered.emit()

func get_card_id():
	var card = memory_card as MemoryCardResource
	return card.get_id()

func is_turned() -> bool:
	return was_clicked

func remove_from_board():
	about_to_get_delete.emit()
	getting_removed = true

func is_getting_removed():
	return getting_removed

func destory_now():
	queue_free()

func card_is_hidden() -> bool:
	if back_side == null:
		return true
	return back_side.is_hidden()

func card_is_fully_shown() -> bool:
	if back_side == null:
		return false
	return back_side.is_fully_shown()

func card_is_focused() -> bool:
	if back_side == null:
		return true
	return back_side.is_currently_in_focus()

func got_focus():
	if was_clicked:
		return
	card_in_focus.emit()

func lost_focus():
	if was_clicked:
		return
	card_lost_focus.emit()

func selected_by_mouse():
	mouse_was_used.emit()

func play_sound(audio: AudioStream):
	if audio == null:
		return
	GlobalSoundManager.play_sound_effect(audio)

func player_changed(ai_player: bool):
	input_active.emit(!ai_player)

func state_changed(new_state: int):
	match new_state:
		GameState.ROUND_FREEZE:
			freeze_card()
		GameState.ROUND_START:
			unfreeze_card()
		GameState.ROUND_END:
			toggle_card_on()
