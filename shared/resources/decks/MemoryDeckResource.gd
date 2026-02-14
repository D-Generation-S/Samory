extends Resource

class_name MemoryDeckResource

@export_group("Deck Data")
@export var built_in: bool = true
@export var name: String
@export var description: String
@export var card_back: Texture2D
@export var cards: Array[MemoryCardResource] = []

@export_group("Ignored")
@export var id: int = -1
@export var file_system_folder: String

var is_ready: bool = false
var using_default_texture: bool = false

func ready_up() -> void:
	if is_ready:
		return
	is_ready = true
	var cid: int = 0
	for card: MemoryCardResource in cards:
		card.set_id(cid)
		cid = cid + 1

func is_using_default_texture() -> bool:
	return using_default_texture or built_in