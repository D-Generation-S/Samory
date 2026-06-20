class_name TutorialStateManager extends Node

signal trigger_tutorial(tutorial_state: Enums.Tutorial_State)

var _current_player: PlayerResource = null

func state_changed(new_state: GameEnum.State) -> void:
	if _is_ai_player():
		return
	if new_state == GameEnum.State.TURN_START:
		trigger_tutorial.emit(Enums.Tutorial_State.PLAYER_TURN)
	if new_state == GameEnum.State.PREPARE_TURN_END:
		trigger_tutorial.emit(Enums.Tutorial_State.PLAYER_TURN_END)
	pass

func card_triggered() -> void:
	if _is_ai_player():
		return
	trigger_tutorial.emit(Enums.Tutorial_State.PLAYER_TURNED_CARD)

func matching_card_found() -> void:
	if _is_ai_player():
		return
	trigger_tutorial.emit(Enums.Tutorial_State.PLAYER_FOUND_MATCHING_PAIR)

func player_changed(new_player: PlayerResource) -> void:
	_current_player = new_player

func _is_ai_player() -> bool:
	return _current_player == null or _current_player.is_ai()
