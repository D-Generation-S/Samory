extends TextureRect

@export var image: Texture2D = null:
	set(value):
		_image = value
		set_image(_image)
	get:
		return _image
@export var max_width: float = 200
@export var max_height: float = 200

var _image: Texture2D
var _initial_image: Texture2D

func _ready() -> void:
	_initial_image = texture
	set_image(image)

func _reset() -> void:
	texture = _initial_image

func new_image_selected(image_path: String) -> void:
	if image_path == "":
		return
	var loaded_image: Image = Image.load_from_file(image_path)
	var loaded_texture: ImageTexture = ImageTexture.create_from_image(loaded_image)
	image = loaded_texture as Texture2D

func set_image(new_image: Texture2D) -> void:
	if new_image == null:
		return
	print(new_image)
	if new_image.get_width() <= max_width and new_image.get_height() < max_height:
		texture = new_image
		return
	var ratio: float = min(max_width / new_image.get_width(), max_height / new_image.get_height())
	var new_image_size: Vector2i = Vector2i(int(new_image.get_width() * ratio), int(new_image.get_height() * ratio))
	var scaled_texture: Image = new_image.get_image()
	scaled_texture.resize(new_image_size.x, new_image_size.y)
	texture = ImageTexture.create_from_image(scaled_texture) as Texture2D

func deck_updated(deck: CustomDeckResource) -> void:
	if deck.loaded_texture != null:
		set_image(deck.loaded_texture)
		return
	new_image_selected(deck.get_image_path())