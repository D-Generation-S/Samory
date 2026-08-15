@tool
@abstract
class_name TranslationPlugin extends EditorTranslationParserPlugin

const ignored_directories: Array[String] = [
	"res://.godot",
	"res://.vscode",
	"res://addons",
]

func _parse_file(path) -> Array[PackedStringArray]:
	return parse(path)

func _get_recognized_extensions() -> PackedStringArray:
	return get_extension()

func _customize_strings(strings: Array[PackedStringArray]) -> Array[PackedStringArray]:
	return register_or_change_translations(strings)


@abstract func parse(path: String) -> Array[PackedStringArray]

@abstract func get_extension() -> PackedStringArray

@abstract func register_or_change_translations(strings: Array[PackedStringArray])

func _get_all_resources() -> Array[String]:
	return _load_resources("res://")

func _load_resources(root: String) -> Array[String]:
	if root in ignored_directories:
		return []
	if not root.ends_with("/"):
		root = root + "/"
	var return_data: Array[String] = []
	for file: String in DirAccess.get_files_at(root):
		return_data.append("%s%s" % [root, file])

	for directory: String in DirAccess.get_directories_at(root):
		return_data.append_array(_load_resources("%s%s" % [root, directory]))

	return return_data
