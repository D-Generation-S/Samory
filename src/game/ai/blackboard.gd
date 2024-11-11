class_name Blackboard extends Node



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_card(position: Point, card: MemoryCardResource):
	pass

func cards_remembered() -> int:
	return 0

func get_random_known_card_from_storage() -> MemoryCardResource:
	return null

func get_card_positions_by_id(index: int) -> Array[MemoryCardResource]:
	return []
