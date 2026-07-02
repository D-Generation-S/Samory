class_name CardTemplate extends Node2D

## The process of hiding has started
signal hide_card()
## The process of showing has started
signal show_card()
## The process of hiding has ended, the card is fully visible now
signal fully_hidden()
## The process of showing has ended, the card is fully visible now
signal fully_shown()

signal remove_requested()

signal animation_done()

## Signals to manage the visual card state

## The card is now queued to be freed
signal about_to_get_delete()

## The card text was changed
signal card_text_changed(new_text: String)

## The card tooltip was changed
signal card_tooltip_changed(new_tooltip: String)

## The card deck was changed
signal deck_changed(deck: MemoryDeckResource)

signal focus_changed(new_state: bool)


@export var is_ghost: bool = false

@export_group("Visuals")
@export var front_side: CardFrontSize
@export var back_side: ToggleCardVisibility
@export var flip_effects: Array[AudioStream]

@export_group("Animation")
@export_range(0,0.25) var card_flip_animation_min_time_delay: float = 0.1
@export_range(0,0.5) var card_flip_animation_max_time_delay: float = 0.5
@export var matching_animation_scale: float = 1.5
@export var shrink_animation_scale: float = 0.3

@export_group("Debug")
@export var debug_remove: bool = false:
	set(value):
		debug_remove = value
		if debug_remove:
			remove_from_board(false)


var card_deck: MemoryDeckResource	
var memory_card: MemoryCardResource
var grid_position: Vector2i

var _timer_for_hide_delay: Timer
var _was_clicked: bool
var _card_frozen: bool = false
var _getting_removed: bool = false
var _playing_animation: bool = false

var _valid_game_state: bool = false
var _memory_game: MemoryGame:
	get():
		if _memory_game == null:
			_memory_game = get_tree().get_first_node_in_group("game_scene")
		return _memory_game

var _ui_information: UiInformationSystem:
	get():
		if _ui_information == null:
			if _memory_game == null:
				return _ui_information
			for system: Node in _memory_game.get_systems().get_systems():
				if system is UiInformationSystem:
					_ui_information = system
					break
		return _ui_information

var _game_manager: GameManager:
	get():
		if _game_manager == null:
			_game_manager = GlobalGameManagerAccess.get_game_manager()
		return _game_manager

func _ready() -> void:
	_setup_timer()
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

func _setup_timer() -> void:
	if _timer_for_hide_delay != null:
		return
	_timer_for_hide_delay = Timer.new()
	_timer_for_hide_delay.one_shot = true
	_timer_for_hide_delay.timeout.connect(hide_card_now)
	add_child(_timer_for_hide_delay)

func change_focus(new_state: bool) -> void:
	focus_changed.emit(new_state)

func toggle_card_on() -> void:
	var time_range: float = card_flip_animation_max_time_delay - card_flip_animation_min_time_delay
	var delay: float = randf() * time_range + card_flip_animation_min_time_delay
	await get_tree().create_timer(delay).timeout
	hide_card_now()
	#_timer_for_hide_delay.wait_time = delay
	#_timer_for_hide_delay.start()

func hide_card_now() -> void:
	if back_side == null or back_side.is_hidden():
		return
	_was_clicked = false
	hide_card.emit()
	_playing_animation = true
	play_card_turn_sound()

func get_height() -> float:
	return back_side.get_rect().size.y

func freeze_card() -> void:
	if back_side == null:
		return
	_card_frozen = true

func unfreeze_card() -> void:
	if back_side == null:
		return
	_was_clicked = false
	_card_frozen = false

func get_width() -> float:
	return back_side.get_rect().size.x

func card_was_clicked() -> void:
	if _card_frozen:
		return
	if _was_clicked:
		printerr("Clicked on already revealed card")
		return
	force_reveal_card()

func force_reveal_card() -> void:
	if _was_clicked or not _valid_game_state:
		return
	_was_clicked = true
	_playing_animation = true
	freeze_card()
	play_card_turn_sound()
	if back_side == null or back_side.is_queued_for_deletion():
		return
	back_side.toggle_off()
	show_card.emit()

