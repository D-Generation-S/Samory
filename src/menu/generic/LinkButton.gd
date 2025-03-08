extends ClickableButton

@export var link: String

func _pressed():
	super()
	OS.shell_open(link)