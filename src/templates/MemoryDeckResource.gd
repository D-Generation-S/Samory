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