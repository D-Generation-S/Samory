extends Sprite2D

class_name CardFrontSize

@export var max_width: float = 500
@export var max_height: float = 500


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_and_scale_texture(new_texture: Texture2D):
	if new_texture.get_width() <= max_width and new_texture.get_height() < max_height:
		texture = new_texture
	var ratio = min(max_width / new_texture.get_width(), max_height / new_texture.get_height())
	var new_image_size = Vector2(new_texture.get_width() * ratio, new_texture.get_height() * ratio)
	var scaled_texture = new_texture.get_image()
	scaled_texture.resize(new_image_size.x, new_image_size.y)
	texture = ImageTexture.create_from_image(scaled_texture) as Texture2D
