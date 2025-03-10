extends ConditionalButton

@export var button_action_name: String = ""

func _ready():
	super()
	if button_action_name == "":
		printerr("No action set for button")
		queue_free()

func _pressed():
	super()
	Input.action_press(button_action_name)
	Input.action_release(button_action_name)