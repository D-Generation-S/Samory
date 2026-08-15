@tool
class_name TranslationResourceParser extends TranslationPlugin

func parse(path: String) -> Array[PackedStringArray]:
	var return_data: Array[PackedStringArray] = []
	var resource: Resource = load(path)
	return_data.append_array(_handle_text_translation(resource))
	return_data.append_array(_handle_card_translation(resource))
	return_data.append_array(_handle_decks_translation(resource))
	return_data.append_array(_handle_tutorials_translation(resource))
	return_data.append_array(_handle_ai_translation(resource))
	return return_data

func _handle_text_translation(resource: Resource) -> Array[PackedStringArray]:
	if not resource is TextTranslation:
		return []
	var translation: TextTranslation = resource as TextTranslation
	return [PackedStringArray([resource.key, resource.context, resource.plural, resource.comment])]

func _handle_card_translation(resource: Resource) -> Array[PackedStringArray]:
	var card_data: PackedStringArray = []
	if resource is MemoryCardResource:
		return [PackedStringArray([resource.name]),
				PackedStringArray([resource.description])]
	return []

func _handle_decks_translation(resource: Resource) -> Array[PackedStringArray]:
	var deck_data: PackedStringArray = []
	if resource is MemoryDeckResource:
		return [PackedStringArray([resource.name]),
				PackedStringArray([resource.description])]
	return []

func _handle_tutorials_translation(resource: Resource) -> Array[PackedStringArray]:
	var tutorial_data: PackedStringArray = []
	if resource is TutorialInformation:
		return [PackedStringArray([resource.title]),
				PackedStringArray([resource.body])]
	return []

func _handle_ai_translation(resource: Resource) -> Array[PackedStringArray]:
	var tutorial_data: PackedStringArray = []
	if resource is AiDifficultyResource:
		return [PackedStringArray([resource.name])]
	return []

func get_extension() -> PackedStringArray:
	return["tres"]

func register_or_change_translations(strings: Array[PackedStringArray]):
	for file: String in _get_all_resources():
		if file.get_extension() in get_extension():
			print("Add for translation: \"%s\"" % file)
			var generated_data: Array[PackedStringArray] = parse(file)
			for data_set: PackedStringArray in generated_data:
				var diff: int = 4 - data_set.size()
				if diff > 1:
					for i in diff:
						data_set.append("")
				if data_set.size() < 5:
					data_set.append(file)
			strings.append_array(generated_data)
	
	return strings