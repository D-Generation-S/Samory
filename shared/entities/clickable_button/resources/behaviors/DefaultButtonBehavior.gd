class_name DefaultButtonBehavior extends ButtonBehavior

## If false the button can only be clicked once
@export var can_multi_click: bool = true
@export var click_sound: AudioStream = load("res://assets/audio/effect/button-click-1.ogg")
@export var hover_sound: AudioStream = load("res://assets/audio/effect/button-hover-1.ogg")


var _sound_bridge: SoundBridge = null
var _target_button: Button = null
var _pressed_action: ButtonAction = null

func init(button: Button, action: ButtonAction) -> void:
	_target_button = button
	_pressed_action = action
	_sound_bridge = GlobalGameManagerAccess.get_sound_bridge()

	_target_button.pressed.connect(_pressed)

	_target_button.mouse_entered.connect(_hover_event)
	_target_button.mouse_exited.connect(_hover_left)
	_target_button.focus_entered.connect(got_focus)
	_target_button.focus_exited.connect(lost_focus)


func _pressed() -> void:
	if !can_multi_click:
		_target_button.disabled = true
	if _sound_bridge == null:
		return
	_sound_bridge.play_sound(click_sound)
	if _pressed_action != null:
		_pressed_action.execute(_target_button)

func _hover_event() -> void:
	if _target_button.has_focus():
		return
	_target_button.grab_focus()

func _hover_left() -> void:
	if not _target_button.has_focus():
		return
	lost_focus()

func got_focus() -> void:
	if _target_button.disabled:
		return
	if _sound_bridge != null:
		_sound_bridge.play_sound(hover_sound)

	_target_button.animate_in()

func lost_focus() -> void:
	_target_button.animate_out()

func destroy() -> void:
	if _target_button.mouse_entered.is_connected(_hover_event):
		_target_button.mouse_entered.disconnect(_hover_event)
		
	if _target_button.mouse_exited.is_connected(_hover_left):
		_target_button.mouse_exited.disconnect(_hover_left)
	
	if _target_button.focus_entered.is_connected(got_focus):
		_target_button.focus_entered.disconnect(got_focus)
	
	if _target_button.focus_exited.is_connected(lost_focus):
		_target_button.focus_exited.disconnect(lost_focus)
