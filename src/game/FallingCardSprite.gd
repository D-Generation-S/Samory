extends Sprite2D

@export var max_width: int = 150
@export var max_height: int = 150

# Called when the node enters the scene tree for the first time.
func _ready():
	var texture_image = texture.get_image()
	texture_image.resize(max_width, max_height)
	texture = ImageTexture.create_from_image(texture_image)
