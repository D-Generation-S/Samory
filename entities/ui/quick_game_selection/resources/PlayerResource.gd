class_name PlayerResource
extends Resource

@export var ai_difficulty: AiDifficultyResource = null
@export var name: String
@export var score: int
@export var order_number: int
@export var id: int

## This will initialize the player, this will also _reset the score and AI node.
## Call this once before starting a new game
func initialize() -> void:
	_reset()
	if is_ai():
		ai_difficulty.initialize()

func get_display_name() -> String:
	if is_ai():
		return name + " [AI]"
	return name

func is_ai() -> bool:
	return ai_difficulty != null

func _reset() -> void:
	score = 0
	if is_ai():
		ai_difficulty.reset()
