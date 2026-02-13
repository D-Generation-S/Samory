extends Node2D

class_name CardTemplate

signal hide_card()
signal card_triggered()
signal card_in_focus()
signal card_lost_focus()
signal mouse_was_used()
signal about_to_get_delete()
signal input_active(is_active: bool)

signal card_text_changed(new_text: String)
signal card_tooltip_changed(new_tooltip: String)
signal deck_changed(deck: MemoryDeckResource)

@export var is_ghost: bool = false

@export var card_deck: MemoryDeckResource
@export var memory_card: MemoryCardResource
@export var front_side: CardFrontSize
@export var back_side: ToggleCardVisibility
@export var flip_effects: Array[AudioStream]
@export_range(0,0.25) var min_time_delay: float = 0.1
@export_range(0,0.5) var max_time_delay: float = 0.5

@export var grid_position: Point

var _timer_for_hide_delay: Timer
var was_clicked: bool
var _card_frozen: bool = false
var getting_removed: bool = false
var is_ai_turn: bool = false

func _ready() -> void:
	_timer_for_hide_delay = Timer.new()
	_timer_for_hide_delay.one_shot = true
	_timer_for_hide_delay.timeout.connect(hide_card_now)
	add_child(_timer_for_hide_delay)

	if is_ghost:
		return
	if memory_card == null:
		printerr("No card was set!")
		return
	if card_deck == null:		
		printerr("No deck was set")
		return
	card_text_changed.emit(memory_card.name)
	card_tooltip_changed.emit(memory_card.description)

	var real_texture: Texture2D = memory_card.texture
	front_side.set_and_scale_texture(real_texture, card_deck.built_in)
	deck_changed.emit(card_deck)

func _enter_tree() -> void:
	if is_ghost:
		return
	var parent_node: MemoryGame = get_parent().get_parent() as MemoryGame
	if parent_node == null:
		printerr("No parent node was found!")

func toggle_card_on() -> void:
	var time_range: float = max_time_delay - min_time_delay
	var delay: float = randf() * time_range + min_time_delay
	_timer_for_hide_delay.wait_time = delay
	_timer_for_hide_delay.start()

func hide_card_now() -> void:
	if back_side == null or back_side.is_hidden():
		return
	was_clicked = false
	hide_card.emit()
	lost_focus()
	play_card_turn_sound()

func get_height() -> float:
	return back_side.get_rect().size.y

func freeze_card() -> void:
	if back_side == null:
		return
	back_side.freeze_card()
	_card_frozen = true
	lost_focus()

func unfreeze_card() -> void:
	if back_side == null:
		return
	was_clicked = false
	_card_frozen = false
	back_side.unfreeze_card()

func get_width() -> float:
	return back_side.get_rect().size.x

func card_was_clicked() -> void:
	if _card_frozen:
		return
	if was_clicked:
		printerr("Clicked on already revealed card")
		return
	force_reveal_card()

func force_reveal_card() -> void:
	if was_clicked:
		return
	was_clicked = true
	freeze_card()
	play_card_turn_sound()
	back_side.toggle_off()
	card_triggered.emit()

func play_card_turn_sound() -> void:
	GlobalSoundManager.play_sound_effect(flip_effects.pick_random())
	

func get_card_id() -> int:
	var card: MemoryCardResource = memory_card as MemoryCardResource
	return card.get_id()

func is_turned() -> bool:
	return was_clicked

func remove_from_board() -> void:
	about_to_get_delete.emit()
	getting_removed = true

func is_getting_removed() -> bool:
	return getting_removed

func destory_now() -> void:
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

func got_focus() -> void:
	if was_clicked or _card_frozen:
		return
	card_in_focus.emit()

func lost_focus() -> void:
	if was_clicked:
		return
	card_lost_focus.emit()

func selected_by_mouse() -> void:
	mouse_was_used.emit()

func play_sound(audio: AudioStream) -> void:
	if audio == null:
		return
	GlobalSoundManager.play_sound_effect(audio)

func player_changed(ai_player: bool) -> void:
	input_active.emit(!ai_player)