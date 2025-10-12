@tool
extends EditorPlugin

var parsers: Array[String] = [
	"res://addons/resource_translation_plugin/resource_parser.gd"
]

var _loaded_parsers: Array = []

func _enter_tree() -> void:
	for parser: String in parsers:
		var resource_parser_plugin: ResourceParser = load(parser).new() as ResourceParser
		if resource_parser_plugin == null:
			printerr("Could not load parser plugin")
		_loaded_parsers.append(resource_parser_plugin)
		add_translation_parser_plugin(resource_parser_plugin)


func _exit_tree() -> void:
	for parser in _loaded_parsers:
		remove_translation_parser_plugin(parser)
