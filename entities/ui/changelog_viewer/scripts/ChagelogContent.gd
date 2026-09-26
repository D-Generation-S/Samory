class_name ChangelogLogViewer extends RichTextLabel

func _ready() -> void:
	bbcode_enabled = true
	if not meta_clicked.is_connected(_meta_data_clicked):
		meta_clicked.connect(_meta_data_clicked)

func load_version(version: String) -> void:
	text = ChangelogService.get_changelog_content(version)

func _meta_data_clicked(meta: Variant) -> void:
	if meta is String:
		OS.shell_open(meta)