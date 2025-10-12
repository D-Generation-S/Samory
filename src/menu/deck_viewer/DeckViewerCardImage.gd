class_name DecKViewerCardImage extends TextureRect

@export var max_width: float = 500.0
@export var max_height: float = 500.0

func set_image(new_texture: Texture) -> void:
	if new_texture.get_width() <= max_width and new_texture.get_height() < max_height:
		texture = new_texture
	var ratio: float = min(max_width / new_texture.get_width(), max_height / new_texture.get_height())
	var new_image_size: Vector2i = Vector2i(new_texture.get_width() * ratio, new_texture.get_height() * ratio)
	var scaled_texture: Image = new_texture.get_image()
	scaled_texture.resize(new_image_size.x, new_image_size.y)
	texture = ImageTexture.create_from_image(scaled_texture) as Texture2D
