class_name ClickableButton extends Button

@export var is_focused: bool = false
@export var play_sounds: bool = true

var sound_bridge: SoundBridge = null

func _ready():
	load_sound_bridge()
	if is_focused:
		grab_focus()

func load_sound_bridge() -> bool:
	sound_bridge = GlobalGameManagerAccess.get_sound_bridge()
	return sound_bridge != null

func _pressed():
	if !load_sound_bridge() or !play_sounds:
		return
	sound_bridge.play_button_click()

func _hover():
	if !load_sound_bridge() or !play_sounds:
		return
	sound_bridge.play_button_hover()

func disable_button():
	disabled = true

func enable_button():
	disabled = false

func toggle_button(on: bool):
	if on:
		enable_button()
		return
	disable_button()
