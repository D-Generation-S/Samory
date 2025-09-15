@tool
class_name ResourceParser extends EditorTranslationParserPlugin

func _parse_file(path: String) -> Array[PackedStringArray]:
	var return_data: Array[PackedStringArray] = []
	var res: Resource = load(path)
	for data in _handle_card(res):
		return_data.append(data)
	for data in _handle_decks(res):
		return_data.append(data)
	for data in _handle_tutorials(res):
		return_data.append(data)
	for data in _handle_ai(res):
		return_data.append(data)
	for data in _handle_translations(res):
		return_data.append(data)
		
		
	return return_data

func _handle_card(resource: Resource) -> Array[PackedStringArray]:
	var card_data: PackedStringArray = []
	if resource is MemoryCardResource:
		return [PackedStringArray([resource.name]),
				PackedStringArray([resource.description])]
	return []

func _handle_decks(resource: Resource) -> Array[PackedStringArray]:
	var deck_data: PackedStringArray = []
	if resource is MemoryDeckResource:
		return [PackedStringArray([resource.name]),
				PackedStringArray([resource.description])]
	return []

func _handle_tutorials(resource: Resource) -> Array[PackedStringArray]:
	var tutorial_data: PackedStringArray = []
	if resource is TutorialInformation:
		return [PackedStringArray([resource.title]),
				PackedStringArray([resource.body])]
	return []

func _handle_ai(resource: Resource) -> Array[PackedStringArray]:
	var tutorial_data: PackedStringArray = []
	if resource is AiDifficultyResource:
		return [PackedStringArray([resource.name])]
	return []

func _handle_translations(resource: Resource) -> Array[PackedStringArray]:
	var tutorial_data: PackedStringArray = []
	if resource is TextTranslation:
		return [PackedStringArray([resource.key, resource.context, resource.plural, resource.comment])]
	return []


func _get_recognized_extensions():
	return ["tres"]