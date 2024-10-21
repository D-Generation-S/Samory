extends Button

@export var link: String

func _pressed():
	OS.shell_open(link)