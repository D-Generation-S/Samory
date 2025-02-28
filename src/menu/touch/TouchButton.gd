class_name TouchButton extends Button

@export var default_visibility: bool = false
@export var continue_press: bool = false
@export var action_to_performe: String
var currently_down: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if action_to_performe == "":
		printerr("No action set for touch button")
		queue_free()
	var active = false
	if is_mobile():
		active = true
	if !active and !OS.is_debug_build():
		queue_free()
		return

	visible = default_visibility

	button_down.connect(button_is_down)
	button_up.connect(button_is_up)

func show_button():
	var should_be_visible = true
	if OS.has_feature("windows") and OS.is_debug_build():
		should_be_visible = false
	visible = should_be_visible

func is_mobile() -> bool:
	return OS.has_feature("web_android") or OS.has_feature("web_ios")

func _process(_delta):
	if Input.is_action_just_pressed("toggle_debug") and OS.is_debug_build() and OS.has_feature("windows"):
		visible = !visible
	if !visible:
		return

	if currently_down and continue_press:
		Input.action_press(action_to_performe)
		return

	Input.action_release(action_to_performe)
	
func _pressed():
	if continue_press:
		return
	
	Input.action_press(action_to_performe)
	Input.action_release(action_to_performe)

func button_is_down():
	currently_down = true

func button_is_up():
	currently_down = false