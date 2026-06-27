class_name CardInformationResource extends Resource

var position: Vector2i
var card: MemoryCardResource

func _init(pos: Vector2i, card_data: MemoryCardResource) -> void:
    position = pos
    card = card_data