extends Resource

class_name MemoryDeckResource

@export_group("Deck Data")
@export var built_in: bool = true
@export var name: String
@export var description: String
@export var card_back: Texture2D
@export var cards: Array[MemoryCardResource] = []

@export_group("Settings")
@export var _settings: DeckSettings = preload("res://shared/resources/decks/settings/assets/DefaultDeckSettings.tres")

@export_group("Ignored")
@export var id: int = -1
@export var file_system_folder: String

var is_ready: bool = false
var using_default_texture: bool = false

var _real_back_image: Texture2D = null

func ready_up() -> void:
	if is_ready:
		return
	is_ready = true
	var cid: int = 0
	for card: MemoryCardResource in cards:
		card.set_id(cid)
		cid = cid + 1

func get_back_image() -> Texture2D:
	if card_back == null:
		return null
	if is_using_default_texture():
		return null
	if _real_back_image != null:
		return _real_back_image

	var image: Image = card_back.get_image()
	if image.get_width() < _settings.target_width or image.get_height() < _settings.target_height:
		var fixed_image: Image = fix_image(image)
		if fixed_image == null:
			return null

		_real_back_image = ImageTexture.create_from_image(fixed_image) as Texture2D
		return _real_back_image
	
	return null

func fix_image(image: Image) -> Image:
	var new_image: Image  = Image.create(_settings.target_width, _settings.target_height, false, image.get_format())
	new_image.fill(_settings.enforced_back_color)

	var offset_x: float = (_settings.target_width - image.get_width()) / 2.0
	var offset_y: float = (_settings.target_height - image.get_height()) / 2.0
	new_image.blit_rect(image, image.get_used_rect(), Vector2i(int(offset_x), int(offset_y)))
	return new_image

func is_using_default_texture() -> bool:
	return using_default_texture or built_in