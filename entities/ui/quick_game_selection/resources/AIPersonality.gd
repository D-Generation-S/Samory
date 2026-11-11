class_name AIPersonality extends Resource

@export var _name: TextTranslation
@export var _actions: Array[AiBehaviorNode]
## This can improve or worsen the base memory or an ai 
@export var _memory_change: int = 0

func get_actions() -> Array[AiBehaviorNode]:
	return _actions

func get_personality_name() -> String:
	if _name == null:
		return "NOT FOUND"
	return tr(_name.key)

func get_memory_change() -> int:
	return _memory_change