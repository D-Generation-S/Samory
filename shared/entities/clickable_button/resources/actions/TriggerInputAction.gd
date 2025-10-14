class_name TriggerInputAction extends ButtonAction

@export var button_action_name: String = ""

func execute(_base: ClickableButton) -> void:
	Input.action_press(button_action_name)
	
func stop() -> void:
	Input.action_release(button_action_name)

func can_execute() -> bool:
	return button_action_name != ""