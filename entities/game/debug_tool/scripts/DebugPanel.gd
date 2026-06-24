class_name DebugPanel extends Control

@export var memory_game: MemoryGame
@export var debug_functions: Array[DebugFunctionality]

@onready var button_root: Control = get_node("%ButtonHook")

func _init() -> void:
	visible = false
	GlobalGameManagerAccess.game_manager.debug_mode.connect(toggle_visibility)
	toggle_visibility(GlobalGameManagerAccess.game_manager.is_debug)

func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return
	if memory_game == null:
		queue_free()
	_create_buttons()

func _create_buttons() -> void:
	for function: DebugFunctionality in debug_functions:
		var child: Button = Button.new()
		child.text = function.get_display_name()
		child.pressed.connect(function.execute_function.bind(memory_game))
		button_root.add_child(child)

func toggle_visibility(new_state: bool) -> void:
	visible = new_state