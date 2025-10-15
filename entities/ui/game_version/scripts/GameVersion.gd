extends Label

@export var version_translation_string: TextTranslation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var version: String = tr(version_translation_string.key)
	if not version.ends_with(" "):
		version += " "
	text = version + ProjectSettings.get_setting("application/config/version")
