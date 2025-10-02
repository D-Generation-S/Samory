class_name PlayerResource
extends Resource

@export var ai_difficulty: AiDifficultyResource = null
@export var name: String
@export var score: int
@export var order_number: int
@export var id: int

func get_display_name():
	if is_ai():
		return name + " [AI]"
	return name

func is_ai() -> bool:
	return ai_difficulty != null

func get_network_data_set() -> Dictionary:
	var ai_path: String = ""
	if ai_difficulty != null:
		ai_path = ai_difficulty.resource_path
	return {
			"id": id,
			"name": name,
			"order": order_number,
			"score": score,
			"ai-path": ai_path
		}
