class_name PlayerResource
extends Resource

@export var ai_difficulty: AiDifficultyResource = null
@export var name: String
@export var score: int
@export var order_number: int
@export var id: int

static func from_network_data(data: Dictionary) -> PlayerResource:
	var player = PlayerResource.new()
	player.id = data["id"]
	player.name = data["name"]
	player.order_number = data["order"]
	player.score = data["score"]
	var ai_path: String = data["ai-path"]
	if ai_path != "":
		player.ai_difficulty = load(ai_path)
	
	return player


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
