class_name ChangelogEntry extends Button

signal version_pressed(version: String)

func _ready() -> void:
	pressed.connect(_was_pressed)

func _was_pressed() -> void:
	version_pressed.emit(text)