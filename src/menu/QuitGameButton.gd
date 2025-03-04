extends ClickableButton

func _ready():
	super()
	if OS.has_feature("web"):
		visible = false

func _pressed():
	get_tree().quit()
