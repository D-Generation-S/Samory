class_name DecKViewerCardImage extends TextureRect

@export var max_width = 500.0
@export var max_heigth = 500.0

func set_image(new_texture: Texture):
	if new_texture.get_width() <= max_width and new_texture.get_height() < max_heigth:
		texture = new_texture
	var ratio = min(max_width / new_texture.get_width(), max_heigth / new_texture.get_height())
	var new_image_size = Vector2(new_texture.get_width() * ratio, new_texture.get_height() * ratio)
	var scaled_texture = new_texture.get_image()
	scaled_texture.resize(new_image_size.x, new_image_size.y)
	texture = ImageTexture.create_from_image(scaled_texture) as Texture2D
