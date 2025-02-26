class_name TutorialWindow extends CenterContainer

signal abort_tutorial()
signal window_closed()

var title: Label = null
var body: RichTextLabel = null
var abort_tutorial_check: CheckButton = null

var should_abort_tutorial = false

func _ready():
	title = get_node("%Title") as Label
	body = get_node("%Body") as RichTextLabel
	abort_tutorial_check = get_node("%CompleteTutorial") as CheckButton
	visible = false

	if !title or !body or !abort_tutorial_check:
		close()

func show_window(new_title: String, new_body: String, allow_abort: bool = true):
	title.text = tr(new_title)
	body.text = tr(new_body)
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
		return
	visible = false
	window_closed.emit()
