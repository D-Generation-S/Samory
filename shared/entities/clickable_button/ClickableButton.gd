class_name ClickableButton extends Button

enum {
	WEB,
	DESKTOP,
	MOBILE,
	DEBUG
}

@export_group("Visibility")
@export var only_show_on_debug: bool = false
## If this is set to true, the button will listen to the debug signal, showing itself if requested
@export var can_request_debug_view: bool = false
@export_flags("Web", "Desktop", "Mobile", "Debug") var active: int = 7

@export_group("Behavior")
@export var is_focused: bool = false
## If false the button can only be clicked once
@export var button_behavior: ButtonBehavior = null

@export_group("Animations")
@export var animation_resource: ControlAnimationResource = null

@export_group("Actions")
## The action to run if this button was clicked
@export var pressed_action: ButtonAction = null
	
var _animation_tween: Tween = null
var _is_animated: bool = false


func _ready() -> void:
	if !_check_for_valid_platform():
		return
	if button_behavior == null:
		button_behavior = DefaultButtonBehavior.new()
	button_behavior.init(self, pressed_action)

	_is_animated = animation_resource != null
	if _is_animated:
		animation_resource.prepare_animation(self)
	if is_focused:
		grab_focus()

func _check_for_valid_platform() -> bool:
	if only_show_on_debug && !OS.is_debug_build():
		print_debug("debug only")
		queue_free()
		return false
	var visibility: bool = false
	visible = false
	if active & (1 << WEB) && OS.has_feature("web"):
		visibility = true

	if active & (1 << DESKTOP) && _is_desktop():
		visibility = true

	if active & (1 << MOBILE) && _is_mobile():
		visibility = true

	if active & (1 << DEBUG) && OS.is_debug_build():
		visibility = true

	visible = visibility
	return true

func _is_desktop() -> bool:
	return OS.has_feature("windows")

func _is_mobile() -> bool:
	return OS.has_feature("web_android") or OS.has_feature("web_ios")

func get_global_center_position() -> Vector2:
	return global_position + (size / 2)

func check_if_can_execute() -> void:
	var can_execute: bool = true
	if pressed_action != null:
		can_execute = pressed_action.can_execute()
	disabled = not can_execute

func _process(_delta: float) -> void:
	if button_behavior != null:
		button_behavior.process()
	if not can_request_debug_view:
		return

	if Input.is_action_just_pressed("toggle_debug") and OS.is_debug_build():
		visible = !visible

func _ensure_new_tween() -> void:
	if _animation_tween != null:
		_animation_tween.kill()
		_animation_tween = null

func disable_button() -> void:
	disabled = true

func enable_button() -> void:
	disabled = false

func toggle_button(on: bool) -> void:
	if on:
		enable_button()
		return
	disable_button()

func animate_in() -> void:
	if !_is_animated or animation_resource.is_animated_in():
		return
	_ensure_new_tween()
	_animation_tween = create_tween()
	animation_resource.animate_in(_animation_tween, self)

func animate_out() -> void:
	if !_is_animated or !animation_resource.is_animated_in():
		return
	_ensure_new_tween()
	_animation_tween = create_tween()
	animation_resource.animate_out(_animation_tween, self)

func _exit_tree() -> void:
	if button_behavior != null:
		button_behavior.destroy()
