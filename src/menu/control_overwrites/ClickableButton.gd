class_name ClickableButton extends Button

@export var is_focused: bool = false
@export var play_sounds: bool = true
@export var animation_resource: ControlAnimationResource = null
	
var sound_bridge: SoundBridge = null
var animation_tween: Tween = null
var is_animated: bool = false

func _ready():
	mouse_entered.connect(_hover_event)
	mouse_exited.connect(_hober_left)
	focus_entered.connect(got_focus)
	focus_exited.connect(lost_focus)
	sound_bridge = GlobalGameManagerAccess.get_sound_bridge()
	is_animated = animation_resource != null
	if is_animated:
		animation_resource.prepare_animation(self)
	if is_focused:
		grab_focus()

func _pressed():
	if sound_bridge == null or !play_sounds:
		return
	sound_bridge.play_button_click()

func _hover_event():
	if has_focus():
		return
	grab_focus()

func _hober_left():
	if !has_focus():
		return
	lost_focus()
	

func ensure_new_tween():
	if animation_tween != null:
		animation_tween.kill()
		animation_tween = null

func got_focus():
	if disabled:
		return
	if sound_bridge != null and play_sounds:
		sound_bridge.play_button_hover()

	if !is_animated or animation_resource.is_animated_in():
		return
	ensure_new_tween()
	animation_tween = create_tween()
	animation_resource.animate_in(animation_tween, self)

func lost_focus():
	if !is_animated or !animation_resource.is_animated_in():
		return
	ensure_new_tween()
	animation_tween = create_tween()
	animation_resource.animate_out(animation_tween, self)

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
		
	if mouse_exited.is_connected(_hober_left):
		mouse_exited.disconnect(_hober_left)
	
	if focus_entered.is_connected(got_focus):
		focus_entered.disconnect(got_focus)
	
	if focus_exited.is_connected(lost_focus):
		focus_exited.disconnect(lost_focus)