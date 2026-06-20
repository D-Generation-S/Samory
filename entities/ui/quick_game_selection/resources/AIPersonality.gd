class_name AIPersonality extends Resource

@export var _name: TextTranslation
@export var _actions: Array[AiBehaviorNode]

func get_actions() -> Array[AiBehaviorNode]:
	return _actions

func get_personality_name() -> String:
	if _name == null:
		return "NOT FOUND"
	return tr(_name.key)