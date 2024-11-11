class_name AiBehaviorNode extends Node

var ai_node: AiAgent

func _ready():
	ai_node = get_parent() as AiAgent

func execute_action(blackboard: Blackboard):
	pass
