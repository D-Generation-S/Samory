extends Button

@export var continue_press: bool = false
@export var action_to_performe: String
var currently_down: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if action_to_performe == "":
		printerr("No action set for touch button")
		queue_free()
	var active = false
	if OS.has_feature("web_android") or OS.has_feature("web_ios") or OS.has_feature("windows"):
		active = true
	if !active:
		queue_free()
		return

	if OS.is_debug_build():
		visible = false

	button_down.connect(button_is_down)
	button_up.connect(button_is_up)


func _process(_delta):
	if Input.is_action_just_pressed("toggle_debug") and OS.is_debug_build():
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