class_name ChangelogLogViewer extends RichTextLabel

func _ready() -> void:
	bbcode_enabled = true

func load_version(version: String) -> void:
	text = ChangelogService.get_changelog_content(version)