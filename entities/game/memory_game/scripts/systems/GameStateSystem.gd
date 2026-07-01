class_name GameStateSystem extends Node

signal state_changed(new_state: GameEnum.State)
signal request_popup(window: PopupWindow)
signal force_close_popup(id: int)
signal game_has_ended()

signal _animations_done()

@export var round_end_message: TextTranslation
@export var round_end_message_no_auto_complete: TextTranslation

var message_banner: PackedScene = preload("res://entities/game/bottom_message_banner/scenes/BottomMessageBanner.tscn")

var _current_state: GameEnum.State = GameEnum.State.GAME_INIT

var _popup_id: int = -1

func _ready() -> void:
	state_changed.emit(_current_state)

## This will set the new state and broadcast the new state via signal
func _change_state(new_state: GameEnum.State) -> void:	
	_current_state = new_state
	print("State changed to %s" % str(_current_state))
	state_changed.emit(_current_state)

func get_current_state() -> GameEnum.State:
	return _current_state

func game_field_ready() -> void:
	if _current_state == GameEnum.State.GAME_INIT:
		_change_state(GameEnum.State.TURN_START)

func matches_found() -> void:
	if _current_state == GameEnum.State.GAME_END:
		return
	print("match found")
	_change_state(GameEnum.State.TURN_FREEZE)
	_change_state(GameEnum.State.TURN_COMPLETED)
	if _current_state == GameEnum.State.GAME_END:
		animation_cleared()
	
	_change_state(GameEnum.State.WAIT_FOR_ANIMATION_FINISH)
	await _animations_done
	_change_state(GameEnum.State.TURN_START)

func no_matches() -> void:
	if _current_state == GameEnum.State.GAME_END:
		return
	print("no matches")
	_change_state(GameEnum.State.TURN_FREEZE)
	_change_state(GameEnum.State.TURN_COMPLETED)
	_change_state(GameEnum.State.PREPARE_TURN_END)
	_change_state(GameEnum.State.WAIT_FOR_ANIMATION_FINISH)
	await _animations_done
	_show_round_ended_banner()

func board_ready() -> void:
	print("board ready")
	_change_state(GameEnum.State.TURN_START)
	
func board_empty() -> void:
	print("board empty")
	_change_state(GameEnum.State.PREPARE_TURN_END)
	_change_state(GameEnum.State.GAME_END)

	var emergency_timer: Timer = Timer.new()
	emergency_timer.one_shot = true
	emergency_timer.timeout.connect(animation_cleared)
	add_child(emergency_timer)
	emergency_timer.start(2)

func animation_cleared() -> void:
	if _current_state == GameEnum.State.WAIT_FOR_ANIMATION_FINISH:
		_animations_done.emit()
	
	if _current_state != GameEnum.State.GAME_END:
		return
	_change_state(GameEnum.State.ANIMATION_CLEARED)
	game_has_ended.emit()

func _show_round_ended_banner() -> void:
	var settings: SettingsResource = SettingsRepository.load_settings() as SettingsResource
	var auto_close: bool = settings.auto_close_round
	var time_until_close: float = settings.close_round_after_seconds
	var popup_banner: BottomMessageBanner = message_banner.instantiate() as BottomMessageBanner
	var message: TextTranslation = round_end_message
	if !auto_close:
		message = round_end_message_no_auto_complete

	popup_banner.initialize_popup(message, time_until_close, auto_close, _begin_new_round)
	popup_banner.should_pause = false
	request_popup.emit(popup_banner)

	_popup_id = popup_banner.get_id()

func force_end_round() -> void:
	if _popup_id == -1:
		return
	force_close_popup.emit(_popup_id)

func _begin_new_round() -> void:
	_change_state(GameEnum.State.TURN_END)
	_popup_id = -1
	_change_state(GameEnum.State.TURN_START)