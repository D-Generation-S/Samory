extends Button

func _ready():
	if OS.has_feature("web"):
		visible = false

func _pressed():
	get_tree().quit()
