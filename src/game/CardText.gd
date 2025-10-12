extends RichTextLabel

@export var max_tooltip_length: int = 75
@export var max_text_length: int = 24

var card_tooltip_text: String = ""
var raw_card_text: String = ""

func set_card_text(card_text: String) -> void:
	if card_text.length() > max_text_length:
		card_text = card_text.substr(0, max_text_length)
	raw_card_text = card_text
	text = "[center]" + raw_card_text +"[/center]"

func set_tooltip(new_tooltip_text: String) -> void:
	_convert_and_set_tooltip(new_tooltip_text)

func _convert_and_set_tooltip(new_tooltip_text: String) -> void:
	if new_tooltip_text == "":
		tooltip_text = ""
		return
	var words: PackedStringArray = new_tooltip_text.split(" ")
	var lines: Array[String] = []
	var current_line: String = ""

	for word: String in words:
		if current_line.length() + word.length() + 1 <= max_tooltip_length:
			
			if current_line == "":
				current_line = word
			else:
				current_line += " " + word
		else:
			lines.append(current_line)
			current_line = word
	
	if current_line != "":
		lines.append(current_line)

	card_tooltip_text = raw_card_text + "\n\n" 
	card_tooltip_text += "\n".join(lines)

func card_revealed() -> void:
	card_state_changed(true)

func card_hidden() -> void:
	card_state_changed(false)

func card_state_changed(state: bool) -> void:
	tooltip_text = ""
	if state:
		tooltip_text = card_tooltip_text
