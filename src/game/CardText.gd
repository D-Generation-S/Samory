extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_card_text(card_text):
	text = "[center]" + card_text +"[/center]"

