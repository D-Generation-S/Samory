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