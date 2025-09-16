@tool
extends EditorPlugin

var parsers: Array = [
	"res://addons/resource_translation_plugin/resource_parser.gd"
]

var _loaded_parsers: Array = []

func _enter_tree():
	for parser in parsers:
		var resource_parser_plugin = load(parser).new()
		if resource_parser_plugin == null:
			printerr("Could not load parser plugin")
		_loaded_parsers.append(resource_parser_plugin)
		add_translation_parser_plugin(resource_parser_plugin)


func _exit_tree():
	for parser in _loaded_parsers:
		remove_translation_parser_plugin(parser)
