class_name ClickableToggle extends CheckButton

@export var starts_ready: bool = false

func _ready():
	mouse_entered.connect(GlobalSoundBridge.play_button_hover)
	focus_entered.connect(GlobalSoundBridge.play_button_hover)


func _toggled(_toggled_on):
	if !starts_ready:
		return
	GlobalSoundBridge.play_toggle_sound()
