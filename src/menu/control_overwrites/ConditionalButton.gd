class_name ConditionalButton extends ClickableButton

enum {
	WEB,
	DESKTOP,
	MOBILE,
	DEBUG
}

@export_flags("Web", "Desktop", "Mobile","Debug") var active: int = 0

func _ready() -> void:
	super()
	visible = false
	if active & (1 << WEB) && OS.has_feature("web"):
		visible = true

	if active & (1 << DESKTOP) && is_desktop():
		visible = true

	if active & (1 << MOBILE) && is_mobile():
		visible = true

	if active & (1 << DEBUG) && !OS.is_debug_build():
		print_debug("debug only")
		queue_free()

func is_desktop() -> bool:
	return OS.has_feature("windows")

func is_mobile() -> bool:
	return OS.has_feature("web_android") or OS.has_feature("web_ios")