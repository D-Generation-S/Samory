extends Node

class_name DeckLoader 

func _get_default_cover() -> Texture2D:
	return load("res://assets/sprites/Axuree/back_card_3.png") as Texture2D

func list_decks() -> Array[String]:
	var base_path: String = build_deck_base_path("")
	DirAccess.make_dir_absolute(base_path)
	var decks: PackedStringArray = DirAccess.get_directories_at(base_path)
	var return_data: Array[String]
	return_data.assign(decks)
	var valid_decks:Array[String] = []
	for deck: String in return_data:
		if validate_deck(deck):
			valid_decks.append(deck)
	return valid_decks

func get_deck_name(deck_folder: String) -> String:
	var path: String = build_deck_base_path(deck_folder)
	var fallback_path: String = path + "/name.txt"
	var localized_path: String = path + "/name.%s.txt" % TranslationServer.get_locale()
	if FileAccess.file_exists(localized_path):
		return FileAccess.get_file_as_string(localized_path)
	return FileAccess.get_file_as_string(fallback_path)

func get_deck_description(deck_folder: String) -> String:
	var path: String = build_deck_base_path(deck_folder)
	var fallback_path: String = path + "/description.txt"
	var localized_path: String = path + "/description.%s.txt" % TranslationServer.get_locale()
	if FileAccess.file_exists(localized_path):
		return FileAccess.get_file_as_string(localized_path)
	return FileAccess.get_file_as_string(fallback_path)

func validate_deck_meta_data(deck_folder: String) -> bool:
	var path: String = build_deck_base_path(deck_folder)
	var fallback_path: String = path + "/name.txt"
	return FileAccess.file_exists(fallback_path)

func list_deck_cards(deck_folder: String) -> Array[String]:
	var base_path: String = build_card_base_path(deck_folder)
	var cards: PackedStringArray = DirAccess.get_directories_at(base_path)
	var return_cards: Array[String]
	for card: String in cards:
		if validate_card_of_deck(deck_folder, card):
			return_cards.append(card)
	return return_cards

func validate_card_of_deck(deck_folder: String, card_name: String) -> bool:
	var path: String = "%s/%s" % [build_card_base_path(deck_folder), card_name]
	var card_name_path: String = path + "/name.txt"
	var valid_front: bool = false
	for allowed_image: String in build_front_image_names():
		var card_image_path: String = "%s/%s" % [path, allowed_image]
		if FileAccess.file_exists(card_image_path):
			valid_front = true
			break
	return FileAccess.file_exists(card_name_path) and valid_front

func build_front_image_names() -> Array[String]:
	return ["front.png", "front.jpg"]

func build_deck_base_path(deck_directory: String) -> String:
	return "user://decks/" + deck_directory
	
func build_card_base_path(deck_directory: String) -> String:
	return build_deck_base_path(deck_directory) + "/cards" 

func validate_deck(deck_folder: String) -> bool:
	return validate_deck_meta_data(deck_folder) and list_deck_cards(deck_folder).size() >= 2

func load_custom_decks() -> Array[MemoryDeckResource]:
	var custom_deck_loader: CustomDeckLoader = CustomDeckLoader.new()
	var data: Array[MemoryDeckResource] = custom_deck_loader.load_decks()
	for deck: MemoryDeckResource in data:
		if deck.card_back == null:
			deck.card_back = _get_default_cover()
	return data

func load_custom_decks_async() -> Thread:
	var thread: Thread = Thread.new()
	thread.start(load_custom_decks)

	return thread

func load_deck(deck_name: String) -> MemoryDeckResource:
	var path: String = build_deck_base_path(deck_name)
	var deck_found: bool = DirAccess.dir_exists_absolute(path)
	if !deck_found:
		printerr("deck not found")
		return null
	var return_deck: MemoryDeckResource = MemoryDeckResource.new()
	return_deck.name = get_deck_name(deck_name)
	return_deck.description = get_deck_description(deck_name)
	return_deck.built_in = false
	return_deck.cards = [] as Array[MemoryCardResource]
	return_deck.file_system_folder = deck_name

	return_deck.card_back = get_cover_image(deck_name)
	for card_name: String in list_deck_cards(deck_name):
		var card: MemoryCardResource = load_card(deck_name, card_name)
		if card != null:
			return_deck.cards.append(card)

	return return_deck

func load_deck_async(deck_name: String) -> Thread:
	var thread: Thread = Thread.new()
	thread.start(load_deck.bind(deck_name))

	return thread

func get_cover_image(deck_name: String) -> Texture2D:
	var image_source_path: String = "%s/cover.png" % build_deck_base_path(deck_name)
	var localized_cover: String = "%s/cover.%s.png" % [build_deck_base_path(deck_name), TranslationServer.get_locale()]

	if FileAccess.file_exists(localized_cover):
		image_source_path = localized_cover

	if FileAccess.file_exists(image_source_path):
		var image: Image = Image.load_from_file(image_source_path)
		return ImageTexture.create_from_image(image) as Texture2D
		
	return _get_default_cover()

func load_card(deck_name: String, card_name: String) -> MemoryCardResource:
	var base_path: String = "%s/%s" % [build_card_base_path(deck_name), card_name]
	var name_path: String =  "%s/name.txt" % base_path
	var description_path: String = "%s/description.txt" % base_path
	var image_path: String = ""
	for allowed_image: String in build_front_image_names():
		var card_image_path: String = "%s/%s" % [base_path, allowed_image]
		if FileAccess.file_exists(card_image_path):
			image_path = card_image_path
	
	var localized_name: String = "%s/name.%s.txt" % [base_path, TranslationServer.get_locale()]
	var localized_description: String = "%s/description.%s.txt" % [base_path, TranslationServer.get_locale()]

	if FileAccess.file_exists(localized_name):
		name_path = localized_name
	if FileAccess.file_exists(localized_description):
		description_path = localized_description

	var final_card_name: String = FileAccess.get_file_as_string(name_path)
	var description: String = FileAccess.get_file_as_string(description_path)

	var image: Image = Image.load_from_file(image_path)
	var texture: ImageTexture = ImageTexture.create_from_image(image)

	var card: MemoryCardResource = MemoryCardResource.new()
	card.name = final_card_name
	card.description = description
	card.texture = texture

	return card
