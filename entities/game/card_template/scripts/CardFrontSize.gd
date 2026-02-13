extends Sprite2D

class_name CardFrontSize

@export var max_build_in_width: float = 480
@export var max_build_in_height: float = 480
@export var max_custom_width: float = 490
@export var max_custom_height: float = 490

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if texture != null:
		set_and_scale_texture(texture, false)

func set_and_scale_texture(new_texture: Texture2D, is_built_in: bool) -> void:
	if is_built_in:
		material = null
	var max_width: float = max_build_in_width
	var max_height: float = max_build_in_height
	if not is_built_in:
		max_width = max_custom_width
		max_height = max_custom_height

	if new_texture.get_width() <= max_width and new_texture.get_height() <= max_height:
		texture = new_texture
		if not is_built_in:
			return
	
	var ratio: float = min(max_width / new_texture.get_width(), max_height / new_texture.get_height())
	var new_image_size: Vector2i = Vector2i(int(new_texture.get_width() * ratio), int(new_texture.get_height() * ratio))
	var scaled_texture: Image = new_texture.get_image()
	scaled_texture.resize(new_image_size.x, new_image_size.y)
	texture = ImageTexture.create_from_image(scaled_texture) as Texture2D
