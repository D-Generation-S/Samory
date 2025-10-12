extends RichTextLabel

func _ready() -> void:
	bbcode_enabled = true

func set_error(error_key: String) -> void:
	text = "[color=red]" + tr(error_key) + "[/color]"

func reset() -> void:
	text = ""

