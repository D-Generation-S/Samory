extends ClickableButton

func _ready() -> void:
	super()
	if OS.has_feature("web"):
		visible = false

func _pressed() -> void:
	super()
	get_tree().quit()
