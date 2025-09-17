class_name ClickableButton extends Button

@export_group("Behavior")
@export var is_focused: bool = false
## If false the button can only be clicked once
@export var can_multi_click: bool = true
@export var play_sounds: bool = true

@export_group("Animations")
@export var animation_resource: ControlAnimationResource = null
	
var _sound_bridge: SoundBridge = null
var _animation_tween: Tween = null
var _is_animated: bool = false


func _ready():
	mouse_entered.connect(_hover_event)
	mouse_exited.connect(_hover_left)
	focus_entered.connect(got_focus)
	focus_exited.connect(lost_focus)

	_sound_bridge = GlobalGameManagerAccess.get_sound_bridge()
	_is_animated = animation_resource != null
	if _is_animated:
		animation_resource.prepare_animation(self)
	if is_focused:
		grab_focus()

func get_global_center_position() -> Vector2:
	return global_position + (size / 2)

func _pressed():
	if !can_multi_click:
		disabled = true
	if _sound_bridge == null or !play_sounds:
		return
	_sound_bridge.play_button_click()

func _hover_event():
	if has_focus():
		return
	grab_focus()

func _hover_left():
	if !has_focus():
		return
	lost_focus()

func ensure_new_tween():
	if _animation_tween != null:
		_animation_tween.kill()
		_animation_tween = null

func got_focus():
	if disabled:
		return
	if _sound_bridge != null and play_sounds:
		_sound_bridge.play_button_hover()

	if !_is_animated or animation_resource.is_animated_in():
		return
	ensure_new_tween()
	_animation_tween = create_tween()
	animation_resource.animate_in(_animation_tween, self)

func lost_focus():
	if !_is_animated or !animation_resource.is_animated_in():
		return
	ensure_new_tween()
	_animation_tween = create_tween()
	animation_resource.animate_out(_animation_tween, self)

func disable_button():
	disabled = true

func enable_button():
	disabled = false

func toggle_button(on: bool):
	if on:
		enable_button()
		return
	disable_button()

func _exit_tree():
	if mouse_entered.is_connected(_hover_event):
		mouse_entered.disconnect(_hover_event)
		
	if mouse_exited.is_connected(_hover_left):
		mouse_exited.disconnect(_hover_left)
	
	if focus_entered.is_connected(got_focus):
		focus_entered.disconnect(got_focus)
	
	if focus_exited.is_connected(lost_focus):
		focus_exited.disconnect(lost_focus)