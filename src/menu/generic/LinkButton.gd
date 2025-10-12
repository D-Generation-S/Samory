extends ClickableButton

@export var link: String

func _pressed() -> void:
	super()
	OS.shell_open(link)