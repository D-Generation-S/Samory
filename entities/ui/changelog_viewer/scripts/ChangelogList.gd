class_name ChangelogList extends VBoxContainer

signal change_display_version(version: String)

@export var template: Node = null

func _ready() -> void:
	assert(not template == null, "Missing template")
	assert(template is InstancePlaceholder, "Template is not a instance placeholder")
	var placeholder: InstancePlaceholder = template as InstancePlaceholder
	assert(not placeholder == null, "Could not convert template to InstancePlaceholder")
	for version: String in ChangelogService.get_changelogs(_custom_version_sort):
		if version.count(".") > 2:
			continue
		var instance: ChangelogEntry = placeholder.create_instance()
		if instance == null:
			continue
		instance.text = version
		instance.version_pressed.connect(_changelog_clicked)
		if version == ProjectSettings.get("application/config/version"):
			instance.pressed.emit()


func _custom_version_sort(a: String, b: String) -> bool:
	var split_a: PackedStringArray = a.split(".")
	var split_b: PackedStringArray = b.split(".")
	if split_a.size() != split_b.size():
		return split_a.size() > split_b.size()

	if split_a[0] == split_b[0]:
		if split_a[1] == split_b[1]:
			return int(split_a[2]) > int(split_b[2])
		return int(split_a[1]) > int(split_b[1])
	return int(split_a[0]) > int(split_b[0])

func _changelog_clicked(version: String) -> void:
	if version.is_empty():
		return
	change_display_version.emit(version)
