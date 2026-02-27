class_name TutorialWindow extends PopupWindow

signal abort_tutorial()
signal append_text(new_text: String)
signal title_changed(new_title: String)

var abort_tutorial_check: CheckButton = null

var should_abort_tutorial: bool = false
var is_ready: bool = false

func _ready() -> void:
	abort_tutorial_check = get_node("%CompleteTutorial") as CheckButton
	visible = true
	is_ready = true

	if !abort_tutorial_check:
		close()

func show_window(new_title: String, new_body: String, allow_abort: bool = true) -> void:
	title_changed.emit(new_title)
	append_text.emit(new_body)
	abort_tutorial_check.button_pressed = false
	should_abort_tutorial = false
	abort_tutorial_check.visible = allow_abort
	visible = true

func toggle_abort_tutorial(value: bool) -> void:
	should_abort_tutorial = value

func close() -> void:
	if should_abort_tutorial:
		abort_tutorial.emit()
		queue_free()
	visible = false
	popup_closed.emit()
