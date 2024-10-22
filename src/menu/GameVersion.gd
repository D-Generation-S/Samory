extends Label

@export var version_translation_string: String = "VERSION"

# Called when the node enters the scene tree for the first time.
func _ready():
	var version = tr(version_translation_string)
	text = version + ProjectSettings.get_setting("application/config/version")