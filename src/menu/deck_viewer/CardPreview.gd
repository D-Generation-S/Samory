class_name CardPreview extends MarginContainer

@export var card_name: Label
@export var card_description: RichTextLabel
@export var card_image: DecKViewerCardImage

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_card(card: MemoryCardResource):
	card_name.text = card.name
	card_description.text = card.description
	card_image.set_image(card.texture)
