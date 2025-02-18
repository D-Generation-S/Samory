class_name PlayerResource
extends Resource

@export var ai_difficulty: AiDifficultyResource = null
@export var name: String
@export var score: int
@export var age: int
@export var id: int

func is_ai() -> bool:
    return ai_difficulty != null