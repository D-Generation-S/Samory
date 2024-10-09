extends Node

class_name DeckLoader 

func list_decks() -> Array[String]:
	var base_path = build_deck_base_path("")
	DirAccess.make_dir_absolute(base_path)
	var decks = DirAccess.get_directories_at(base_path)
	var return_data: Array[String]
	return_data.assign(decks)
	var valid_decks:Array[String] = []
	for deck in return_data:
		if validate_deck(deck):
			valid_decks.append(deck)
	return valid_decks

func get_deck_name(deck_folder: String) -> String:
	var path = build_deck_base_path(deck_folder)
	var fallback_path = path + "/name.txt"
	var localized_path = path + "/name." + TranslationServer.get_locale() + ".txt"
	if FileAccess.file_exists(localized_path):
		return FileAccess.get_file_as_string(localized_path)
	return FileAccess.get_file_as_string(fallback_path)

func validate_deck_meta_data(deck_folder: String) -> bool:
	var path = build_deck_base_path(deck_folder)
	var fallback_path = path + "/name.txt"
	return FileAccess.file_exists(fallback_path)

func list_deck_cards(deck_folder: String) -> Array[String]:
	var base_path = build_card_base_path(deck_folder)
	var cards = DirAccess.get_directories_at(base_path)
	var return_cards: Array[String]
	for card in cards:
		if valdiate_card_of_deck(deck_folder, card):
			return_cards.append(card)
	return return_cards

func valdiate_card_of_deck(deck_folder: String, card_name: String) -> bool:
	var path = build_card_base_path(deck_folder) + "/" + card_name
	var card_name_path = path + "/name.txt"
	var valid_front = false
	for allowed_image in build_front_image_names():
		var card_image_path = path + "/" + allowed_image
		if FileAccess.file_exists(card_image_path):
			valid_front = true
			break
	var name_exists = FileAccess.file_exists(card_name_path)
	return name_exists and valid_front

func build_front_image_names() -> Array[String]:
	return ["front.png", "front.jpg"]

func build_deck_base_path(deck_directory: String) -> String:
	return "user://decks/" + deck_directory
	
func build_card_base_path(deck_directory: String) -> String:
	return build_deck_base_path(deck_directory) + "/cards" 

func validate_deck(deck_folder: String) -> bool:
	var meta_valid = validate_deck_meta_data(deck_folder)
	var cards = list_deck_cards(deck_folder)
	return meta_valid and cards.size() >= 2

func load_deck(deck_name: String) -> MemoryDeckResource:
	var path = build_deck_base_path(deck_name)
	var deck_found = DirAccess.dir_exists_absolute(path)
	if !deck_found:
		print("deck not found")
		return null
	var return_deck = MemoryDeckResource.new()
	return_deck.name = get_deck_name(deck_name)
	return_deck.built_in = false
	return_deck.cards = [] as Array[MemoryCardResource]
	return_deck.file_system_folder = deck_name

	return_deck.card_back = get_cover_image(deck_name)
	for card_name in list_deck_cards(deck_name):
		var card = load_card(deck_name, card_name)
		if card != null:
			return_deck.cards.append(card)

	print(return_deck)
	return return_deck

func load_deck_async(deck_name: String) -> Thread:
	var thread = Thread.new()
	thread.start(load_deck.bind(deck_name))

	return thread

func get_cover_image(deck_name: String) -> Texture2D:
	var image_source_path = build_deck_base_path(deck_name) + "/cover.png"
	var localized_cover = build_deck_base_path(deck_name) + "/cover." + TranslationServer.get_locale() + ".png"

	if FileAccess.file_exists(localized_cover):
		image_source_path = localized_cover

	if FileAccess.file_exists(image_source_path):
		var image = Image.load_from_file(image_source_path)
		return ImageTexture.create_from_image(image) as Texture2D
		
	return load("res://assets/sprites/CardDefaultBack.png") as Texture2D

func load_card(deck_name: String, card_name: String) -> MemoryCardResource:
	var base_path = build_card_base_path(deck_name) + "/" + card_name
	var name_path = base_path + "/name.txt"
	var description_path = base_path + "/description.txt"
	var image_path = ""
	for allowed_image in build_front_image_names():
		var card_image_path = base_path + "/" + allowed_image
		if FileAccess.file_exists(card_image_path):
			image_path = card_image_path
	
	var localized_name = base_path + "/name." + TranslationServer.get_locale() + ".txt"
	var localized_description = base_path + "/description." + TranslationServer.get_locale() + ".txt"

	if FileAccess.file_exists(localized_name):
		name_path = localized_name
	if FileAccess.file_exists(localized_description):
		description_path = localized_description

	var final_card_name = FileAccess.get_file_as_string(name_path)
	var description = FileAccess.get_file_as_string(description_path)

	var image = Image.load_from_file(image_path)
	var texture = ImageTexture.create_from_image(image)

	var card = MemoryCardResource.new()
	card.name = final_card_name
	card.description = description
	card.texture = texture

	return card
