extends RichTextLabel

func _ready():
	bbcode_enabled = true

func set_error(error_key: String):
	text = "[color=red]" + tr(error_key) + "[/color]"

func reset():
	text = ""

