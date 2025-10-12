extends ClickableButton

@export var continue_text_template: String
@export var close_text_template: String

signal close_dialog()
signal continue_text()

var is_continue_mode: bool = false

func _pressed() -> void:
	visible = false
	if is_continue_mode:
		continue_text.emit()
		return

	close_dialog.emit()

func set_continue_text_mode() -> void:
	is_continue_mode = true
	text = tr(continue_text_template)
	pass

func set_to_close_mode() -> void:
	is_continue_mode = false
	text = tr(close_text_template)
	pass

func disable_button() -> void:
	disabled = true

func enable_button() -> void:
	disabled = false