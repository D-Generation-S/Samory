class_name ClickableToggle extends CheckButton

@export var starts_ready: bool = false

var _initialized: bool = false

func _ready() -> void:
	mouse_entered.connect(GlobalSoundBridge.play_button_hover)
	focus_entered.connect(GlobalSoundBridge.play_button_hover)
	if not starts_ready:
		await get_tree().physics_frame
		_initialized = true


func _toggled(_toggled_on: bool) -> void:
	if not _initialized and !starts_ready:
		return
	GlobalSoundBridge.play_toggle_sound()