func play_card_turn_sound() -> void:
	GlobalSoundManager.play_sound_effect(flip_effects.pick_random())

func get_card_id() -> int:
	var card: MemoryCardResource = memory_card as MemoryCardResource
	return card.get_id()

func is_turned() -> bool:
	return _was_clicked

func remove_from_board(was_ai: bool) -> void:
	top_level = true
	z_index = 100
	_getting_removed = true
	remove_requested.emit()
	var settings: SettingsResource = SettingsRepository.load_settings()
	_playing_animation = true

	if not settings.animate_card_matches or was_ai:
		_fast_match_animation(settings)
		return
	_player_match_animation(settings)

func _fast_match_animation(settings: SettingsResource) -> void:
	var remove_tween: Tween = create_tween()
	remove_tween.tween_property(self, "scale", scale, settings.animation_time)
	remove_tween.tween_property(self, "scale", Vector2(shrink_animation_scale, shrink_animation_scale), settings.animation_time / 2)
	remove_tween.parallel()
	remove_tween.tween_method(_move_to_player_ui, 0.0, 1.0, settings.animation_time * 1.5)
	remove_tween.finished.connect(_trigger_remove)

func _player_match_animation(settings: SettingsResource) -> void:
	var camera: Camera2D = get_viewport().get_camera_2d()
	var additional_scale: float = 1
	if camera != null:
		additional_scale = 1.0 / camera.zoom.x
	var target_scale: Vector2 = Vector2(matching_animation_scale * additional_scale, matching_animation_scale * additional_scale)

	var remove_tween: Tween = create_tween()
	remove_tween.tween_property(self, "scale", scale, settings.animation_time)

	remove_tween.tween_method(_move_to_center, 0.0, 1.0, settings.animation_time)
	remove_tween.parallel()
	remove_tween.tween_property(self, "scale", target_scale, settings.animation_time)
	## Wait for some time to display card
	remove_tween.tween_property(self, "scale", target_scale, settings.animation_time)
	remove_tween.tween_property(self, "scale", Vector2(shrink_animation_scale, shrink_animation_scale), settings.animation_time / 2)
	remove_tween.parallel()
	remove_tween.tween_method(_move_to_player_ui, 0.0, 1.0, settings.animation_time / 2)
	remove_tween.finished.connect(_trigger_remove)

func _move_to_center(lerp_weight: float)  -> void:
	var center: Vector2 = _game_manager._get_viewport_size() / 2.0
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera != null:
		center = camera.get_screen_center_position()

	global_position = lerp(global_position, center, lerp_weight)

func _move_to_player_ui(lerp_weight: float) -> void:
	var target_position: Vector2 = _get_global_player_ui_position()

	global_position = lerp(global_position, target_position, lerp_weight)

func _get_global_player_ui_position() -> Vector2:
	if _ui_information == null:
		return global_position
	var player_overlay: PlayerGameOverlay = _ui_information.get_ui_element("PlayersOverlay")
	return player_overlay.get_global_position_of_current_player()

func _trigger_remove() -> void:
	for group: String in get_groups():
		remove_from_group(group)
	_playing_animation = false
	animation_done.emit()
	about_to_get_delete.emit()

func is_playing_animation() -> bool:
	return _playing_animation

func is_getting_removed() -> bool:
	return _getting_removed

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

func play_sound(audio: AudioStream) -> void:
	if audio == null:
		return
	GlobalSoundManager.play_sound_effect(audio)

func signal_repeater_fully_shown() -> void:
	_playing_animation = false
	animation_done.emit()
	fully_shown.emit()

func signal_repeater_fully_hidden() -> void:
	_playing_animation = false
	animation_done.emit()
	fully_hidden.emit()

func game_state_changed(new_state: GameEnum.State) -> void:
	if new_state == GameEnum.State.TURN_FREEZE:
		_valid_game_state = false
		freeze_card()
	if new_state == GameEnum.State.TURN_END:
		print ("hide card by state")
		hide_card_now()
	if new_state == GameEnum.State.TURN_START:
		unfreeze_card()
		_valid_game_state = true
