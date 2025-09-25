class_name ClickableOptionButton extends OptionButton

func _ready():
	item_selected.connect(_selection_changed)
	mouse_entered.connect(_on_focused)
	focus_entered.connect(_on_focused)
	pressed.connect(_on_click)

func _on_focused():
	GlobalSoundBridge.play_button_hover()

func _on_click():
	GlobalSoundBridge.play_toggle_sound()

func _selection_changed(_selection):
	_on_click()