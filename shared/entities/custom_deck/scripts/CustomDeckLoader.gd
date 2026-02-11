class_name CustomDeckLoader extends Resource

var _max_image_width: float = 500
var _max_image_height: float = 500
var _base_path: String = "user://custom_decks/"
var _back_image_name: String = "back.png"
var _deck_information_file_name: String = "deck_info"
var _card_base_path: String = "cards/"
var _asset_base_folder: String = "assets/"

func save_deck(deck_information: CustomDeckResource, deck_data: Array[CustomDeckResource]) -> bool:
	print("Saving deck with name: " + deck_information.get_resource_name())
	var cards: Array[CustomDeckResource] = []
	for resource: CustomDeckResource in deck_data:
		if not resource.get_is_deck():
			cards.append(resource)
	
	var save_file_name: String =deck_information.get_file_name().replace(" ", "_")
	save_file_name = save_file_name.to_lower()
	var path: String = "%s%s.sdeck" % [_base_path, save_file_name]
	var packer: ZIPPacker = ZIPPacker.new()
	DirAccess.make_dir_absolute(_base_path)
	packer.open(path)
	save_deck_information(packer, deck_information)

	for card: CustomDeckResource in cards:
		save_card(packer,card)

	packer.close()
	return true

func save_card(packer: ZIPPacker, card: CustomDeckResource) -> bool:
	var image_name: String = "%s_%s.png" % [card.get_id(), card.get_resource_name()]
	_save_asset(packer, card, image_name)
	card.set_image(image_name)
	packer.start_file("%s%s" % [_card_base_path, card.get_id()])
	packer.write_file(
		_create_deck_information(card).to_utf8_buffer()
	)
	packer.close_file()
	return false

func save_deck_information(packer: ZIPPacker, deck_information: CustomDeckResource) -> bool:
	_save_asset(packer, deck_information, _back_image_name)
	deck_information.set_image(_back_image_name)

	packer.start_file("%s" % [_deck_information_file_name])
	packer.write_file(_create_deck_information(deck_information).to_utf8_buffer())
	packer.close_file()

	return true

func _create_deck_information(deck_information: CustomDeckResource) -> String:
	return JSON.stringify({
			"id": deck_information.get_id(),
			"file_name": deck_information.get_file_name(),
			"name": deck_information.get_resource_name(),
			"description": deck_information.get_description(),
			"is_deck": deck_information.get_is_deck(),
			"image": deck_information.get_image_path()
		})

func _load_asset_from_disc(asset_path: String) -> Texture2D:
	if asset_path == "":
		return null
	var loaded_image: Image = Image.load_from_file(asset_path)
	var loaded_texture: ImageTexture = ImageTexture.create_from_image(loaded_image)
	var real_texture: Texture2D = loaded_texture as Texture2D
	return real_texture

func _save_asset(packer: ZIPPacker, data: CustomDeckResource, asset_name: String) -> bool:
	var current_texture: Texture2D = data.loaded_texture
	if current_texture == null:
		current_texture = _load_asset_from_disc(data.get_image_path())
	if current_texture == null:
		return false

	var image_resource: Texture2D = convert_image_to_resource(current_texture)
	packer.start_file("%s%s" % [_asset_base_folder, asset_name])
	packer.write_file(image_resource.get_image().save_png_to_buffer())
	packer.close_file()
	return true

func convert_image_to_resource(real_texture: Texture2D) -> Texture2D:
	if real_texture == null:
		return null
	var loaded_image: Image = real_texture.get_image()

	if loaded_image.get_width() <= _max_image_width and loaded_image.get_height() <= _max_image_height:
		return real_texture
	var ratio: float = minf(_max_image_width / loaded_image.get_width(), _max_image_height / loaded_image.get_height())
	var new_image_size: Vector2i = Vector2i(int(loaded_image.get_width() * ratio), int(loaded_image.get_height() * ratio))

	var scaled_texture: Image = real_texture.get_image()
	scaled_texture.resize(new_image_size.x, new_image_size.y)
	return ImageTexture.create_from_image(scaled_texture) as Texture2D

func load_editable_deck(deck_path: String) -> Array[CustomDeckResource]:
	if not FileAccess.file_exists(deck_path):
		return []
	var loaded_data: Array[CustomDeckResource] = []
	var reader: ZIPReader = ZIPReader.new()
	reader.open(deck_path)

	var deck_information: CustomDeckResource = load_deck_information(reader)
	loaded_data.append(deck_information)
	var files: PackedStringArray = reader.get_files()
	for file: String in files:
		if file.begins_with(_card_base_path):
			var card_data: CustomDeckResource = _load_resource_information(reader, file)
			if card_data != null and not card_data.get_is_deck():
				loaded_data.append(card_data)

	reader.close()
	return loaded_data

func load_deck_information(reader: ZIPReader) -> CustomDeckResource:
	return _load_resource_information(reader, "%s" % [_deck_information_file_name])

func _create_deck_info_from_dictionary(dict: Dictionary) -> CustomDeckResource:
	var file_name: String = dict.get_or_add("file_name", dict["name"])
	var return_resource: CustomDeckResource = CustomDeckResource.new(dict["id"], dict["is_deck"], file_name, dict["description"], dict["image"])
	return_resource.set_deck_name(dict["name"])
	return return_resource

func _load_resource_information(reader: ZIPReader, card_path: String) -> CustomDeckResource:
	var read_data: PackedByteArray = reader.read_file(card_path)
	var deck_info_data: Dictionary = JSON.parse_string(read_data.get_string_from_utf8())
	var deck_resource: CustomDeckResource = _create_deck_info_from_dictionary(deck_info_data)
	deck_resource.loaded_texture = load_image(reader, deck_resource.get_image_path())

	return deck_resource

func load_image(reader: ZIPReader, image_path: String) -> Texture2D:
	var file_path: String = "%s%s" % [_asset_base_folder, image_path]
	if image_path == "" or not reader.file_exists(file_path):
		return null
	
	var read_data: PackedByteArray = reader.read_file(file_path)

	var loaded_image: Image = Image.new()
	loaded_image.load_png_from_buffer(read_data)
	var loaded_texture: ImageTexture = ImageTexture.create_from_image(loaded_image)
	return loaded_texture as Texture2D

func convert_to_playable_card(resource: CustomDeckResource) -> MemoryCardResource:
	if resource == null or resource.get_is_deck():
		return
	var return_resource: MemoryCardResource = MemoryCardResource.new()
	return_resource.name = resource.get_resource_name()
	return_resource.description = resource.get_description()
	var image: Texture2D = resource.loaded_texture
	if image == null:
		image = _load_asset_from_disc(resource.get_image_path())
	return_resource.texture = image

	return return_resource

func load_playable_deck(deck_path: String) -> MemoryDeckResource:
	return null
