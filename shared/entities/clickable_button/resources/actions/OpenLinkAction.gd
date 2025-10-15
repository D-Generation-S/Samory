class_name OpenLinkAction extends ButtonAction

@export var link: String

func execute(_base: ClickableButton) -> void:
	OS.shell_open(link)