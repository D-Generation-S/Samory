class_name TouchButtonBehavior extends ButtonBehavior

var _currently_down: bool = false
var _target_button: Button = null
var _action: ButtonAction = null

func init(button: Button, action: ButtonAction) -> void:
	_target_button = button
	_action = action

	_target_button.button_down.connect(button_is_down)
	_target_button.button_up.connect(button_is_up)

func button_is_down() -> void:
	_currently_down = true

func button_is_up() -> void:
	_currently_down = false

func process() -> void:
	if not _target_button.visible:
		return

	if _currently_down:
		_action.execute(_target_button)
		return

	_action.stop()

func destroy() -> void:
	pass
