class_name TutorialWindow extends PopupWindow

signal abort_tutorial()

var title: Label = null
var body: AnimatedText = null
var abort_tutorial_check: CheckButton = null

var should_abort_tutorial = false
var is_ready = false

func _ready():
	title = get_node("%Title") as Label
	body = get_node("%Body") as AnimatedText
	abort_tutorial_check = get_node("%CompleteTutorial") as CheckButton
	visible = true
	is_ready = true

	if !title or !body or !abort_tutorial_check:
		close()

func show_window(new_title: String, new_body: String, allow_abort: bool = true):
	title.text = tr(new_title)
	body.add_animated_text(new_body)
	abort_tutorial_check.button_pressed = false
	should_abort_tutorial = false
	abort_tutorial_check.visible = allow_abort
	visible = true

func toggle_abort_tutorial(value: bool):
	should_abort_tutorial = value

func close():
	if should_abort_tutorial:
		abort_tutorial.emit()
		queue_free()
	visible = false
	popup_closed.emit()