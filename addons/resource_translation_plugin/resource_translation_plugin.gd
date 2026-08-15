@tool
extends EditorPlugin

const built_in_translation_provider_path: String = "res://addons/resource_translation_plugin/parsers/"
const custom_in_translation_provider_path: String = ""

var parsers: Array[String] = [
	"res://addons/resource_translation_plugin/resource_parser.gd"
]

var _loaded_parsers: Array[TranslationPlugin] = []

func _enter_tree() -> void:
	add_parsers_from_path(built_in_translation_provider_path)
	add_parsers_from_path(custom_in_translation_provider_path)

func add_parsers_from_path(path: String) -> void:
	if not DirAccess.dir_exists_absolute(built_in_translation_provider_path):
		return
	
	var files: PackedStringArray = DirAccess.get_files_at(path)
	for file_name: String in files:
		var real_path: String = "%s%s" % [path, file_name]
		if not real_path.ends_with(".gd"):
			continue
		var parser_resource: TranslationPlugin = load(real_path).new() as TranslationPlugin
		if parser_resource == null:
			continue
		_loaded_parsers.append(parser_resource)
		add_translation_parser_plugin(parser_resource)

func _exit_tree() -> void:
	for parser: TranslationPlugin in _loaded_parsers:
		remove_translation_parser_plugin(parser)