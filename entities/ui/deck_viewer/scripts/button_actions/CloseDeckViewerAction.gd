class_name CloseDeckViewerAction extends ButtonAction

var _can_execute: bool = true

func _init() -> void:
	GlobalSystemDeckManager.loading_system_decks.connect(loading_decks)

func execute(base: ClickableButton) -> void:
	GlobalGameManagerAccess.get_game_manager().close_game_with_position(base.get_global_center_position())

func can_execute() -> bool:
	return _can_execute

func loading_decks() -> void:
	_can_execute_changed(false)

func loading_decks_done() -> void:
	_can_execute_changed(true)

func _can_execute_changed(new_state: bool) -> void:
	_can_execute = new_state
	can_execute_changed.emit()