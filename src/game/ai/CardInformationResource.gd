class_name CardInformationResource extends Resource

var position: Point
var card: MemoryCardResource

func _init(pos: Point, card_data: MemoryCardResource) -> void:
    position = pos
    card = card_data