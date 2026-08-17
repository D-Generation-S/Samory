extends Node

const default_empty_changelog_text_template: String = "No Information for version %s provided!"
const changelog_not_existing_template: String = "Changelog %s does not exist!"
const changelog_directory: String = "res://shared/resources/changelog/"

const allowed_extensions: Array[String] = [
	"txt"
]

var _changelog_paths: Dictionary[String, String] = {}
var _changelog_content: Dictionary[String, String] = {}

func _ready() -> void:
	_scan_for_changelogs()

func get_changelogs(sort_callable: Callable = _custom_sort) -> Array[String]:
	var versions: Array[String] = _changelog_paths.keys()
	if sort_callable != null:
		versions.sort_custom(sort_callable)
	return versions

func _custom_sort(_a: String, _b: String) -> bool:
	return false

func get_changelog_content(version: String) -> String:
	if _changelog_content.has(version):
		return _changelog_content.get(version)
	return _load_file_content(version)

func _load_file_content(version: String) -> String:
	if not version in _changelog_paths.keys():
		return changelog_not_existing_template % version
	var path: String = _changelog_paths.get(version)
	var file_access: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file_access == null or file_access.get_error() != OK:
		return changelog_not_existing_template % version

	var return_data: String = file_access.get_as_text()
	if return_data.is_empty():
		return_data = default_empty_changelog_text_template % version

	return return_data

func _scan_for_changelogs() -> void:
	assert(DirAccess.dir_exists_absolute(changelog_directory), "Missing changelog directory")
	for file: String in DirAccess.get_files_at(changelog_directory):
		if not file.get_extension() in allowed_extensions:
			continue
		var path: String = "%s%s" % [changelog_directory, file]
		var version: String = file.replace(".%s" % file.get_extension(), "")
		_changelog_paths.set(version, path)
